// lib/providers/gradient_theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class GradientThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  int _selectedThemeIndex = 0;

  bool get isDarkMode => _isDarkMode;
  int get selectedThemeIndex => _selectedThemeIndex;
  GradientTheme get currentTheme => gradientThemes[_selectedThemeIndex];

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

  // Color getters for current theme
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

  // Theme methods
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
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

  // Helper methods
  Widget createGradientContainer({
    required Widget child,
    double? height,
    double? width,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      height: height,
      width: width,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        gradient: primaryGradient,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: currentTheme.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  ElevatedButton createGradientButton({
    required VoidCallback? onPressed,
    required Widget child,
    double? elevation,
    EdgeInsetsGeometry? padding,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: elevation ?? 0,
        padding: padding ?? EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          constraints: BoxConstraints(minHeight: 48),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}