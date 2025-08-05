import 'package:hive/hive.dart';
import 'models/transaction.dart';
import 'models/add_date.dart'; // โมเดลเก่า

class MigrationHelper {
  static Future<void> migrateOldData() async {
    final oldBox = await Hive.openBox<Add_data>('data');
    final newBox = await Hive.openBox<Transaction>('transactions');
    
    if (oldBox.isNotEmpty && newBox.isEmpty) {
      for (var oldData in oldBox.values) {
        final newTransaction = Transaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          categoryId: _mapOldToNewCategory(oldData.name),
          amount: double.tryParse(oldData.amount) ?? 0.0,
          datetime: oldData.datetime,
          description: oldData.explain,
          type: oldData.IN,
        );
        await newBox.add(newTransaction);
      }
    }
  }
  
  static String _mapOldToNewCategory(String oldName) {
    // แมปชื่อเก่าเป็น categoryId ใหม่
    switch (oldName.toLowerCase()) {
      case 'food': return 'food';
      case 'coffee': return 'coffee';
      // ... เพิ่มการแมปอื่นๆ
      default: return 'other_expense';
    }
  }
}