// 1. แก้ไข transaction.dart - เปลี่ยน typeId
import 'package:hive/hive.dart';
import 'category.dart';

part 'transaction.g.dart';

@HiveType(typeId: 3) // เปลี่ยนเป็น 3 เพื่อไม่ให้ชนกับอะไร
class Transaction extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String categoryId;

  @HiveField(2)
  late double amount;

  @HiveField(3)
  late DateTime datetime;

  @HiveField(4)
  late String description;

  @HiveField(5)
  late String type;

  @HiveField(6)
  String? note;

  @HiveField(7)
  String? location;

  @HiveField(8)
  List<String>? tags;

  @HiveField(9)
  bool isRecurring;

  @HiveField(10)
  String? recurringType;

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

  bool get isIncome => type == 'Income';
  bool get isExpense => type == 'Expense';
  
  String get formattedAmount {
    String prefix = isIncome ? '+' : '-';
    return '$prefix\$${amount.toStringAsFixed(2)}';
  }

  Category? getCategory(Box<Category> categoryBox) {
    try {
      return categoryBox.values.firstWhere((cat) => cat.id == categoryId);
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

  bool matchesTags(List<String> searchTags) {
    if (tags == null || tags!.isEmpty) return false;
    return searchTags.any((tag) => 
      tags!.any((t) => t.toLowerCase().contains(tag.toLowerCase()))
    );
  }
}