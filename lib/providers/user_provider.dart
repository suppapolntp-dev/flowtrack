// lib/providers/user_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String _userName = 'Mr.Suppapol Tabudda';
  String _userEmail = 'user@email.com';
  String _userPhone = '';

  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;

  // โหลดข้อมูล user เมื่อเริ่มต้น
  Future<void> loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _userName = prefs.getString('user_name') ?? 'Mr.Suppapol Tabudda';
      _userEmail = prefs.getString('user_email') ?? 'user@email.com';
      _userPhone = prefs.getString('user_phone') ?? '';
      notifyListeners();
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  // อัปเดตข้อมูล user
  Future<void> updateUserData({
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name);
      await prefs.setString('user_email', email);
      await prefs.setString('user_phone', phone);

      _userName = name;
      _userEmail = email;
      _userPhone = phone;
      
      notifyListeners();
    } catch (e) {
      print('Error updating user data: $e');
      throw e;
    }
  }

  // รีเซ็ตข้อมูล user
  Future<void> resetUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_name');
      await prefs.remove('user_email');
      await prefs.remove('user_phone');

      _userName = 'Mr.Suppapol Tabudda';
      _userEmail = 'user@email.com';
      _userPhone = '';
      
      notifyListeners();
    } catch (e) {
      print('Error resetting user data: $e');
    }
  }
}