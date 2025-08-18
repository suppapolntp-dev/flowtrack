// lib/screens/personal_screen.dart - Updated with Theme Support
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flowtrack/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_screen.dart';
import 'theme_settings.dart';
import 'budget_screen.dart';
import 'export_screen.dart';
import 'category_manager.dart';

class PersonalScreen extends StatefulWidget {
  const PersonalScreen({super.key});

  @override
  State<PersonalScreen> createState() => _PersonalScreenState();
}

class _PersonalScreenState extends State<PersonalScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String userName = 'User';
  String userEmail = 'user@email.com';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        userName = prefs.getString('user_name') ?? 'Mr.Suppapol Tabudda';
        userEmail = prefs.getString('user_email') ?? 'user@email.com';
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (isLoading) {
      return Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        body: Center(
            child: CircularProgressIndicator(
          color: themeProvider.primaryColor,
        )),
      );
    }

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildModernHeader(),
                SizedBox(height: 20),
                _buildMenuList(),
                SizedBox(height: 20),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeProvider.primaryColor,
            themeProvider.primaryColor.withOpacity(0.8),
            themeProvider.primaryColor.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
        boxShadow: [
          BoxShadow(
            color: themeProvider.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Section
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      userEmail,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Container(
                    //   padding: EdgeInsets.symmetric(
                    //     horizontal: 12,
                    //     vertical: 4,
                    //   ),
                    //   decoration: BoxDecoration(
                    //     color: Colors.white.withOpacity(0.2),
                    //     borderRadius: BorderRadius.circular(20),
                    //   ),
                    //   child: Text(
                    //     'Premium User',
                    //     style: TextStyle(
                    //       fontSize: 12,
                    //       color: Colors.white,
                    //       fontWeight: FontWeight.w500,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 25),

          // Quick Actions
          // Container(
          //   padding: EdgeInsets.all(20),
          //   decoration: BoxDecoration(
          //     color: Colors.white.withOpacity(0.15),
          //     borderRadius: BorderRadius.circular(20),
          //     border: Border.all(
          //       color: Colors.white.withOpacity(0.2),
          //       width: 1,
          //     ),
          //   ),
          //   // child: Row(
          //   //   mainAxisAlignment: MainAxisAlignment.spaceAround,
          //   //   children: [
          //   //     _buildQuickStat('Categories', '12', Icons.category),
          //   //     _buildVerticalDivider(),
          //   //     _buildQuickStat('This Month', '\$1,234', Icons.trending_up),
          //   //     _buildVerticalDivider(),
          //   //     _buildQuickStat('Transactions', '89', Icons.receipt_long),
          //   //   ],
          //   // ),
          // ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
        SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildMenuList() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final menuItems = [
      {
        'icon': Icons.person,
        'title': 'Profile Settings',
        'subtitle': 'Edit your personal information',
        'color': Colors.blue,
        'screen': ProfileScreen(),
      },
      {
        'icon': Icons.category,
        'title': 'Category Manager',
        'subtitle': 'Manage income and expense categories',
        'color': Colors.purple,
        'screen': CategoryManagerScreen(),
      },
      {
        'icon': Icons.palette,
        'title': 'Theme Settings',
        'subtitle': 'Customize app appearance',
        'color': Colors.pink,
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
        'subtitle': 'Save your data as CSV or JSON',
        'color': Colors.orange,
        'screen': ExportScreen(),
      }
    ];
  
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(
          menuItems.length,
          (index) => TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 600 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(50 * (1 - value), 0),
                child: Opacity(
                  opacity: value,
                  child: _buildEnhancedMenuItem(
                    context,
                    icon: menuItems[index]['icon'] as IconData,
                    title: menuItems[index]['title'] as String,
                    subtitle: menuItems[index]['subtitle'] as String,
                    color: menuItems[index]['color'] as Color,
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  menuItems[index]['screen'] as Widget,
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: animation.drive(
                                Tween(
                                  begin: Offset(1.0, 0.0),
                                  end: Offset.zero,
                                ).chain(CurveTween(curve: Curves.easeInOut)),
                              ),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: themeProvider.isDarkMode
                ? Colors.black26
                : Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(0.8),
                        color,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: themeProvider.textColor,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.subtitleColor,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: color,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Divider(
            color: themeProvider.dividerColor,
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite,
                color: Colors.red.shade400,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                'Made with love in FlowTrack',
                style: TextStyle(
                  fontSize: 12,
                  color: themeProvider.subtitleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Version 1.0.0',
            style: TextStyle(
              fontSize: 10,
              color: themeProvider.subtitleColor.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
