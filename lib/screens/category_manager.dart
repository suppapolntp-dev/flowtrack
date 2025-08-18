// lib/screens/category_manager.dart - Updated with Theme Support
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        title: const Text('Category Manager'),
        backgroundColor: themeProvider.primaryColor,
        elevation: 0,
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
                _buildReorderableList(expenseCategories, 'Expense'),
                _buildReorderableList(incomeCategories, 'Income'),
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

  Widget _buildReorderableList(List<Category> categories, String type) {
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

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      onReorder: (oldIndex, newIndex) =>
          _reorderCategories(categories, oldIndex, newIndex, type),
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryCard(category, index);
      },
    );
  }

  Widget _buildCategoryCard(Category category, int index) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final color = Color(int.parse('0xFF${category.colorHex.substring(1)}'));

    return Card(
      key: ValueKey(category.id),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: themeProvider.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Image.asset('images/${category.iconName}.png',
                width: 30,
                height: 30,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.category, color: color, size: 24)),
          ),
        ),
        title: Text(category.name,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: themeProvider.textColor)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(category.type,
                style: TextStyle(color: themeProvider.subtitleColor)),
            if (category.budgetLimit != null) ...[
              SizedBox(height: 4),
              Text('Budget: \฿${category.budgetLimit!.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.green[600], fontSize: 12)),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.drag_handle, color: themeProvider.subtitleColor),
            SizedBox(width: 8),
            IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _showEditCategoryDialog(category)),
            IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _showDeleteConfirmation(category)),
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
          title: Text(
            isEditing ? 'Edit Category' : 'Add New Category',
            style: TextStyle(color: themeProvider.textColor),
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
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: themeProvider.dividerColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
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
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: themeProvider.dividerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
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
                  Text('Select Color:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: themeProvider.textColor)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: availableColors.map((color) {
                      final isSelected = selectedColor.value == color.value;
                      return GestureDetector(
                        onTap: () =>
                            setDialogState(() => selectedColor = color),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? themeProvider.textColor
                                  : themeProvider.dividerColor,
                              width: isSelected ? 3 : 1,
                            ),
                          ),
                          child: isSelected
                              ? Icon(Icons.check, color: Colors.white, size: 20)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text('Select Icon:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: themeProvider.textColor)),
                  const SizedBox(height: 8),
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: themeProvider.dividerColor),
                      borderRadius: BorderRadius.circular(8),
                      color: themeProvider.backgroundColor,
                    ),
                    child: GridView.builder(
                      padding: EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
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
                              borderRadius: BorderRadius.circular(6),
                              color: isSelected
                                  ? selectedColor.withOpacity(0.1)
                                  : null,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Image.asset('images/$icon.png',
                                  width: 16,
                                  height: 16,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.category,
                                          color: selectedColor, size: 16)),
                            ),
                          ),
                        );
                      },
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
                  backgroundColor: themeProvider.primaryColor),
              child: Text(isEditing ? 'Update' : 'Add',
                  style: TextStyle(color: Colors.white)),
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
        title: Text('Delete Category',
            style: TextStyle(color: themeProvider.textColor)),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
