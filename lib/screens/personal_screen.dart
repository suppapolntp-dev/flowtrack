// lib/screens/personal_screen.dart - หน้า Personal หลัก
import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'theme_settings.dart';
import 'budget_screen.dart';
import 'export_screen.dart';
import 'backup_screen.dart';

class PersonalScreen extends StatelessWidget {
  const PersonalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildMenuList(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: Color(0xFFFFC870),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(
              Icons.person,
              size: 50,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Personal Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'Manage your app preferences',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(BuildContext context) {
    final menuItems = [
      {
        'icon': Icons.person,
        'title': 'Profile Settings',
        'subtitle': 'Edit your personal information',
        'color': Colors.blue,
        'screen': ProfileScreen(),
      },
      {
        'icon': Icons.palette,
        'title': 'Theme Settings',
        'subtitle': 'Customize app appearance',
        'color': Colors.purple,
        'screen': ThemeSettingsScreen(),
      },
      {
        'icon': Icons.account_balance_wallet,
        'title': 'Budget Settings',
        'subtitle': 'Set monthly spending limits',
        'color': Colors.green,
        'screen': BudgetScreen(),
      },
      {
        'icon': Icons.file_download,
        'title': 'Export Data',
        'subtitle': 'Save your data as CSV or PDF',
        'color': Colors.orange,
        'screen': ExportScreen(),
      },
      {
        'icon': Icons.backup,
        'title': 'Backup & Restore',
        'subtitle': 'Backup and restore your data',
        'color': Colors.red,
        'screen': BackupScreen(),
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _buildMenuItem(
          context,
          icon: item['icon'] as IconData,
          title: item['title'] as String,
          subtitle: item['subtitle'] as String,
          color: item['color'] as Color,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => item['screen'] as Widget,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        elevation: 2,
        shadowColor: Colors.grey.withOpacity(0.1),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
