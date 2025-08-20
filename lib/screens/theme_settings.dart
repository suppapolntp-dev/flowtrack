// lib/screens/theme_settings.dart - Compact Version
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeCategory {
  popular,
  nature,
  ocean,
  fruits,
  sky,
  fire,
  mystic,
  elegant,
  seasonal,
  urban,
  tropical,
  mood,
  timeBased,
  artistic,
  geographic,
  professional,
  purpose
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
      ThemeCategory.fruits: Icons.apple,
      ThemeCategory.sky: Icons.cloud,
      ThemeCategory.fire: Icons.local_fire_department,
      ThemeCategory.mystic: Icons.auto_fix_high,
      ThemeCategory.elegant: Icons.diamond,
      ThemeCategory.seasonal: Icons.calendar_today,
      ThemeCategory.urban: Icons.location_city,
      ThemeCategory.tropical: Icons.beach_access,
      ThemeCategory.mood: Icons.mood,
      ThemeCategory.timeBased: Icons.access_time,
      ThemeCategory.artistic: Icons.palette,
      ThemeCategory.geographic: Icons.public,
      ThemeCategory.professional: Icons.work,
      ThemeCategory.purpose: Icons.flag,
    };
    return icons[this] ?? Icons.star;
  }

  Color get color {
    const colors = {
      ThemeCategory.popular: Color(0xFFFF6B35),
      ThemeCategory.nature: Color(0xFF4CAF50),
      ThemeCategory.ocean: Color(0xFF2196F3),
      ThemeCategory.fruits: Color(0xFFE91E63),
      ThemeCategory.sky: Color(0xFF9C27B0),
      ThemeCategory.fire: Color(0xFFFF5722),
      ThemeCategory.mystic: Color(0xFF7B1FA2),
      ThemeCategory.elegant: Color(0xFF607D8B),
      ThemeCategory.seasonal: Color(0xFF795548),
      ThemeCategory.urban: Color(0xFF455A64),
      ThemeCategory.tropical: Color(0xFF009688),
      ThemeCategory.mood: Color(0xFFF44336),
      ThemeCategory.timeBased: Color(0xFF3F51B5),
      ThemeCategory.artistic: Color(0xFF673AB7),
      ThemeCategory.geographic: Color(0xFF00BCD4),
      ThemeCategory.professional: Color(0xFF37474F),
      ThemeCategory.purpose: Color(0xFFFF9800),
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
  final String description;

  const GradientTheme({
    required this.name,
    required this.colors,
    required this.icon,
    required this.primaryColor,
    required this.category,
    required this.description,
  });
}

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  int _selectedThemeIndex = 0;

  bool get isDarkMode => _isDarkMode;
  int get selectedThemeIndex => _selectedThemeIndex;
  GradientTheme get currentTheme => gradientThemes[_selectedThemeIndex];
  Color get primaryColor => currentTheme.primaryColor;

  // 51 Compact Themes - Organized by Category
  static const List<GradientTheme> gradientThemes = [
    // POPULAR (6)
    GradientTheme(
        name: 'Instagram',
        colors: [Color(0xFFFF6B35), Color(0xFFE91E63), Color(0xFF9C27B0)],
        icon: Icons.camera_alt,
        primaryColor: Color(0xFFE91E63),
        category: ThemeCategory.popular,
        description: 'Social media gradient'),
    GradientTheme(
        name: 'Sunset',
        colors: [Color(0xFFFF5722), Color(0xFFFF9800)],
        icon: Icons.wb_twilight,
        primaryColor: Color(0xFFFF7043),
        category: ThemeCategory.popular,
        description: 'Warm sunset'),
    GradientTheme(
        name: 'Ocean',
        colors: [Color(0xFF2196F3), Color(0xFF00BCD4)],
        icon: Icons.water,
        primaryColor: Color(0xFF2196F3),
        category: ThemeCategory.popular,
        description: 'Cool ocean blue'),
    GradientTheme(
        name: 'Aurora',
        colors: [Color(0xFF4CAF50), Color(0xFF2196F3)],
        icon: Icons.stars,
        primaryColor: Color(0xFF4CAF50),
        category: ThemeCategory.popular,
        description: 'Northern lights'),
    GradientTheme(
        name: 'Rose Gold',
        colors: [Color(0xFFE91E63), Color(0xFFFFAB91)],
        icon: Icons.auto_awesome,
        primaryColor: Color(0xFFE91E63),
        category: ThemeCategory.popular,
        description: 'Luxury rose gold'),
    GradientTheme(
        name: 'Neon',
        colors: [Color(0xFFE040FB), Color(0xFF00E5FF)],
        icon: Icons.flash_on,
        primaryColor: Color(0xFFE040FB),
        category: ThemeCategory.popular,
        description: 'Electric vibes'),

    // NATURE (4)
    GradientTheme(
        name: 'Forest',
        colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
        icon: Icons.forest,
        primaryColor: Color(0xFF2E7D32),
        category: ThemeCategory.nature,
        description: 'Deep forest'),
    GradientTheme(
        name: 'Jungle',
        colors: [Color(0xFF388E3C), Color(0xFF689F38)],
        icon: Icons.park,
        primaryColor: Color(0xFF388E3C),
        category: ThemeCategory.nature,
        description: 'Lush jungle'),
    GradientTheme(
        name: 'Emerald',
        colors: [Color(0xFF00E676), Color(0xFF00C853)],
        icon: Icons.brightness_7,
        primaryColor: Color(0xFF00E676),
        category: ThemeCategory.nature,
        description: 'Precious emerald'),
    GradientTheme(
        name: 'Mountain',
        colors: [Color(0xFF81C784), Color(0xFFA5D6A7)],
        icon: Icons.terrain,
        primaryColor: Color(0xFF81C784),
        category: ThemeCategory.nature,
        description: 'Mountain mist'),

    // OCEAN (4)
    GradientTheme(
        name: 'Deep Sea',
        colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
        icon: Icons.sailing,
        primaryColor: Color(0xFF0D47A1),
        category: ThemeCategory.ocean,
        description: 'Ocean depths'),
    GradientTheme(
        name: 'Coral',
        colors: [Color(0xFFFF6F61), Color(0xFFFF8A80)],
        icon: Icons.waves,
        primaryColor: Color(0xFFFF6F61),
        category: ThemeCategory.ocean,
        description: 'Coral reef'),
    GradientTheme(
        name: 'Arctic',
        colors: [Color(0xFF81D4FA), Color(0xFFB3E5FC)],
        icon: Icons.ac_unit,
        primaryColor: Color(0xFF81D4FA),
        category: ThemeCategory.ocean,
        description: 'Arctic ice'),
    GradientTheme(
        name: 'Tidal',
        colors: [Color(0xFF006064), Color(0xFF00ACC1)],
        icon: Icons.water_damage,
        primaryColor: Color(0xFF006064),
        category: ThemeCategory.ocean,
        description: 'Ocean waves'),

    // FRUITS (4)
    GradientTheme(
        name: 'Strawberry',
        colors: [Color(0xFFE91E63), Color(0xFFF06292)],
        icon: Icons.favorite,
        primaryColor: Color(0xFFE91E63),
        category: ThemeCategory.fruits,
        description: 'Sweet strawberry'),
    GradientTheme(
        name: 'Mango',
        colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
        icon: Icons.wb_sunny,
        primaryColor: Color(0xFFFFB74D),
        category: ThemeCategory.fruits,
        description: 'Tropical mango'),
    GradientTheme(
        name: 'Grape',
        colors: [Color(0xFF7B1FA2), Color(0xFF9C27B0)],
        icon: Icons.bubble_chart,
        primaryColor: Color(0xFF7B1FA2),
        category: ThemeCategory.fruits,
        description: 'Rich grape'),
    GradientTheme(
        name: 'Citrus',
        colors: [Color(0xFFFF6F00), Color(0xFFFFC107)],
        icon: Icons.circle,
        primaryColor: Color(0xFFFF6F00),
        category: ThemeCategory.fruits,
        description: 'Zesty citrus'),

    // SKY (4)
    GradientTheme(
        name: 'Midnight',
        colors: [Color(0xFF1A237E), Color(0xFF303F9F)],
        icon: Icons.nights_stay,
        primaryColor: Color(0xFF303F9F),
        category: ThemeCategory.sky,
        description: 'Midnight sky'),
    GradientTheme(
        name: 'Galaxy',
        colors: [Color(0xFF4A148C), Color(0xFF8E24AA)],
        icon: Icons.star_border,
        primaryColor: Color(0xFF4A148C),
        category: ThemeCategory.sky,
        description: 'Galaxy purple'),
    GradientTheme(
        name: 'Cosmic',
        colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
        icon: Icons.rocket,
        primaryColor: Color(0xFFBA68C8),
        category: ThemeCategory.sky,
        description: 'Cosmic space'),
    GradientTheme(
        name: 'Nebula',
        colors: [Color(0xFF3F51B5), Color(0xFF9C27B0)],
        icon: Icons.blur_on,
        primaryColor: Color(0xFF3F51B5),
        category: ThemeCategory.sky,
        description: 'Space nebula'),

    // FIRE (3)
    GradientTheme(
        name: 'Blaze',
        colors: [Color(0xFFFF5722), Color(0xFFFFC107)],
        icon: Icons.local_fire_department,
        primaryColor: Color(0xFFFF5722),
        category: ThemeCategory.fire,
        description: 'Blazing fire'),
    GradientTheme(
        name: 'Volcanic',
        colors: [Color(0xFFBF360C), Color(0xFFFF5722)],
        icon: Icons.whatshot,
        primaryColor: Color(0xFFBF360C),
        category: ThemeCategory.fire,
        description: 'Volcanic lava'),
    GradientTheme(
        name: 'Inferno',
        colors: [Color(0xFFD32F2F), Color(0xFFFF5722)],
        icon: Icons.fireplace,
        primaryColor: Color(0xFFD32F2F),
        category: ThemeCategory.fire,
        description: 'Burning flame'),

    // MYSTIC (3)
    GradientTheme(
        name: 'Mystic',
        colors: [Color(0xFF7E57C2), Color(0xFF9575CD)],
        icon: Icons.auto_fix_high,
        primaryColor: Color(0xFF7E57C2),
        category: ThemeCategory.mystic,
        description: 'Purple aura'),
    GradientTheme(
        name: 'Enchanted',
        colors: [Color(0xFF4A148C), Color(0xFF9C27B0)],
        icon: Icons.stars,
        primaryColor: Color(0xFF4A148C),
        category: ThemeCategory.mystic,
        description: 'Magical forest'),
    GradientTheme(
        name: 'Spell',
        colors: [Color(0xFF512DA8), Color(0xFF9FA8DA)],
        icon: Icons.auto_fix_normal,
        primaryColor: Color(0xFF512DA8),
        category: ThemeCategory.mystic,
        description: 'Spell colors'),

    // ELEGANT (3)
    GradientTheme(
        name: 'Royal',
        colors: [Color(0xFF1A237E), Color(0xFF5C6BC0)],
        icon: Icons.diamond,
        primaryColor: Color(0xFF1A237E),
        category: ThemeCategory.elegant,
        description: 'Royal blue'),
    GradientTheme(
        name: 'Platinum',
        colors: [Color(0xFF90A4AE), Color(0xFFCFD8DC)],
        icon: Icons.military_tech,
        primaryColor: Color(0xFF90A4AE),
        category: ThemeCategory.elegant,
        description: 'Platinum metal'),
    GradientTheme(
        name: 'Champagne',
        colors: [Color(0xFFD7CCC8), Color(0xFFF3E5F5)],
        icon: Icons.wine_bar,
        primaryColor: Color(0xFFD7CCC8),
        category: ThemeCategory.elegant,
        description: 'Champagne gold'),

    // SEASONAL (4)
    GradientTheme(
        name: 'Spring',
        colors: [Color(0xFF8BC34A), Color(0xFFFFEB3B)],
        icon: Icons.local_florist,
        primaryColor: Color(0xFF8BC34A),
        category: ThemeCategory.seasonal,
        description: 'Spring bloom'),
    GradientTheme(
        name: 'Summer',
        colors: [Color(0xFFFF9800), Color(0xFFFFEB3B)],
        icon: Icons.wb_sunny,
        primaryColor: Color(0xFFFF9800),
        category: ThemeCategory.seasonal,
        description: 'Summer heat'),
    GradientTheme(
        name: 'Autumn',
        colors: [Color(0xFFD84315), Color(0xFFFF8F00)],
        icon: Icons.eco,
        primaryColor: Color(0xFFD84315),
        category: ThemeCategory.seasonal,
        description: 'Autumn leaves'),
    GradientTheme(
        name: 'Winter',
        colors: [Color(0xFFE3F2FD), Color(0xFF90CAF9)],
        icon: Icons.ac_unit,
        primaryColor: Color(0xFF90CAF9),
        category: ThemeCategory.seasonal,
        description: 'Winter frost'),

    // URBAN (3)
    GradientTheme(
        name: 'Neon City',
        colors: [Color(0xFFE91E63), Color(0xFF00E5FF)],
        icon: Icons.location_city,
        primaryColor: Color(0xFFE91E63),
        category: ThemeCategory.urban,
        description: 'City lights'),
    GradientTheme(
        name: 'Metro',
        colors: [Color(0xFF37474F), Color(0xFF607D8B)],
        icon: Icons.train,
        primaryColor: Color(0xFF37474F),
        category: ThemeCategory.urban,
        description: 'Metro steel'),
    GradientTheme(
        name: 'Industrial',
        colors: [Color(0xFF424242), Color(0xFF757575)],
        icon: Icons.factory,
        primaryColor: Color(0xFF424242),
        category: ThemeCategory.urban,
        description: 'Industrial'),

    // TROPICAL (3)
    GradientTheme(
        name: 'Hawaiian',
        colors: [Color(0xFF00ACC1), Color(0xFF4DD0E1)],
        icon: Icons.beach_access,
        primaryColor: Color(0xFF00ACC1),
        category: ThemeCategory.tropical,
        description: 'Hawaiian ocean'),
    GradientTheme(
        name: 'Caribbean',
        colors: [Color(0xFF00E676), Color(0xFF64FFDA)],
        icon: Icons.sailing,
        primaryColor: Color(0xFF00E676),
        category: ThemeCategory.tropical,
        description: 'Caribbean turquoise'),
    GradientTheme(
        name: 'Bali',
        colors: [Color(0xFFFF6F00), Color(0xFFFFA000)],
        icon: Icons.flight,
        primaryColor: Color(0xFFFF6F00),
        category: ThemeCategory.tropical,
        description: 'Bali sunset'),

    // MOOD (4)
    GradientTheme(
        name: 'Energetic',
        colors: [Color(0xFFFF5722), Color(0xFFFFC107)],
        icon: Icons.flash_on,
        primaryColor: Color(0xFFFF5722),
        category: ThemeCategory.mood,
        description: 'High energy'),
    GradientTheme(
        name: 'Calm',
        colors: [Color(0xFF81C784), Color(0xFFC8E6C9)],
        icon: Icons.spa,
        primaryColor: Color(0xFF81C784),
        category: ThemeCategory.mood,
        description: 'Peaceful calm'),
    GradientTheme(
        name: 'Romantic',
        colors: [Color(0xFFE91E63), Color(0xFFF8BBD9)],
        icon: Icons.favorite,
        primaryColor: Color(0xFFE91E63),
        category: ThemeCategory.mood,
        description: 'Love romance'),
    GradientTheme(
        name: 'Focus',
        colors: [Color(0xFF3F51B5), Color(0xFF7986CB)],
        icon: Icons.center_focus_strong,
        primaryColor: Color(0xFF3F51B5),
        category: ThemeCategory.mood,
        description: 'Deep focus'),

    // TIME-BASED (5)
    GradientTheme(
        name: 'Dawn',
        colors: [Color(0xFFFFC107), Color(0xFFF8BBD9)],
        icon: Icons.wb_twilight,
        primaryColor: Color(0xFFFFC107),
        category: ThemeCategory.timeBased,
        description: 'Early dawn'),
    GradientTheme(
        name: 'Morning',
        colors: [Color(0xFF2196F3), Color(0xFF00BCD4)],
        icon: Icons.wb_sunny,
        primaryColor: Color(0xFF2196F3),
        category: ThemeCategory.timeBased,
        description: 'Fresh morning'),
    GradientTheme(
        name: 'Noon',
        colors: [Color(0xFFFFEB3B), Color(0xFFFF9800)],
        icon: Icons.light_mode,
        primaryColor: Color(0xFFFFEB3B),
        category: ThemeCategory.timeBased,
        description: 'Bright noon'),
    GradientTheme(
        name: 'Evening',
        colors: [Color(0xFFFF5722), Color(0xFFFFC107)],
        icon: Icons.wb_twilight,
        primaryColor: Color(0xFFFF5722),
        category: ThemeCategory.timeBased,
        description: 'Golden evening'),
    GradientTheme(
        name: 'Night',
        colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
        icon: Icons.nights_stay,
        primaryColor: Color(0xFF1A237E),
        category: ThemeCategory.timeBased,
        description: 'Deep night'),

    // ARTISTIC (4)
    GradientTheme(
        name: 'Van Gogh',
        colors: [Color(0xFFFFEB3B), Color(0xFF4CAF50)],
        icon: Icons.brush,
        primaryColor: Color(0xFFFFEB3B),
        category: ThemeCategory.artistic,
        description: 'Starry night'),
    GradientTheme(
        name: 'Picasso',
        colors: [Color(0xFF2196F3), Color(0xFFFFEB3B)],
        icon: Icons.palette,
        primaryColor: Color(0xFF2196F3),
        category: ThemeCategory.artistic,
        description: 'Cubist colors'),
    GradientTheme(
        name: 'Monet',
        colors: [Color(0xFF81C784), Color(0xFFBA68C8)],
        icon: Icons.water_drop,
        primaryColor: Color(0xFF81C784),
        category: ThemeCategory.artistic,
        description: 'Water lilies'),
    GradientTheme(
        name: 'Modern Art',
        colors: [Color(0xFFE91E63), Color(0xFF673AB7)],
        icon: Icons.art_track,
        primaryColor: Color(0xFFE91E63),
        category: ThemeCategory.artistic,
        description: 'Abstract art'),

    // GEOGRAPHIC (4)
    GradientTheme(
        name: 'Asian',
        colors: [Color(0xFF4CAF50), Color(0xFFCDDC39)],
        icon: Icons.temple_buddhist,
        primaryColor: Color(0xFF4CAF50),
        category: ThemeCategory.geographic,
        description: 'Asian zen'),
    GradientTheme(
        name: 'European',
        colors: [Color(0xFF607D8B), Color(0xFFB0BEC5)],
        icon: Icons.account_balance,
        primaryColor: Color(0xFF607D8B),
        category: ThemeCategory.geographic,
        description: 'European classic'),
    GradientTheme(
        name: 'African',
        colors: [Color(0xFFFF6F00), Color(0xFFFFA000)],
        icon: Icons.terrain,
        primaryColor: Color(0xFFFF6F00),
        category: ThemeCategory.geographic,
        description: 'African safari'),
    GradientTheme(
        name: 'Nordic',
        colors: [Color(0xFF90A4AE), Color(0xFFECEFF1)],
        icon: Icons.ac_unit,
        primaryColor: Color(0xFF90A4AE),
        category: ThemeCategory.geographic,
        description: 'Nordic minimal'),

    // PROFESSIONAL (4)
    GradientTheme(
        name: 'Corporate',
        colors: [Color(0xFF1976D2), Color(0xFF2196F3)],
        icon: Icons.business,
        primaryColor: Color(0xFF1976D2),
        category: ThemeCategory.professional,
        description: 'Corporate blue'),
    GradientTheme(
        name: 'Creative',
        colors: [Color(0xFFE91E63), Color(0xFF673AB7)],
        icon: Icons.create,
        primaryColor: Color(0xFFE91E63),
        category: ThemeCategory.professional,
        description: 'Creative industry'),
    GradientTheme(
        name: 'Medical',
        colors: [Color(0xFF00E676), Color(0xFF64FFDA)],
        icon: Icons.local_hospital,
        primaryColor: Color(0xFF00E676),
        category: ThemeCategory.professional,
        description: 'Medical clean'),
    GradientTheme(
        name: 'Tech',
        colors: [Color(0xFF263238), Color(0xFF455A64)],
        icon: Icons.computer,
        primaryColor: Color(0xFF263238),
        category: ThemeCategory.professional,
        description: 'Tech modern'),

    // PURPOSE (4)
    GradientTheme(
        name: 'Study',
        colors: [Color(0xFF3F51B5), Color(0xFF7986CB)],
        icon: Icons.school,
        primaryColor: Color(0xFF3F51B5),
        category: ThemeCategory.purpose,
        description: 'Study focus'),
    GradientTheme(
        name: 'Work',
        colors: [Color(0xFF455A64), Color(0xFF607D8B)],
        icon: Icons.work,
        primaryColor: Color(0xFF455A64),
        category: ThemeCategory.purpose,
        description: 'Work productive'),
    GradientTheme(
        name: 'Relax',
        colors: [Color(0xFF81C784), Color(0xFFC8E6C9)],
        icon: Icons.self_improvement,
        primaryColor: Color(0xFF81C784),
        category: ThemeCategory.purpose,
        description: 'Relax peaceful'),
    GradientTheme(
        name: 'Exercise',
        colors: [Color(0xFFFF5722), Color(0xFFFF8A65)],
        icon: Icons.fitness_center,
        primaryColor: Color(0xFFFF5722),
        category: ThemeCategory.purpose,
        description: 'High energy workout'),
  ];

  // Getters & Methods
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

// Compact Theme Settings Screen
class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  ThemeCategory? selectedCategory;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => searchQuery = _searchController.text.toLowerCase());
    });
  }

  List<GradientTheme> getFilteredThemes() {
    List<GradientTheme> themes = selectedCategory != null
        ? ThemeProvider.getThemesByCategory(selectedCategory!)
        : ThemeProvider.gradientThemes;

    if (searchQuery.isNotEmpty) {
      themes = themes
          .where((theme) =>
              theme.name.toLowerCase().contains(searchQuery) ||
              theme.description.toLowerCase().contains(searchQuery) ||
              theme.category.name.toLowerCase().contains(searchQuery))
          .toList();
    }
    return themes;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final filteredThemes = getFilteredThemes();

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        title: Text('Themes (${ThemeProvider.gradientThemes.length})'),
        flexibleSpace: Container(
            decoration: BoxDecoration(gradient: themeProvider.primaryGradient)),
        actions: [
          IconButton(
            icon: Icon(Icons.shuffle, color: Colors.white),
            onPressed: () {
              final random = DateTime.now().millisecondsSinceEpoch %
                  ThemeProvider.gradientThemes.length;
              themeProvider.changeTheme(random);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Dark Mode
          Container(
            margin: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search themes...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: themeProvider.cardColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        gradient: themeProvider.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Switch(
                        value: themeProvider.isDarkMode,
                        onChanged: (_) => themeProvider.toggleTheme(),
                        activeColor: Colors.white,
                        activeTrackColor: Colors.white24,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                // Category Filter
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
                        () => setState(() => selectedCategory = null)),
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
          ),

          // Theme Grid
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: filteredThemes.length,
              itemBuilder: (context, index) {
                final theme = filteredThemes[index];
                final globalIndex = ThemeProvider.gradientThemes.indexOf(theme);
                final isSelected =
                    themeProvider.selectedThemeIndex == globalIndex;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    themeProvider.changeTheme(globalIndex);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: theme.colors),
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor
                              .withOpacity(isSelected ? 0.6 : 0.3),
                          blurRadius: isSelected ? 16 : 8,
                          offset: Offset(0, isSelected ? 8 : 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Category badge
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(theme.category.icon,
                                color: Colors.white, size: 12),
                          ),
                        ),
                        // Main content
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isSelected ? Icons.check_circle : theme.icon,
                              color: Colors.white,
                              size: isSelected ? 32 : 28,
                            ),
                            SizedBox(height: 8),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                theme.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
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
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'ACTIVE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
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
              },
            ),
          ),

          // Stats Footer
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeProvider.cardColor,
              border:
                  Border(top: BorderSide(color: themeProvider.dividerColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('${filteredThemes.length}', 'Found'),
                _buildStat('17', 'Categories'),
                _buildStat('${ThemeProvider.gradientThemes.length * 2}',
                    'Combinations'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String name, int count, IconData icon, Color color,
      bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // ลบ margin: EdgeInsets.only(right: 8), ออก
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [color, color.withOpacity(0.7)])
              : null,
          color: isSelected ? null : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : color),
            SizedBox(width: 4),
            Text(
              '$name ($count)',
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: themeProvider.primaryColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: themeProvider.subtitleColor,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
