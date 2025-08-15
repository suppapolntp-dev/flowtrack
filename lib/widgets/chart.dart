import 'package:flutter/material.dart';
import 'package:flowtrack/data/models/transaction.dart';
import 'package:flowtrack/data/utlity.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Chart extends StatefulWidget {
  int indexx;
  Chart({super.key, required this.indexx});

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  List<Transaction>? a;
  bool b = true;
  bool j = true;

  @override
  Widget build(BuildContext context) {
    // กำหนดข้อมูลตาม index
    switch (widget.indexx) {
      case 0:
        a = today();
        b = true;  // show by hour
        j = true;  // show time details
        break;
      case 1:
        a = week();
        b = false; // show by day
        j = true;  // show time details
        break;
      case 2:
        a = month();
        b = false; // show by day
        j = true;  // show time details
        break;
      case 3:
        a = year();
        j = false; // show by month
        break;
      default:
    }

    // เช็คว่ามีข้อมูลหรือไม่
    if (a == null || a!.isEmpty) {
      return SizedBox(
        width: double.infinity,
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.show_chart, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No data to display',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Add some transactions to see the chart',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // สร้างข้อมูลสำหรับ chart
    List<SalesData> chartData = _createChartData();

    return SizedBox(
      width: double.infinity,
      height: 300,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(
          labelStyle: TextStyle(fontSize: 12),
        ),
        primaryYAxis: NumericAxis(
          labelFormat: '\${value}',
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <SplineSeries<SalesData, String>>[
          SplineSeries<SalesData, String>(
            color: Color.fromARGB(255, 255, 200, 112),
            width: 3,
            dataSource: chartData,
            xValueMapper: (SalesData sales, _) => sales.period,
            yValueMapper: (SalesData sales, _) => sales.amount,
            markerSettings: MarkerSettings(
              isVisible: true,
              color: Color.fromARGB(255, 255, 200, 112),
              borderColor: Colors.white,
              borderWidth: 2,
            ),
          ),
        ],
      ),
    );
  }

  List<SalesData> _createChartData() {
    List<SalesData> chartData = [];
    
    if (a == null || a!.isEmpty) return chartData;

    // จัดกลุ่มข้อมูลตามช่วงเวลา
    Map<String, double> groupedData = {};

    for (var transaction in a!) {
      String period = _getPeriodLabel(transaction);
      double amount = transaction.isIncome ? transaction.amount : -transaction.amount;
      
      groupedData[period] = (groupedData[period] ?? 0) + amount;
    }

    // แปลงเป็น List และเรียงตามลำดับ
    var sortedEntries = groupedData.entries.toList();
    
    // เรียงลำดับตาม period
    if (widget.indexx == 0) {
      // เรียงตามชั่วโมง
      sortedEntries.sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));
    } else if (widget.indexx == 1) {
      // เรียงตามวันในสัปดาห์
      final dayOrder = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      sortedEntries.sort((a, b) => dayOrder.indexOf(a.key).compareTo(dayOrder.indexOf(b.key)));
    } else if (widget.indexx == 2) {
      // เรียงตามวันในเดือน
      sortedEntries.sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));
    } else {
      // เรียงตามเดือนในปี
      final monthOrder = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                         'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      sortedEntries.sort((a, b) => monthOrder.indexOf(a.key).compareTo(monthOrder.indexOf(b.key)));
    }

    // สร้าง cumulative data
    double cumulativeAmount = 0;
    for (var entry in sortedEntries) {
      cumulativeAmount += entry.value;
      chartData.add(SalesData(entry.key, cumulativeAmount));
    }

    return chartData;
  }

  String _getPeriodLabel(Transaction transaction) {
    switch (widget.indexx) {
      case 0: // Day - show by hour
        return transaction.datetime.hour.toString();
      case 1: // Week - show by day name
        const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return dayNames[transaction.datetime.weekday - 1];
      case 2: // Month - show by day
        return transaction.datetime.day.toString();
      case 3: // Year - show by month
        const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                           'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return monthNames[transaction.datetime.month - 1];
      default:
        return '';
    }
  }
}

class SalesData {
  SalesData(this.period, this.amount);
  final String period;
  final double amount;
}