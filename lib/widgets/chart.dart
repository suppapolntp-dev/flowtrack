// lib/widgets/chart.dart - Updated with Theme Support
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flowtrack/screens/theme_settings.dart';
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
    final themeProvider = Provider.of<ThemeProvider>(context);

    // กำหนดข้อมูลตาม index
    switch (widget.indexx) {
      case 0:
        a = today();
        b = true; // show by hour
        j = true; // show time details
        break;
      case 1:
        a = week();
        b = false; // show by day
        j = true; // show time details
        break;
      case 2:
        a = month();
        b = false; // show by day
        j = true; // show time details
        break;
      case 3:
        a = year();
        j = false; // show by month
        break;
      default:
    }

    // เช็คว่ามีข้อมูลหรือไม่
    if (a == null || a!.isEmpty) {
      return Container(
        width: double.infinity,
        height: 300,
        margin: EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: themeProvider.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: themeProvider.isDarkMode
                  ? Colors.black26
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.show_chart,
                  size: 64, color: themeProvider.subtitleColor),
              SizedBox(height: 16),
              Text(
                'No data to display',
                style: TextStyle(
                  fontSize: 18,
                  color: themeProvider.subtitleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Add some transactions to see the chart',
                style: TextStyle(
                  fontSize: 14,
                  color: themeProvider.subtitleColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // สร้างข้อมูลสำหรับ chart
    List<SalesData> chartData = _createChartData();

    return Container(
      width: double.infinity,
      height: 300,
      margin: EdgeInsets.symmetric(horizontal: 15),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: themeProvider.isDarkMode
                ? Colors.black26
                : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        primaryXAxis: CategoryAxis(
          labelStyle: TextStyle(
            fontSize: 12,
            color: themeProvider.textColor,
          ),
          majorGridLines: MajorGridLines(
            width: 0.5,
            color: themeProvider.dividerColor.withOpacity(0.3),
          ),
          axisLine: AxisLine(
            color: themeProvider.dividerColor,
            width: 1,
          ),
          majorTickLines: MajorTickLines(
            color: themeProvider.dividerColor,
            width: 1,
          ),
        ),
        primaryYAxis: NumericAxis(
          labelFormat: '\${value}',
          labelStyle: TextStyle(
            fontSize: 12,
            color: themeProvider.textColor,
          ),
          majorGridLines: MajorGridLines(
            width: 0.5,
            color: themeProvider.dividerColor.withOpacity(0.3),
            dashArray: <double>[5, 5],
          ),
          axisLine: AxisLine(
            width: 0,
          ),
          majorTickLines: MajorTickLines(
            width: 0,
          ),
        ),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          color: themeProvider.isDarkMode
              ? Colors.grey.shade800
              : Colors.grey.shade700,
          textStyle: TextStyle(color: Colors.white),
          borderWidth: 0,
          animationDuration: 200,
        ),
        series: <SplineSeries<SalesData, String>>[
          SplineSeries<SalesData, String>(
            color: themeProvider.primaryColor,
            width: 3,
            dataSource: chartData,
            xValueMapper: (SalesData sales, _) => sales.period,
            yValueMapper: (SalesData sales, _) => sales.amount,
            markerSettings: MarkerSettings(
              isVisible: true,
              height: 8,
              width: 8,
              color: themeProvider.primaryColor,
              borderColor: themeProvider.cardColor,
              borderWidth: 2,
            ),
            dataLabelSettings: DataLabelSettings(
              isVisible: false,
            ),
            splineType: SplineType.cardinal,
            cardinalSplineTension: 0.9,
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
      double amount =
          transaction.isIncome ? transaction.amount : -transaction.amount;

      groupedData[period] = (groupedData[period] ?? 0) + amount;
    }

    // แปลงเป็น List และเรียงตามลำดับ
    var sortedEntries = groupedData.entries.toList();

    // เรียงลำดับตาม period
    if (widget.indexx == 0) {
      // เรียงตามชั่วโมง
      sortedEntries
          .sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));
    } else if (widget.indexx == 1) {
      // เรียงตามวันในสัปดาห์
      final dayOrder = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      sortedEntries.sort(
          (a, b) => dayOrder.indexOf(a.key).compareTo(dayOrder.indexOf(b.key)));
    } else if (widget.indexx == 2) {
      // เรียงตามวันในเดือน
      sortedEntries
          .sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));
    } else {
      // เรียงตามเดือนในปี
      final monthOrder = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      sortedEntries.sort((a, b) =>
          monthOrder.indexOf(a.key).compareTo(monthOrder.indexOf(b.key)));
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
        return '${transaction.datetime.hour}:00';
      case 1: // Week - show by day name
        const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return dayNames[transaction.datetime.weekday - 1];
      case 2: // Month - show by day
        return transaction.datetime.day.toString();
      case 3: // Year - show by month
        const monthNames = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];
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
