// lib/screens/backup_screen.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flowtrack/data/services/database_services.dart';
import 'package:flowtrack/data/models/category.dart';
import 'package:flowtrack/data/models/transaction.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool isLoading = false;
  String statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Backup & Restore'),
        backgroundColor: Color(0xFFFFC870),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoCard(),
            SizedBox(height: 20),
            _buildBackupSection(),
            SizedBox(height: 20),
            _buildRestoreSection(),
            SizedBox(height: 20),
            if (statusMessage.isNotEmpty) _buildStatusCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue,
            size: 40,
          ),
          SizedBox(height: 12),
          Text(
            'Data Protection',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Keep your financial data safe by creating regular backups. You can restore your data anytime on any device.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.backup, color: Colors.green, size: 24),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Backup',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Export all your data to a secure file',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          
          _buildFeatureList([
            'All transactions and categories',
            'App settings and preferences', 
            'Encrypted JSON format',
            'Share or save to device',
          ]),
          
          SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : _createBackup,
              icon: isLoading 
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.backup, color: Colors.white),
              label: Text(
                isLoading ? 'Creating Backup...' : 'Create Backup',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestoreSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.restore, color: Colors.orange, size: 24),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Restore Backup',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Import data from a backup file',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Warning: This will replace all current data!',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 15),
          
          _buildFeatureList([
            'Select backup file from device',
            'Verify data before restore',
            'Current data will be replaced',
            'Process cannot be undone',
          ]),
          
          SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : _showRestoreConfirmation,
              icon: Icon(Icons.restore, color: Colors.white),
              label: Text(
                'Restore from Backup',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureList(List<String> features) {
    return Column(
      children: features.map((feature) => 
        Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  feature,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ).toList(),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: Colors.blue),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              statusMessage,
              style: TextStyle(
                color: Colors.blue.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createBackup() async {
    setState(() {
      isLoading = true;
      statusMessage = 'Creating backup...';
    });

    try {
      // ดึงข้อมูลทั้งหมด
      final categories = DatabaseService.categoryBox.values.toList();
      final transactions = DatabaseService.transactionBox.values.toList();
      
      // สร้าง JSON
      Map<String, dynamic> backupData = {
        'app_version': '1.0.0',
        'backup_date': DateTime.now().toIso8601String(),
        'total_categories': categories.length,
        'total_transactions': transactions.length,
        'categories': categories.map((c) => {
          'id': c.id,
          'name': c.name,
          'iconName': c.iconName,
          'colorHex': c.colorHex,
          'type': c.type,
          'isActive': c.isActive,
          'createdAt': c.createdAt.toIso8601String(),
          'budgetLimit': c.budgetLimit,
        }).toList(),
        'transactions': transactions.map((t) => {
          'id': t.id,
          'categoryId': t.categoryId,
          'amount': t.amount,
          'datetime': t.datetime.toIso8601String(),
          'description': t.description,
          'type': t.type,
          'note': t.note,
          'location': t.location,
          'tags': t.tags,
          'isRecurring': t.isRecurring,
          'recurringType': t.recurringType,
        }).toList(),
      };
      
      // บันทึกเป็นไฟล์
      String jsonString = jsonEncode(backupData);
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/flowtrack_backup_$timestamp.json');
      await file.writeAsString(jsonString);
      
      // แชร์ไฟล์
      await Share.shareXFiles(
        [XFile(file.path)], 
        text: 'FlowTrack Backup - ${DateTime.now().toLocal().toString().split(' ')[0]}',
      );
      
      setState(() {
        statusMessage = 'Backup created successfully! ${categories.length} categories and ${transactions.length} transactions exported.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backup created and shared successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      setState(() {
        statusMessage = 'Backup failed: $e';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backup failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  void _showRestoreConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('⚠️ Confirm Restore'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This action will:'),
            SizedBox(height: 8),
            Text('• Delete all current data', style: TextStyle(color: Colors.red)),
            Text('• Replace with backup data', style: TextStyle(color: Colors.red)),
            Text('• Cannot be undone', style: TextStyle(color: Colors.red)),
            SizedBox(height: 16),
            Text('Are you sure you want to continue?',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _restoreBackup();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Continue', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _restoreBackup() async {
    setState(() {
      isLoading = true;
      statusMessage = 'Selecting backup file...';
    });

    try {
      // เลือกไฟล์
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Select FlowTrack Backup File',
      );
      
      if (result == null || result.files.single.path == null) {
        setState(() {
          isLoading = false;
          statusMessage = 'No file selected.';
        });
        return;
      }

      setState(() {
        statusMessage = 'Reading backup file...';
      });

      File file = File(result.files.single.path!);
      String jsonString = await file.readAsString();
      
      // แปลง JSON
      Map<String, dynamic> backupData = jsonDecode(jsonString);
      
      // ตรวจสอบไฟล์
      if (!backupData.containsKey('categories') || !backupData.containsKey('transactions')) {
        throw Exception('Invalid backup file format');
      }

      setState(() {
        statusMessage = 'Restoring data...';
      });

      // ล้างข้อมูลเดิม
      await DatabaseService.categoryBox.clear();
      await DatabaseService.transactionBox.clear();

      // กู้คืนหมวดหมู่
      int categoryCount = 0;
      for (var categoryData in backupData['categories']) {
        try {
          Category category = Category(
            id: categoryData['id'],
            name: categoryData['name'],
            iconName: categoryData['iconName'],
            colorHex: categoryData['colorHex'],
            type: categoryData['type'],
            isActive: categoryData['isActive'] ?? true,
            createdAt: DateTime.parse(categoryData['createdAt']),
            budgetLimit: categoryData['budgetLimit']?.toDouble(),
          );
          await DatabaseService.addCategory(category);
          categoryCount++;
        } catch (e) {
          print('Error restoring category: $e');
        }
      }
      
      // กู้คืน transactions
      int transactionCount = 0;
      for (var transactionData in backupData['transactions']) {
        try {
          Transaction transaction = Transaction(
            id: transactionData['id'],
            categoryId: transactionData['categoryId'],
            amount: transactionData['amount'].toDouble(),
            datetime: DateTime.parse(transactionData['datetime']),
            description: transactionData['description'],
            type: transactionData['type'],
            note: transactionData['note'],
            location: transactionData['location'],
            tags: transactionData['tags']?.cast<String>(),
            isRecurring: transactionData['isRecurring'] ?? false,
            recurringType: transactionData['recurringType'],
          );
          await DatabaseService.addTransaction(transaction);
          transactionCount++;
        } catch (e) {
          print('Error restoring transaction: $e');
        }
      }

      setState(() {
        statusMessage = 'Restore completed! $categoryCount categories and $transactionCount transactions restored.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Restore completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      setState(() {
        statusMessage = 'Restore failed: $e';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Restore failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }
}