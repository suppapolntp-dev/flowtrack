// lib/data/utlity.dart
import 'package:flowtrack/data/services/database_services.dart';
import 'package:flowtrack/data/models/transaction.dart';

// ใช้ DatabaseService แทน Hive box โดยตรง
double total() {
  try {
    return DatabaseService.getTotalBalance();
  } catch (e) {
    print('Error getting total balance: $e');
    return 0.0;
  }
}

double income() {
  try {
    return DatabaseService.getTotalIncome();
  } catch (e) {
    print('Error getting total income: $e');
    return 0.0;
  }
}

double expenses() {
  try {
    return DatabaseService.getTotalExpense();
  } catch (e) {
    print('Error getting total expense: $e');
    return 0.0;
  }
}

List<Transaction> today() {
  try {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return DatabaseService.getTransactions(
      startDate: startOfDay,
      endDate: endOfDay,
    );
  } catch (e) {
    print('Error getting today transactions: $e');
    return [];
  }
}

List<Transaction> week() {
  try {
    DateTime now = DateTime.now();
    DateTime weekAgo = now.subtract(Duration(days: 7));
    
    return DatabaseService.getTransactions(
      startDate: weekAgo,
      endDate: now,
    );
  } catch (e) {
    print('Error getting week transactions: $e');
    return [];
  }
}

List<Transaction> month() {
  try {
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    
    return DatabaseService.getTransactions(
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
  } catch (e) {
    print('Error getting month transactions: $e');
    return [];
  }
}

List<Transaction> year() {
  try {
    DateTime now = DateTime.now();
    DateTime startOfYear = DateTime(now.year, 1, 1);
    DateTime endOfYear = DateTime(now.year, 12, 31, 23, 59, 59);
    
    return DatabaseService.getTransactions(
      startDate: startOfYear,
      endDate: endOfYear,
    );
  } catch (e) {
    print('Error getting year transactions: $e');
    return [];
  }
}

double total_chart(List<Transaction> transactions) {
  try {
    double total = 0;
    for (var transaction in transactions) {
      if (transaction.isIncome) {
        total += transaction.amount;
      } else {
        total -= transaction.amount;
      }
    }
    return total;
  } catch (e) {
    print('Error calculating chart total: $e');
    return 0.0;
  }
}

List<double> time(List<Transaction> transactions, bool hour) {
  try {
    if (transactions.isEmpty) return [0.0];
    
    Map<String, double> grouped = {};
    
    for (var transaction in transactions) {
      String key;
      if (hour) {
        // กลุ่มตามชั่วโมง
        key = transaction.datetime.hour.toString();
      } else {
        // กลุ่มตามวัน
        key = transaction.datetime.day.toString();
      }
      
      double amount = transaction.isIncome ? transaction.amount : -transaction.amount;
      grouped[key] = (grouped[key] ?? 0) + amount;
    }
    
    // แปลงเป็น List และเรียงตามลำดับ
    var sortedEntries = grouped.entries.toList()
      ..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));
    
    return sortedEntries.map((e) => e.value).toList();
  } catch (e) {
    print('Error processing time data: $e');
    return [0.0];
  }
}