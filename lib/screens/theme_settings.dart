// lib/screens/theme_settings.dart - Complete Beautiful Theme Gallery with ListView and TitleView
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeCategory {
  popular,
  nature,
  ocean,
  sky,
  fire,
  elegant,
  mood,
  artistic,
  seasonal,
  fruits,
  neon,
  pastel,
  dark
}

extension ThemeCategoryExtension on ThemeCategory {
  String get name => toString().split('.').last.replaceFirst(
      toString().split('.').last[0],
      toString().split('.').last[0].toUpperCase());

  IconData get icon {
    const icons = {
      ThemeCategory.popular: Icons.star,
      ThemeCategory.nature: Icons.nature,
      ThemeCategory.ocean: Icons.water,
      ThemeCategory.sky: Icons.cloud,
      ThemeCategory.fire: Icons.local_fire_department,
      ThemeCategory.elegant: Icons.diamond,
      ThemeCategory.mood: Icons.mood,
      ThemeCategory.artistic: Icons.palette,
      ThemeCategory.seasonal: Icons.calendar_today,
      ThemeCategory.fruits: Icons.apple,
      ThemeCategory.neon: Icons.flash_on,
      ThemeCategory.pastel: Icons.gradient,
      ThemeCategory.dark: Icons.dark_mode,
    };
    return icons[this] ?? Icons.star;
  }

  Color get color {
    const colors = {
      ThemeCategory.popular: Color(0xFFFF6B35),
      ThemeCategory.nature: Color(0xFF4CAF50),
      ThemeCategory.ocean: Color(0xFF2196F3),
      ThemeCategory.sky: Color(0xFF9C27B0),
      ThemeCategory.fire: Color(0xFFFF5722),
      ThemeCategory.elegant: Color(0xFF607D8B),
      ThemeCategory.mood: Color(0xFFF44336),
      ThemeCategory.artistic: Color(0xFF673AB7),
      ThemeCategory.seasonal: Color(0xFF795548),
      ThemeCategory.fruits: Color(0xFFE91E63),
      ThemeCategory.neon: Color(0xFFE040FB),
      ThemeCategory.pastel: Color(0xFFFFB6C1),
      ThemeCategory.dark: Color(0xFF424242),
    };
    return colors[this] ?? Color(0xFFFF6B35);
  }
}

class GradientTheme {
  final String name;
  final List<Color> colors;
  final IconData icon;
  final Color primaryColor;
  final ThemeCategory category;

  const GradientTheme({
    required this.name,
    required this.colors,
    required this.icon,
    required this.primaryColor,
    required this.category,
  });
}

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  int _selectedThemeIndex = 0;

  bool get isDarkMode => _isDarkMode;
  int get selectedThemeIndex => _selectedThemeIndex;
  GradientTheme get currentTheme => gradientThemes[_selectedThemeIndex];
  Color get primaryColor => currentTheme.primaryColor;

  // 52 Beautiful Themes - Complete Collection
  static const List<GradientTheme> gradientThemes = [
    // POPULAR (8)
    GradientTheme(
      name: 'Instagram',
      colors: [Color(0xFFFF6B35), Color(0xFFE91E63), Color(0xFF9C27B0)],
      icon: Icons.camera_alt,
      primaryColor: Color(0xFFE91E63),
      category: ThemeCategory.popular,
    ),
    GradientTheme(
      name: 'Sunset',
      colors: [Color(0xFFFF5722), Color(0xFFFF9800)],
      icon: Icons.wb_twilight,
      primaryColor: Color(0xFFFF7043),
      category: ThemeCategory.popular,
    ),
    GradientTheme(
      name: 'Ocean',
      colors: [Color(0xFF2196F3), Color(0xFF00BCD4)],
      icon: Icons.water,
      primaryColor: Color(0xFF2196F3),
      category: ThemeCategory.popular,
    ),
    GradientTheme(
      name: 'Aurora',
      colors: [Color(0xFF4CAF50), Color(0xFF2196F3)],
      icon: Icons.stars,
      primaryColor: Color(0xFF4CAF50),
      category: ThemeCategory.popular,
    ),
    GradientTheme(
      name: 'Rose Gold',
      colors: [Color(0xFFE91E63), Color(0xFFFFAB91)],
      icon: Icons.auto_awesome,
      primaryColor: Color(0xFFE91E63),
      category: ThemeCategory.popular,
    ),
    GradientTheme(
      name: 'Neon',
      colors: [Color(0xFFE040FB), Color(0xFF00E5FF)],
      icon: Icons.flash_on,
      primaryColor: Color(0xFFE040FB),
      category: ThemeCategory.popular,
    ),
    GradientTheme(
      name: 'Paradise',
      colors: [Color(0xFFE91E63), Color(0xFFFFC107)],
      icon: Icons.local_florist,
      primaryColor: Color(0xFFE91E63),
      category: ThemeCategory.popular,
    ),
    GradientTheme(
      name: 'Cosmic',
      colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
      icon: Icons.rocket,
      primaryColor: Color(0xFFBA68C8),
      category: ThemeCategory.popular,
    ),

    // NATURE (6)
    GradientTheme(
      name: 'Forest',
      colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
      icon: Icons.forest,
      primaryColor: Color(0xFF2E7D32),
      category: ThemeCategory.nature,
    ),
    GradientTheme(
      name: 'Emerald',
      colors: [Color(0xFF00E676), Color(0xFF00C853)],
      icon: Icons.brightness_7,
      primaryColor: Color(0xFF00E676),
      category: ThemeCategory.nature,
    ),
    GradientTheme(
      name: 'Lime',
      colors: [Color(0xFF8BC34A), Color(0xFF4CAF50)],
      icon: Icons.eco,
      primaryColor: Color(0xFF66BB6A),
      category: ThemeCategory.nature,
    ),
    GradientTheme(
      name: 'Mountain',
      colors: [Color(0xFF81C784), Color(0xFFA5D6A7)],
      icon: Icons.terrain,
      primaryColor: Color(0xFF81C784),
      category: ThemeCategory.nature,
    ),
    GradientTheme(
      name: 'Jungle',
      colors: [Color(0xFF388E3C), Color(0xFF689F38)],
      icon: Icons.park,
      primaryColor: Color(0xFF388E3C),
      category: ThemeCategory.nature,
    ),
    GradientTheme(
      name: 'Moss',
      colors: [Color(0xFF558B2F), Color(0xFF8BC34A)],
      icon: Icons.grass,
      primaryColor: Color(0xFF558B2F),
      category: ThemeCategory.nature,
    ),

    // OCEAN (6)
    GradientTheme(
      name: 'Deep Sea',
      colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
      icon: Icons.sailing,
      primaryColor: Color(0xFF0D47A1),
      category: ThemeCategory.ocean,
    ),
    GradientTheme(
      name: 'Aqua',
      colors: [Color(0xFF00E5FF), Color(0xFF0091EA)],
      icon: Icons.water_drop,
      primaryColor: Color(0xFF00BCD4),
      category: ThemeCategory.ocean,
    ),
    GradientTheme(
      name: 'Tidal',
      colors: [Color(0xFF006064), Color(0xFF00ACC1)],
      icon: Icons.water_damage,
      primaryColor: Color(0xFF006064),
      category: ThemeCategory.ocean,
    ),
    GradientTheme(
      name: 'Mint',
      colors: [Color(0xFF00BCD4), Color(0xFF2196F3)],
      icon: Icons.ac_unit,
      primaryColor: Color(0xFF26C6DA),
      category: ThemeCategory.ocean,
    ),
    GradientTheme(
      name: 'Caribbean',
      colors: [Color(0xFF00E676), Color(0xFF64FFDA)],
      icon: Icons.sailing,
      primaryColor: Color(0xFF00E676),
      category: ThemeCategory.ocean,
    ),
    GradientTheme(
      name: 'Coral',
      colors: [Color(0xFFFF6F61), Color(0xFFFF8A80)],
      icon: Icons.waves,
      primaryColor: Color(0xFFFF6F61),
      category: ThemeCategory.ocean,
    ),

    // SKY (5)
    GradientTheme(
      name: 'Midnight',
      colors: [Color(0xFF1A237E), Color(0xFF303F9F)],
      icon: Icons.nights_stay,
      primaryColor: Color(0xFF303F9F),
      category: ThemeCategory.sky,
    ),
    GradientTheme(
      name: 'Galaxy',
      colors: [Color(0xFF4A148C), Color(0xFF8E24AA)],
      icon: Icons.star_border,
      primaryColor: Color(0xFF4A148C),
      category: ThemeCategory.sky,
    ),
    GradientTheme(
      name: 'Nebula',
      colors: [Color(0xFF3F51B5), Color(0xFF9C27B0)],
      icon: Icons.blur_on,
      primaryColor: Color(0xFF3F51B5),
      category: ThemeCategory.sky,
    ),
    GradientTheme(
      name: 'Lavender',
      colors: [Color(0xFF87CEEB), Color(0xFFDDA0DD)],
      icon: Icons.spa,
      primaryColor: Color(0xFF9C88FF),
      category: ThemeCategory.sky,
    ),
    GradientTheme(
      name: 'Violet',
      colors: [Color(0xFF7B1FA2), Color(0xFF512DA8)],
      icon: Icons.colorize,
      primaryColor: Color(0xFF7B1FA2),
      category: ThemeCategory.sky,
    ),

    // FIRE (5)
    GradientTheme(
      name: 'Blaze',
      colors: [Color(0xFFFF5722), Color(0xFFFFC107)],
      icon: Icons.local_fire_department,
      primaryColor: Color(0xFFFF5722),
      category: ThemeCategory.fire,
    ),
    GradientTheme(
      name: 'Volcanic',
      colors: [Color(0xFFBF360C), Color(0xFFFF5722)],
      icon: Icons.whatshot,
      primaryColor: Color(0xFFBF360C),
      category: ThemeCategory.fire,
    ),
    GradientTheme(
      name: 'Copper',
      colors: [Color(0xFFD84315), Color(0xFFBF360C)],
      icon: Icons.local_fire_department,
      primaryColor: Color(0xFFD84315),
      category: ThemeCategory.fire,
    ),
    GradientTheme(
      name: 'Phoenix',
      colors: [Color(0xFFFF6F00), Color(0xFFFF3D00)],
      icon: Icons.fireplace,
      primaryColor: Color(0xFFFF6F00),
      category: ThemeCategory.fire,
    ),
    GradientTheme(
      name: 'Ember',
      colors: [Color(0xFFE65100), Color(0xFFFF9800)],
      icon: Icons.whatshot,
      primaryColor: Color(0xFFE65100),
      category: ThemeCategory.fire,
    ),

    // ELEGANT (4)
    GradientTheme(
      name: 'Royal',
      colors: [Color(0xFF1A237E), Color(0xFF5C6BC0)],
      icon: Icons.diamond,
      primaryColor: Color(0xFF1A237E),
      category: ThemeCategory.elegant,
    ),
    GradientTheme(
      name: 'Platinum',
      colors: [Color(0xFF90A4AE), Color(0xFFCFD8DC)],
      icon: Icons.military_tech,
      primaryColor: Color(0xFF90A4AE),
      category: ThemeCategory.elegant,
    ),
    GradientTheme(
      name: 'Gold',
      colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
      icon: Icons.workspace_premium,
      primaryColor: Color(0xFFFFD700),
      category: ThemeCategory.elegant,
    ),
    GradientTheme(
      name: 'Champagne',
      colors: [Color(0xFFD7CCC8), Color(0xFFF3E5F5)],
      icon: Icons.wine_bar,
      primaryColor: Color(0xFFD7CCC8),
      category: ThemeCategory.elegant,
    ),

    // MOOD (4)
    GradientTheme(
      name: 'Energetic',
      colors: [Color(0xFFFF5722), Color(0xFFFFC107)],
      icon: Icons.flash_on,
      primaryColor: Color(0xFFFF5722),
      category: ThemeCategory.mood,
    ),
    GradientTheme(
      name: 'Calm',
      colors: [Color(0xFF81C784), Color(0xFFC8E6C9)],
      icon: Icons.spa,
      primaryColor: Color(0xFF81C784),
      category: ThemeCategory.mood,
    ),
    GradientTheme(
      name: 'Romantic',
      colors: [Color(0xFFE91E63), Color(0xFFF8BBD9)],
      icon: Icons.favorite,
      primaryColor: Color(0xFFE91E63),
      category: ThemeCategory.mood,
    ),
    GradientTheme(
      name: 'Focus',
      colors: [Color(0xFF3F51B5), Color(0xFF7986CB)],
      icon: Icons.center_focus_strong,
      primaryColor: Color(0xFF3F51B5),
      category: ThemeCategory.mood,
    ),

    // ARTISTIC (3)
    GradientTheme(
      name: 'Van Gogh',
      colors: [Color(0xFFFFEB3B), Color(0xFF4CAF50)],
      icon: Icons.brush,
      primaryColor: Color(0xFFFFEB3B),
      category: ThemeCategory.artistic,
    ),
    GradientTheme(
      name: 'Picasso',
      colors: [Color(0xFF2196F3), Color(0xFFFFEB3B)],
      icon: Icons.palette,
      primaryColor: Color(0xFF2196F3),
      category: ThemeCategory.artistic,
    ),
    GradientTheme(
      name: 'Monet',
      colors: [Color(0xFF81C784), Color(0xFFBA68C8)],
      icon: Icons.water_drop,
      primaryColor: Color(0xFF81C784),
      category: ThemeCategory.artistic,
    ),

    // SEASONAL (4)
    GradientTheme(
      name: 'Spring',
      colors: [Color(0xFF8BC34A), Color(0xFFFFEB3B)],
      icon: Icons.local_florist,
      primaryColor: Color(0xFF8BC34A),
      category: ThemeCategory.seasonal,
    ),
    GradientTheme(
      name: 'Summer',
      colors: [Color(0xFFFF9800), Color(0xFFFFEB3B)],
      icon: Icons.wb_sunny,
      primaryColor: Color(0xFFFF9800),
      category: ThemeCategory.seasonal,
    ),
    GradientTheme(
      name: 'Autumn',
      colors: [Color(0xFFD84315), Color(0xFFFF8F00)],
      icon: Icons.eco,
      primaryColor: Color(0xFFD84315),
      category: ThemeCategory.seasonal,
    ),
    GradientTheme(
      name: 'Winter',
      colors: [Color(0xFFE3F2FD), Color(0xFF90CAF9)],
      icon: Icons.ac_unit,
      primaryColor: Color(0xFF90CAF9),
      category: ThemeCategory.seasonal,
    ),

    // FRUITS (4)
    GradientTheme(
      name: 'Strawberry',
      colors: [Color(0xFFE91E63), Color(0xFFF06292)],
      icon: Icons.favorite,
      primaryColor: Color(0xFFE91E63),
      category: ThemeCategory.fruits,
    ),
    GradientTheme(
      name: 'Mango',
      colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
      icon: Icons.wb_sunny,
      primaryColor: Color(0xFFFFB74D),
      category: ThemeCategory.fruits,
    ),
    GradientTheme(
      name: 'Grape',
      colors: [Color(0xFF7B1FA2), Color(0xFF9C27B0)],
      icon: Icons.bubble_chart,
      primaryColor: Color(0xFF7B1FA2),
      category: ThemeCategory.fruits,
    ),
    GradientTheme(
      name: 'Orange',
      colors: [Color(0xFFFF6F00), Color(0xFFFFC107)],
      icon: Icons.circle,
      primaryColor: Color(0xFFFF6F00),
      category: ThemeCategory.fruits,
    ),

    // NEON (3)
    GradientTheme(
      name: 'Electric',
      colors: [Color(0xFFE040FB), Color(0xFF00E5FF)],
      icon: Icons.flash_on,
      primaryColor: Color(0xFFE040FB),
      category: ThemeCategory.neon,
    ),
    GradientTheme(
      name: 'Cyber',
      colors: [Color(0xFF00E676), Color(0xFF00E5FF)],
      icon: Icons.computer,
      primaryColor: Color(0xFF00E676),
      category: ThemeCategory.neon,
    ),
    GradientTheme(
      name: 'Synthwave',
      colors: [Color(0xFFE91E63), Color(0xFF9C27B0), Color(0xFF3F51B5)],
      icon: Icons.waves,
      primaryColor: Color(0xFFE91E63),
      category: ThemeCategory.neon,
    ),

    // PASTEL (3)
    GradientTheme(
      name: 'Cotton Candy',
      colors: [Color(0xFFFFB6C1), Color(0xFFE6E6FA)],
      icon: Icons.cloud,
      primaryColor: Color(0xFFFFB6C1),
      category: ThemeCategory.pastel,
    ),
    GradientTheme(
      name: 'Peach',
      colors: [Color(0xFFFFDAB9), Color(0xFFFFE4E1)],
      icon: Icons.favorite,
      primaryColor: Color(0xFFFFDAB9),
      category: ThemeCategory.pastel,
    ),
    GradientTheme(
      name: 'Baby Blue',
      colors: [Color(0xFFB3E5FC), Color(0xFFE1F5FE)],
      icon: Icons.child_care,
      primaryColor: Color(0xFFB3E5FC),
      category: ThemeCategory.pastel,
    ),

    // DARK (3)
    GradientTheme(
      name: 'Obsidian',
      colors: [Color(0xFF212121), Color(0xFF424242)],
      icon: Icons.dark_mode,
      primaryColor: Color(0xFF212121),
      category: ThemeCategory.dark,
    ),
    GradientTheme(
      name: 'Carbon',
      colors: [Color(0xFF263238), Color(0xFF37474F)],
      icon: Icons.layers,
      primaryColor: Color(0xFF263238),
      category: ThemeCategory.dark,
    ),
    GradientTheme(
      name: 'Midnight Blue',
      colors: [Color(0xFF0D47A1), Color(0xFF1A237E)],
      icon: Icons.nights_stay,
      primaryColor: Color(0xFF0D47A1),
      category: ThemeCategory.dark,
    ),
  ];

  // Getters
  LinearGradient get primaryGradient =>
      LinearGradient(colors: currentTheme.colors);
  Color get backgroundColor =>
      _isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50;
  Color get cardColor => _isDarkMode ? Colors.grey.shade800 : Colors.white;
  Color get textColor => _isDarkMode ? Colors.white : Colors.black87;
  Color get subtitleColor =>
      _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
  Color get dividerColor =>
      _isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;

  static List<GradientTheme> getThemesByCategory(ThemeCategory category) =>
      gradientThemes.where((theme) => theme.category == category).toList();

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
}

// Beautiful Theme Settings Screen
class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen>
    with SingleTickerProviderStateMixin {
  ThemeCategory? selectedCategory;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isListView = false; // Toggle between Grid and List view

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _searchController.addListener(() {
      setState(() => searchQuery = _searchController.text.toLowerCase());
    });

    _animationController.forward();
  }

  List<GradientTheme> getFilteredThemes() {
    List<GradientTheme> themes = selectedCategory != null
        ? ThemeProvider.getThemesByCategory(selectedCategory!)
        : ThemeProvider.gradientThemes;

    if (searchQuery.isNotEmpty) {
      themes = themes
          .where((theme) =>
              theme.name.toLowerCase().contains(searchQuery) ||
              theme.category.name.toLowerCase().contains(searchQuery))
          .toList();
    }
    return themes;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildGradientHeader()),
              SliverToBoxAdapter(child: _buildCurrentThemeCard()),
              SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(child: _buildControls()),
              SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(child: _buildCategoryTabs()),
              SliverToBoxAdapter(child: SizedBox(height: 16)),
              // Title View Section
              SliverToBoxAdapter(child: _buildTitleView()),
              SliverToBoxAdapter(child: SizedBox(height: 16)),
              // Toggle View Mode Section
              SliverToBoxAdapter(child: _buildViewToggle()),
              SliverToBoxAdapter(child: SizedBox(height: 16)),
              // Dynamic Content based on view mode
              _isListView ? _buildThemeListSliver() : _buildThemeGridSliver(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientHeader() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: themeProvider.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: themeProvider.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                    Colors.black.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back,
                            color: Colors.white, size: 24),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Column(
                          children: [
                            Text('Theme Gallery',
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            Text('Choose Your Perfect Style',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9))),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.shuffle, color: Colors.white),
                        onPressed: () {
                          final random = DateTime.now().millisecondsSinceEpoch %
                              ThemeProvider.gradientThemes.length;
                          themeProvider.changeTheme(random);
                          HapticFeedback.mediumImpact();
                        },
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Row(
                  children: [
                    Icon(Icons.palette, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                        '${ThemeProvider.gradientThemes.length} Beautiful Themes Available',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.category,
                        color: Colors.white.withOpacity(0.8), size: 16),
                    SizedBox(width: 6),
                    Text('${ThemeCategory.values.length} Categories',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8))),
                  ],
                ),
                SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentThemeCard() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;

    return Transform.translate(
      offset: Offset(0, 10),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: themeProvider.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: themeProvider.isDarkMode
                  ? Colors.black26
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: currentTheme.colors),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: currentTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
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
                  Row(
                    children: [
                      Text('Currently Active',
                          style: TextStyle(
                              fontSize: 12,
                              color: themeProvider.subtitleColor,
                              fontWeight: FontWeight.w500)),
                      SizedBox(width: 8),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: themeProvider.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('ACTIVE',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(currentTheme.name,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.textColor)),
                  Text('${currentTheme.category.name} Theme',
                      style: TextStyle(
                          fontSize: 14, color: themeProvider.subtitleColor)),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: themeProvider.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(currentTheme.category.icon,
                  color: themeProvider.primaryColor, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: themeProvider.cardColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: themeProvider.isDarkMode
                        ? Colors.black26
                        : Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: themeProvider.textColor),
                decoration: InputDecoration(
                  hintText: 'Search themes...',
                  hintStyle: TextStyle(color: themeProvider.subtitleColor),
                  prefixIcon:
                      Icon(Icons.search, color: themeProvider.primaryColor),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: themeProvider.primaryGradient,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: themeProvider.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  themeProvider.toggleTheme();
                  HapticFeedback.lightImpact();
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        themeProvider.isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        themeProvider.isDarkMode ? 'Light' : 'Dark',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  Widget _buildCategoryTabs() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Browse by Category',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor,
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCategoryChip(
                'All',
                ThemeProvider.gradientThemes.length,
                Icons.apps,
                themeProvider.primaryColor,
                selectedCategory == null,
                () => setState(() => selectedCategory = null),
              ),
              ...ThemeCategory.values.map((category) {
                final count =
                    ThemeProvider.getThemesByCategory(category).length;
                return _buildCategoryChip(
                  category.name,
                  count,
                  category.icon,
                  category.color,
                  selectedCategory == category,
                  () => setState(() => selectedCategory = category),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  // NEW: Title View Section
  Widget _buildTitleView() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final filteredThemes = getFilteredThemes();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, 
                   color: themeProvider.primaryColor, size: 20),
              SizedBox(width: 8),
              Text(
                'Theme Collection Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themeProvider.primaryColor.withOpacity(0.05),
                  themeProvider.primaryColor.withOpacity(0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: themeProvider.primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTitleStat(
                    '${filteredThemes.length}',
                    'Themes Found',
                    Icons.palette,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: themeProvider.dividerColor,
                ),
                Expanded(
                  child: _buildTitleStat(
                    selectedCategory?.name ?? 'All',
                    'Category',
                    Icons.category,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: themeProvider.dividerColor,
                ),
                Expanded(
                  child: _buildTitleStat(
                    _isListView ? 'List' : 'Grid',
                    'View Mode',
                    _isListView ? Icons.list : Icons.grid_view,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleStat(String value, String label, IconData icon) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Column(
      children: [
        Icon(icon, color: themeProvider.primaryColor, size: 20),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: themeProvider.textColor,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: themeProvider.subtitleColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // NEW: View Toggle Section
  Widget _buildViewToggle() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            'Display Options',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor,
            ),
          ),
          Spacer(),
          Container(
            decoration: BoxDecoration(
              color: themeProvider.cardColor,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: themeProvider.isDarkMode
                      ? Colors.black26
                      : Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildViewButton(
                  icon: Icons.grid_view,
                  label: 'Grid',
                  isSelected: !_isListView,
                  onTap: () {
                    setState(() => _isListView = false);
                    HapticFeedback.lightImpact();
                  },
                ),
                _buildViewButton(
                  icon: Icons.list,
                  label: 'List',
                  isSelected: _isListView,
                  onTap: () {
                    setState(() => _isListView = true);
                    HapticFeedback.lightImpact();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? themeProvider.primaryGradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : themeProvider.subtitleColor,
              size: 18,
            ),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : themeProvider.subtitleColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String name, int count, IconData icon, Color color,
      bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [color, color.withOpacity(0.7)])
              : null,
          color: isSelected ? null : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: color.withOpacity(0.3)),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4))
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.white : color),
            SizedBox(width: 4),
            Text(
              '$name ($count)',
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // NEW: Theme List View
  Widget _buildThemeListSliver() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final filteredThemes = getFilteredThemes();

    if (filteredThemes.isEmpty) {
      return _buildEmptyState();
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final theme = filteredThemes[index];
            final globalIndex = ThemeProvider.gradientThemes.indexOf(theme);
            final isSelected = themeProvider.selectedThemeIndex == globalIndex;

            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 400 + (index * 50)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: Container(
                      margin: EdgeInsets.only(bottom: 12),
                      child: _buildThemeListItem(theme, globalIndex, isSelected),
                    ),
                  ),
                );
              },
            );
          },
          childCount: filteredThemes.length,
        ),
      ),
    );
  }

  Widget _buildThemeListItem(
      GradientTheme theme, int globalIndex, bool isSelected) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        themeProvider.changeTheme(globalIndex);
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeProvider.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: isSelected 
              ? Border.all(color: themeProvider.primaryColor, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: themeProvider.isDarkMode
                  ? Colors.black26
                  : Colors.grey.withOpacity(0.1),
              blurRadius: isSelected ? 12 : 6,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Theme Preview
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: theme.colors),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(theme.icon, color: Colors.white, size: 24),
            ),
            SizedBox(width: 16),
            // Theme Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        theme.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.textColor,
                        ),
                      ),
                      if (isSelected) ...[
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: themeProvider.primaryGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'ACTIVE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.category.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              theme.category.icon,
                              size: 12,
                              color: theme.category.color,
                            ),
                            SizedBox(width: 4),
                            Text(
                              theme.category.name,
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.category.color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      // Color Dots
                      Row(
                        children: theme.colors.take(3).map((color) {
                          return Container(
                            width: 12,
                            height: 12,
                            margin: EdgeInsets.only(left: 2),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Action Icon
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? themeProvider.primaryColor.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isSelected ? Icons.check_circle : Icons.arrow_forward_ios,
                color: isSelected 
                    ? themeProvider.primaryColor
                    : themeProvider.subtitleColor,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeGridSliver() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final filteredThemes = getFilteredThemes();

    if (filteredThemes.isEmpty) {
      return _buildEmptyState();
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final theme = filteredThemes[index];
            final globalIndex = ThemeProvider.gradientThemes.indexOf(theme);
            final isSelected = themeProvider.selectedThemeIndex == globalIndex;

            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 600 + (index * 50)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: _buildThemeCard(theme, globalIndex, isSelected),
                  ),
                );
              },
            );
          },
          childCount: filteredThemes.length,
        ),
      ),
    );
  }

  Widget _buildThemeCard(
      GradientTheme theme, int globalIndex, bool isSelected) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        themeProvider.changeTheme(globalIndex);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: theme.colors),
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(isSelected ? 0.6 : 0.3),
              blurRadius: isSelected ? 12 : 6,
              offset: Offset(0, isSelected ? 6 : 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Category badge
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(theme.category.icon, color: Colors.white, size: 10),
              ),
            ),
            // Main content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  padding: EdgeInsets.all(isSelected ? 8 : 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(isSelected ? 0.2 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSelected ? Icons.check_circle : theme.icon,
                    color: Colors.white,
                    size: isSelected ? 24 : 20,
                  ),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    theme.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected) ...[
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return SliverToBoxAdapter(
      child: Container(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: themeProvider.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.search_off, size: 40, color: Colors.white),
              ),
              SizedBox(height: 16),
              Text('No themes found',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: themeProvider.subtitleColor)),
              Text('Try adjusting your search or category filter',
                  style: TextStyle(
                      fontSize: 14, color: themeProvider.subtitleColor)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}