// lib/services/backup_service.dart - สำรอง/กู้คืนข้อมูล
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flowtrack/data/services/database_services.dart';

class BackupService {
  // สำรองข้อมูล
  static Future<void> createBackup() async {
    try {
      // ดึงข้อมูลทั้งหมด
      final categories = DatabaseService.categoryBox.values.toList();
      final transactions = DatabaseService.transactionBox.values.toList();

      // สร้าง JSON
      Map<String, dynamic> backupData = {
        'app_version': '1.0.0',
        'backup_date': DateTime.now().toIso8601String(),
        'categories': categories
            .map((c) => {
                  'id': c.id,
                  'name': c.name,
                  'iconName': c.iconName,
                  'colorHex': c.colorHex,
                  'type': c.type,
                  'isActive': c.isActive,
                })
            .toList(),
        'transactions': transactions
            .map((t) => {
                  'id': t.id,
                  'categoryId': t.categoryId,
                  'amount': t.amount,
                  'datetime': t.datetime.toIso8601String(),
                  'description': t.description,
                  'type': t.type,
                })
            .toList(),
      };

      // บันทึกเป็นไฟล์
      String jsonString = jsonEncode(backupData);
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
          '${directory.path}/flowtrack_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonString);

      // แชร์ไฟล์
      await Share.shareXFiles([XFile(file.path)], text: 'FlowTrack Backup');
    } catch (e) {
      throw Exception('Backup failed: $e');
    }
  }

  // กู้คืนข้อมูล
  static Future<void> restoreBackup() async {
    try {
      // เลือกไฟล์
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String jsonString = await file.readAsString();

        // แปลง JSON
        Map<String, dynamic> backupData = jsonDecode(jsonString);

        // ล้างข้อมูลเดิม (ระวัง!)
        await DatabaseService.categoryBox.clear();
        await DatabaseService.transactionBox.clear();

        // กู้คืนหมวดหมู่
        for (var categoryData in backupData['categories']) {
          // สร้าง Category object และบันทึก
        }

        // กู้คืน transactions
        for (var transactionData in backupData['transactions']) {
          // สร้าง Transaction object และบันทึก
        }
      }
    } catch (e) {
      throw Exception('Restore failed: $e');
    }
  }
}

// lib/screens/backup_screen.dart - หน้าสำรอง/กู้คืน
class BackupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Backup & Restore')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // สำรองข้อมูล
            Card(
              child: ListTile(
                leading: Icon(Icons.backup, color: Colors.blue),
                title: Text('Create Backup'),
                subtitle: Text('Save all your data'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  try {
                    await BackupService.createBackup();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Backup created successfully!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Backup failed: $e')),
                    );
                  }
                },
              ),
            ),

            // กู้คืนข้อมูล
            Card(
              child: ListTile(
                leading: Icon(Icons.restore, color: Colors.orange),
                title: Text('Restore Backup'),
                subtitle: Text('⚠️ This will replace all current data'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  // แสดงคำเตือน
                  bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('⚠️ Warning'),
                      content: Text(
                          'This will delete all current data and replace with backup data. Continue?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Cancel')),
                        TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('Continue')),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    try {
                      await BackupService.restoreBackup();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Restore completed!')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Restore failed: $e')),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
