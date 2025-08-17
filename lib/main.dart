import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flowtrack/widgets/bottomnavigationbar.dart';
import 'package:flowtrack/data/services/database_services.dart';
import 'package:flowtrack/data/migration_helper.dart';
import 'package:flowtrack/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await DatabaseService.init();
    await MigrationHelper.migrateOldData();
  } catch (e) {
    print('Database error: $e');
  }
  
  runApp(const FlowTrackApp());
}

class FlowTrackApp extends StatelessWidget {
  const FlowTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider()..loadTheme(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'FlowTrack',
            theme: _buildTheme(themeProvider.primaryColor, false),
            darkTheme: _buildTheme(themeProvider.primaryColor, true),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: Bottom(),
          );
        },
      ),
    );
  }

  ThemeData _buildTheme(Color primaryColor, bool isDark) {
    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}