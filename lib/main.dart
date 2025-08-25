// lib/main.dart - Fixed Version with No Errors
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flowtrack/data/services/database_services.dart';
import 'package:flowtrack/data/migration_helper.dart';
import 'package:flowtrack/screens/theme_settings.dart'; // Gradient ThemeProvider
import 'package:flowtrack/providers/user_provider.dart';
import 'package:flowtrack/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await DatabaseService.init();
    await MigrationHelper.migrateOldData();
  } catch (e) {
    print('Database error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
        ChangeNotifierProvider(create: (_) => UserProvider()..loadUserData()),
      ],
      child: const FlowTrackApp(),
    ),
  );
}

class FlowTrackApp extends StatelessWidget {
  const FlowTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'FlowTrack',
          theme: _buildTheme(themeProvider, false),
          darkTheme: _buildTheme(themeProvider, true),
          themeMode:
              themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: SplashScreen(), // เปลี่ยนจาก Bottom() เป็น SplashScreen()
        );
      },
    );
  }

  ThemeData _buildTheme(ThemeProvider themeProvider, bool isDark) {
    final primaryColor = themeProvider.primaryColor;
    final currentTheme = themeProvider.currentTheme;

    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: primaryColor,

      // Color Scheme with Gradient Support
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),

      // Background Colors
      scaffoldBackgroundColor: themeProvider.backgroundColor,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      // FloatingActionButton
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: themeProvider.cardColor,
        elevation: 2,
        shadowColor: isDark
            ? Colors.black.withOpacity(0.3)
            : Colors.grey.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: themeProvider.cardColor,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: themeProvider.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: themeProvider.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: TextStyle(color: themeProvider.subtitleColor),
        hintStyle: TextStyle(color: themeProvider.subtitleColor),
      ),

      // Text Theme
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: themeProvider.textColor,
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
        headlineMedium: TextStyle(
          color: themeProvider.textColor,
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
        headlineSmall: TextStyle(
          color: themeProvider.textColor,
          fontWeight: FontWeight.w600,
          fontSize: 24,
        ),
        titleLarge: TextStyle(
          color: themeProvider.textColor,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        titleMedium: TextStyle(
          color: themeProvider.textColor,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        bodyLarge: TextStyle(
          color: themeProvider.textColor,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: themeProvider.textColor,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: themeProvider.subtitleColor,
          fontSize: 12,
        ),
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: themeProvider.textColor,
        size: 24,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: themeProvider.dividerColor,
        thickness: 1,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return themeProvider.subtitleColor;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor.withOpacity(0.3);
          }
          return themeProvider.dividerColor;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Progress Indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: themeProvider.dividerColor,
        circularTrackColor: themeProvider.dividerColor,
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: themeProvider.cardColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: themeProvider.subtitleColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Snack Bar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade700,
        contentTextStyle: TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // List Tile
      listTileTheme: ListTileThemeData(
        textColor: themeProvider.textColor,
        iconColor: themeProvider.textColor,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
