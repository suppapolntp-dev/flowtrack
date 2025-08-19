// lib/screens/wallet.dart - Updated with Gradient Effects (Category Icons unchanged)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flowtrack/screens/theme_settings.dart';
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

  // เพิ่มตัวแปรสำหรับการเรียงลำดับ
  String sortType = 'amount_desc';
  final List<Map<String, dynamic>> sortOptions = [
    {
      'value': 'amount_desc',
      'label': 'Highest Spending',
      'icon': Icons.trending_up
    },
    {
      'value': 'amount_asc',
      'label': 'Lowest Spending',
      'icon': Icons.trending_down
    },
    {
      'value': 'trans_desc',
      'label': 'Most Transactions',
      'icon': Icons.receipt_long
    },
    {
      'value': 'trans_asc',
      'label': 'Least Transactions',
      'icon': Icons.receipt
    },
    {'value': 'name_asc', 'label': 'Name (A-Z)', 'icon': Icons.sort_by_alpha},
    {'value': 'name_desc', 'label': 'Name (Z-A)', 'icon': Icons.sort},
  ];

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
      _sortCategories(); // เรียงลำดับตาม sortType
    } catch (e) {
      print('Error loading category spending: $e');
      categorySpendingList = [];
    }

    setState(() {
      isLoading = false;
    });
  }

  void _sortCategories() {
    switch (sortType) {
      case 'amount_desc':
        categorySpendingList
            .sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
        break;
      case 'amount_asc':
        categorySpendingList
            .sort((a, b) => a.totalAmount.compareTo(b.totalAmount));
        break;
      case 'trans_desc':
        categorySpendingList
            .sort((a, b) => b.transactionCount.compareTo(a.transactionCount));
        break;
      case 'trans_asc':
        categorySpendingList
            .sort((a, b) => a.transactionCount.compareTo(b.transactionCount));
        break;
      case 'name_asc':
        categorySpendingList
            .sort((a, b) => a.category.name.compareTo(b.category.name));
        break;
      case 'name_desc':
        categorySpendingList
            .sort((a, b) => b.category.name.compareTo(a.category.name));
        break;
    }
  }

  void _showSortOptions() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: themeProvider.cardColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  gradient: themeProvider.primaryGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Sort Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textColor,
                  ),
                ),
              ),
              Container(
                height: 2,
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  gradient: themeProvider.primaryGradient,
                ),
              ),
              Container(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5),
                child: SingleChildScrollView(
                  child: Column(
                    children: sortOptions
                        .map((option) => ListTile(
                              leading: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: sortType == option['value']
                                      ? themeProvider.primaryGradient
                                      : null,
                                  color: sortType == option['value']
                                      ? null
                                      : themeProvider.backgroundColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  option['icon'],
                                  color: sortType == option['value']
                                      ? Colors.white
                                      : themeProvider.subtitleColor,
                                ),
                              ),
                              title: Text(
                                option['label'],
                                style: TextStyle(
                                  color: sortType == option['value']
                                      ? themeProvider.primaryColor
                                      : themeProvider.textColor,
                                  fontWeight: sortType == option['value']
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              trailing: sortType == option['value']
                                  ? Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        gradient: themeProvider.primaryGradient,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.check, color: Colors.white, size: 16),
                                    )
                                  : null,
                              onTap: () {
                                setState(() {
                                  sortType = option['value'];
                                  _sortCategories();
                                });
                                Navigator.pop(context);
                              },
                            ))
                        .toList(),
                  ),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadCategorySpending,
          child: Column(
            children: [
              _buildHeader(),
              _buildPeriodSelector(),
              _buildSortingBar(),
              _buildTotalSummary(),
              Expanded(child: _buildCategoryList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        gradient: themeProvider.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: themeProvider.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
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
    final themeProvider = Provider.of<ThemeProvider>(context);

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
                  gradient: isSelected
                      ? themeProvider.primaryGradient
                      : null,
                  color: isSelected
                      ? null
                      : themeProvider.cardColor,
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: themeProvider.primaryColor.withOpacity(0.4),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      )
                    else
                      BoxShadow(
                        color: themeProvider.isDarkMode
                            ? Colors.black26
                            : Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                  ],
                  border: isSelected
                      ? null
                      : Border.all(
                          color: themeProvider.dividerColor,
                        ),
                ),
                child: Text(
                  periods[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : themeProvider.textColor,
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

  Widget _buildSortingBar() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Categories',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor,
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _showSortOptions,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: themeProvider.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: themeProvider.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      sortOptions.firstWhere(
                          (opt) => opt['value'] == sortType)['icon'],
                      size: 16,
                      color: Colors.white,
                    ),
                    SizedBox(width: 6),
                    Text(
                      sortOptions.firstWhere(
                          (opt) => opt['value'] == sortType)['label'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 18,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSummary() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (isLoading) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 80,
        child: Center(
            child: CircularProgressIndicator(
          color: themeProvider.primaryColor,
        )),
      );
    }

    double totalSpending =
        categorySpendingList.fold(0, (sum, item) => sum + item.totalAmount);
    int totalTransactions = categorySpendingList.fold(
        0, (sum, item) => sum + item.transactionCount);

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: themeProvider.isDarkMode
                  ? Colors.black26
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 2))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text('Total Spending',
                  style: TextStyle(
                      color: themeProvider.subtitleColor, fontSize: 14)),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade400, Colors.red.shade600],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('\฿${totalSpending.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ],
          ),
          Container(height: 40, width: 1, color: themeProvider.dividerColor),
          Column(
            children: [
              Text('Transactions',
                  style: TextStyle(
                      color: themeProvider.subtitleColor, fontSize: 14)),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$totalTransactions',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ],
          ),
          Container(height: 40, width: 1, color: themeProvider.dividerColor),
          Column(
            children: [
              Text('Categories',
                  style: TextStyle(
                      color: themeProvider.subtitleColor, fontSize: 14)),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${categorySpendingList.length}',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (isLoading) {
      return Center(
          child: CircularProgressIndicator(
        color: themeProvider.primaryColor,
      ));
    }

    if (categorySpendingList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: themeProvider.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.wallet, size: 40, color: Colors.white),
            ),
            SizedBox(height: 16),
            Text('No spending data',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: themeProvider.subtitleColor)),
            SizedBox(height: 8),
            Text('Add some transactions to see category breakdown',
                style:
                    TextStyle(fontSize: 14, color: themeProvider.subtitleColor),
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final category = categorySpending.category;
    final color = Color(int.parse('0xFF${category.colorHex.substring(1)}'));

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Material(
        color: themeProvider.cardColor,
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
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: themeProvider.textColor)),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: category.type == 'Expense'
                                  ? LinearGradient(colors: [Colors.red.shade400, Colors.red.shade600])
                                  : LinearGradient(colors: [Colors.green.shade400, Colors.green.shade600]),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('\฿${categorySpending.totalAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
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
                                  color: themeProvider.subtitleColor,
                                  fontSize: 12)),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: themeProvider.primaryGradient,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('${percentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                            color: themeProvider.dividerColor,
                            borderRadius: BorderRadius.circular(2)),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: percentage / 100,
                          child: Container(
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [color, color.withOpacity(0.7)],
                                ),
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
          _loadCategorySpending();
        },
      ),
    );
  }
}

// CategoryDetailsBottomSheet และ CategorySpending class คงเดิม
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final category = categorySpending.category;
    final color = Color(int.parse('0xFF${category.colorHex.substring(1)}'));

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
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
                gradient: themeProvider.primaryGradient,
                borderRadius: BorderRadius.circular(2)),
          ),
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
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.textColor)),
                      Text('$period Period',
                          style: TextStyle(
                              color: themeProvider.subtitleColor,
                              fontSize: 14)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: category.type == 'Expense'
                            ? LinearGradient(colors: [Colors.red.shade400, Colors.red.shade600])
                            : LinearGradient(colors: [Colors.green.shade400, Colors.green.shade600]),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('\฿${categorySpending.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                    SizedBox(height: 4),
                    Text('${categorySpending.transactionCount} transactions',
                        style: TextStyle(
                            color: themeProvider.subtitleColor, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: themeProvider.dividerColor),
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Dismissible(
      key: Key(transaction.id),
      background: Container(
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.red.shade400, Colors.red.shade600]), 
            borderRadius: BorderRadius.circular(10)),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: themeProvider.cardColor,
            title: Text('Delete Transaction',
                style: TextStyle(color: themeProvider.textColor)),
            content: Text(
                'Are you sure you want to delete this transaction?\n\n"${transaction.description}"',
                style: TextStyle(color: themeProvider.textColor)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Cancel')),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.red.shade400, Colors.red.shade600]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: Text('Delete', style: TextStyle(color: Colors.white)),
                ),
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
            color: themeProvider.backgroundColor,
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transaction.description,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: themeProvider.textColor)),
                  SizedBox(height: 4),
                  Text(
                      '${dayNames[transaction.datetime.weekday - 1]} ${transaction.datetime.day}/${transaction.datetime.month}/${transaction.datetime.year}',
                      style: TextStyle(
                          color: themeProvider.subtitleColor, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: transaction.isIncome 
                        ? LinearGradient(colors: [Colors.green.shade400, Colors.green.shade600])
                        : LinearGradient(colors: [Colors.red.shade400, Colors.red.shade600]),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(transaction.formattedAmount,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.white)),
                ),
                SizedBox(height: 2),
                Text('Swipe to delete',
                    style: TextStyle(
                        color: themeProvider.subtitleColor.withOpacity(0.7),
                        fontSize: 10)),
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