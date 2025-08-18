// lib/screens/add.dart - Updated with Theme Support
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flowtrack/providers/theme_provider.dart';
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
  String selectedType = "Expense"; // เริ่มต้นเป็น Expense
  final TextEditingController expalin_C = TextEditingController();
  FocusNode ex = FocusNode();
  final TextEditingController amount_c = TextEditingController();
  FocusNode amount_ = FocusNode();

  List<Category> availableCategories = [];
  final List<String> _itemei = ['Expense', 'Income'];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    ex.addListener(() {
      setState(() {});
    });
    amount_.addListener(() {
      setState(() {});
    });
  }

  void _loadCategories() {
    setState(() {
      availableCategories = DatabaseService.getCategories(type: selectedType);
      // เลือกหมวดหมู่แรกเป็นค่าเริ่มต้น
      if (availableCategories.isNotEmpty) {
        selectedCategory = availableCategories.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: SafeArea(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            background_container(context),
            Positioned(top: 120, child: main_container()),
          ],
        ),
      ),
    );
  }

  Container main_container() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: themeProvider.cardColor,
        boxShadow: [
          BoxShadow(
            color: themeProvider.isDarkMode
                ? Colors.black26
                : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      height: 550,
      width: 340,
      child: Column(
        children: [
          SizedBox(height: 50),
          typeSelector(),
          SizedBox(height: 30),
          categorySelector(),
          SizedBox(height: 30),
          explain(),
          SizedBox(height: 30),
          amount(),
          SizedBox(height: 30),
          date_time(),
          Spacer(),
          save(),
          SizedBox(height: 25),
        ],
      ),
    );
  }

  Widget typeSelector() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: _itemei
            .map((item) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedType = item;
                          _loadCategories(); // โหลดหมวดหมู่ใหม่ตามประเภท
                        });
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              width: 2,
                              color: selectedType == item
                                  ? themeProvider.primaryColor
                                  : themeProvider.inputBorderColor),
                          color: selectedType == item
                              ? themeProvider.primaryColor.withOpacity(0.1)
                              : themeProvider.inputFillColor,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(item,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: selectedType == item
                                      ? themeProvider.primaryColor
                                      : themeProvider.textColor,
                                  fontWeight: selectedType == item
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                )),
                            SizedBox(width: 5),
                            if (selectedType == item)
                              Icon(Icons.check_circle,
                                  color: themeProvider.primaryColor, size: 20)
                            else
                              Icon(Icons.radio_button_unchecked,
                                  color: themeProvider.subtitleColor, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget categorySelector() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InputDecorator(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          labelText: 'Category',
          labelStyle:
              TextStyle(fontSize: 17, color: themeProvider.subtitleColor),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(width: 2, color: themeProvider.inputBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 2, color: themeProvider.primaryColor),
          ),
          filled: true,
          fillColor: themeProvider.inputFillColor,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Category>(
            value: selectedCategory,
            dropdownColor: themeProvider.cardColor,
            style: TextStyle(color: themeProvider.textColor),
            iconEnabledColor: themeProvider.textColor,
            onChanged: (Category? newValue) {
              setState(() {
                selectedCategory = newValue;
              });
            },
            items: availableCategories.map((Category category) {
              return DropdownMenuItem<Category>(
                value: category,
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      child: Image.asset(
                        'images/${category.iconName}.png',
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.category,
                              size: 30, color: themeProvider.subtitleColor);
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(category.name,
                        style: TextStyle(
                            fontSize: 16, color: themeProvider.textColor)),
                  ],
                ),
              );
            }).toList(),
            hint: Text('Select category',
                style: TextStyle(color: themeProvider.subtitleColor)),
            isExpanded: true,
          ),
        ),
      ),
    );
  }

  GestureDetector save() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return GestureDetector(
      onTap: () async {
        if (selectedCategory == null ||
            amount_c.text.isEmpty ||
            expalin_C.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please fill in all required fields'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        try {
          double amount = double.parse(amount_c.text);

          var transaction = Transaction(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            categoryId: selectedCategory!.id,
            amount: amount,
            datetime: date,
            description: expalin_C.text,
            type: selectedType,
          );

          await DatabaseService.addTransaction(transaction);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Data saved successfully'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.of(context).pop();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: themeProvider.primaryColor,
          boxShadow: [
            BoxShadow(
              color: themeProvider.primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        width: 120,
        height: 50,
        child: Text(
          'Save',
          style: TextStyle(
            fontFamily: 'f',
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 17,
          ),
        ),
      ),
    );
  }

  Widget date_time() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      alignment: Alignment.bottomLeft,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 2, color: themeProvider.inputBorderColor),
        color: themeProvider.inputFillColor,
      ),
      width: 300,
      child: TextButton(
        onPressed: () async {
          DateTime? newDate = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: themeProvider.primaryColor,
                    onPrimary: Colors.white,
                    surface: themeProvider.cardColor,
                    onSurface: themeProvider.textColor,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (newDate != null) {
            setState(() {
              date = newDate;
            });
          }
        },
        child: Text(
          'Date : ${date.year} / ${date.day} / ${date.month}',
          style: TextStyle(fontSize: 15, color: themeProvider.textColor),
        ),
      ),
    );
  }

  Padding amount() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        keyboardType: TextInputType.number,
        focusNode: amount_,
        controller: amount_c,
        style: TextStyle(color: themeProvider.textColor),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          labelText: 'amount',
          labelStyle:
              TextStyle(fontSize: 17, color: themeProvider.subtitleColor),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(width: 2, color: themeProvider.inputBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 2, color: themeProvider.primaryColor),
          ),
          filled: true,
          fillColor: themeProvider.inputFillColor,
        ),
      ),
    );
  }

  Padding explain() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        focusNode: ex,
        controller: expalin_C,
        style: TextStyle(color: themeProvider.textColor),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          labelText: 'explain',
          labelStyle:
              TextStyle(fontSize: 17, color: themeProvider.subtitleColor),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(width: 2, color: themeProvider.inputBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 2, color: themeProvider.primaryColor),
          ),
          filled: true,
          fillColor: themeProvider.inputFillColor,
        ),
      ),
    );
  }

  Column background_container(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 240,
          decoration: BoxDecoration(
            color: themeProvider.primaryColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 40),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Text(
                      'Adding',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Icon(Icons.attach_file_outlined, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
