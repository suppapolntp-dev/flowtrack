// lib/screens/theme_settings.dart - Updated with Gradient Theme System
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


// Gradient Theme Data Class
class GradientTheme {
  final String name;
  final List<Color> colors;
  final IconData icon;
  final Color primaryColor;

  const GradientTheme({
    required this.name,
    required this.colors,
    required this.icon,
    required this.primaryColor,
  });
}

// Updated Theme Provider with Gradient Support
class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  int _selectedThemeIndex = 0;

  bool get isDarkMode => _isDarkMode;
  int get selectedThemeIndex => _selectedThemeIndex;
  GradientTheme get currentTheme => gradientThemes[_selectedThemeIndex];
  Color get primaryColor => currentTheme.primaryColor; // For backward compatibility

  // 20 Gradient Themes Collection
  static const List<GradientTheme> gradientThemes = [
    GradientTheme(
      name: 'Instagram',
      colors: [Color(0xFFFF6B35), Color(0xFFE91E63), Color(0xFF9C27B0), Color(0xFF3F51B5)],
      icon: Icons.camera_alt,
      primaryColor: Color(0xFFE91E63),
    ),
    GradientTheme(
      name: 'Sunset',
      colors: [Color(0xFFFF5722), Color(0xFFFF9800)],
      icon: Icons.wb_twilight,
      primaryColor: Color(0xFFFF7043),
    ),
    GradientTheme(
      name: 'Ocean',
      colors: [Color(0xFF2196F3), Color(0xFF9C27B0)],
      icon: Icons.water,
      primaryColor: Color(0xFF2196F3),
    ),
    GradientTheme(
      name: 'Paradise',
      colors: [Color(0xFFE91E63), Color(0xFFFFC107)],
      icon: Icons.local_florist,
      primaryColor: Color(0xFFE91E63),
    ),
    GradientTheme(
      name: 'Aurora',
      colors: [Color(0xFF4CAF50), Color(0xFF2196F3)],
      icon: Icons.stars,
      primaryColor: Color(0xFF4CAF50),
    ),
    GradientTheme(
      name: 'Lavender',
      colors: [Color(0xFF87CEEB), Color(0xFFDDA0DD)],
      icon: Icons.spa,
      primaryColor: Color(0xFF9C88FF),
    ),
    GradientTheme(
      name: 'Fire',
      colors: [Color(0xFFFF5722), Color(0xFFFFC107)],
      icon: Icons.local_fire_department,
      primaryColor: Color(0xFFFF6F00),
    ),
    GradientTheme(
      name: 'Royal',
      colors: [Color(0xFF607D8B), Color(0xFF3F51B5)],
      icon: Icons.diamond,
      primaryColor: Color(0xFF5C6BC0),
    ),
    GradientTheme(
      name: 'Mint',
      colors: [Color(0xFF00BCD4), Color(0xFF2196F3)],
      icon: Icons.ac_unit,
      primaryColor: Color(0xFF26C6DA),
    ),
    GradientTheme(
      name: 'Berry',
      colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
      icon: Icons.favorite,
      primaryColor: Color(0xFFAD1457),
    ),
    GradientTheme(
      name: 'Lime',
      colors: [Color(0xFF8BC34A), Color(0xFF4CAF50)],
      icon: Icons.eco,
      primaryColor: Color(0xFF66BB6A),
    ),
    GradientTheme(
      name: 'Cosmic',
      colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
      icon: Icons.rocket,
      primaryColor: Color(0xFFBA68C8),
    ),
    GradientTheme(
      name: 'Mango',
      colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
      icon: Icons.wb_sunny,
      primaryColor: Color(0xFFFFB74D),
    ),
    GradientTheme(
      name: 'Emerald',
      colors: [Color(0xFF00E676), Color(0xFF00C853)],
      icon: Icons.brightness_7,
      primaryColor: Color(0xFF00E676),
    ),
    GradientTheme(
      name: 'Rose Gold',
      colors: [Color(0xFFE91E63), Color(0xFFFFAB91)],
      icon: Icons.auto_awesome,
      primaryColor: Color(0xFFE91E63),
    ),
    GradientTheme(
      name: 'Violet',
      colors: [Color(0xFF7B1FA2), Color(0xFF512DA8)],
      icon: Icons.colorize,
      primaryColor: Color(0xFF7B1FA2),
    ),
    GradientTheme(
      name: 'Aqua',
      colors: [Color(0xFF00E5FF), Color(0xFF0091EA)],
      icon: Icons.water_drop,
      primaryColor: Color(0xFF00BCD4),
    ),
    GradientTheme(
      name: 'Copper',
      colors: [Color(0xFFD84315), Color(0xFFBF360C)],
      icon: Icons.local_fire_department,
      primaryColor: Color(0xFFD84315),
    ),
    GradientTheme(
      name: 'Forest',
      colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
      icon: Icons.forest,
      primaryColor: Color(0xFF2E7D32),
    ),
    GradientTheme(
      name: 'Neon',
      colors: [Color(0xFFE040FB), Color(0xFF00E5FF)],
      icon: Icons.flash_on,
      primaryColor: Color(0xFFE040FB),
    ),
  ];

  // Color getters
  LinearGradient get primaryGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: currentTheme.colors,
      );

  Color get backgroundColor => _isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50;
  Color get cardColor => _isDarkMode ? Colors.grey.shade800 : Colors.white;
  Color get textColor => _isDarkMode ? Colors.white : Colors.black87;
  Color get subtitleColor => _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
  Color get dividerColor => _isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;
  Color get inputFillColor => _isDarkMode ? Colors.grey.shade800 : Colors.white;
  Color get inputBorderColor => _isDarkMode ? Colors.grey.shade600 : Color(0xffC5C5C5);

  // Methods
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> changeColor(Color color) async {
    // Find matching theme or keep current
    int newIndex = gradientThemes.indexWhere((theme) => theme.primaryColor.value == color.value);
    if (newIndex != -1) {
      _selectedThemeIndex = newIndex;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('selectedTheme', _selectedThemeIndex);
      notifyListeners();
    }
  }

  Future<void> changeTheme(int themeIndex) async {
    if (themeIndex >= 0 && themeIndex < gradientThemes.length) {
      _selectedThemeIndex = themeIndex;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('selectedTheme', _selectedThemeIndex);
      notifyListeners();
    }
  }

  Future<void> loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _selectedThemeIndex = prefs.getInt('selectedTheme') ?? 0;
    notifyListeners();
  }
}

// Theme Settings Screen
class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Gradient App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.white),
                onPressed: _resetToDefault,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: themeProvider.primaryGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 40),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              Icon(Icons.palette, color: Colors.white, size: 48),
                              SizedBox(height: 12),
                              Text(
                                'Theme Gallery',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildCurrentThemeCard(),
                      SizedBox(height: 24),
                      _buildDarkModeSection(),
                      SizedBox(height: 24),
                      _buildThemeGrid(),
                      SizedBox(height: 24),
                      _buildFeatureShowcase(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentThemeCard() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: themeProvider.isDarkMode ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: themeProvider.primaryGradient,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: currentTheme.primaryColor.withOpacity(0.4),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(currentTheme.icon, color: Colors.white, size: 28),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Theme',
                      style: TextStyle(
                        color: themeProvider.subtitleColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      currentTheme.name,
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: themeProvider.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            height: 8,
            decoration: BoxDecoration(
              gradient: themeProvider.primaryGradient,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkModeSection() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: themeProvider.isDarkMode ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: themeProvider.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dark Mode',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  themeProvider.isDarkMode 
                      ? 'Easier on your eyes' 
                      : 'Better in bright light',
                  style: TextStyle(
                    color: themeProvider.subtitleColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: themeProvider.isDarkMode,
            onChanged: (_) {
              HapticFeedback.lightImpact();
              themeProvider.toggleTheme();
            },
            activeColor: themeProvider.currentTheme.primaryColor,
            activeTrackColor: themeProvider.currentTheme.primaryColor.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeGrid() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Style',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: themeProvider.textColor,
          ),
        ),
        SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: ThemeProvider.gradientThemes.length,
          itemBuilder: (context, index) {
            final theme = ThemeProvider.gradientThemes[index];
            final isSelected = themeProvider.selectedThemeIndex == index;

            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 300 + (index * 50)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.5 + (value * 0.5),
                  child: Opacity(
                    opacity: value,
                    child: _buildThemeCard(theme, index, isSelected),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildThemeCard(GradientTheme theme, int index, bool isSelected) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        themeProvider.changeTheme(index);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: theme.colors,
          ),
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: Colors.white, width: 3)
              : null,
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(isSelected ? 0.6 : 0.3),
              blurRadius: isSelected ? 16 : 8,
              offset: Offset(0, isSelected ? 8 : 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.check_circle : theme.icon,
              color: Colors.white,
              size: isSelected ? 32 : 28,
            ),
            SizedBox(height: 8),
            Text(
              theme.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (isSelected) ...[
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'ACTIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureShowcase() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: themeProvider.isDarkMode ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor,
            ),
          ),
          SizedBox(height: 16),
          // Sample Transaction Card
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeProvider.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: themeProvider.dividerColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: themeProvider.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.shopping_cart, color: Colors.white, size: 20),
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
                Text(
                  '\฿125.50',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: themeProvider.currentTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          // Sample Button
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              gradient: themeProvider.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Sample Gradient Button',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.refresh, color: themeProvider.currentTheme.primaryColor),
            SizedBox(width: 8),
            Text('Reset Theme?', style: TextStyle(color: themeProvider.textColor)),
          ],
        ),
        content: Text(
          'This will reset to the Instagram theme and light mode.',
          style: TextStyle(color: themeProvider.textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: themeProvider.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ElevatedButton(
              onPressed: () {
                themeProvider.changeTheme(0); // Instagram theme
                if (themeProvider.isDarkMode) {
                  themeProvider.toggleTheme();
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Theme reset to default'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: Text('Reset', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}