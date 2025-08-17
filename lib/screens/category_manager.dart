// lib/screens/category_manager.dart - แก้ไขสมบูรณ์
import 'package:flutter/material.dart';
import 'package:flowtrack/data/models/category.dart';
import 'package:flowtrack/data/services/database_services.dart';

class CategoryManagerScreen extends StatefulWidget {
  const CategoryManagerScreen({super.key});

  @override
  State<CategoryManagerScreen> createState() => _CategoryManagerScreenState();
}

class _CategoryManagerScreenState extends State<CategoryManagerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Category> expenseCategories = [];
  List<Category> incomeCategories = [];
  bool isLoading = false;

  // สีที่ใช้ได้
  final List<Color> availableColors = [
    const Color(0xFFFF6B6B), // Red
    const Color(0xFF4ECDC4), // Teal
    const Color(0xFF45B7D1), // Blue
    const Color(0xFF96CEB4), // Green
    const Color(0xFFFFEAA7), // Yellow
    const Color(0xFFDDA0DD), // Purple
    const Color(0xFF98D8C8), // Mint
    const Color(0xFFF39C12), // Orange
    const Color(0xFF2ECC71), // Success Green
    const Color(0xFFE74C3C), // Red
    const Color(0xFF9B59B6), // Purple
    const Color(0xFF34495E), // Dark
  ];

  // ไอคอนที่ใช้ได้ - อัปเดตตามรูปที่มี
  final List<String> availableIcons = [
    'Food', 'Coffee', 'Grocery', 'Food-delivery', 'Gas-pump',
    'Public Transport', 'Rent or Mortgage', 'Water Bill', 
    'Electricity Bill', 'Internet Bill', 'Clothes', 'Shoes',
    'Accessories', 'Personal Care Items', 'Movie', 'Concert',
    'Hobby', 'Travel', 'Health-Report', 'Doctor VisitsHospital',
    'Education', 'Bank Fees', 'Giftbox', 'Donation',
    'salary', 'commission', 'freelanceincome', 'dividends', 
    'interest', 'rentalincome', 'taxrefunds'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      isLoading = true;
    });

    try {
      await Future.delayed(Duration(milliseconds: 300)); // UX delay
      expenseCategories = DatabaseService.getAllCategories(type: 'Expense');
      incomeCategories = DatabaseService.getAllCategories(type: 'Income');
      print('Loaded: ${expenseCategories.length} expense, ${incomeCategories.length} income categories');
    } catch (e) {
      print('Error loading categories: $e');
      _showSnackBar('Error loading categories: $e', Colors.red);
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Category Manager',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFFC870),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'sort_name') {
                setState(() {
                  expenseCategories.sort((a, b) => a.name.compareTo(b.name));
                  incomeCategories.sort((a, b) => a.name.compareTo(b.name));
                });
              } else if (value == 'sort_date') {
                setState(() {
                  expenseCategories.sort((a, b) => a.createdAt.compareTo(b.createdAt));
                  incomeCategories.sort((a, b) => a.createdAt.compareTo(b.createdAt));
                });
              } else if (value == 'refresh') {
                _loadCategories();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(value: 'sort_name', child: Text('Sort by Name')),
              PopupMenuItem(value: 'sort_date', child: Text('Sort by Date')),
              PopupMenuDivider(),
              PopupMenuItem(value: 'refresh', child: Text('Refresh')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              text: 'Expenses (${expenseCategories.length})', 
              icon: Icon(Icons.remove_circle_outline),
            ),
            Tab(
              text: 'Income (${incomeCategories.length})', 
              icon: Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCategoryList(expenseCategories, 'Expense'),
                _buildCategoryList(incomeCategories, 'Income'),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategoryDialog(),
        backgroundColor: const Color(0xFFFFC870),
        icon: const Icon(Icons.add),
        label: Text('Add Category'),
      ),
    );
  }

  Widget _buildCategoryList(List<Category> categories, String type) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'Expense' ? Icons.remove_circle_outline : Icons.add_circle_outline,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No ${type.toLowerCase()} categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap + to add your first category',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCategories,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return _buildCategoryCard(categories[index]);
        },
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    final color = Color(int.parse('0xFF${category.colorHex.substring(1)}'));
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _buildCategoryIcon(category.iconName, color),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(category.type),
            if (category.budgetLimit != null) ...[
              SizedBox(height: 4),
              Text(
                'Budget: \$${category.budgetLimit!.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.green[600], fontSize: 12),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditCategoryDialog(category),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteConfirmation(category),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(String iconName, Color color) {
    // ลองใช้ Image asset ก่อน ถ้าไม่ได้ใช้ Icon
    return Image.asset(
      'images/$iconName.png',
      width: 24,
      height: 24,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.category, color: color, size: 24);
      },
    );
  }

  void _showAddCategoryDialog() {
    final String currentType = _tabController.index == 0 ? 'Expense' : 'Income';
    _showCategoryDialog(null, currentType);
  }

  void _showEditCategoryDialog(Category category) {
    _showCategoryDialog(category, category.type);
  }

  void _showCategoryDialog(Category? category, String type) {
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    final budgetController = TextEditingController(
      text: category?.budgetLimit?.toString() ?? '',
    );
    
    String selectedIcon = category?.iconName ?? availableIcons.first;
    Color selectedColor = category != null 
        ? Color(int.parse('0xFF${category.colorHex.substring(1)}'))
        : availableColors.first;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(isEditing ? Icons.edit : Icons.add),
              SizedBox(width: 8),
              Text(isEditing ? 'Edit Category' : 'Add New Category'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.6, // จำกัดความสูง
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ชื่อหมวดหมู่
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Category Name *',
                      hintText: 'Enter category name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: selectedColor, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // งบประมาณ (สำหรับรายจ่าย)
                  if (type == 'Expense') ...[
                    TextField(
                      controller: budgetController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Budget Limit (Optional)',
                        hintText: '0.00',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixText: '\$ ',
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // เลือกไอคอน
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select Icon:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: GridView.builder(
                      padding: EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: availableIcons.length,
                      itemBuilder: (context, index) {
                        final icon = availableIcons[index];
                        final isSelected = selectedIcon == icon;
                        
                        return GestureDetector(
                          onTap: () => setDialogState(() => selectedIcon = icon),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected ? selectedColor : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(6),
                              color: isSelected ? selectedColor.withOpacity(0.1) : null,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Image.asset(
                                'images/$icon.png',
                                width: 16,
                                height: 16,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.category, color: selectedColor, size: 16);
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _saveCategory(
                category,
                nameController.text,
                selectedIcon,
                selectedColor,
                type,
                budgetController.text,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC870),
              ),
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCategory(
    Category? existingCategory,
    String name,
    String iconName,
    Color color,
    String type,
    String budgetText,
  ) async {
    if (name.trim().isEmpty) {
      _showSnackBar('Please enter category name', Colors.red);
      return;
    }

    double? budgetLimit;
    if (budgetText.isNotEmpty) {
      budgetLimit = double.tryParse(budgetText);
      if (budgetLimit == null) {
        _showSnackBar('Invalid budget amount', Colors.red);
        return;
      }
    }

    try {
      setState(() {
        isLoading = true;
      });

      if (existingCategory != null) {
        // แก้ไข
        existingCategory.name = name.trim();
        existingCategory.iconName = iconName;
        existingCategory.colorHex = '#${color.value.toRadixString(16).substring(2)}';
        existingCategory.budgetLimit = budgetLimit;
        await DatabaseService.updateCategory(existingCategory);
        _showSnackBar('Category updated successfully!', Colors.green);
      } else {
        // เพิ่มใหม่
        final newCategory = Category(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name.trim(),
          iconName: iconName,
          colorHex: '#${color.value.toRadixString(16).substring(2)}',
          type: type,
          budgetLimit: budgetLimit,
        );
        await DatabaseService.addCategory(newCategory);
        _showSnackBar('Category added successfully!', Colors.green);
      }

      Navigator.pop(context);
      await _loadCategories();
      
    } catch (e) {
      print('Error saving category: $e');
      _showSnackBar('Error: ${e.toString()}', Colors.red);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showDeleteConfirmation(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Category'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${category.name}"?'),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone. Categories with transactions cannot be deleted.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteCategory(category);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(Category category) async {
    try {
      setState(() {
        isLoading = true;
      });

      await DatabaseService.deleteCategory(category.id);
      _showSnackBar('Category deleted successfully!', Colors.green);
      await _loadCategories();
      
    } catch (e) {
      print('Error deleting category: $e');
      _showSnackBar('Error: ${e.toString()}', Colors.red);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}