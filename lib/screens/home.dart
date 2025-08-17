// lib/screens/home.dart - แก้ไข overflow + เพิ่ม budget
import 'package:flutter/material.dart';
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
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                  child: SizedBox(height: 380, child: _head())), // เพิ่มความสูง
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Transactions History',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      GestureDetector(
                        onTap: () {},
                        child: Text('See All',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.grey)),
                      ),
                    ],
                  ),
                ),
              ),
              transactions.isEmpty
                  ? SliverToBoxAdapter(
                      child: Container(
                        height: 200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No transactions yet',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500)),
                              Text('Add your first transaction to get started',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey)),
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
          _loadData();
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
                  Icon(Icons.help, size: 40, color: Colors.grey)),
        ),
      ),
      title: Text(transaction.description,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      subtitle: Text(
        '${category?.name ?? 'Unknown'} • ${day[transaction.datetime.weekday - 1]}  ${transaction.datetime.year}-${transaction.datetime.day}-${transaction.datetime.month}',
        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[600]),
      ),
      trailing: Text(transaction.formattedAmount,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 19,
              color: transaction.isIncome ? Colors.green : Colors.red)),
    );
  }

  Widget _head() {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              width: double.infinity,
              height: 240,
              decoration: BoxDecoration(
                color: Color(0xFFFFC870),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 30, left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('FlowTrack Project',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 24,
                            color: Colors.white)),
                    Text('Mr.Suppapol Tabudda',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Main Balance Card
        Positioned(
          top: 140,
          left: 37,
          right: 37,
          child: Container(
            height: 170,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: Color.fromARGB(255, 195, 148, 73),
                    offset: Offset(0, 6),
                    blurRadius: 12,
                    spreadRadius: 1)
              ],
              color: Color.fromARGB(255, 255, 200, 112),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Balance',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.white)),
                    ],
                  ),
                  SizedBox(height: 7),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('\$ ${total().toStringAsFixed(2)}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            color: Colors.white)),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                              radius: 13,
                              backgroundColor:
                                  Color.fromARGB(255, 255, 200, 112),
                              child: Icon(Icons.arrow_downward,
                                  color: Colors.white, size: 19)),
                          SizedBox(width: 7),
                          Text('Income',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: Colors.white)),
                        ],
                      ),
                      Row(
                        children: [
                          CircleAvatar(
                              radius: 13,
                              backgroundColor:
                                  Color.fromARGB(255, 255, 200, 112),
                              child: Icon(Icons.arrow_upward,
                                  color: Colors.white, size: 19)),
                          SizedBox(width: 7),
                          Text('Expenses',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 17,
                                  color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$ ${income().toStringAsFixed(2)}',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                              color: Colors.white)),
                      Text('\$ ${expenses().abs().toStringAsFixed(2)}',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                              color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Budget Card
        if (monthlyBudget > 0)
          Positioned(
            top: 320,
            left: 37,
            right: 37,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getBudgetColor().withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2))
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _getBudgetColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.account_balance_wallet,
                          color: _getBudgetColor(), size: 20),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Monthly Budget',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500)),
                          Text(
                                '${_getBudgetPercentage().toStringAsFixed(0)}% used • \$${(monthlyBudget - currentSpent).toStringAsFixed(0)} left',
                              style: TextStyle(
                                  fontSize: 10, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      child: LinearProgressIndicator(
                        value: _getBudgetPercentage() / 100,
                        backgroundColor: Colors.grey.shade200,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(_getBudgetColor()),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
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
