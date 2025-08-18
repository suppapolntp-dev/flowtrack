// lib/widgets/bottomnavigationbar.dart - Updated with Theme Support
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flowtrack/providers/theme_provider.dart';
import 'package:flowtrack/screens/add.dart';
import 'package:flowtrack/screens/home.dart';
import 'package:flutter/services.dart';
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    
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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: themeProvider.primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => Add_Screen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 1.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;

                  var tween = Tween(begin: begin, end: end).chain(
                    CurveTween(curve: curve),
                  );

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              ),
            );
          },
          backgroundColor: themeProvider.primaryColor,
          elevation: 0,
          child: Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: themeProvider.cardColor,
        shape: CircularNotchedRectangle(),
        notchMargin: 8,
        elevation: 8,
        shadowColor: themeProvider.isDarkMode ? Colors.black : Colors.grey.withOpacity(0.3),
        height: 70,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: themeProvider.dividerColor.withOpacity(0.2),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, 'Home', 0),
              _buildNavItem(Icons.bar_chart_rounded, 'Stats', 1),
              SizedBox(width: 60), // Space for FAB
              _buildNavItem(Icons.wallet_rounded, 'Wallet', 2),
              _buildNavItem(Icons.person_rounded, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isSelected = index_color == index;
    
    return GestureDetector(
      onTap: () {
        setState(() => index_color = index);
        // Add haptic feedback
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              padding: EdgeInsets.all(isSelected ? 8 : 4),
              decoration: BoxDecoration(
                color: isSelected 
                    ? themeProvider.primaryColor.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected 
                    ? themeProvider.primaryColor 
                    : themeProvider.subtitleColor,
                size: isSelected ? 26 : 24,
              ),
            ),
            SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected 
                    ? themeProvider.primaryColor 
                    : themeProvider.subtitleColor,
                fontSize: isSelected ? 12 : 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              child: Text(label),
            ),
            // Add indicator dot
            if (isSelected)
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                margin: EdgeInsets.only(top: 2),
                height: 3,
                width: 3,
                decoration: BoxDecoration(
                  color: themeProvider.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Add HapticFeedback import if not already present