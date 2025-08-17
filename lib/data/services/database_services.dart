// lib/data/services/database_services.dart - แก้ไขแล้ว
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flowtrack/data/models/add_date.dart';
import 'package:flowtrack/data/models/category.dart';
import 'package:flowtrack/data/models/transaction.dart';

class DatabaseService {
  static const String _transactionBoxName = 'transactions';
  static const String _categoryBoxName = 'categories';

  static Box<Transaction>? _transactionBox;
  static Box<Category>? _categoryBox;

  static Box<Transaction> get transactionBox => _transactionBox!;
  static Box<Category> get categoryBox => _categoryBox!;

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters with correct typeIds
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CategoryAdapter()); // typeId = 0
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(AdddataAdapter()); // typeId = 1 (legacy)
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(TransactionAdapter()); // typeId = 3
    }

    // Open boxes
    _categoryBox = await Hive.openBox<Category>(_categoryBoxName);
    _transactionBox = await Hive.openBox<Transaction>(_transactionBoxName);

    await _initializeDefaultCategories();
  }

  static Future<void> _initializeDefaultCategories() async {
    if (categoryBox.isEmpty) {
      final expenseCategories = [
        Category(
            id: 'food',
            name: 'Food',
            iconName: 'Food',
            colorHex: '#FF6B6B',
            type: 'Expense'),
        Category(
            id: 'coffee',
            name: 'Coffee',
            iconName: 'Coffee',
            colorHex: '#8B4513',
            type: 'Expense'),
        Category(
            id: 'grocery',
            name: 'Grocery',
            iconName: 'Grocery',
            colorHex: '#32CD32',
            type: 'Expense'),
        Category(
            id: 'food_delivery',
            name: 'Food Delivery',
            iconName: 'Food-delivery',
            colorHex: '#FF4500',
            type: 'Expense'),
        Category(
            id: 'gas_pump',
            name: 'Gas Pump',
            iconName: 'Gas-pump',
            colorHex: '#1E90FF',
            type: 'Expense'),
        Category(
            id: 'public_transport',
            name: 'Public Transport',
            iconName: 'Public Transport',
            colorHex: '#4ECDC4',
            type: 'Expense'),
        Category(
            id: 'rent',
            name: 'Rent or Mortgage',
            iconName: 'Rent or Mortgage',
            colorHex: '#8B4513',
            type: 'Expense'),
        Category(
            id: 'water_bill',
            name: 'Water Bill',
            iconName: 'Water Bill',
            colorHex: '#1E90FF',
            type: 'Expense'),
        Category(
            id: 'electricity',
            name: 'Electricity Bill',
            iconName: 'Electricity Bill',
            colorHex: '#FFD700',
            type: 'Expense'),
        Category(
            id: 'internet',
            name: 'Internet Bill',
            iconName: 'Internet Bill',
            colorHex: '#6A5ACD',
            type: 'Expense'),
        Category(
            id: 'clothes',
            name: 'Clothes',
            iconName: 'Clothes',
            colorHex: '#FF69B4',
            type: 'Expense'),
        Category(
            id: 'shoes',
            name: 'Shoes',
            iconName: 'Shoes',
            colorHex: '#8B4513',
            type: 'Expense'),
        Category(
            id: 'accessories',
            name: 'Accessories',
            iconName: 'Accessories',
            colorHex: '#DA70D6',
            type: 'Expense'),
        Category(
            id: 'personal_care',
            name: 'Personal Care Items',
            iconName: 'Personal Care Items',
            colorHex: '#FFB6C1',
            type: 'Expense'),
        Category(
            id: 'movie',
            name: 'Movie',
            iconName: 'Movie',
            colorHex: '#DC143C',
            type: 'Expense'),
        Category(
            id: 'concert',
            name: 'Concert',
            iconName: 'Concert',
            colorHex: '#9370DB',
            type: 'Expense'),
        Category(
            id: 'hobby',
            name: 'Hobby',
            iconName: 'Hobby',
            colorHex: '#20B2AA',
            type: 'Expense'),
        Category(
            id: 'travel',
            name: 'Travel',
            iconName: 'Travel',
            colorHex: '#3CB371',
            type: 'Expense'),
        Category(
            id: 'health',
            name: 'Health Report',
            iconName: 'Health-Report',
            colorHex: '#DC143C',
            type: 'Expense'),
        Category(
            id: 'doctor',
            name: 'Doctor Visits Hospital',
            iconName: 'Doctor VisitsHospital',
            colorHex: '#FF4500',
            type: 'Expense'),
        Category(
            id: 'education',
            name: 'Education',
            iconName: 'Education',
            colorHex: '#4169E1',
            type: 'Expense'),
        Category(
            id: 'bank_fees',
            name: 'Bank Fees',
            iconName: 'Bank Fees',
            colorHex: '#696969',
            type: 'Expense'),
        Category(
            id: 'donation',
            name: 'Donation',
            iconName: 'Donation',
            colorHex: '#32CD32',
            type: 'Expense'),
        Category(
            id: 'other_expense',
            name: 'Other Expense',
            iconName: 'Giftbox',
            colorHex: '#999999',
            type: 'Expense'),
      ];

      final incomeCategories = [
        Category(
            id: 'salary',
            name: 'Salary',
            iconName: 'salary',
            colorHex: '#2ECC71',
            type: 'Income'),
        Category(
            id: 'commission',
            name: 'Commission',
            iconName: 'commission',
            colorHex: '#2ECC71',
            type: 'Income'),
        Category(
            id: 'freelanceincome',
            name: 'Freelance Income',
            iconName: 'freelanceincome',
            colorHex: '#2ECC71',
            type: 'Income'),
        Category(
            id: 'dividends',
            name: 'Dividends',
            iconName: 'dividends',
            colorHex: '#2ECC71',
            type: 'Income'),
        Category(
            id: 'interest',
            name: 'Interest',
            iconName: 'interest',
            colorHex: '#2ECC71',
            type: 'Income'),
        Category(
            id: 'rentalincome',
            name: 'Rental Income',
            iconName: 'rentalincome',
            colorHex: '#2ECC71',
            type: 'Income'),
        Category(
            id: 'taxrefunds',
            name: 'Tax Refunds',
            iconName: 'taxrefunds',
            colorHex: '#2ECC71',
            type: 'Income'),
        Category(
            id: 'gift',
            name: 'Gift',
            iconName: 'Giftbox',
            colorHex: '#E74C3C',
            type: 'Income'),
        Category(
            id: 'other_income',
            name: 'Other Income',
            iconName: 'Giftbox',
            colorHex: '#1ABC9C',
            type: 'Income'),
      ];

      // เพิ่มทีละตัว พร้อม error handling
      for (var category in [...expenseCategories, ...incomeCategories]) {
        try {
          await addCategory(category);
          print('Added category: ${category.name}');
        } catch (e) {
          print('Error adding category ${category.name}: $e');
        }
      }
    }
  }

  // === CATEGORY METHODS === ปรับปรุงใหม่
  static Future<void> addCategory(Category category) async {
    try {
      await categoryBox.add(category);
      await categoryBox.flush(); // บังคับให้บันทึกทันที
      print('Category ${category.name} added successfully');
    } catch (e) {
      print('Error adding category: $e');
      throw e;
    }
  }

  static Future<void> updateCategory(Category category) async {
    try {
      await category.save();
      await categoryBox.flush();
      print('Category ${category.name} updated successfully');
    } catch (e) {
      print('Error updating category: $e');
      throw e;
    }
  }

  static Future<void> deleteCategory(String categoryId) async {
    try {
      // ตรวจสอบก่อนว่ามี transaction ที่ใช้ category นี้หรือไม่
      final transactionsUsingCategory = transactionBox.values
          .where((t) => t.categoryId == categoryId)
          .toList();

      if (transactionsUsingCategory.isNotEmpty) {
        throw Exception(
            'Cannot delete category. ${transactionsUsingCategory.length} transactions are using this category.');
      }

      final categoryIndex =
          categoryBox.values.toList().indexWhere((cat) => cat.id == categoryId);

      if (categoryIndex != -1) {
        await categoryBox.deleteAt(categoryIndex);
        await categoryBox.flush();
        print('Category deleted successfully');
      } else {
        throw Exception('Category not found');
      }
    } catch (e) {
      print('Error deleting category: $e');
      throw e;
    }
  }

  static List<Category> getCategories({String? type}) {
    try {
      var categories = categoryBox.values.where((cat) => cat.isActive).toList();
      if (type != null) {
        categories = categories.where((cat) => cat.type == type).toList();
      }
      // เรียงตามชื่อ
      categories.sort((a, b) => a.name.compareTo(b.name));
      return categories;
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  static List<Category> getAllCategories({String? type}) {
    try {
      var categories = categoryBox.values.toList();
      if (type != null) {
        categories = categories.where((cat) => cat.type == type).toList();
      }
      categories.sort((a, b) => a.name.compareTo(b.name));
      return categories;
    } catch (e) {
      print('Error getting all categories: $e');
      return [];
    }
  }

  static Category? getCategoryById(String id) {
    try {
      return categoryBox.values.firstWhere((cat) => cat.id == id);
    } catch (e) {
      print('Category with id $id not found');
      return null;
    }
  }

  // เพิ่มฟังก์ชันสำหรับตรวจสอบว่า Category มีอยู่หรือไม่
  static bool categoryExists(String id) {
    return categoryBox.values.any((cat) => cat.id == id);
  }

  // เพิ่มฟังก์ชันสำหรับนับจำนวน Category
  static int getCategoryCount({String? type}) {
    return getCategories(type: type).length;
  }

  // === TRANSACTION METHODS === (เหมือนเดิม)
  static Future<void> addTransaction(Transaction transaction) async {
    try {
      await transactionBox.add(transaction);
      await transactionBox.flush();
    } catch (e) {
      print('Error adding transaction: $e');
      throw e;
    }
  }

  static Future<void> updateTransaction(Transaction transaction) async {
    try {
      await transaction.save();
      await transactionBox.flush();
    } catch (e) {
      print('Error updating transaction: $e');
      throw e;
    }
  }

  static Future<void> deleteTransaction(String transactionId) async {
    try {
      final transactionIndex = transactionBox.values
          .toList()
          .indexWhere((t) => t.id == transactionId);

      if (transactionIndex != -1) {
        await transactionBox.deleteAt(transactionIndex);
        await transactionBox.flush();
      } else {
        throw Exception('Transaction not found');
      }
    } catch (e) {
      print('Error deleting transaction: $e');
      throw e;
    }
  }

  static List<Transaction> getTransactions({
    String? type,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) {
    try {
      var transactions = transactionBox.values.toList();

      if (type != null) {
        transactions = transactions.where((t) => t.type == type).toList();
      }

      if (categoryId != null) {
        transactions =
            transactions.where((t) => t.categoryId == categoryId).toList();
      }

      if (startDate != null) {
        transactions = transactions
            .where((t) =>
                t.datetime.isAfter(startDate) ||
                t.datetime.isAtSameMomentAs(startDate))
            .toList();
      }

      if (endDate != null) {
        transactions = transactions
            .where((t) =>
                t.datetime.isBefore(endDate) ||
                t.datetime.isAtSameMomentAs(endDate))
            .toList();
      }

      transactions.sort((a, b) => b.datetime.compareTo(a.datetime));

      if (limit != null && transactions.length > limit) {
        transactions = transactions.take(limit).toList();
      }

      return transactions;
    } catch (e) {
      print('Error getting transactions: $e');
      return [];
    }
  }

  // === ANALYTICS METHODS === (ปรับปรุง)
  static double getTotalBalance() {
    try {
      final transactions = transactionBox.values.toList();
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
      print('Error calculating total balance: $e');
      return 0.0;
    }
  }

  static double getTotalIncome({DateTime? startDate, DateTime? endDate}) {
    try {
      final transactions = getTransactions(
        type: 'Income',
        startDate: startDate,
        endDate: endDate,
      );
      return transactions.fold(0.0, (sum, t) => sum + t.amount);
    } catch (e) {
      print('Error calculating total income: $e');
      return 0.0;
    }
  }

  static double getTotalExpense({DateTime? startDate, DateTime? endDate}) {
    try {
      final transactions = getTransactions(
        type: 'Expense',
        startDate: startDate,
        endDate: endDate,
      );
      return transactions.fold(0.0, (sum, t) => sum + t.amount);
    } catch (e) {
      print('Error calculating total expense: $e');
      return 0.0;
    }
  }

  static Map<String, double> getCategoryExpenseData({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    try {
      final transactions = getTransactions(
        type: 'Expense',
        startDate: startDate,
        endDate: endDate,
      );

      Map<String, double> categoryData = {};

      for (var transaction in transactions) {
        final category = getCategoryById(transaction.categoryId);
        final categoryName = category?.name ?? 'Unknown';

        categoryData[categoryName] =
            (categoryData[categoryName] ?? 0) + transaction.amount;
      }

      return categoryData;
    } catch (e) {
      print('Error getting category expense data: $e');
      return {};
    }
  }

  // เพิ่มฟังก์ชันสำหรับรีเซ็ตข้อมูล
  static Future<void> resetAllData() async {
    try {
      await categoryBox.clear();
      await transactionBox.clear();
      await _initializeDefaultCategories();
      print('All data reset successfully');
    } catch (e) {
      print('Error resetting data: $e');
      throw e;
    }
  }

  static Future<void> close() async {
    try {
      await _transactionBox?.flush();
      await _categoryBox?.flush();
      await _transactionBox?.close();
      await _categoryBox?.close();
    } catch (e) {
      print('Error closing database: $e');
    }
  }

  // Debug methods
  static void printDatabaseInfo() {
    print('=== Database Info ===');
    print('Categories: ${categoryBox.length}');
    print('Transactions: ${transactionBox.length}');
    print('Categories:');
    for (var cat in categoryBox.values) {
      print('  - ${cat.name} (${cat.type}) - ${cat.id}');
    }
  }
}
