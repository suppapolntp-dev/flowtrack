import 'package:hive/hive.dart';
import 'transaction.dart';

part 'category.g.dart';

@HiveType(typeId: 0)
class Category extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String iconName;

  @HiveField(3)
  late String colorHex;

  @HiveField(4)
  late String type; // 'Income' หรือ 'Expense'

  @HiveField(5)
  late bool isActive;

  @HiveField(6)
  late DateTime createdAt;

  @HiveField(7)
  double? budgetLimit; // งบประมาณสำหรับหมวดหมู่นี้

  Category({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorHex,
    required this.type,
    this.isActive = true,
    DateTime? createdAt,
    this.budgetLimit,
  }) {
    this.createdAt = createdAt ?? DateTime.now();
  }

  // Helper methods
  bool get isIncome => type == 'Income';
  bool get isExpense => type == 'Expense';
  
  // ดึงข้อมูลยอดใช้จ่ายในหมวดหมู่นี้
  double getTotalAmount(List<Transaction> transactions) {
    return transactions
        .where((t) => t.categoryId == id)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // เช็คว่าเกินงบประมาณไหม
  bool isOverBudget(List<Transaction> transactions) {
    if (budgetLimit == null) return false;
    return getTotalAmount(transactions) > budgetLimit!;
  }
}