// lib/providers/theme_provider.dart - จัดการ Theme
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  Color _primaryColor = Color(0xFFFFC870);

  bool get isDarkMode => _isDarkMode;
  Color get primaryColor => _primaryColor;

  // เปลี่ยน Dark/Light Mode
  toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  // เปลี่ยนสีหลัก
  changeColor(Color color) async {
    _primaryColor = color;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('primaryColor', color.value);
    notifyListeners();
  }

  // โหลดการตั้งค่า
  loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _primaryColor = Color(prefs.getInt('primaryColor') ?? 0xFFFFC870);
    notifyListeners();
  }
}

// lib/screens/theme_settings.dart - หน้าตั้งค่า Theme
class ThemeSettingsScreen extends StatelessWidget {
  final List<Color> colors = [
    Color(0xFFFFC870), // เดิม
    Color(0xFF2196F3), // น้ำเงิน
    Color(0xFF4CAF50), // เขียว
    Color(0xFFE91E63), // ชมพู
    Color(0xFFFF5722), // ส้ม
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Theme Settings')),
      body: Column(
        children: [
          // Dark/Light Mode Toggle
          SwitchListTile(
            title: Text('Dark Mode'),
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (bool value) {
              // Provider.of<ThemeProvider>(context).toggleTheme();
            },
          ),

          // Color Picker
          Text('Choose Primary Color:', style: TextStyle(fontSize: 18)),
          Wrap(
            children: colors
                .map((color) => GestureDetector(
                      onTap: () {
                        // Provider.of<ThemeProvider>(context).changeColor(color);
                      },
                      child: Container(
                        margin: EdgeInsets.all(8),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
