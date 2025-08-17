// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  Color _primaryColor = Color(0xFFFFC870);

  bool get isDarkMode => _isDarkMode;
  Color get primaryColor => _primaryColor;

  toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  changeColor(Color color) async {
    _primaryColor = color;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('primaryColor', color.value);
    notifyListeners();
  }

  loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _primaryColor = Color(prefs.getInt('primaryColor') ?? 0xFFFFC870);
    notifyListeners();
  }
}