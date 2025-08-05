import 'package:flutter/material.dart';
import 'package:flowtrack/widgets/bottomnavigationbar.dart';
import 'package:flowtrack/data/services/database_services.dart';
import 'package:flowtrack/data/migration_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.init(); // Initialize the new database structure
  await MigrationHelper.migrateOldData(); // Migrate old data if it exists
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: Bottom());
  }
}