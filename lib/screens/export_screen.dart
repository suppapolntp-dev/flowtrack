// lib/screens/export_screen.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flowtrack/data/services/database_services.dart';
import 'dart:convert';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  bool isExporting = false;
  String selectedPeriod = 'All Time';
  final List<String> periods = ['This Month', 'Last Month', 'This Year', 'All Time'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Export Data'),
        backgroundColor: Color(0xFFFFC870),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            SizedBox(height: 30),
            _buildPeriodSelection(),
            SizedBox(height: 30),
            _buildExportOptions(),
            SizedBox(height: 30),
            _buildDataPreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
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
              Icon(Icons.file_download, color: Color(0xFFFFC870), size: 28),
              SizedBox(width: 12),
              Text(
                'Export Your Data',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'Export your transaction data to use in other applications like Excel, Google Sheets, or for backup purposes.',
            style: TextStyle(
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelection() {
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
          Text(
            'Select Time Period',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          ...periods.map((period) => RadioListTile<String>(
            title: Text(period),
            value: period,
            groupValue: selectedPeriod,
            activeColor: Color(0xFFFFC870),
            onChanged: (value) {
              setState(() {
                selectedPeriod = value!;
              });
            },
            contentPadding: EdgeInsets.zero,
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildExportOptions() {
    return Column(
      children: [
        // CSV Export
        _buildExportCard(
          icon: Icons.table_chart,
          title: 'Export as CSV',
          subtitle: 'Compatible with Excel, Google Sheets, Numbers',
          color: Colors.green,
          onTap: () => _exportToCSV(),
        ),
        SizedBox(height: 15),
        
        // PDF Export (Coming soon)
        _buildExportCard(
          icon: Icons.picture_as_pdf,
          title: 'Export as PDF',
          subtitle: 'Professional report format (Coming soon)',
          color: Colors.grey,
          onTap: null,
        ),
        SizedBox(height: 15),
        
        // JSON Export (for backup)
        _buildExportCard(
          icon: Icons.code,
          title: 'Export as JSON',
          subtitle: 'Raw data format for developers',
          color: Colors.blue,
          onTap: () => _exportToJSON(),
        ),
      ],
    );
  }

  Widget _buildExportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;
    
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: isExporting ? null : onTap,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isEnabled ? Colors.black87 : Colors.grey,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isExporting)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (isEnabled)
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey.shade400,
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataPreview() {
    final transactions = _getTransactionsForPeriod();
    
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
          Text(
            'Data Preview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPreviewStat('Transactions', '${transactions.length}', Icons.receipt),
              _buildPreviewStat('Period', selectedPeriod, Icons.date_range),
              _buildPreviewStat('Size', '~${(transactions.length * 0.1).toStringAsFixed(1)} KB', Icons.storage),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Color(0xFFFFC870), size: 24),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  List<dynamic> _getTransactionsForPeriod() {
    final now = DateTime.now();
    DateTime? startDate;
    DateTime? endDate;

    switch (selectedPeriod) {
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0);
        break;
      case 'Last Month':
        startDate = DateTime(now.year, now.month - 1, 1);
        endDate = DateTime(now.year, now.month, 0);
        break;
      case 'This Year':
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year, 12, 31);
        break;
      case 'All Time':
        // No date filter
        break;
    }

    return DatabaseService.getTransactions(
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<void> _exportToCSV() async {
    setState(() {
      isExporting = true;
    });

    try {
      final transactions = _getTransactionsForPeriod();
      
      // Create CSV headers
      List<List<dynamic>> csvData = [
        ['Date', 'Category', 'Description', 'Amount', 'Type']
      ];
      
      // Add transaction data
      for (var transaction in transactions) {
        final category = DatabaseService.getCategoryById(transaction.categoryId);
        csvData.add([
          '${transaction.datetime.year}-${transaction.datetime.month.toString().padLeft(2,'0')}-${transaction.datetime.day.toString().padLeft(2,'0')}',
          category?.name ?? 'Unknown',
          transaction.description,
          transaction.amount.toStringAsFixed(2),
          transaction.type,
        ]);
      }
      
      // Convert to CSV string
      String csvString = const ListToCsvConverter().convert(csvData);
      
      // Create file
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'FlowTrack_Export_${selectedPeriod.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csvString);
      
      // Share file
      await Share.shareXFiles(
        [XFile(file.path)], 
        text: 'FlowTrack Transaction Export - $selectedPeriod'
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CSV exported successfully! ${transactions.length} transactions'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      isExporting = false;
    });
  }

  Future<void> _exportToJSON() async {
    setState(() {
      isExporting = true;
    });

    try {
      final transactions = _getTransactionsForPeriod();
      
      // Create JSON data
      Map<String, dynamic> exportData = {
        'export_info': {
          'app': 'FlowTrack',
          'version': '1.0.0',
          'export_date': DateTime.now().toIso8601String(),
          'period': selectedPeriod,
          'total_transactions': transactions.length,
        },
        'transactions': transactions.map((transaction) {
          final category = DatabaseService.getCategoryById(transaction.categoryId);
          return {
            'id': transaction.id,
            'date': transaction.datetime.toIso8601String(),
            'category': category?.name ?? 'Unknown',
            'category_id': transaction.categoryId,
            'description': transaction.description,
            'amount': transaction.amount,
            'type': transaction.type,
          };
        }).toList(),
      };
      
      // Convert to JSON string
      String jsonString = JsonEncoder.withIndent('  ').convert(exportData);
      
      // Create file
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'FlowTrack_Export_${selectedPeriod.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);
      
      // Share file
      await Share.shareXFiles(
        [XFile(file.path)], 
        text: 'FlowTrack JSON Export - $selectedPeriod'
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('JSON exported successfully! ${transactions.length} transactions'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      isExporting = false;
    });
  }
}