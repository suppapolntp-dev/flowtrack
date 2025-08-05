import 'package:hive/hive.dart';
import 'category.dart';

part 'transaction.g.dart';

@HiveType(typeId: 1)
class Transaction extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String categoryId; // เชื่อมกับ Category

  @HiveField(2)
  late double amount;

  @HiveField(3)
  late DateTime datetime;

  @HiveField(4)
  late String description;

  @HiveField(5)
  late String type; // 'Income' หรือ 'Expense'

  @HiveField(6)
  String? note; // บันทึกเพิ่มเติม

  @HiveField(7)
  String? location; // สถานที่ (optional)

  @HiveField(8)
  List<String>? tags; // แท็กสำหรับค้นหา

  @HiveField(9)
  bool isRecurring; // รายการประจำ

  @HiveField(10)
  String? recurringType; // daily, weekly, monthly, yearly

  Transaction({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.datetime,
    required this.description,
    required this.type,
    this.note,
    this.location,
    this.tags,
    this.isRecurring = false,
    this.recurringType,
  });

  // Helper methods
  bool get isIncome => type == 'Income';
  bool get isExpense => type == 'Expense';
  
  // Format amount เป็น string
  String get formattedAmount {
    String prefix = isIncome ? '+' : '-';
    return '$prefix\$${amount.toStringAsFixed(2)}';
  }

  // ดึงข้อมูล Category
  Category? getCategory(Box<Category> categoryBox) {
    try {
      return categoryBox.values.firstWhere(
        (cat) => cat.id == categoryId,
      );
    } catch (e) {
      return Category(
        id: 'unknown',
        name: 'Unknown',
        iconName: 'help',
        colorHex: '#999999',
        type: type,
      );
    }
  }

  // ค้นหาด้วย tags
  bool matchesTags(List<String> searchTags) {
    if (tags == null || tags!.isEmpty) return false;
    return searchTags.any((tag) => 
      tags!.any((t) => t.toLowerCase().contains(tag.toLowerCase()))
    );
  }
}