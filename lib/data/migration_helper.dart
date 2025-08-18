import 'package:hive/hive.dart';
import 'models/transaction.dart';
import 'models/add_date.dart';

class MigrationHelper {
  static Future<void> migrateOldData() async {
    try {
      print('Starting migration process...');
      
      // ลองเปิด box เก่า
      Box<Add_data>? oldBox;
      try {
        oldBox = await Hive.openBox<Add_data>('data');
        print('Old data box opened successfully');
      } catch (e) {
        print('No old data found or error opening old box: $e');
        return; // ไม่มีข้อมูลเก่า หรือเกิดข้อผิดพลาด ให้ skip
      }
      
      // เปิด box ใหม่
      final newBox = await Hive.openBox<Transaction>('transactions');
      print('New transactions box opened');
      
      // ตรวจสอบว่า box เก่ามีข้อมูล และ box ใหม่ยังว่าง
      if (oldBox.isNotEmpty && newBox.isEmpty) {
        print('Found ${oldBox.length} old records to migrate');
        
        int successCount = 0;
        int errorCount = 0;
        
        for (var i = 0; i < oldBox.length; i++) {
          try {
            var oldData = oldBox.getAt(i);
            if (oldData == null) continue;
            
            // แปลง amount จาก String เป็น double
            double amount = 0.0;
            try {
              // ลบเครื่องหมาย $ และ , ออกก่อน
              String cleanAmount = oldData.amount
                  .replaceAll('\฿', '')
                  .replaceAll(',', '')
                  .replaceAll(' ', '')
                  .trim();
              
              amount = double.parse(cleanAmount);
            } catch (e) {
              print('Error parsing amount "${oldData.amount}": $e');
              amount = 0.0; // ใช้ค่า default
            }
            
            final newTransaction = Transaction(
              id: '${DateTime.now().millisecondsSinceEpoch}_$i',
              categoryId: _mapOldToNewCategory(oldData.name),
              amount: amount,
              datetime: oldData.datetime,
              description: oldData.explain,
              type: oldData.IN,
            );
            
            await newBox.add(newTransaction);
            successCount++;
            
          } catch (e) {
            print('Error migrating record $i: $e');
            errorCount++;
          }
        }
        
        print('Migration completed: $successCount success, $errorCount errors');
      } else {
        print('No migration needed (old box empty or new box has data)');
      }
      
    } catch (e) {
      print('Migration process error: $e');
      // ไม่ throw error เพื่อให้แอปยังรันได้
    }
  }
  
  static String _mapOldToNewCategory(String oldName) {
    switch (oldName.toLowerCase()) {
      case 'food': return 'food';
      case 'coffee': return 'coffee';
      case 'grocery': return 'grocery';
      case 'food-delivery': return 'food_delivery';
      case 'gas-pump': return 'gas_pump';
      case 'public transport': return 'public_transport';
      case 'rent or mortgage': return 'rent';
      case 'water bill': return 'water_bill';
      case 'electricity bill': return 'electricity';
      case 'internet bill': return 'internet';
      case 'clothes': return 'clothes';
      case 'shoes': return 'shoes';
      case 'accessories': return 'accessories';
      case 'personal care items': return 'personal_care';
      case 'movie': return 'movie';
      case 'concert': return 'concert';
      case 'hobby': return 'hobby';
      case 'travel': return 'travel';
      case 'health-report': return 'health';
      case 'doctor visitshospital': return 'doctor';
      case 'education': return 'education';
      case 'bank fees': return 'bank_fees';
      case 'giftbox': return 'gift';
      case 'donation': return 'donation';
      default: return 'other_expense';
    }
  }
}