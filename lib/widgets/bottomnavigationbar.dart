// lib/widgets/bottomnavigationbar.dart - Updated with Gradient FAB
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flowtrack/screens/theme_settings.dart';
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
      Home(onNavigateToWallet: (index) {
        setState(() {
          index_color = index;
        });
      }),
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
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: themeProvider.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: themeProvider.primaryColor.withOpacity(0.4),
              blurRadius: 16,
              offset: Offset(0, 8),
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    Add_Screen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: animation.drive(
                      Tween(
                        begin: Offset(0.0, 1.0),
                        end: Offset.zero,
                      ).chain(CurveTween(curve: Curves.easeInOut)),
                    ),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: themeProvider.cardColor,
        shape: CircularNotchedRectangle(),
        notchMargin: 8,
        elevation: 8,
        shadowColor: themeProvider.isDarkMode
            ? Colors.black.withOpacity(0.3)
            : Colors.grey.withOpacity(0.2),
        height: 105,
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
              SizedBox(width: 80), // Space for FAB
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
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.all(isSelected ? 10 : 6),
              decoration: BoxDecoration(
                gradient: isSelected ? themeProvider.primaryGradient : null,
                color: isSelected
                    ? null
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: themeProvider.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : themeProvider.subtitleColor,
                size: isSelected ? 18 : 12,
              ),
            ),
            SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: 300),
              style: TextStyle(
                color: isSelected
                    ? themeProvider.primaryColor
                    : themeProvider.subtitleColor,
                fontSize: isSelected ? 12 : 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                letterSpacing: isSelected ? 0.5 : 0,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}