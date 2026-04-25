// lib/main.dart
// REPLACE your existing main.dart with this
// Added: Dark Mode support via ThemeService

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init(); // Init notifications
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const BMIApp());
}

class BMIApp extends StatefulWidget {
  const BMIApp({super.key});

  // Allow child widgets to call toggleTheme via context
  static _BMIAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_BMIAppState>();

  @override
  State<BMIApp> createState() => _BMIAppState();
}

class _BMIAppState extends State<BMIApp> {
  bool _isDark = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isDark = prefs.getBool('dark_mode') ?? false);
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isDark = !_isDark);
    await prefs.setBool('dark_mode', _isDark);
  }

  bool get isDark => _isDark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      debugShowCheckedModeBanner: false,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,

      // ── Light Theme ────────────────────────────────
      theme: ThemeData(
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
        textTheme: GoogleFonts.nunitoTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A56DB),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),

      // ── Dark Theme ─────────────────────────────────
      darkTheme: ThemeData(
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
        textTheme: GoogleFonts.nunitoTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A56DB),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),

      home: const SplashScreen(),
    );
  }
}
