// lib/screens/wallet.dart - เพิ่ม Delete Transaction
import 'package:flutter/material.dart';
import 'package:flowtrack/data/services/database_services.dart';
import 'package:flowtrack/data/models/category.dart';
import 'package:flowtrack/data/models/transaction.dart';
import 'package:flowtrack/data/utlity.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int selectedPeriodIndex = 0;
  List<String> periods = ['Day', 'Week', 'Month', 'Year', 'All Time'];
  List<CategorySpending> categorySpendingList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategorySpending();

    DatabaseService.transactionStream.listen((transactions) {
      if (mounted) _loadCategorySpending();
    });
  }

  Future<void> _loadCategorySpending() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Transaction> transactions = [];

      switch (selectedPeriodIndex) {
        case 0:
          transactions = today();
          break;
        case 1:
          transactions = week();
          break;
        case 2:
          transactions = month();
          break;
        case 3:
          transactions = year();
          break;
        case 4:
          transactions = DatabaseService.getTransactions();
          break;
      }

      Map<String, CategorySpending> categoryMap = {};

      for (var transaction in transactions) {
        final category =
            DatabaseService.getCategoryById(transaction.categoryId);
        if (category != null) {
          final key = category.id;

          if (!categoryMap.containsKey(key)) {
            categoryMap[key] = CategorySpending(
              category: category,
              totalAmount: 0,
              transactionCount: 0,
              transactions: [],
            );
          }

          categoryMap[key]!.totalAmount += transaction.amount;
          categoryMap[key]!.transactionCount += 1;
          categoryMap[key]!.transactions.add(transaction);
        }
      }

      categorySpendingList = categoryMap.values.toList();
      categorySpendingList
          .sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    } catch (e) {
      print('Error loading category spending: $e');
      categorySpendingList = [];
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadCategorySpending,
          child: Column(
            children: [
              _buildHeader(),
              _buildPeriodSelector(),
              _buildTotalSummary(),
              Expanded(child: _buildCategoryList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Text('Wallet',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          SizedBox(height: 8),
          Text('Category Spending Analysis',
              style: TextStyle(
                  fontSize: 14, color: Colors.white.withOpacity(0.9))),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(periods.length, (index) {
            final isSelected = selectedPeriodIndex == index;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedPeriodIndex = index;
                });
                _loadCategorySpending();
              },
              child: Container(
                margin: EdgeInsets.only(right: 12),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.white,
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                  ],
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  periods[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTotalSummary() {
    if (isLoading) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    double totalSpending =
        categorySpendingList.fold(0, (sum, item) => sum + item.totalAmount);
    int totalTransactions = categorySpendingList.fold(
        0, (sum, item) => sum + item.transactionCount);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text('Total Spending',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              SizedBox(height: 4),
              Text('\$${totalSpending.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade600)),
            ],
          ),
          Container(height: 40, width: 1, color: Colors.grey.shade300),
          Column(
            children: [
              Text('Transactions',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              SizedBox(height: 4),
              Text('$totalTransactions',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade600)),
            ],
          ),
          Container(height: 40, width: 1, color: Colors.grey.shade300),
          Column(
            children: [
              Text('Categories',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              SizedBox(height: 4),
              Text('${categorySpendingList.length}',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (categorySpendingList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wallet, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No spending data',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey)),
            SizedBox(height: 8),
            Text('Add some transactions to see category breakdown',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center),
          ],
        ),
      );
    }

    double totalAmount =
        categorySpendingList.fold(0, (sum, item) => sum + item.totalAmount);

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: categorySpendingList.length,
      itemBuilder: (context, index) {
        final categorySpending = categorySpendingList[index];
        final percentage = totalAmount > 0
            ? (categorySpending.totalAmount / totalAmount) * 100
            : 0;
        return _buildCategoryCard(categorySpending, percentage.toDouble());
      },
    );
  }

  Widget _buildCategoryCard(
      CategorySpending categorySpending, double percentage) {
    final category = categorySpending.category;
    final color = Color(int.parse('0xFF${category.colorHex.substring(1)}'));

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => _showCategoryDetails(categorySpending),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: category.iconName != 'help'
                      ? Image.asset('images/${category.iconName}.png',
                          width: 30,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.category, color: color, size: 30))
                      : Icon(Icons.help, color: color, size: 30),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(category.name,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          Text(
                              '\$${categorySpending.totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: category.type == 'Expense'
                                      ? Colors.red.shade600
                                      : Colors.green.shade600)),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              '${categorySpending.transactionCount} transactions',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 12)),
                          Text('${percentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(2)),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: percentage / 100,
                          child: Container(
                            decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(2)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCategoryDetails(CategorySpending categorySpending) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategoryDetailsBottomSheet(
        categorySpending: categorySpending,
        period: periods[selectedPeriodIndex],
        onTransactionDeleted: () {
          _loadCategorySpending(); // Refresh data
        },
      ),
    );
  }
}

// Category Details Bottom Sheet with Delete Functionality
class CategoryDetailsBottomSheet extends StatelessWidget {
  final CategorySpending categorySpending;
  final String period;
  final VoidCallback onTransactionDeleted;

  const CategoryDetailsBottomSheet({
    Key? key,
    required this.categorySpending,
    required this.period,
    required this.onTransactionDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final category = categorySpending.category;
    final color = Color(int.parse('0xFF${category.colorHex.substring(1)}'));

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25), topRight: Radius.circular(25)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2)),
          ),

          // Header
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15)),
                  child: category.iconName != 'help'
                      ? Image.asset('images/${category.iconName}.png',
                          width: 40,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.category, color: color, size: 40))
                      : Icon(Icons.help, color: color, size: 40),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category.name,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('$period Period',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 14)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('\$${categorySpending.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: category.type == 'Expense'
                                ? Colors.red.shade600
                                : Colors.green.shade600)),
                    Text('${categorySpending.transactionCount} transactions',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),

          Divider(height: 1),

          // Transaction List with Delete
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20),
              itemCount: categorySpending.transactions.length,
              itemBuilder: (context, index) {
                final transaction = categorySpending.transactions[index];
                return _buildTransactionItem(context, transaction);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transaction transaction) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Dismissible(
      key: Key(transaction.id),
      background: Container(
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
            color: Colors.red, borderRadius: BorderRadius.circular(10)),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete Transaction'),
            content: Text(
                'Are you sure you want to delete this transaction?\n\n"${transaction.description}"'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Cancel')),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Delete', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        try {
          await DatabaseService.deleteTransaction(transaction.id);
          onTransactionDeleted();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Transaction deleted'),
                backgroundColor: Colors.green),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error deleting transaction'),
                backgroundColor: Colors.red),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transaction.description,
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  SizedBox(height: 4),
                  Text(
                      '${dayNames[transaction.datetime.weekday - 1]} ${transaction.datetime.day}/${transaction.datetime.month}/${transaction.datetime.year}',
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(transaction.formattedAmount,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color:
                            transaction.isIncome ? Colors.green : Colors.red)),
                Text('Swipe to delete',
                    style:
                        TextStyle(color: Colors.grey.shade500, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CategorySpending {
  final Category category;
  double totalAmount;
  int transactionCount;
  List<Transaction> transactions;

  CategorySpending({
    required this.category,
    required this.totalAmount,
    required this.transactionCount,
    required this.transactions,
  });
}
