import 'package:hive_flutter/hive_flutter.dart';
import 'package:flowtrack/data/models/add_date.dart';
import 'package:flowtrack/data/models/category.dart';
import 'package:flowtrack/data/models/transaction.dart';
import 'dart:async';

class DatabaseService {
  static const String _transactionBoxName = 'transactions';
  static const String _categoryBoxName = 'categories';

  static Box<Transaction>? _transactionBox;
  static Box<Category>? _categoryBox;

  // Stream Controllers สำหรับ Real-time Updates
  static final StreamController<List<Category>> _categoryController =
      StreamController<List<Category>>.broadcast();
  static final StreamController<List<Transaction>> _transactionController =
      StreamController<List<Transaction>>.broadcast();

  static Box<Transaction> get transactionBox => _transactionBox!;
  static Box<Category> get categoryBox => _categoryBox!;

  // Streams สำหรับฟัง changes
  static Stream<List<Category>> get categoryStream =>
      _categoryController.stream;
  static Stream<List<Transaction>> get transactionStream =>
      _transactionController.stream;

  static Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(AdddataAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(TransactionAdapter());
    }

    _categoryBox = await Hive.openBox<Category>(_categoryBoxName);
    _transactionBox = await Hive.openBox<Transaction>(_transactionBoxName);

    await _initializeDefaultCategories();

    // ส่ง initial data
    _notifyListeners();
  }

  static void _notifyListeners() {
    _categoryController.add(categoryBox.values.toList());
    _transactionController.add(transactionBox.values.toList());
  }

  // แก้ไขใน lib/data/services/database_services.dart
// เปลี่ยนเฉพาะ method _initializeDefaultCategories()

  static Future<void> _initializeDefaultCategories() async {
    if (categoryBox.isEmpty) {
      print('Initializing default categories...');

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
            id: 'gift',
            name: 'Gift',
            iconName: 'Giftbox',
            colorHex: '#FF1493',
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
            colorHex: '#27AE60',
            type: 'Income'),
        Category(
            id: 'freelanceincome',
            name: 'Freelance Income',
            iconName: 'freelanceincome',
            colorHex: '#16A085',
            type: 'Income'),
        Category(
            id: 'dividends',
            name: 'Dividends',
            iconName: 'dividends',
            colorHex: '#3498DB',
            type: 'Income'),
        Category(
            id: 'interest',
            name: 'Interest',
            iconName: 'interest',
            colorHex: '#9B59B6',
            type: 'Income'),
        Category(
            id: 'rentalincome',
            name: 'Rental Income',
            iconName: 'rentalincome',
            colorHex: '#E74C3C',
            type: 'Income'),
        Category(
            id: 'taxrefunds',
            name: 'Tax Refunds',
            iconName: 'taxrefunds',
            colorHex: '#F39C12',
            type: 'Income'),
        Category(
            id: 'gift_income',
            name: 'Gift',
            iconName: 'Giftbox',
            colorHex: '#E91E63',
            type: 'Income'),
        Category(
            id: 'other_income',
            name: 'Other Income',
            iconName: 'Giftbox',
            colorHex: '#1ABC9C',
            type: 'Income'),
      ];

      // บันทึกทั้งหมดลง database โดยตรง
      for (var category in [...expenseCategories, ...incomeCategories]) {
        try {
          await categoryBox.add(category);
          print('Added category: ${category.name}');
        } catch (e) {
          print('Error adding category ${category.name}: $e');
        }
      }

      // Force save to disk
      await categoryBox.flush();
      print('All categories initialized successfully!');
    } else {
      print(
          'Categories already exist in database: ${categoryBox.length} items');
    }
  }

// เพิ่ม method สำหรับ reset categories (ใช้เมื่อต้องการ reset ข้อมูล)
  static Future<void> resetCategories() async {
    try {
      await categoryBox.clear();
      await _initializeDefaultCategories();
      _notifyListeners();
      print('Categories reset successfully!');
    } catch (e) {
      print('Error resetting categories: $e');
    }
  }

  static Future<void> addCategory(Category category) async {
    try {
      await categoryBox.add(category);
      await categoryBox.flush();
      _notifyListeners();
    } catch (e) {
      print('Error adding category: $e');
      throw e;
    }
  }

  static Future<void> updateCategory(Category category) async {
    try {
      await category.save();
      await categoryBox.flush();
      _notifyListeners();
    } catch (e) {
      print('Error updating category: $e');
      throw e;
    }
  }

  static Future<void> deleteCategory(String categoryId) async {
    try {
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
        _notifyListeners();
      }
    } catch (e) {
      print('Error deleting category: $e');
      throw e;
    }
  }

  static Future<void> reorderCategories(List<Category> newOrder) async {
    try {
      await categoryBox.clear();
      for (var category in newOrder) {
        await categoryBox.add(category);
      }
      await categoryBox.flush();
      _notifyListeners();
    } catch (e) {
      print('Error reordering categories: $e');
      throw e;
    }
  }

  static List<Category> getCategories({String? type}) {
    try {
      var categories = categoryBox.values.where((cat) => cat.isActive).toList();
      if (type != null) {
        categories = categories.where((cat) => cat.type == type).toList();
      }
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
      return null;
    }
  }

  static Future<void> addTransaction(Transaction transaction) async {
    try {
      await transactionBox.add(transaction);
      await transactionBox.flush();
      _notifyListeners();
    } catch (e) {
      print('Error adding transaction: $e');
      throw e;
    }
  }

  static Future<void> updateTransaction(Transaction transaction) async {
    try {
      await transaction.save();
      await transactionBox.flush();
      _notifyListeners();
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
        _notifyListeners();
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

  // === ANALYTICS METHODS ===
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
      return 0.0;
    }
  }

  static double getTotalIncome({DateTime? startDate, DateTime? endDate}) {
    try {
      final transactions = getTransactions(
          type: 'Income', startDate: startDate, endDate: endDate);
      return transactions.fold(0.0, (sum, t) => sum + t.amount);
    } catch (e) {
      return 0.0;
    }
  }

  static double getTotalExpense({DateTime? startDate, DateTime? endDate}) {
    try {
      final transactions = getTransactions(
          type: 'Expense', startDate: startDate, endDate: endDate);
      return transactions.fold(0.0, (sum, t) => sum + t.amount);
    } catch (e) {
      return 0.0;
    }
  }

  static Future<void> close() async {
    try {
      _categoryController.close();
      _transactionController.close();
      await _transactionBox?.close();
      await _categoryBox?.close();
    } catch (e) {
      print('Error closing database: $e');
    }
  }
}
