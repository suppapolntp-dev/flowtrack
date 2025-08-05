import 'package:flutter/material.dart';
import 'package:flowtrack/data/models/add_date.dart';
import 'package:flowtrack/data/utlity.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Chart extends StatefulWidget {
  int indexx;
  Chart({super.key, required this.indexx});

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  List<Add_data>? a;
  bool b = true;
  bool j = true;

  @override
  Widget build(BuildContext context) {
    switch (widget.indexx) {
      case 0:
        a = today();
        b = true;
        j = true;
        break;
      case 1:
        a = week();
        b = false;
        j = true;
        break;
      case 2:
        a = month();
        b = false;
        j = true;
        break;
      case 3:
        a = year();
        j = false;
        break;
      default:
    }

    // เช็คว่ามีข้อมูลหรือไม่
    if (a == null || a!.isEmpty) {
      return SizedBox(
        width: double.infinity,
        height: 300,
        child: Center(
          child: Text('ไม่มีข้อมูลสำหรับแสดงผล'),
        ),
      );
    }

    // ดึงข้อมูลจาก time function
    var timeData = time(a!, b ? true : false);

    // เช็คว่า timeData ไม่ว่าง
    if (timeData.isEmpty) {
      return SizedBox(
        width: double.infinity,
        height: 300,
        child: Center(
          child: Text('ไม่มีข้อมูลสำหรับแสดงผล'),
        ),
      );
    }

    // ใช้ขนาดของ a! เป็นหลัก เพื่อป้องกัน RangeError
    int maxLength = a!.length;

    // สร้างข้อมูลสำหรับ chart
    List<SalesData> chartData = [];
    int cumulativeSum = 0;

    for (int index = 0; index < maxLength; index++) {
      // ตรวจสอบว่า index ไม่เกินขอบเขตของ timeData
      int currentValue = index < timeData.length ? timeData[index] : 0;

      // คำนวณ cumulative sum
      if (b) {
        // สำหรับ case วัน (รายชั่วโมง)
        cumulativeSum = index > 0 ? cumulativeSum + currentValue : currentValue;
      } else {
        // สำหรับ case สัปดาห์/เดือน/ปี
        cumulativeSum = index > 0 ? cumulativeSum + currentValue : currentValue;
      }

      // สร้าง x-axis label
      String xLabel;
      if (j) {
        if (b) {
          // แสดงชั่วโมง
          xLabel = a![index].datetime.hour.toString();
        } else {
          // แสดงวันที่ หรือวันในสัปดาห์สำหรับ week
          if (widget.indexx == 1) {
            // Week case
            List<String> dayNames = [
              'จันทร์',
              'อังคาร',
              'พุธ',
              'พฤหัสบดี',
              'ศุกร์',
              'เสาร์',
              'อาทิตย์'
            ];
            int weekday = a![index].datetime.weekday;
            xLabel = dayNames[weekday - 1];
          } else {
            xLabel = a![index].datetime.day.toString();
          }
        }
      } else {
        // แสดงเดือนสำหรับ year case
        List<String> monthNames = [
          'ม.ค.',
          'ก.พ.',
          'มี.ค.',
          'เม.ย.',
          'พ.ค.',
          'มิ.ย.',
          'ก.ค.',
          'ส.ค.',
          'ก.ย.',
          'ต.ค.',
          'พ.ย.',
          'ธ.ค.'
        ];
        xLabel = monthNames[a![index].datetime.month - 1];
      }

      chartData.add(SalesData(xLabel, cumulativeSum));
    }

    return SizedBox(
      width: double.infinity,
      height: 300,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        series: <SplineSeries<SalesData, String>>[
          SplineSeries<SalesData, String>(
            color: Color.fromARGB(255, 255, 200, 112),
            width: 3,
            dataSource: chartData,
            xValueMapper: (SalesData sales, _) => sales.year,
            yValueMapper: (SalesData sales, _) => sales.sales,
          ),
        ],
      ),
    );
  }
}

class SalesData {
  SalesData(this.year, this.sales);
  final String year;
  final int sales;
}
