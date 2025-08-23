// lib/screens/add.dart - Super Compact Working Version
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flowtrack/screens/theme_settings.dart';
import 'package:flowtrack/data/services/database_services.dart';
import 'package:flowtrack/data/models/transaction.dart';
import 'package:flowtrack/data/models/category.dart';

class Add_Screen extends StatefulWidget {
  const Add_Screen({super.key});
  @override
  State<Add_Screen> createState() => _Add_ScreenState();
}

class _Add_ScreenState extends State<Add_Screen> {
  DateTime date = DateTime.now();
  Category? selectedCategory;
  String selectedType = "Expense";
  final descController = TextEditingController();
  final amountController = TextEditingController();
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    setState(() {
      categories = DatabaseService.getCategories(type: selectedType);
      selectedCategory = categories.isNotEmpty ? categories.first : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: theme.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      Text(
                        'Add Transaction',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.attach_file, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Form Container
            Expanded(
              child: Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: theme.isDarkMode ? Colors.black26 : Colors.grey.withOpacity(0.1),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Type Selector
                    Row(
                      children: ['Expense', 'Income'].map((type) => 
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: type == 'Expense' ? 5 : 0, left: type == 'Income' ? 5 : 0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedType = type;
                                  _loadCategories();
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                decoration: BoxDecoration(
                                  gradient: selectedType == type ? theme.primaryGradient : null,
                                  color: selectedType == type ? null : theme.cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selectedType == type ? Colors.transparent : theme.dividerColor,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  type,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: selectedType == type ? Colors.white : theme.textColor,
                                    fontWeight: selectedType == type ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ).toList(),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Category Dropdown
                    DropdownButtonFormField<Category>(
                      value: selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        labelStyle: TextStyle(color: theme.subtitleColor),
                        // prefixIcon: Icon(Icons.category, color: theme.primaryColor),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: theme.dividerColor, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: theme.primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: theme.cardColor,
                      ),
                      dropdownColor: theme.cardColor,
                      style: TextStyle(color: theme.textColor),
                      items: categories.map((category) => DropdownMenuItem<Category>(
                        value: category,
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              child: Image.asset(
                                'images/${category.iconName}.png',
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.category, size: 20, color: theme.subtitleColor),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(category.name),
                          ],
                        ),
                      )).toList(),
                      onChanged: (Category? newValue) {
                        setState(() => selectedCategory = newValue);
                      },
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Description Field
                    TextField(
                      controller: descController,
                      style: TextStyle(color: theme.textColor),
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(color: theme.subtitleColor),
                        prefixIcon: Icon(Icons.description, color: theme.primaryColor),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: theme.dividerColor, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: theme.primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: theme.cardColor,
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Amount Field
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: theme.textColor),
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        labelStyle: TextStyle(color: theme.subtitleColor),
                        prefixIcon: Icon(Icons.attach_money, color: theme.primaryColor),
                        prefixText: '฿ ',
                        prefixStyle: TextStyle(color: theme.textColor),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: theme.dividerColor, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: theme.primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: theme.cardColor,
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Date Picker
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: theme.dividerColor, width: 2),
                        color: theme.cardColor,
                      ),
                      child: InkWell(
                        onTap: () async {
                          DateTime? newDate = await showDatePicker(
                            context: context,
                            initialDate: date,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (newDate != null) {
                            setState(() => date = newDate);
                          }
                        },
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: theme.primaryColor),
                            SizedBox(width: 15),
                            Text(
                              'Date: ${date.day}/${date.month}/${date.year}',
                              style: TextStyle(fontSize: 16, color: theme.textColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    Spacer(),
                    
                    // Save Button
                    Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: theme.primaryGradient,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.4),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _saveTransaction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: Text(
                          'Save Transaction',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTransaction() async {
    if (selectedCategory == null || amountController.text.isEmpty || descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      double amount = double.parse(amountController.text);
      
      var transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: selectedCategory!.id,
        amount: amount,
        datetime: date,
        description: descController.text,
        type: selectedType,
      );

      await DatabaseService.addTransaction(transaction);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaction saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    descController.dispose();
    amountController.dispose();
    super.dispose();
  }
}