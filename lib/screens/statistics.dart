// lib/screens/statistics.dart - Updated with Summary Boxes
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flowtrack/screens/theme_settings.dart';
import 'package:flowtrack/data/utlity.dart';
import 'package:flowtrack/widgets/chart.dart';
import 'package:flowtrack/data/models/transaction.dart';
import 'package:flowtrack/data/services/database_services.dart';

class Statistics extends StatefulWidget {
  const Statistics({super.key});

  @override
  State<Statistics> createState() => _StatisticsState();
}

ValueNotifier kj = ValueNotifier(0);

class _StatisticsState extends State<Statistics> {
  List<String> day = ['Day', 'Week', 'Month', 'Year'];
  List<List<Transaction>> f = [];
  List<Transaction> a = [];
  int index_color = 0;
  
  String sortType = 'amount_desc';
  final List<Map<String, dynamic>> sortOptions = [
    {'value': 'amount_desc', 'label': 'Highest Amount', 'icon': Icons.arrow_downward},
    {'value': 'amount_asc', 'label': 'Lowest Amount', 'icon': Icons.arrow_upward},
    {'value': 'date_desc', 'label': 'Most Recent', 'icon': Icons.calendar_today},
    {'value': 'date_asc', 'label': 'Oldest First', 'icon': Icons.history},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    try {
      setState(() {
        f = [today(), week(), month(), year()];
        if (f.isNotEmpty && index_color < f.length) {
          a = List.from(f[index_color]);
          _sortTransactions();
        } else {
          a = [];
        }
      });
    } catch (e) {
      print('Error loading statistics data: $e');
      setState(() {
        f = [[], [], [], []];
        a = [];
      });
    }
  }

  void _sortTransactions() {
    switch (sortType) {
      case 'amount_desc':
        a.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'amount_asc':
        a.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case 'date_desc':
        a.sort((a, b) => b.datetime.compareTo(a.datetime));
        break;
      case 'date_asc':
        a.sort((a, b) => a.datetime.compareTo(b.datetime));
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
                  'Sort Transactions',
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
              ...sortOptions.map((option) => ListTile(
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
                    _sortTransactions();
                  });
                  Navigator.pop(context);
                },
              )).toList(),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummarySection() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    if (a.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        child: Center(
          child: Text(
            'No data for ${day[index_color].toLowerCase()}',
            style: TextStyle(
              color: themeProvider.subtitleColor,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    double totalIncome = a.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.amount);
    double totalExpense = a.where((t) => t.isExpense).fold(0.0, (sum, t) => sum + t.amount);
    double netAmount = totalIncome - totalExpense;
    int totalTransactions = a.length;

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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text('Income',
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
                    child: Text('\฿${totalIncome.toStringAsFixed(2)}',
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
                  Text('Expense',
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
                    child: Text('\฿${totalExpense.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          Divider(color: themeProvider.dividerColor),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text('Net Amount',
                      style: TextStyle(
                          color: themeProvider.subtitleColor, fontSize: 14)),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: netAmount >= 0
                          ? LinearGradient(colors: [Colors.green.shade400, Colors.green.shade600])
                          : LinearGradient(colors: [Colors.red.shade400, Colors.red.shade600]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('${netAmount >= 0 ? '+' : ''}\฿${netAmount.toStringAsFixed(2)}',
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
                      gradient: themeProvider.primaryGradient,
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
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _loadData();
          },
          child: ValueListenableBuilder(
            valueListenable: kj,
            builder: (context, dynamic value, child) {
              if (value < f.length) {
                a = List.from(f[value]);
                _sortTransactions();
              }
              return custom();
            },
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
          Text('Statistics',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          SizedBox(height: 8),
          Text('Transaction Analytics & Insights',
              style: TextStyle(
                  fontSize: 14, color: Colors.white.withOpacity(0.9))),
        ],
      ),
    );
  }

  CustomScrollView custom() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverToBoxAdapter(
          child: Column(
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ...List.generate(4, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            index_color = index;
                            kj.value = index;
                            _loadData();
                          });
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          height: 40,
                          width: 80,
                          decoration: BoxDecoration(
                            gradient: index_color == index
                                ? themeProvider.primaryGradient
                                : null,
                            color: index_color == index
                                ? null
                                : themeProvider.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: index_color == index
                                ? [
                                    BoxShadow(
                                      color: themeProvider.primaryColor.withOpacity(0.4),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: themeProvider.isDarkMode
                                          ? Colors.black26
                                          : Colors.grey.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            day[index],
                            style: TextStyle(
                              color: index_color == index
                                  ? Colors.white
                                  : themeProvider.textColor,
                              fontSize: 16,
                              fontWeight: index_color == index
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              SizedBox(height: 20),
              _buildSummarySection(),
              SizedBox(height: 10),
              Chart(indexx: index_color),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Top Spending',
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
                                  (opt) => opt['value'] == sortType
                                )['icon'],
                                size: 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: 6),
                              Text(
                                sortOptions.firstWhere(
                                  (opt) => opt['value'] == sortType
                                )['label'],
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
              ),
            ],
          ),
        ),
        a.isEmpty
            ? SliverToBoxAdapter(
                child: Container(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: themeProvider.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.bar_chart, size: 40, color: Colors.white),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No transactions for this period',
                          style: TextStyle(
                            fontSize: 18,
                            color: themeProvider.subtitleColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add some transactions to see statistics',
                          style: TextStyle(
                            fontSize: 14,
                            color: themeProvider.subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return buildTransactionTile(a[index]);
                }, childCount: a.length),
              ),
      ],
    );
  }

  Widget buildTransactionTile(Transaction transaction) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final category = DatabaseService.getCategoryById(transaction.categoryId);
    final iconName = category?.iconName ?? 'Giftbox';

    final List<String> dayNames = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: themeProvider.isDarkMode
                ? Colors.black26
                : Colors.grey.withOpacity(0.08),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: themeProvider.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Image.asset(
                'images/$iconName.png',
                // ไม่เปลี่ยนสีไอคอน - ใช้สีเดิม
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.category, size: 25, color: themeProvider.primaryColor);
                },
              ),
            ),
          ),
        ),
        title: Text(
          transaction.description,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: themeProvider.textColor,
          ),
        ),
        subtitle: Text(
          '${category?.name ?? 'Unknown'} • ${dayNames[transaction.datetime.weekday - 1]}  ${transaction.datetime.day}/${transaction.datetime.month}/${transaction.datetime.year}',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: themeProvider.subtitleColor,
            fontSize: 13,
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: transaction.isIncome
                ? LinearGradient(colors: [Colors.green.shade400, Colors.green.shade600])
                : LinearGradient(colors: [Colors.red.shade400, Colors.red.shade600]),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            transaction.formattedAmount,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}