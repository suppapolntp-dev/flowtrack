import 'package:flutter/material.dart';
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
  final List<String> day = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _loadTransactions();
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(height: 340, child: _head()),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transactions History',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: Navigate to all transactions
                        },
                        child: Text(
                          'See All',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
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
                              Text(
                                'No transactions yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Add your first transaction to get started',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return getList(transactions[index], index);
                        },
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
          _loadTransactions(); // Refresh list
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
          child: Image.asset(
            'images/$iconName.png',
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.help, size: 40, color: Colors.grey);
            },
          ),
        ),
      ),
      title: Text(
        transaction.description, // เปลี่ยนจาก category?.name เป็น description
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${category?.name ?? 'Unknown'} • ${day[transaction.datetime.weekday - 1]}  ${transaction.datetime.year}-${transaction.datetime.day}-${transaction.datetime.month}',
        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[600]),
      ),
      trailing: Text(
        transaction.formattedAmount,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 19,
          color: transaction.isIncome ? Colors.green : Colors.red,
        ),
      ),
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
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 30, left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FlowTrack Project',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Mr.Suppapol Tabudda',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: 140,
          left: 37,
          child: Container(
            height: 170,
            width: 320,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(255, 195, 148, 73),
                  offset: Offset(0, 6),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
              color: Color.fromARGB(255, 255, 200, 112),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Balance',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 7),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Row(
                    children: [
                      Text(
                        '\$ ${total().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 13,
                            backgroundColor: Color.fromARGB(255, 255, 200, 112),
                            child: Icon(
                              Icons.arrow_downward,
                              color: Colors.white,
                              size: 19,
                            ),
                          ),
                          SizedBox(width: 7),
                          Text(
                            'Income',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 13,
                            backgroundColor: Color.fromARGB(255, 255, 200, 112),
                            child: Icon(
                              Icons.arrow_upward,
                              color: Colors.white,
                              size: 19,
                            ),
                          ),
                          SizedBox(width: 7),
                          Text(
                            'Expenses',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 17,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$ ${income().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '\$ ${expenses().abs().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
