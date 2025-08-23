// lib/screens/home.dart - Updated with Calendar Grid, Budget Limits, and Profile in Header
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flowtrack/screens/theme_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flowtrack/data/services/database_services.dart';
import 'package:flowtrack/data/models/transaction.dart';
import 'package:flowtrack/data/utlity.dart';

class Home extends StatefulWidget {
  final Function(int)? onNavigateToWallet;
  const Home({super.key, this.onNavigateToWallet});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Transaction> recentTransactions = [];
  double monthlyBudget = 0;
  double currentSpent = 0;
  String userName = 'Loading...';
  String userEmail = 'user@email.com';

  // Calendar variables
  DateTime selectedMonth = DateTime.now();
  Map<int, Map<String, double>> monthlyData = {};

  // Period summary variables
  String selectedPeriod = 'Day';
  final List<String> periods = ['Day', 'Week', 'Month'];

  // Goals/Notes
  String currentGoal = '';
  final TextEditingController goalController = TextEditingController();

  final List<String> dayNames = [
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
    _loadUserData();
    _loadCalendarData();
    _loadGoal();

    DatabaseService.transactionStream.listen((transactions) {
      if (mounted) {
        _loadData();
        _loadCalendarData();
      }
    });
  }

  Future<void> _loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        userName = prefs.getString('user_name') ?? 'Mr.Suppapol Tabudda';
        userEmail = prefs.getString('user_email') ?? 'user@email.com';
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadData() async {
    _loadRecentTransactions();
    await _loadBudgetData();
  }

  void _loadRecentTransactions() {
    try {
      // Get transactions from last 7 days, limit to 5
      DateTime sevenDaysAgo = DateTime.now().subtract(Duration(days: 7));

      List<Transaction> allRecent = DatabaseService.getTransactions()
          .where((t) => t.datetime.isAfter(sevenDaysAgo))
          .toList();

      // Sort by most recent first and take only 5
      allRecent.sort((a, b) => b.datetime.compareTo(a.datetime));

      setState(() {
        recentTransactions = allRecent.take(5).toList();
      });
    } catch (e) {
      print('Error loading recent transactions: $e');
      setState(() {
        recentTransactions = [];
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

  void _loadCalendarData() {
    try {
      DateTime startOfMonth =
          DateTime(selectedMonth.year, selectedMonth.month, 1);
      DateTime endOfMonth =
          DateTime(selectedMonth.year, selectedMonth.month + 1, 0);

      List<Transaction> monthTransactions = DatabaseService.getTransactions(
        startDate: startOfMonth,
        endDate: endOfMonth,
      );

      Map<int, Map<String, double>> newMonthlyData = {};

      for (var transaction in monthTransactions) {
        int day = transaction.datetime.day;

        if (!newMonthlyData.containsKey(day)) {
          newMonthlyData[day] = {'income': 0.0, 'expense': 0.0};
        }

        if (transaction.isIncome) {
          newMonthlyData[day]!['income'] =
              newMonthlyData[day]!['income']! + transaction.amount;
        } else {
          newMonthlyData[day]!['expense'] =
              newMonthlyData[day]!['expense']! + transaction.amount;
        }
      }

      setState(() {
        monthlyData = newMonthlyData;
      });
    } catch (e) {
      print('Error loading calendar data: $e');
    }
  }

  Future<void> _loadGoal() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        currentGoal = prefs.getString('current_goal') ?? '';
        goalController.text = currentGoal;
      });
    } catch (e) {
      print('Error loading goal: $e');
    }
  }

  Future<void> _saveGoal() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_goal', goalController.text);
      setState(() {
        currentGoal = goalController.text;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Goal saved!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      print('Error saving goal: $e');
    }
  }

  Map<String, double> getPeriodSummaryWithBudget() {
    DateTime now = DateTime.now();
    DateTime startDate;
    DateTime endDate = now;
    double budgetLimit = 0;

    switch (selectedPeriod) {
      case 'Day':
        startDate = DateTime(now.year, now.month, now.day);
        budgetLimit = monthlyBudget / 30; // daily budget from monthly
        break;
      case 'Week':
        int weekday = now.weekday;
        startDate = now.subtract(Duration(days: weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        budgetLimit = monthlyBudget / 4; // weekly budget from monthly
        break;
      case 'Month':
        startDate = DateTime(now.year, now.month, 1);
        budgetLimit = monthlyBudget; // monthly budget
        break;
      default:
        startDate = DateTime(now.year, now.month, now.day);
        budgetLimit = monthlyBudget / 30;
    }

    List<Transaction> periodTransactions = DatabaseService.getTransactions(
      startDate: startDate,
      endDate: endDate,
    );

    double income = 0;
    double expense = 0;

    for (var transaction in periodTransactions) {
      if (transaction.isIncome) {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }

    return {
      'income': income,
      'expense': expense,
      'net': income - expense,
      'budget': budgetLimit,
    };
  }

  List<DateTime> getCalendarDays() {
    DateTime firstDayOfMonth =
        DateTime(selectedMonth.year, selectedMonth.month, 1);
    DateTime lastDayOfMonth =
        DateTime(selectedMonth.year, selectedMonth.month + 1, 0);

    // Get the first Monday of the calendar (might be from previous month)
    int firstWeekday = firstDayOfMonth.weekday; // 1=Monday, 7=Sunday
    DateTime firstMondayOfCalendar =
        firstDayOfMonth.subtract(Duration(days: firstWeekday - 1));

    List<DateTime> calendarDays = [];
    DateTime currentDay = firstMondayOfCalendar;

    // Generate 42 days (6 weeks * 7 days) to fill the calendar grid
    for (int i = 0; i < 42; i++) {
      calendarDays.add(currentDay);
      currentDay = currentDay.add(Duration(days: 1));
    }

    return calendarDays;
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
            await _loadUserData();
            _loadCalendarData();
            await _loadGoal();
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                SizedBox(height: 12),
                _head(),
                SizedBox(height: 8),
                _buildPeriodSummaryCard(),
                SizedBox(height: 16),
                _buildRecentTransactions(),
                SizedBox(height: 16),
                _buildCalendarCard(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        gradient: themeProvider.primaryGradient,
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: themeProvider.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to profile or show profile options
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            // Profile info
            Row(
              children: [
                Icon(Icons.account_circle,
                    color: Colors.white.withOpacity(0.9), size: 22),
                SizedBox(width: 8),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _head() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Transform.translate(
      offset: Offset(0, 0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                themeProvider.primaryColor,
                themeProvider.primaryColor.withOpacity(0.8),
                if (themeProvider.currentTheme.colors.length > 1)
                  themeProvider.currentTheme.colors[1].withOpacity(0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: themeProvider.primaryColor.withOpacity(0.4),
                offset: Offset(0, 8),
                blurRadius: 20,
                spreadRadius: 2,
              )
            ],
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('\฿ ${total().toStringAsFixed(2)}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.white)),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.arrow_downward,
                                  color: Colors.white, size: 16),
                            ),
                            SizedBox(width: 8),
                            Text('Income',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: Colors.white)),
                          ],
                        ),
                        SizedBox(height: 5),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: Text('\฿ ${income().toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.white)),
                        ),
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
                            Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.arrow_upward,
                                  color: Colors.white, size: 16),
                            ),
                            SizedBox(width: 8),
                            Text('Expenses',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: Colors.white)),
                          ],
                        ),
                        SizedBox(height: 5),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: Text(
                              '\฿ ${expenses().abs().toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Goal Section
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.flag, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'My Goal',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 4),
                        IconButton(
                          icon: Icon(Icons.edit, size: 16, color: Colors.white),
                          onPressed: () => _showGoalDialog(),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      currentGoal.isEmpty
                          ? 'Tap edit to set your goal'
                          : currentGoal,
                      style: TextStyle(
                        color: currentGoal.isEmpty
                            ? Colors.white.withOpacity(0.7)
                            : Colors.white,
                        fontSize: 13,
                        fontStyle: currentGoal.isEmpty
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSummaryCard() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final summary = getPeriodSummaryWithBudget();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: themeProvider.isDarkMode
                ? Colors.black26
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          // Period Selector
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themeProvider.primaryColor.withOpacity(0.1),
                  themeProvider.primaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: themeProvider.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          Icon(Icons.bar_chart, color: Colors.white, size: 16),
                    ),
                    SizedBox(width: 16),
                    Text(
                      'Period Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: themeProvider.backgroundColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: periods.map((period) {
                      bool isSelected = selectedPeriod == period;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedPeriod = period;
                          });
                        },
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? themeProvider.primaryGradient
                                : null,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            period,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : themeProvider.textColor,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 8,
          ),

          // Budget Summary
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Income
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: themeProvider.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${selectedPeriod} Income',
                        style: TextStyle(
                          color: themeProvider.textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade400,
                              Colors.green.shade600
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '\฿${summary['income']!.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),

                // Expense vs Budget
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: themeProvider.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${selectedPeriod} Expense',
                            style: TextStyle(
                              color: themeProvider.textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '\฿${summary['expense']!.toStringAsFixed(0)} / \฿${summary['budget']!.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: themeProvider.subtitleColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: themeProvider.dividerColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: summary['budget']! > 0
                                ? (summary['expense']! / summary['budget']!)
                                    .clamp(0.0, 1.0)
                                : 0.0,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors:
                                      summary['expense']! > summary['budget']!
                                          ? [
                                              Colors.red.shade400,
                                              Colors.red.shade600
                                            ]
                                          : [
                                              Colors.blue.shade400,
                                              Colors.blue.shade600
                                            ],
                                ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),

                // Net Amount
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: themeProvider.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Net Amount (Income - Expense)',
                        style: TextStyle(
                          color: themeProvider.textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: summary['net']! >= 0
                                ? [Colors.green.shade400, Colors.green.shade600]
                                : [Colors.red.shade400, Colors.red.shade600],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${summary['net']! >= 0 ? '+' : ''}\฿${summary['net']!.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 16,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: themeProvider.isDarkMode
                ? Colors.black26
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themeProvider.primaryColor.withOpacity(0.1),
                  themeProvider.primaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: themeProvider.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.history, color: Colors.white, size: 16),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Recent Transactions (7 days)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textColor,
                      ),
                    ),
                  ],
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      if (widget.onNavigateToWallet != null) {
                        widget.onNavigateToWallet!(2);
                      }
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: themeProvider.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'See All',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 10,
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
          recentTransactions.isEmpty
              ? Container(
                  height: 100,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox,
                            size: 32, color: themeProvider.subtitleColor),
                        SizedBox(height: 8),
                        Text(
                          'No recent transactions',
                          style: TextStyle(
                            fontSize: 14,
                            color: themeProvider.subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: recentTransactions.map((transaction) {
                    final category =
                        DatabaseService.getCategoryById(transaction.categoryId);
                    final iconName = category?.iconName ?? 'Giftbox';

                    return Dismissible(
                        key: Key(transaction.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Colors.red.shade400,
                              Colors.red.shade600
                            ]),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: themeProvider.cardColor,
                              title: Text('Delete Transaction',
                                  style: TextStyle(
                                      color: themeProvider.textColor)),
                              content: Text(
                                  'Are you sure you want to delete this transaction?\n\n"${transaction.description}"',
                                  style: TextStyle(
                                      color: themeProvider.textColor)),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text('Cancel')),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [
                                      Colors.red.shade400,
                                      Colors.red.shade600
                                    ]),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                    ),
                                    child: Text('Delete',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) async {
                          try {
                            await DatabaseService.deleteTransaction(
                                transaction.id);
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
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: themeProvider.primaryColor
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Image.asset(
                                      'images/$iconName.png',
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
                                              Icons.help,
                                              size: 20,
                                              color:
                                                  themeProvider.primaryColor),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      transaction.description,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: themeProvider.textColor,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${category?.name ?? 'Unknown'} • ${_formatTransactionDate(transaction.datetime)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: themeProvider.subtitleColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: transaction.isIncome
                                      ? LinearGradient(colors: [
                                          Colors.green.shade400,
                                          Colors.green.shade600
                                        ])
                                      : LinearGradient(colors: [
                                          Colors.red.shade400,
                                          Colors.red.shade600
                                        ]),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  transaction.formattedAmount,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ));
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final calendarDays = getCalendarDays();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: themeProvider.isDarkMode
                ? Colors.black26
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          // Month Navigation
          Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    themeProvider.primaryColor.withOpacity(0.1),
                    themeProvider.primaryColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: themeProvider.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.calendar_month,
                            color: Colors.white, size: 16),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Monthly Calendar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.textColor,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left,
                            color: themeProvider.primaryColor),
                        onPressed: () {
                          setState(() {
                            selectedMonth = DateTime(
                                selectedMonth.year, selectedMonth.month - 1);
                          });
                          _loadCalendarData();
                        },
                      ),
                      Text(
                        '${_getMonthName(selectedMonth.month)} ${selectedMonth.year}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: themeProvider.textColor,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_right,
                            color: themeProvider.primaryColor),
                        onPressed: () {
                          setState(() {
                            selectedMonth = DateTime(
                                selectedMonth.year, selectedMonth.month + 1);
                          });
                          _loadCalendarData();
                        },
                      ),
                    ],
                  ),
                ],
              )),
          // Day headers (Mon-Sun)
          Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children:
                  ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) {
                return Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        color: themeProvider.subtitleColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Calendar Grid
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            height: 300,
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: 35, // 5 weeks * 7 days (ครอบคลุมเดือนเต็ม)
              itemBuilder: (context, index) {
                DateTime day = calendarDays[index];
                bool isCurrentMonth = day.month == selectedMonth.month;
                bool isToday = day.day == DateTime.now().day &&
                    day.month == DateTime.now().month &&
                    day.year == DateTime.now().year;

                Map<String, double>? dayData = monthlyData[day.day];
                bool hasTransactions = dayData != null && isCurrentMonth;

                return Container(
                  decoration: BoxDecoration(
                    color: isToday
                        ? themeProvider.primaryColor.withOpacity(0.2)
                        : (hasTransactions
                            ? themeProvider.backgroundColor
                            : Colors.transparent),
                    borderRadius: BorderRadius.circular(4),
                    border: isToday
                        ? Border.all(
                            color: themeProvider.primaryColor, width: 1)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          color: !isCurrentMonth
                              ? themeProvider.subtitleColor.withOpacity(0.3)
                              : (isToday
                                  ? themeProvider.primaryColor
                                  : themeProvider.textColor),
                          fontSize: 10,
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (hasTransactions) ...[
                        SizedBox(height: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (dayData['income']! > 0)
                              Container(
                                width: 2,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            if (dayData['income']! > 0 &&
                                dayData['expense']! > 0)
                              SizedBox(width: 1),
                            if (dayData['expense']! > 0)
                              Container(
                                width: 2,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        if (dayData['income']! > 0 ||
                            dayData['expense']! > 0) ...[
                          SizedBox(height: 1),
                          if (dayData['income']! > 0)
                            Text(
                              '+${dayData['income']!.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 6,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (dayData['expense']! > 0)
                            Text(
                              '-${dayData['expense']!.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 6,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          // Legend
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Income',
                      style: TextStyle(
                        color: themeProvider.subtitleColor,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 16),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Expense',
                      style: TextStyle(
                        color: themeProvider.subtitleColor,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showGoalDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: themeProvider.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.flag, color: Colors.white, size: 20),
            ),
            SizedBox(width: 12),
            Text(
              'Set Goal',
              style: TextStyle(color: themeProvider.textColor),
            ),
          ],
        ),
        content: TextField(
          controller: goalController,
          style: TextStyle(color: themeProvider.textColor),
          maxLength: 100,
          decoration: InputDecoration(
            labelText: 'What do you want to achieve?',
            labelStyle: TextStyle(color: themeProvider.subtitleColor),
            hintText: 'e.g. Save ฿10,000 for new laptop',
            hintStyle:
                TextStyle(color: themeProvider.subtitleColor.withOpacity(0.7)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: themeProvider.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: themeProvider.primaryColor, width: 2),
            ),
            filled: true,
            fillColor: themeProvider.backgroundColor,
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: themeProvider.subtitleColor)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: themeProvider.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ElevatedButton(
              onPressed: () {
                _saveGoal();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Save',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

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

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  String _formatTransactionDate(DateTime date) {
    DateTime now = DateTime.now();
    Duration difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
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
  