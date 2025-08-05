// lib/data/services/database_services.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flowtrack/data/models/add_date.dart';
import 'package:flowtrack/data/models/category.dart';
import 'package:flowtrack/data/models/transaction.dart';

class DatabaseService {
  static const String _transactionBoxName = 'transactions';
  static const String _categoryBoxName = 'categories';

  // Boxes
  static Box<Transaction>? _transactionBox;
  static Box<Category>? _categoryBox;

  // Getters
  static Box<Transaction> get transactionBox => _transactionBox!;
  static Box<Category> get categoryBox => _categoryBox!;

  // Initialize Database
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TransactionAdapter());
    }
    // เอา Add_dataAdapter ออกก่อน เนื่องจากยังไม่ได้ใช้งาน
    // if (!Hive.isAdapterRegistered(2)) {
    //   Hive.registerAdapter(Add_dataAdapter()); // Legacy adapter
    // }

    // Open boxes
    _categoryBox = await Hive.openBox<Category>(_categoryBoxName);
    _transactionBox = await Hive.openBox<Transaction>(_transactionBoxName);

    // สร้างหมวดหมู่เริ่มต้น
    await _initializeDefaultCategories();
  }

  // สร้างหมวดหมู่เริ่มต้น (ตามรายการที่มีอยู่)
  static Future<void> _initializeDefaultCategories() async {
    if (categoryBox.isEmpty) {
      // หมวดหมู่ค่าใช้จ่าย (ตามไอคอนที่มีอยู่)
      final expenseCategories = [
        Category(id: 'food', name: 'Food', iconName: 'Food', colorHex: '#FF6B6B', type: 'Expense'),
        Category(id: 'coffee', name: 'Coffee', iconName: 'Coffee', colorHex: '#8B4513', type: 'Expense'),
        Category(id: 'grocery', name: 'Grocery', iconName: 'Grocery', colorHex: '#32CD32', type: 'Expense'),
        Category(id: 'food_delivery', name: 'Food Delivery', iconName: 'Food-delivery', colorHex: '#FF4500', type: 'Expense'),
        Category(id: 'gas_pump', name: 'Gas Pump', iconName: 'Gas-pump', colorHex: '#1E90FF', type: 'Expense'),
        Category(id: 'public_transport', name: 'Public Transport', iconName: 'Public Transport', colorHex: '#4ECDC4', type: 'Expense'),
        Category(id: 'rent', name: 'Rent or Mortgage', iconName: 'Rent or Mortgage', colorHex: '#8B4513', type: 'Expense'),
        Category(id: 'water_bill', name: 'Water Bill', iconName: 'Water Bill', colorHex: '#1E90FF', type: 'Expense'),
        Category(id: 'electricity', name: 'Electricity Bill', iconName: 'Electricity Bill', colorHex: '#FFD700', type: 'Expense'),
        Category(id: 'internet', name: 'Internet Bill', iconName: 'Internet Bill', colorHex: '#6A5ACD', type: 'Expense'),
        Category(id: 'clothes', name: 'Clothes', iconName: 'Clothes', colorHex: '#FF69B4', type: 'Expense'),
        Category(id: 'shoes', name: 'Shoes', iconName: 'Shoes', colorHex: '#8B4513', type: 'Expense'),
        Category(id: 'accessories', name: 'Accessories', iconName: 'Accessories', colorHex: '#DA70D6', type: 'Expense'),
        Category(id: 'personal_care', name: 'Personal Care Items', iconName: 'Personal Care Items', colorHex: '#FFB6C1', type: 'Expense'),
        Category(id: 'movie', name: 'Movie', iconName: 'Movie', colorHex: '#DC143C', type: 'Expense'),
        Category(id: 'concert', name: 'Concert', iconName: 'Concert', colorHex: '#9370DB', type: 'Expense'),
        Category(id: 'hobby', name: 'Hobby', iconName: 'Hobby', colorHex: '#20B2AA', type: 'Expense'),
        Category(id: 'travel', name: 'Travel', iconName: 'Travel', colorHex: '#3CB371', type: 'Expense'),
        Category(id: 'health', name: 'Health Report', iconName: 'Health-Report', colorHex: '#DC143C', type: 'Expense'),
        Category(id: 'doctor', name: 'Doctor Visits Hospital', iconName: 'Doctor VisitsHospital', colorHex: '#FF4500', type: 'Expense'),
        Category(id: 'education', name: 'Education', iconName: 'Education', colorHex: '#4169E1', type: 'Expense'),
        Category(id: 'bank_fees', name: 'Bank Fees', iconName: 'Bank Fees', colorHex: '#696969', type: 'Expense'),
        Category(id: 'donation', name: 'Donation', iconName: 'Donation', colorHex: '#32CD32', type: 'Expense'),
      ];

      // หมวดหมู่รายได้
      final incomeCategories = [
        Category(id: 'salary', name: 'Salary', iconName: 'Giftbox', colorHex: '#2ECC71', type: 'Income'),
        Category(id: 'gift', name: 'Gift', iconName: 'Giftbox', colorHex: '#E74C3C', type: 'Income'),
        Category(id: 'other_income', name: 'Other Income', iconName: 'Giftbox', colorHex: '#1ABC9C', type: 'Income'),
      ];

      // เพิ่มเข้า database
      for (var category in [...expenseCategories, ...incomeCategories]) {
        await categoryBox.add(category);
      }
    }
  }

  // === CATEGORY METHODS ===
  
  static Future<void> addCategory(Category category) async {
    await categoryBox.add(category);
  }

  static Future<void> updateCategory(Category category) async {
    await category.save();
  }

  static Future<void> deleteCategory(String categoryId) async {
    final category = categoryBox.values.firstWhere((cat) => cat.id == categoryId);
    await category.delete();
  }

  static List<Category> getCategories({String? type}) {
    var categories = categoryBox.values.where((cat) => cat.isActive).toList();
    if (type != null) {
      categories = categories.where((cat) => cat.type == type).toList();
    }
    return categories;
  }

  static Category? getCategoryById(String id) {
    try {
      return categoryBox.values.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  // === TRANSACTION METHODS ===
  
  static Future<void> addTransaction(Transaction transaction) async {
    await transactionBox.add(transaction);
  }

  static Future<void> updateTransaction(Transaction transaction) async {
    await transaction.save();
  }

  static Future<void> deleteTransaction(String transactionId) async {
    final transaction = transactionBox.values.firstWhere((t) => t.id == transactionId);
    await transaction.delete();
  }

  static List<Transaction> getTransactions({
    String? type,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) {
    var transactions = transactionBox.values.toList();

    // Filter by type
    if (type != null) {
      transactions = transactions.where((t) => t.type == type).toList();
    }

    // Filter by category
    if (categoryId != null) {
      transactions = transactions.where((t) => t.categoryId == categoryId).toList();
    }

    // Filter by date range
    if (startDate != null) {
      transactions = transactions.where((t) => t.datetime.isAfter(startDate) || t.datetime.isAtSameMomentAs(startDate)).toList();
    }
    if (endDate != null) {
      transactions = transactions.where((t) => t.datetime.isBefore(endDate) || t.datetime.isAtSameMomentAs(endDate)).toList();
    }

    // Sort by date (latest first)
    transactions.sort((a, b) => b.datetime.compareTo(a.datetime));

    // Limit results
    if (limit != null && transactions.length > limit) {
      transactions = transactions.take(limit).toList();
    }

    return transactions;
  }

  // === ANALYTICS METHODS ===
  
  static double getTotalBalance() {
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
  }

  static double getTotalIncome({DateTime? startDate, DateTime? endDate}) {
    final transactions = getTransactions(
      type: 'Income',
      startDate: startDate,
      endDate: endDate,
    );
    return transactions.fold(0.0, (sum, t) => sum + t.amount);
  }

  static double getTotalExpense({DateTime? startDate, DateTime? endDate}) {
    final transactions = getTransactions(
      type: 'Expense',
      startDate: startDate,
      endDate: endDate,
    );
    return transactions.fold(0.0, (sum, t) => sum + t.amount);
  }

  // ข้อมูลสำหรับแผนภูมิ
  static Map<String, double> getCategoryExpenseData({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final transactions = getTransactions(
      type: 'Expense',
      startDate: startDate,
      endDate: endDate,
    );
    
    Map<String, double> categoryData = {};
    
    for (var transaction in transactions) {
      final category = getCategoryById(transaction.categoryId);
      final categoryName = category?.name ?? 'Unknown';
      
      categoryData[categoryName] = (categoryData[categoryName] ?? 0) + transaction.amount;
    }
    
    return categoryData;
  }

  // ปิด database
  static Future<void> close() async {
    await _transactionBox?.close();
    await _categoryBox?.close();
  }
}