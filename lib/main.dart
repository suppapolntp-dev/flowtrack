import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flowtrack/widgets/bottomnavigationbar.dart';
import 'package:flowtrack/data/services/database_services.dart';
import 'package:flowtrack/data/migration_helper.dart';

// Import สำหรับ runZonedGuarded
import 'dart:async';
import 'dart:ui';

void main() async {
  // จัดการ error ก่อนเริ่ม app
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // จัดการ error ใน Flutter framework
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      print('Flutter Error: ${details.exception}');
      print('Stack trace: ${details.stack}');
      
      // หาก error ร้ายแรง ให้ restart app
      if (details.exception.toString().contains('RenderFlex') || 
          details.exception.toString().contains('MouseTracker') ||
          details.exception.toString().contains('Failed assertion')) {
        print('Critical error detected, restarting app...');
        _restartApp();
      }
    };

    // จัดการ error ที่ไม่ได้ handle
    PlatformDispatcher.instance.onError = (error, stack) {
      print('Unhandled Error: $error');
      print('Stack trace: $stack');
      
      // หาก error ร้ายแรง ให้ restart app
      if (error.toString().contains('MouseTracker') ||
          error.toString().contains('Failed assertion') ||
          error.toString().contains('RenderObject')) {
        print('Critical platform error detected, restarting app...');
        _restartApp();
      }
      return true;
    };
    
    try {
      await DatabaseService.init();
      await MigrationHelper.migrateOldData();
      print('Database initialized successfully');
    } catch (e) {
      print('Database initialization error: $e');
      // ยังคงรันแอปต่อไป
    }
    
    runApp(const BugProofApp());
    
  }, (error, stack) {
    print('Zone Error: $error');
    print('Stack trace: $stack');
    
    // หาก error ร้ายแรง ให้ restart app
    if (error.toString().contains('MouseTracker') ||
        error.toString().contains('Failed assertion')) {
      print('Zone error detected, restarting app...');
      _restartApp();
    }
  });
}

// ฟังก์ชัน restart app
void _restartApp() {
  try {
    // วิธี 1: ใช้ ServicesBinding
    WidgetsBinding.instance.reassembleApplication();
  } catch (e) {
    try {
      // วิธี 2: ใช้ SystemNavigator
      SystemNavigator.pop();
    } catch (e2) {
      print('Could not restart app: $e2');
    }
  }
}

class BugProofApp extends StatelessWidget {
  const BugProofApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // จัดการ error ใน MaterialApp level
      builder: (context, widget) {
        // จัดการ error boundary
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          print('Widget Error: ${errorDetails.exception}');
          
          // ถ้า error เกี่ยวกับ MouseTracker ให้ restart
          if (errorDetails.exception.toString().contains('MouseTracker') ||
              errorDetails.exception.toString().contains('Failed assertion')) {
            
            // แสดง loading screen ก่อน restart
            Future.delayed(Duration(seconds: 1), () {
              _restartApp();
            });
            
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFFFFC870),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Restarting app...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }
          
          // Error screen ปกติ
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    errorDetails.exception.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _restartApp();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFC870),
                  ),
                  child: Text('Restart App'),
                ),
              ],
            ),
          );
        };

        return widget!;
      },
      home: SafeHome(),
    );
  }
}

// Wrapper widget ที่ปลอดภัยสำหรับ home screen
class SafeHome extends StatefulWidget {
  @override
  _SafeHomeState createState() => _SafeHomeState();
}

class _SafeHomeState extends State<SafeHome> with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // จัดการเมื่อ app กลับมาจาก background
    if (state == AppLifecycleState.resumed) {
      // Refresh หน้าจอเพื่อป้องกัน stale state
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ErrorBoundaryWidget(
      child: Bottom(),
      onError: (error, stackTrace) {
        print('Home Error: $error');
        
        // หาก error เกี่ยวกับ MouseTracker
        if (error.toString().contains('MouseTracker') ||
            error.toString().contains('Failed assertion')) {
          Future.delayed(Duration(milliseconds: 500), () {
            _restartApp();
          });
        }
      },
    );
  }
}

// Error boundary widget
class ErrorBoundaryWidget extends StatefulWidget {
  final Widget child;
  final Function(Object error, StackTrace stackTrace)? onError;
  
  const ErrorBoundaryWidget({
    Key? key,
    required this.child,
    this.onError,
  }) : super(key: key);

  @override
  _ErrorBoundaryWidgetState createState() => _ErrorBoundaryWidgetState();
}

class _ErrorBoundaryWidgetState extends State<ErrorBoundaryWidget> {
  bool hasError = false;
  Object? error;
  
  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.refresh,
              size: 64,
              color: Color(0xFFFFC870),
            ),
            SizedBox(height: 20),
            Text(
              'Refreshing...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    
    return widget.child;
  }
  
  @override
  void initState() {
    super.initState();
    
    // จัดการ error ใน widget นี้
    FlutterError.onError = (FlutterErrorDetails details) {
      if (mounted) {
        setState(() {
          hasError = true;
          error = details.exception;
        });
        
        widget.onError?.call(details.exception, details.stack ?? StackTrace.empty);
        
        // Auto recover หลัง 2 วินาที
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              hasError = false;
              error = null;
            });
          }
        });
      }
    };
  }
}
