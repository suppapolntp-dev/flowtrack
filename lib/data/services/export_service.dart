// lib/services/export_service.dart - ส่งออกข้อมูล
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flowtrack/data/services/database_services.dart';

class ExportService {
  // ส่งออกเป็น CSV
  static Future<void> exportToCSV() async {
    try {
      // ดึงข้อมูล transactions
      final transactions = DatabaseService.getTransactions();

      // สร้างหัวตาราง
      List<List<dynamic>> csvData = [
        ['Date', 'Category', 'Description', 'Amount', 'Type']
      ];

      // เพิ่มข้อมูล
      for (var transaction in transactions) {
        final category =
            DatabaseService.getCategoryById(transaction.categoryId);
        csvData.add([
          '${transaction.datetime.year}-${transaction.datetime.month.toString().padLeft(2, '0')}-${transaction.datetime.day.toString().padLeft(2, '0')}',
          category?.name ?? 'Unknown',
          transaction.description,
          transaction.amount.toStringAsFixed(2),
          transaction.type,
        ]);
      }

      // แปลงเป็น CSV string
      String csvString = const ListToCsvConverter().convert(csvData);

      // สร้างไฟล์
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/transactions_export.csv');
      await file.writeAsString(csvString);

      // แชร์ไฟล์
      await Share.shareXFiles([XFile(file.path)], text: 'Transaction Export');
    } catch (e) {
      print('Export error: $e');
    }
  }
}

// lib/screens/export_screen.dart - หน้าส่งออกข้อมูล
class ExportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Export Data')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Export your transaction data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            SizedBox(height: 20),

            // CSV Export
            Card(
              child: ListTile(
                leading: Icon(Icons.table_chart),
                title: Text('Export as CSV'),
                subtitle: Text('For Excel, Google Sheets'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  // แสดง loading
                  showDialog(
                    context: context,
                    builder: (context) =>
                        Center(child: CircularProgressIndicator()),
                  );

                  await ExportService.exportToCSV();

                  Navigator.pop(context); // ปิด loading

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('CSV exported successfully!')),
                  );
                },
              ),
            ),

            // PDF Export (ยังไม่ทำ)
            Card(
              child: ListTile(
                leading: Icon(Icons.picture_as_pdf, color: Colors.grey),
                title:
                    Text('Export as PDF', style: TextStyle(color: Colors.grey)),
                subtitle: Text('Coming soon...'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
