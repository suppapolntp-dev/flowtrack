import 'package:flutter/material.dart';
import 'package:flowtrack/widgets/bottomnavigationbar.dart';
import 'package:flowtrack/data/services/database_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await DatabaseService.init();
    print('Database initialized successfully');
  } catch (e) {
    print('Database initialization error: $e');
    // ยังคงรันแอปต่อไป
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      home: Bottom()
    );
  }
}