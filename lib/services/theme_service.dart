// lib/services/theme_service.dart
// Dark Mode support

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _key = 'dark_mode';
  bool _isDark = false;

  bool get isDark => _isDark;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool(_key) ?? false;
    notifyListeners();
  }

  Future<void> toggle() async {
    _isDark = !_isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, _isDark);
    notifyListeners();
  }

  // Light Theme
  static ThemeData get lightTheme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A56DB),
          primary: const Color(0xFF1A56DB),
          secondary: const Color(0xFF0E9F6E),
          surface: Colors.white,
          background: const Color(0xFFF9FAFB),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        cardColor: Colors.white,
      );

  // Dark Theme
  static ThemeData get darkTheme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A56DB),
          primary: const Color(0xFF1A56DB),
          secondary: const Color(0xFF0E9F6E),
          surface: const Color(0xFF1E1E2E),
          background: const Color(0xFF12121A),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF12121A),
        cardColor: const Color(0xFF1E1E2E),
      );
}
