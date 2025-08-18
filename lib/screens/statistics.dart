// lib/screens/statistics.dart - Updated with Advanced Sorting
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flowtrack/providers/theme_provider.dart';
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
  
  // เพิ่มตัวแปรสำหรับการเรียงลำดับ
  String sortType = 'amount_desc'; // ค่าเริ่มต้น: ใช้มากสุดไปน้อยสุด
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
          a = List.from(f[index_color]); // สร้าง copy เพื่อไม่ให้กระทบข้อมูลต้นฉบับ
          _sortTransactions(); // เรียงลำดับตาม sortType ปัจจุบัน
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
                  color: themeProvider.dividerColor,
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
              Divider(color: themeProvider.dividerColor),
              ...sortOptions.map((option) => ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: sortType == option['value'] 
                        ? themeProvider.primaryColor.withOpacity(0.1)
                        : themeProvider.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    option['icon'],
                    color: sortType == option['value'] 
                        ? themeProvider.primaryColor 
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
                    ? Icon(Icons.check_circle, color: themeProvider.primaryColor)
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

  CustomScrollView custom() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                'Statistics',
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
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
                        child: Container(
                          height: 40,
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: index_color == index
                                ? themeProvider.primaryColor
                                : themeProvider.cardColor,
                            boxShadow: index_color == index
                                ? [
                                    BoxShadow(
                                      color: themeProvider.primaryColor
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            day[index],
                            style: TextStyle(
                              color: index_color == index
                                  ? Colors.white
                                  : themeProvider.textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              SizedBox(height: 20),
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
                    // ปุ่มเรียงลำดับที่สวยขึ้น
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: _showSortOptions,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: themeProvider.primaryColor.withOpacity(0.5),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            color: themeProvider.primaryColor.withOpacity(0.1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                sortOptions.firstWhere(
                                  (opt) => opt['value'] == sortType
                                )['icon'],
                                size: 16,
                                color: themeProvider.primaryColor,
                              ),
                              SizedBox(width: 6),
                              Text(
                                sortOptions.firstWhere(
                                  (opt) => opt['value'] == sortType
                                )['label'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: themeProvider.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_drop_down,
                                size: 18,
                                color: themeProvider.primaryColor,
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
                        Icon(Icons.bar_chart,
                            size: 64, color: themeProvider.subtitleColor),
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
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
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
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.category,
                      size: 25, color: themeProvider.primaryColor);
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
            color: transaction.isIncome
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            transaction.formattedAmount,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: transaction.isIncome ? Colors.green : Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}