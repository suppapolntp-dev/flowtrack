// lib/screens/wallet.dart
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
  }

  Future<void> _loadCategorySpending() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Transaction> transactions = [];
      DateTime now = DateTime.now();

      // Get transactions based on selected period
      switch (selectedPeriodIndex) {
        case 0: // Day
          transactions = today();
          break;
        case 1: // Week
          transactions = week();
          break;
        case 2: // Month
          transactions = month();
          break;
        case 3: // Year
          transactions = year();
          break;
        case 4: // All Time
          transactions = DatabaseService.getTransactions();
          break;
      }

      // Group by category
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

      // Convert to list and sort by amount (descending)
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
      backgroundColor: Colors.grey.shade50,
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
        color: Color(0xFFFFC870),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Wallet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Category Spending Analysis',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
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
                  color: isSelected ? Color(0xFFFFC870) : Colors.white,
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: Color(0xFFFFC870).withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                  ],
                  border: Border.all(
                    color:
                        isSelected ? Color(0xFFFFC870) : Colors.grey.shade300,
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
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                'Total Spending',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '\$${totalSpending.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade600,
                ),
              ),
            ],
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.grey.shade300,
          ),
          Column(
            children: [
              Text(
                'Transactions',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '$totalTransactions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade600,
                ),
              ),
            ],
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.grey.shade300,
          ),
          Column(
            children: [
              Text(
                'Categories',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '${categorySpendingList.length}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade600,
                ),
              ),
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
            Text(
              'No spending data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add some transactions to see category breakdown',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
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
                // Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: category.iconName != 'help'
                      ? Image.asset(
                          'images/${category.iconName}.png',
                          width: 30,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.category, color: color, size: 30);
                          },
                        )
                      : Icon(Icons.help, color: color, size: 30),
                ),
                SizedBox(width: 16),

                // Category info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '\$${categorySpending.totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: category.type == 'Expense'
                                  ? Colors.red.shade600
                                  : Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${categorySpending.transactionCount} transactions',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      // Progress bar
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: percentage / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(2),
                            ),
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
      ),
    );
  }
}

// Category Details Bottom Sheet
class CategoryDetailsBottomSheet extends StatelessWidget {
  final CategorySpending categorySpending;
  final String period;

  const CategoryDetailsBottomSheet({
    Key? key,
    required this.categorySpending,
    required this.period,
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
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
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
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: category.iconName != 'help'
                      ? Image.asset(
                          'images/${category.iconName}.png',
                          width: 40,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.category, color: color, size: 40);
                          },
                        )
                      : Icon(Icons.help, color: color, size: 40),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$period Period',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${categorySpending.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: category.type == 'Expense'
                            ? Colors.red.shade600
                            : Colors.green.shade600,
                      ),
                    ),
                    Text(
                      '${categorySpending.transactionCount} transactions',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Divider(height: 1),

          // Transaction List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20),
              itemCount: categorySpending.transactions.length,
              itemBuilder: (context, index) {
                final transaction = categorySpending.transactions[index];
                return _buildTransactionItem(transaction);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${dayNames[transaction.datetime.weekday - 1]} ${transaction.datetime.day}/${transaction.datetime.month}/${transaction.datetime.year}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            transaction.formattedAmount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: transaction.isIncome ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

// Data class for category spending
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
