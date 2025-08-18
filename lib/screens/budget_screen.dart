// lib/screens/budget_screen.dart - Updated with Theme Support
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flowtrack/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flowtrack/data/services/database_services.dart';

class BudgetScreen extends StatefulWidget {
  final VoidCallback? onBudgetUpdated;
  const BudgetScreen({super.key, this.onBudgetUpdated});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  double monthlyBudget = 0;
  double currentSpent = 0;
  double weeklyBudget = 0;
  double dailyBudget = 0;

  final TextEditingController budgetController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBudgetData();
  }

  Future<void> _loadBudgetData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      monthlyBudget = prefs.getDouble('monthly_budget') ?? 0;

      DateTime now = DateTime.now();
      DateTime startOfMonth = DateTime(now.year, now.month, 1);
      DateTime endOfMonth = DateTime(now.year, now.month + 1, 0);

      currentSpent = DatabaseService.getTotalExpense(
          startDate: startOfMonth, endDate: endOfMonth);
      weeklyBudget = monthlyBudget / 4;
      dailyBudget = monthlyBudget / 30;

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading budget data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveBudget() async {
    try {
      double newBudget = double.parse(budgetController.text);
      if (newBudget <= 0) throw Exception('Budget must be greater than 0');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('monthly_budget', newBudget);

      setState(() {
        monthlyBudget = newBudget;
        weeklyBudget = newBudget / 4;
        dailyBudget = newBudget / 30;
      });

      budgetController.clear();
      widget.onBudgetUpdated?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Budget updated successfully!'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        title: Text('Budget Settings'),
        backgroundColor: themeProvider.primaryColor,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(
              color: themeProvider.primaryColor,
            ))
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildCurrentBudgetCard(),
                  SizedBox(height: 20),
                  if (monthlyBudget > 0) ...[
                    _buildBudgetBreakdown(),
                    SizedBox(height: 20),
                  ],
                  _buildSetBudgetCard(),
                  SizedBox(height: 20),
                  _buildBudgetTips(),
                ],
              ),
            ),
    );
  }

  Widget _buildCurrentBudgetCard() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    if (monthlyBudget <= 0) {
      return Container(
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
            Icon(Icons.account_balance_wallet, 
                size: 60, 
                color: themeProvider.subtitleColor),
            SizedBox(height: 16),
            Text('No Budget Set',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textColor)),
            Text('Set a monthly budget to track your spending',
                style: TextStyle(color: themeProvider.subtitleColor),
                textAlign: TextAlign.center),
          ],
        ),
      );
    }

    double percentage =
        monthlyBudget > 0 ? (currentSpent / monthlyBudget) * 100 : 0;
    double remaining = monthlyBudget - currentSpent;
    Color progressColor = percentage > 90
        ? Colors.red
        : percentage > 70
            ? Colors.orange
            : Colors.green;

    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Monthly Budget',
                  style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textColor)),
            ],
          ),
          SizedBox(height: 10),
          Text('\฿${monthlyBudget.toStringAsFixed(2)}',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.primaryColor)),
          SizedBox(height: 20),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Spent',
                      style: TextStyle(fontSize: 12, color: themeProvider.subtitleColor)),
                  Text('${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(fontSize: 12, color: themeProvider.subtitleColor)),
                ],
              ),
              SizedBox(height: 5),
              LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: themeProvider.dividerColor,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 8,
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text('Spent',
                      style:
                          TextStyle(color: themeProvider.subtitleColor, fontSize: 12)),
                  Text('\฿${currentSpent.toStringAsFixed(2)}',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red)),
                ],
              ),
              Container(height: 40, width: 1, color: themeProvider.dividerColor),
              Column(
                children: [
                  Text('Remaining',
                      style:
                          TextStyle(color: themeProvider.subtitleColor, fontSize: 12)),
                  Text('\฿${remaining.toStringAsFixed(2)}',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: remaining >= 0 ? Colors.green : Colors.red)),
                ],
              ),
            ],
          ),
          if (percentage > 80)
            Container(
              margin: EdgeInsets.only(top: 15),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: progressColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: progressColor, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      percentage > 100
                          ? 'You have exceeded your budget!'
                          : 'You are close to your budget limit!',
                      style: TextStyle(
                          color: progressColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBudgetBreakdown() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Budget Breakdown',
              style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textColor)),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBudgetItem('Daily', dailyBudget, Icons.today),
              _buildBudgetItem('Weekly', weeklyBudget, Icons.view_week),
              _buildBudgetItem('Monthly', monthlyBudget, Icons.calendar_month),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetItem(String period, double amount, IconData icon) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: themeProvider.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: themeProvider.primaryColor),
        ),
        SizedBox(height: 8),
        Text(period,
            style: TextStyle(color: themeProvider.subtitleColor, fontSize: 12)),
        Text('\฿${amount.toStringAsFixed(0)}',
            style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 16,
                color: themeProvider.textColor)),
      ],
    );
  }

  Widget _buildSetBudgetCard() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Set Monthly Budget',
              style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textColor)),
          SizedBox(height: 15),
          TextField(
            controller: budgetController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: themeProvider.textColor),
            decoration: InputDecoration(
              labelText: 'Monthly Budget Amount',
              labelStyle: TextStyle(color: themeProvider.subtitleColor),
              prefixText: '\฿ ',
              prefixStyle: TextStyle(color: themeProvider.textColor),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: themeProvider.dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: themeProvider.primaryColor, width: 2),
              ),
              filled: true,
              fillColor: themeProvider.backgroundColor,
            ),
          ),
          SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _saveBudget,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Update Budget',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetTips() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withOpacity(themeProvider.isDarkMode ? 0.1 : 1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
            color: Colors.blue.shade200.withOpacity(themeProvider.isDarkMode ? 0.3 : 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.blue.shade600),
              SizedBox(width: 8),
              Text('Budget Tips',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade600)),
            ],
          ),
          SizedBox(height: 10),
          Text(
            '• Set realistic goals based on your income\n'
            '• Track your expenses regularly\n'
            '• Leave room for unexpected expenses\n'
            '• Review and adjust monthly',
            style: TextStyle(color: Colors.blue.shade700, height: 1.5),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    budgetController.dispose();
    super.dispose();
  }
}