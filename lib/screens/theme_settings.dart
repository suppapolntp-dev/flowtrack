// lib/screens/theme_settings.dart - Updated with Complete Theme Support
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flowtrack/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<ThemeColorOption> colorOptions = [
    ThemeColorOption('Yellow Gold', Color(0xFFFFC870), Icons.wb_sunny),
    ThemeColorOption('Ocean Blue', Color(0xFF2196F3), Icons.water),
    ThemeColorOption('Forest Green', Color(0xFF4CAF50), Icons.forest),
    ThemeColorOption('Rose Pink', Color(0xFFE91E63), Icons.local_florist),
    ThemeColorOption('Sunset Orange', Color(0xFFFF5722), Icons.wb_twilight),
    ThemeColorOption('Royal Purple', Color(0xFF9C27B0), Icons.stars),
    ThemeColorOption('Cyan Sky', Color(0xFF00BCD4), Icons.cloud),
    ThemeColorOption('Amber Glow', Color(0xFFFF9800), Icons.light_mode),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        title: Text('Theme Settings'),
        backgroundColor: themeProvider.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _resetToDefault,
          ),
        ],
      ),
      body: ScaleTransition(
        scale: _scaleAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDarkModeSection(),
              SizedBox(height: 30),
              _buildColorSection(),
              SizedBox(height: 30),
              _buildPreviewSection(),
              SizedBox(height: 30),
              _buildCustomizationTips(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDarkModeSection() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: themeProvider.isDarkMode
                ? Colors.black26
                : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: themeProvider.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: themeProvider.primaryColor,
                  size: 28,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Display Mode',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: themeProvider.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (themeProvider.isDarkMode) {
                        themeProvider.toggleTheme();
                      }
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !themeProvider.isDarkMode
                            ? themeProvider.primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.light_mode,
                            color: !themeProvider.isDarkMode
                                ? Colors.white
                                : themeProvider.subtitleColor,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Light',
                            style: TextStyle(
                              color: !themeProvider.isDarkMode
                                  ? Colors.white
                                  : themeProvider.subtitleColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (!themeProvider.isDarkMode) {
                        themeProvider.toggleTheme();
                      }
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode
                            ? themeProvider.primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.dark_mode,
                            color: themeProvider.isDarkMode
                                ? Colors.white
                                : themeProvider.subtitleColor,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Dark',
                            style: TextStyle(
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : themeProvider.subtitleColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Text(
            themeProvider.isDarkMode
                ? 'Easier on your eyes in low light environments'
                : 'Better visibility in bright environments',
            style: TextStyle(
              color: themeProvider.subtitleColor,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSection() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: themeProvider.isDarkMode
                ? Colors.black26
                : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: themeProvider.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.palette,
                  color: themeProvider.primaryColor,
                  size: 28,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Primary Color',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Choose your favorite color theme',
            style: TextStyle(
              color: themeProvider.subtitleColor,
            ),
          ),
          SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: colorOptions.length,
            itemBuilder: (context, index) {
              final option = colorOptions[index];
              final isSelected =
                  themeProvider.primaryColor.value == option.color.value;

              return GestureDetector(
                onTap: () => themeProvider.changeColor(option.color),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: option.color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: option.color.withOpacity(isSelected ? 0.6 : 0.3),
                        blurRadius: isSelected ? 12 : 6,
                        offset: Offset(0, isSelected ? 4 : 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle : option.icon,
                        color: Colors.white,
                        size: isSelected ? 30 : 24,
                      ),
                      if (isSelected) ...[
                        SizedBox(height: 4),
                        Text(
                          option.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: themeProvider.isDarkMode
                ? Colors.black26
                : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: themeProvider.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.preview,
                  color: themeProvider.primaryColor,
                  size: 28,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Preview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Sample Transaction Card
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeProvider.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: themeProvider.dividerColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: themeProvider.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.account_balance_wallet,
                      color: themeProvider.primaryColor),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sample Transaction',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: themeProvider.textColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'This is how your app will look',
                        style: TextStyle(
                          color: themeProvider.subtitleColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '\฿25.50',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 12),

          // Sample Buttons
          
        ],
      ),
    );
  }

  Widget _buildCustomizationTips() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeProvider.primaryColor.withOpacity(0.1),
            themeProvider.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: themeProvider.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: themeProvider.primaryColor),
              SizedBox(width: 8),
              Text('Customization Tips',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.primaryColor)),
            ],
          ),
          SizedBox(height: 10),
          Text(
            '• Dark mode saves battery on OLED screens\n'
            '• Choose colors that match your mood\n'
            '• Warm colors are energizing\n'
            '• Cool colors are calming',
            style: TextStyle(
              color: themeProvider.textColor.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _resetToDefault() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.cardColor,
        title: Text('Reset to Default?',
            style: TextStyle(color: themeProvider.textColor)),
        content: Text(
          'This will reset to the default yellow theme and light mode.',
          style: TextStyle(color: themeProvider.textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              themeProvider.changeColor(Color(0xFFFFC870));
              if (themeProvider.isDarkMode) {
                themeProvider.toggleTheme();
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Theme reset to default'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProvider.primaryColor,
            ),
            child: Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class ThemeColorOption {
  final String name;
  final Color color;
  final IconData icon;

  ThemeColorOption(this.name, this.color, this.icon);
}
