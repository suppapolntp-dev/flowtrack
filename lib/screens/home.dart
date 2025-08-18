// lib/screens/home.dart - Updated with Username Display
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flowtrack/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flowtrack/data/services/database_services.dart';
import 'package:flowtrack/data/models/transaction.dart';
import 'package:flowtrack/data/utlity.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Transaction> transactions = [];
  double monthlyBudget = 0;
  double currentSpent = 0;
  String userName = 'Loading...'; // เพิ่มตัวแปรสำหรับเก็บชื่อ

  final List<String> day = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadUserName(); // เพิ่มการโหลดชื่อผู้ใช้

    DatabaseService.transactionStream.listen((transactions) {
      if (mounted) _loadData();
    });
  }

  // เพิ่ม method สำหรับโหลดชื่อผู้ใช้
  Future<void> _loadUserName() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        userName = prefs.getString('user_name') ?? 'Mr.Suppapol Tabudda';
      });
    } catch (e) {
      print('Error loading user name: $e');
      setState(() {
        userName = 'Mr.Suppapol Tabudda';
      });
    }
  }

  Future<void> _loadData() async {
    _loadTransactions();
    await _loadBudgetData();
  }

  void _loadTransactions() {
    try {
      setState(() {
        transactions = DatabaseService.getTransactions(limit: 20);
      });
    } catch (e) {
      print('Error loading transactions: $e');
      setState(() {
        transactions = [];
      });
    }
  }

  Future<void> _loadBudgetData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      double budget = prefs.getDouble('monthly_budget') ?? 0;

      DateTime now = DateTime.now();
      DateTime startOfMonth = DateTime(now.year, now.month, 1);
      DateTime endOfMonth = DateTime(now.year, now.month + 1, 0);

      double spent = DatabaseService.getTotalExpense(
          startDate: startOfMonth, endDate: endOfMonth);

      setState(() {
        monthlyBudget = budget;
        currentSpent = spent;
      });
    } catch (e) {
      print('Error loading budget: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _loadData();
            await _loadUserName(); // รีโหลดชื่อด้วยเมื่อ refresh
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _head()),
              SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Transactions History',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, 
                              fontSize: 16,
                              color: themeProvider.textColor)),
                      GestureDetector(
                        onTap: () {},
                        child: Text('See All',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: themeProvider.subtitleColor)),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 10)),
              transactions.isEmpty
                  ? SliverToBoxAdapter(
                      child: Container(
                        height: 200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox, size: 64, color: themeProvider.subtitleColor),
                              SizedBox(height: 16),
                              Text('No transactions yet',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: themeProvider.subtitleColor,
                                      fontWeight: FontWeight.w500)),
                              Text('Add your first transaction to get started',
                                  style: TextStyle(
                                      fontSize: 14, color: themeProvider.subtitleColor)),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => getList(transactions[index], index),
                        childCount: transactions.length,
                      ),
                    ),
              SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget getList(Transaction transaction, int index) {
    return Dismissible(
      key: Key(transaction.id),
      onDismissed: (direction) async {
        try {
          await DatabaseService.deleteTransaction(transaction.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Transaction deleted')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting transaction')),
          );
        }
      },
      child: get(transaction),
    );
  }

  ListTile get(Transaction transaction) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final category = DatabaseService.getCategoryById(transaction.categoryId);
    final iconName = category?.iconName ?? 'Giftbox';

    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
          width: 40,
          height: 40,
          child: Image.asset('images/$iconName.png',
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.help, size: 40, color: themeProvider.subtitleColor)),
        ),
      ),
      title: Text(transaction.description,
          style: TextStyle(
            fontSize: 17, 
            fontWeight: FontWeight.w600,
            color: themeProvider.textColor)),
      subtitle: Text(
        '${category?.name ?? 'Unknown'} • ${day[transaction.datetime.weekday - 1]}  ${transaction.datetime.year}-${transaction.datetime.day}-${transaction.datetime.month}',
        style: TextStyle(fontWeight: FontWeight.w600, color: themeProvider.subtitleColor),
      ),
      trailing: Text(transaction.formattedAmount,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 19,
              color: transaction.isIncome ? Colors.green : Colors.red)),
    );
  }

  Widget _head() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Column(
      children: [
        // Header Background
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: themeProvider.primaryColor,
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 30, left: 15, right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('FlowTrack Project',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 24,
                                color: Colors.white)),
                        SizedBox(height: 4),
                        // แสดงชื่อผู้ใช้ที่โหลดมา
                        Row(
                          children: [
                            Icon(Icons.person, 
                                color: Colors.white.withOpacity(0.9), 
                                size: 14),
                            SizedBox(width: 4),
                            Text(userName,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9))),
                          ],
                        ),
                      ],
                    ),
                    // เพิ่มปุ่ม refresh ชื่อ
                    IconButton(
                      icon: Icon(Icons.refresh, 
                          color: Colors.white.withOpacity(0.8)),
                      onPressed: () async {
                        await _loadUserName();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Profile updated'),
                            duration: Duration(seconds: 1),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // เพิ่มข้อความต้อนรับ
                Text(
                  _getGreeting(),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Cards
        Transform.translate(
          offset: Offset(0, -75),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Main Balance Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                            color: Color.lerp(themeProvider.primaryColor, Colors.black, 0.25) ?? themeProvider.primaryColor,
                          offset: Offset(0, 4),
                          blurRadius: 8,
                          spreadRadius: 1)
                    ],
                    color: themeProvider.primaryColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Balance',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.white)),
                      SizedBox(height: 10),
                      Text('\฿ ${total().toStringAsFixed(2)}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              color: Colors.white)),
                      SizedBox(height: 20),

                      // Income/Expense Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                        radius: 12,
                                        backgroundColor:
                                            Colors.white.withOpacity(0.3),
                                        child: Icon(Icons.arrow_downward,
                                            color: Colors.white, size: 16)),
                                    SizedBox(width: 8),
                                    Text('Income',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            color: Colors.white)),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text('\฿ ${income().toStringAsFixed(2)}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.white)),
                              ],
                            ),
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                        radius: 12,
                                        backgroundColor:
                                            Colors.white.withOpacity(0.3),
                                        child: Icon(Icons.arrow_upward,
                                            color: Colors.white, size: 16)),
                                    SizedBox(width: 8),
                                    Text('Expenses',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            color: Colors.white)),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text(
                                    '\฿ ${expenses().abs().toStringAsFixed(2)}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.white)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Budget Card
                if (monthlyBudget > 0) ...[
                  SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: themeProvider.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: _getBudgetColor().withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                            color: themeProvider.isDarkMode 
                                ? Colors.black26 
                                : Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2))
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getBudgetColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.account_balance_wallet,
                              color: _getBudgetColor(), size: 20),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Monthly Budget',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: themeProvider.textColor)),
                              SizedBox(height: 4),
                              Text(
                                  '${_getBudgetPercentage().toStringAsFixed(0)}% used • \฿${(currentSpent).toStringAsFixed(0)} / \฿${(monthlyBudget).toStringAsFixed(0)}',
                                  style: TextStyle(
                                      fontSize: 12, 
                                      color: themeProvider.subtitleColor)),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: LinearProgressIndicator(
                            value: _getBudgetPercentage() / 100,
                            backgroundColor: themeProvider.dividerColor,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                _getBudgetColor()),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // เพิ่ม method สำหรับแสดงคำทักทายตามเวลา
  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning! ☀️';
    } else if (hour < 17) {
      return 'Good Afternoon! 🌤️';
    } else {
      return 'Good Evening! 🌙';
    }
  }

  double _getBudgetPercentage() {
    if (monthlyBudget <= 0) return 0;
    return (currentSpent / monthlyBudget * 100).clamp(0, 100);
  }

  Color _getBudgetColor() { 
    double percentage = _getBudgetPercentage();
    if (percentage >= 90) return Colors.red;
    if (percentage >= 70) return Colors.orange;
    return Colors.green;
  }
}