// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  Color _primaryColor = Color(0xFFFFC870);

  bool get isDarkMode => _isDarkMode;
  Color get primaryColor => _primaryColor;

  // เพิ่ม getter สำหรับสีต่างๆ ที่ใช้ทั่วทั้งแอป
  Color get backgroundColor =>
      _isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50;
  Color get cardColor => _isDarkMode ? Colors.grey.shade800 : Colors.white;
  Color get textColor => _isDarkMode ? Colors.white : Colors.black87;
  Color get subtitleColor =>
      _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
  Color get dividerColor =>
      _isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;

  // สีสำหรับ input fields
  Color get inputFillColor => _isDarkMode ? Colors.grey.shade800 : Colors.white;
  Color get inputBorderColor =>
      _isDarkMode ? Colors.grey.shade600 : Color(0xffC5C5C5);

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
