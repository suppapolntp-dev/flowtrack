// lib/screens/category_manager.dart - Complete File with Long Press Drag
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flowtrack/providers/theme_provider.dart';
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
  bool isReorderMode = false;

  final List<Color> availableColors = [
    const Color(0xFFFF6B6B),
    const Color(0xFF4ECDC4),
    const Color(0xFF45B7D1),
    const Color(0xFF96CEB4),
    const Color(0xFFFFEAA7),
    const Color(0xFFDDA0DD),
    const Color(0xFF98D8C8),
    const Color(0xFFF39C12),
    const Color(0xFF2ECC71),
    const Color(0xFFE74C3C),
    const Color(0xFF9B59B6),
    const Color(0xFF34495E),
  ];

  final List<String> availableIcons = [
    'Food',
    'Coffee',
    'Grocery',
    'Food-delivery',
    'Gas-pump',
    'Public Transport',
    'Rent or Mortgage',
    'Water Bill',
    'Electricity Bill',
    'Internet Bill',
    'Clothes',
    'Shoes',
    'Accessories',
    'Personal Care Items',
    'Movie',
    'Concert',
    'Hobby',
    'Travel',
    'Health-Report',
    'Doctor VisitsHospital',
    'Education',
    'Bank Fees',
    'Giftbox',
    'Donation',
    'salary',
    'commission',
    'freelanceincome',
    'dividends',
    'interest',
    'rentalincome',
    'taxrefunds'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCategories();

    DatabaseService.categoryStream.listen((categories) {
      if (mounted) {
        setState(() {
          expenseCategories =
              categories.where((cat) => cat.type == 'Expense').toList();
          incomeCategories =
              categories.where((cat) => cat.type == 'Income').toList();
        });
      }
    });
  }

  void _loadCategories() {
    setState(() {
      isLoading = true;
    });

    try {
      expenseCategories = DatabaseService.getAllCategories(type: 'Expense');
      incomeCategories = DatabaseService.getAllCategories(type: 'Income');
    } catch (e) {
      _showSnackBar('Error loading categories: $e', Colors.red);
    }

    setState(() {
      isLoading = false;
    });
  }

  void _toggleReorderMode() {
    setState(() {
      isReorderMode = !isReorderMode;
    });
    
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    if (isReorderMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('Long press and drag any card to reorder'),
              ),
            ],
          ),
          backgroundColor: themeProvider.primaryColor,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: 'GOT IT',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    } else {
      _showSnackBar('Reorder mode disabled', Colors.blue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        title: const Text('Category Manager'),
        backgroundColor: themeProvider.primaryColor,
        elevation: 0,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: isReorderMode 
                  ? Colors.white.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: Icon(
                  isReorderMode ? Icons.done_all : Icons.reorder,
                  color: Colors.white,
                  key: ValueKey(isReorderMode),
                ),
              ),
              onPressed: _toggleReorderMode,
              tooltip: isReorderMode ? 'Done Reordering' : 'Reorder Categories',
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: [
            Tab(
                text: 'Expenses (${expenseCategories.length})',
                icon: Icon(Icons.remove_circle_outline)),
            Tab(
                text: 'Income (${incomeCategories.length})',
                icon: Icon(Icons.add_circle_outline)),
          ],
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: themeProvider.primaryColor,
            ))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCategoryList(expenseCategories, 'Expense'),
                _buildCategoryList(incomeCategories, 'Income'),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategoryDialog(),
        backgroundColor: themeProvider.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Category', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildCategoryList(List<Category> categories, String type) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                type == 'Expense'
                    ? Icons.remove_circle_outline
                    : Icons.add_circle_outline,
                size: 80,
                color: themeProvider.subtitleColor),
            SizedBox(height: 16),
            Text('No ${type.toLowerCase()} categories',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: themeProvider.subtitleColor)),
            SizedBox(height: 8),
            Text('Tap + to add your first category',
                style: TextStyle(color: themeProvider.subtitleColor)),
          ],
        ),
      );
    }

    if (isReorderMode) {
      return ReorderableListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        buildDefaultDragHandles: false,
        onReorder: (oldIndex, newIndex) =>
            _reorderCategories(categories, oldIndex, newIndex, type),
        itemBuilder: (context, index) {
          final category = categories[index];
          return ReorderableDragStartListener(
            key: ValueKey(category.id),
            index: index,
            child: _buildReorderableCard(category, index),
          );
        },
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _buildCategoryCard(category, index);
        },
      );
    }
  }

  Widget _buildReorderableCard(Category category, int index) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final color = Color(int.parse('0xFF${category.colorHex.substring(1)}'));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      color: themeProvider.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: themeProvider.primaryColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.drag_handle_rounded,
                    color: themeProvider.primaryColor,
                    size: 24,
                  ),
                  Text(
                    'HOLD',
                    style: TextStyle(
                      fontSize: 9,
                      color: themeProvider.primaryColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.3),
                    color.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: color.withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: Center(
                child: Image.asset('images/${category.iconName}.png',
                    width: 30,
                    height: 30,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.category, color: color, size: 24)),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.name,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: themeProvider.textColor)),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: themeProvider.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          category.type,
                          style: TextStyle(
                            color: themeProvider.primaryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (category.budgetLimit != null) ...[
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '\฿${category.budgetLimit!.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              child: Icon(
                Icons.reorder,
                color: themeProvider.subtitleColor.withOpacity(0.5),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Category category, int index) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final color = Color(int.parse('0xFF${category.colorHex.substring(1)}'));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: themeProvider.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.2),
                    color.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Image.asset('images/${category.iconName}.png',
                    width: 32,
                    height: 32,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.category, color: color, size: 28)),
              ),
            ),
            SizedBox(width: 12),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.name,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: themeProvider.textColor)),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: themeProvider.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          category.type,
                          style: TextStyle(
                            color: themeProvider.primaryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (category.budgetLimit != null) ...[
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '\฿${category.budgetLimit!.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            Container(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.edit_rounded, size: 20),
                      color: Colors.blue,
                      onPressed: () => _showEditCategoryDialog(category),
                      constraints: BoxConstraints(minWidth: 40, minHeight: 40),
                      padding: EdgeInsets.all(8),
                    ),
                  ),
                  SizedBox(width: 8),
                  
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.delete_rounded, size: 20),
                      color: Colors.red,
                      onPressed: () => _showDeleteConfirmation(category),
                      constraints: BoxConstraints(minWidth: 40, minHeight: 40),
                      padding: EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _reorderCategories(List<Category> categories, int oldIndex, int newIndex,
      String type) async {
    if (newIndex > oldIndex) newIndex--;

    final Category movedCategory = categories.removeAt(oldIndex);
    categories.insert(newIndex, movedCategory);

    try {
      await DatabaseService.reorderCategories([
        ...expenseCategories,
        ...incomeCategories,
      ]);
      _showSnackBar('Categories reordered!', Colors.green);
    } catch (e) {
      _showSnackBar('Error reordering categories: $e', Colors.red);
      _loadCategories();
    }
  }

  void _showAddCategoryDialog() {
    final String currentType = _tabController.index == 0 ? 'Expense' : 'Income';
    _showCategoryDialog(null, currentType);
  }

  void _showEditCategoryDialog(Category category) {
    _showCategoryDialog(category, category.type);
  }

  void _showCategoryDialog(Category? category, String type) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    final budgetController =
        TextEditingController(text: category?.budgetLimit?.toString() ?? '');

    String selectedIcon = category?.iconName ?? availableIcons.first;
    Color selectedColor = category != null
        ? Color(int.parse('0xFF${category.colorHex.substring(1)}'))
        : availableColors.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: themeProvider.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeProvider.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isEditing ? Icons.edit : Icons.add_circle,
                  color: themeProvider.primaryColor,
                ),
              ),
              SizedBox(width: 12),
              Text(
                isEditing ? 'Edit Category' : 'Add New Category',
                style: TextStyle(color: themeProvider.textColor),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: TextStyle(color: themeProvider.textColor),
                    decoration: InputDecoration(
                      labelText: 'Category Name *',
                      labelStyle: TextStyle(color: themeProvider.subtitleColor),
                      prefixIcon: Icon(Icons.label, color: themeProvider.primaryColor),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: themeProvider.dividerColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: selectedColor, width: 2),
                      ),
                      filled: true,
                      fillColor: themeProvider.backgroundColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (type == 'Expense') ...[
                    TextField(
                      controller: budgetController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: themeProvider.textColor),
                      decoration: InputDecoration(
                        labelText: 'Budget Limit (Optional)',
                        labelStyle:
                            TextStyle(color: themeProvider.subtitleColor),
                        prefixIcon: Icon(Icons.account_balance_wallet, 
                            color: themeProvider.primaryColor),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: themeProvider.dividerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: selectedColor, width: 2),
                        ),
                        prefixText: '\฿ ',
                        prefixStyle: TextStyle(color: themeProvider.textColor),
                        filled: true,
                        fillColor: themeProvider.backgroundColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: themeProvider.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: themeProvider.dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.palette, 
                                color: themeProvider.primaryColor, size: 20),
                            SizedBox(width: 8),
                            Text('Select Color',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: themeProvider.textColor)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: availableColors.map((color) {
                            final isSelected = selectedColor.value == color.value;
                            return GestureDetector(
                              onTap: () =>
                                  setDialogState(() => selectedColor = color),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? themeProvider.textColor
                                        : Colors.transparent,
                                    width: isSelected ? 3 : 0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withOpacity(0.4),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: isSelected
                                    ? Icon(Icons.check, color: Colors.white, size: 20)
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: themeProvider.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: themeProvider.dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.category, 
                                color: themeProvider.primaryColor, size: 20),
                            SizedBox(width: 8),
                            Text('Select Icon',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: themeProvider.textColor)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 140,
                          child: GridView.builder(
                            padding: EdgeInsets.all(4),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: availableIcons.length,
                            itemBuilder: (context, index) {
                              final icon = availableIcons[index];
                              final isSelected = selectedIcon == icon;

                              return GestureDetector(
                                onTap: () =>
                                    setDialogState(() => selectedIcon = icon),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isSelected
                                          ? selectedColor
                                          : themeProvider.dividerColor,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: isSelected
                                        ? selectedColor.withOpacity(0.1)
                                        : themeProvider.cardColor,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Image.asset('images/$icon.png',
                                        errorBuilder: (context, error, stackTrace) =>
                                            Icon(Icons.category,
                                                color: selectedColor, size: 20)),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel',
                    style: TextStyle(color: themeProvider.subtitleColor))),
            ElevatedButton(
              onPressed: () => _saveCategory(category, nameController.text,
                  selectedIcon, selectedColor, type, budgetController.text),
              style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(isEditing ? 'Update' : 'Add',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCategory(Category? existingCategory, String name,
      String iconName, Color color, String type, String budgetText) async {
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
      if (existingCategory != null) {
        existingCategory.name = name.trim();
        existingCategory.iconName = iconName;
        existingCategory.colorHex =
            '#${color.value.toRadixString(16).substring(2)}';
        existingCategory.budgetLimit = budgetLimit;
        await DatabaseService.updateCategory(existingCategory);
        _showSnackBar('Category updated!', Colors.green);
      } else {
        final newCategory = Category(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name.trim(),
          iconName: iconName,
          colorHex: '#${color.value.toRadixString(16).substring(2)}',
          type: type,
          budgetLimit: budgetLimit,
        );
        await DatabaseService.addCategory(newCategory);
        _showSnackBar('Category added!', Colors.green);
      }

      Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', Colors.red);
    }
  }

  void _showDeleteConfirmation(Category category) {
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
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.delete, color: Colors.red),
            ),
            SizedBox(width: 12),
            Text('Delete Category',
                style: TextStyle(color: themeProvider.textColor)),
          ],
        ),
        content: Text(
            'Delete "${category.name}"?\n\nCategories with transactions cannot be deleted.',
            style: TextStyle(color: themeProvider.textColor)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: TextStyle(color: themeProvider.subtitleColor))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteCategory(category);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(Category category) async {
    try {
      await DatabaseService.deleteCategory(category.id);
      _showSnackBar('Category deleted!', Colors.green);
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(message),
            backgroundColor: color,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: Duration(seconds: 2)),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}