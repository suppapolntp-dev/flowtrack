// lib/screens/statistics.dart - Updated with Theme Support
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    try {
      setState(() {
        f = [today(), week(), month(), year()];
        // เลือกข้อมูลตาม index_color
        if (f.isNotEmpty && index_color < f.length) {
          a = f[index_color];
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
                a = f[value];
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
                            _loadData(); // โหลดข้อมูลใหม่
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
                    GestureDetector(
                      onTap: () {
                        // สลับการเรียงลำดับ
                        setState(() {
                          a.sort((a, b) => b.amount.compareTo(a.amount));
                        });
                      },
                      child: Icon(Icons.swap_vert,
                          size: 25, color: themeProvider.subtitleColor),
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
