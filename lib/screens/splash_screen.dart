import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const OnboardingScreen(),
            transitionDuration: const Duration(milliseconds: 600),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A56DB), Color(0xFF0E9F6E)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ).animate().scale(
                    duration: 1200.ms,
                    curve: Curves.easeOut,
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                  ),
            ),
            Positioned(
              bottom: -100,
              left: -60,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ).animate().scale(
                    duration: 1400.ms,
                    curve: Curves.easeOut,
                    begin: const Offset(0.3, 0.3),
                    end: const Offset(1.0, 1.0),
                  ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.monitor_weight_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        duration: 800.ms,
                        curve: Curves.elasticOut,
                      ),
                  const SizedBox(height: 28),
                  Text(
                    'BMI Calculator',
                    style: GoogleFonts.nunito(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 10),
                  Text(
                    'Know Your Health Status',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 700.ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 60),
                  SizedBox(
                    width: 140,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        backgroundColor: Colors.white24,
                        color: Colors.white,
                        minHeight: 4,
                      ),
                    ),
                  ).animate().fadeIn(delay: 1000.ms, duration: 400.ms),
                ],
              ),
            ),
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Text(
                'Version 1.0.0',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.5),
                ),
              ).animate().fadeIn(delay: 1200.ms, duration: 400.ms),
            ),
          ],
        ),
      ),
    );
  }
}
