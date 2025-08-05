// lib/screens/category_manager.dart
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

  final List<Color> availableColors = [
    const Color(0xFFFF6B6B), // Red
    const Color(0xFF4ECDC4), // Teal
    const Color(0xFF45B7D1), // Blue
    const Color(0xFF96CEB4), // Green
    const Color(0xFFFFEAA7), // Yellow
    const Color(0xFFDDA0DD), // Purple
    const Color(0xFF98D8C8), // Mint
    const Color(0xFFF39C12), // Orange
  ];

  final List<String> availableIcons = [
    'Food', 'Coffee', 'Grocery', 'Food-delivery', 'Gas-pump',
    'Public Transport', 'Rent or Mortgage', 'Water Bill', 
    'Electricity Bill', 'Internet Bill', 'Clothes', 'Shoes',
    'Accessories', 'Personal Care Items', 'Movie', 'Concert',
    'Hobby', 'Travel', 'Health-Report', 'Doctor VisitsHospital',
    'Education', 'Bank Fees', 'Giftbox', 'Donation'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCategories();
  }

  void _loadCategories() {
    setState(() {
      expenseCategories = DatabaseService.getCategories(type: 'Expense');
      incomeCategories = DatabaseService.getCategories(type: 'Income');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('จัดการหมวดหมู่'),
        backgroundColor: const Color(0xFFFFC870),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'รายจ่าย', icon: Icon(Icons.remove)),
            Tab(text: 'รายรับ', icon: Icon(Icons.add)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryList(expenseCategories, 'Expense'),
          _buildCategoryList(incomeCategories, 'Income'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(),
        backgroundColor: const Color(0xFFFFC870),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryList(List<Category> categories, String type) {
    if (categories.isEmpty) {
      return const Center(
        child: Text('ไม่มีหมวดหมู่', style: TextStyle(fontSize: 16)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryCard(category);
      },
    );
  }

  Widget _buildCategoryCard(Category category) {
    final color = Color(int.parse('0xFF${category.colorHex.substring(1)}'));
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: category.iconName != 'help' 
            ? Image.asset('images/${category.iconName}.png', width: 30)
            : Icon(Icons.help, color: color, size: 30),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category.type),
            if (category.budgetLimit != null)
              Text(
                'งบประมาณ: \$${category.budgetLimit!.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
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
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'แก้ไขหมวดหมู่' : 'เพิ่มหมวดหมู่ใหม่'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ชื่อหมวดหมู่
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อหมวดหมู่',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // งบประมาณ (สำหรับรายจ่ายเท่านั้น)
                if (type == 'Expense') ...[
                  TextField(
                    controller: budgetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'งบประมาณ (ไม่บังคับ)',
                      border: OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // เลือกไอคอน
                const Text('เลือกไอคอน:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  height: 120,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
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
                              color: isSelected ? selectedColor : Colors.grey,
                              width: isSelected ? 3 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Image.asset('images/$icon.png'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                
                // เลือกสี
                const Text('เลือกสี:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: availableColors.map((color) {
                    final isSelected = selectedColor == color;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedColor = color),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected 
                              ? Border.all(color: Colors.black, width: 2)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
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
              child: Text(isEditing ? 'อัปเดต' : 'เพิ่ม'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveCategory(
    Category? existingCategory,
    String name,
    String iconName,
    Color color,
    String type,
    String budgetText,
  ) async {
    if (name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกชื่อหมวดหมู่')),
      );
      return;
    }

    double? budgetLimit;
    if (budgetText.isNotEmpty) {
      budgetLimit = double.tryParse(budgetText);
    }

    try {
      if (existingCategory != null) {
        // แก้ไข
        existingCategory.name = name;
        existingCategory.iconName = iconName;
        existingCategory.colorHex = '#${color.value.toRadixString(16).substring(2)}';
        existingCategory.budgetLimit = budgetLimit;
        await DatabaseService.updateCategory(existingCategory);
      } else {
        // เพิ่มใหม่
        final newCategory = Category(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          iconName: iconName,
          colorHex: '#${color.value.toRadixString(16).substring(2)}',
          type: type,
          budgetLimit: budgetLimit,
        );
        await DatabaseService.addCategory(newCategory);
      }

      Navigator.pop(context);
      _loadCategories();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(existingCategory != null ? 'แก้ไขสำเร็จ' : 'เพิ่มสำเร็จ')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  void _showDeleteConfirmation(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบหมวดหมู่ "${category.name}" หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await DatabaseService.deleteCategory(category.id);
                Navigator.pop(context);
                _loadCategories();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ลบสำเร็จ')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}