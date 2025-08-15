import 'package:flutter/material.dart';
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
    return Scaffold(
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
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                'Statistics',
                style: TextStyle(
                  color: Colors.black,
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
                                ? Color.fromARGB(255, 255, 200, 112)
                                : Colors.white,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            day[index],
                            style: TextStyle(
                              color: index_color == index
                                  ? Colors.white
                                  : Colors.black,
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
                        color: Colors.grey,
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
                      child: Icon(Icons.swap_vert, size: 25, color: Colors.grey),
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
                        Icon(Icons.bar_chart, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No transactions for this period',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add some transactions to see statistics',
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
                delegate: SliverChildBuilderDelegate((context, index) {
                  return buildTransactionTile(a[index]);
                }, childCount: a.length),
              ),
      ],
    );
  }

  Widget buildTransactionTile(Transaction transaction) {
    final category = DatabaseService.getCategoryById(transaction.categoryId);
    final iconName = category?.iconName ?? 'Giftbox';
    
    final List<String> dayNames = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];

    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
          width: 40,
          height: 40,
          child: Image.asset(
            'images/$iconName.png',
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.category, size: 40, color: Colors.grey);
            },
          ),
        ),
      ),
      title: Text(
        transaction.description, // เปลี่ยนจาก category?.name เป็น description
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${category?.name ?? 'Unknown'} • ${dayNames[transaction.datetime.weekday - 1]}  ${transaction.datetime.year}-${transaction.datetime.day}-${transaction.datetime.month}',
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
}