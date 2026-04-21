import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'input_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      icon: Icons.person_rounded,
      iconColor: Color(0xFF1A56DB),
      bgColor: Color(0xFFEBF5FF),
      title: 'Enter Your Details',
      subtitle:
          'Enter your height, weight, age and gender. You can also add a profile photo from camera or gallery.',
      accentColor: Color(0xFF1A56DB),
    ),
    _OnboardingData(
      icon: Icons.monitor_weight_rounded,
      iconColor: Color(0xFF0E9F6E),
      bgColor: Color(0xFFE6F9F1),
      title: 'Calculate Your BMI',
      subtitle:
          'Get your Body Mass Index instantly. See your healthy weight range and how much to gain or lose.',
      accentColor: Color(0xFF0E9F6E),
    ),
    _OnboardingData(
      icon: Icons.history_rounded,
      iconColor: Color(0xFFF05252),
      bgColor: Color(0xFFFEEBEB),
      title: 'Save & Track Results',
      subtitle:
          'Save your BMI results and track your progress over time. View your full history anytime.',
      accentColor: Color(0xFFF05252),
    ),
  ];

  void _goToInput() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const InputScreen(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: _goToInput,
                      child: Text(
                        'Skip',
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (_, index) =>
                    _PageContent(data: _pages[index]),
              ),
            ),
            // Dots + Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _controller,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: _pages[_currentPage].accentColor,
                      dotColor: Colors.grey.shade200,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 4,
                      spacing: 6,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pages[_currentPage].accentColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _goToInput();
                        }
                      },
                      child: Text(
                        _currentPage < _pages.length - 1
                            ? 'Next'
                            : 'Get Started',
                        style: GoogleFonts.nunito(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  final _OnboardingData data;
  const _PageContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: data.bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 96, color: data.iconColor),
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .scale(
                begin: const Offset(0.8, 0.8),
                curve: Curves.elasticOut,
                duration: 700.ms,
              ),
          const SizedBox(height: 44),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111928),
              height: 1.3,
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 16),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
              height: 1.6,
            ),
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;
  final Color accentColor;

  const _OnboardingData({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });
}
