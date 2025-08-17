// lib/widgets/bottomnavigationbar.dart - แบบเรียบ
import 'package:flutter/material.dart';
import 'package:flowtrack/screens/add.dart';
import 'package:flowtrack/screens/home.dart';
import 'package:flowtrack/screens/statistics.dart';
import 'package:flowtrack/screens/wallet.dart';
import 'package:flowtrack/screens/personal_screen.dart';

class Bottom extends StatefulWidget {
  const Bottom({super.key});

  @override
  State<Bottom> createState() => _BottomState();
}

class _BottomState extends State<Bottom> {
  int index_color = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [
      Home(),
      Statistics(),
      WalletScreen(),
      PersonalScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: index_color,
        children: screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Add_Screen()),
          );
        },
        backgroundColor: Color(0xFFFFC870),
        child: Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6,
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 'Home', 0),
            _buildNavItem(Icons.bar_chart, 'Stats', 1),
            SizedBox(width: 40), // Space for FAB
            _buildNavItem(Icons.wallet, 'Wallet', 2),
            _buildNavItem(Icons.person, 'Profile', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = index_color == index;
    return GestureDetector(
      onTap: () => setState(() => index_color = index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Color(0xFFFFC870) : Colors.grey,
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Color(0xFFFFC870) : Colors.grey,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
