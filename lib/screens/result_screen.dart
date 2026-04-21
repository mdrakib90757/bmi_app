import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/bmi_calculator.dart';
import '../services/results_storage.dart';
import 'input_screen.dart';

class ResultScreen extends StatefulWidget {
  final BMICalculator calculator;
  final File? profileImage;

  const ResultScreen({
    super.key,
    required this.calculator,
    this.profileImage,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _saved = false;

  BMICalculator get calc => widget.calculator;

  Future<void> _saveResult() async {
    final result = BMIResult(
      bmi: calc.bmiString,
      category: calc.category,
      normalWeightRange: calc.normalWeightRange,
      savedDate: DateTime.now(),
      height: calc.height,
      weight: calc.weight,
      age: calc.age,
      isMale: calc.isMale,
      advice: calc.advice,
      bmiValue: calc.bmiValue,
      profileImagePath: widget.profileImage?.path ?? '',
    );
    await ResultsStorage.saveResult(result);
    if (mounted) {
      setState(() => _saved = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Result saved!',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
          backgroundColor: const Color(0xFF0E9F6E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [calc.categoryColor, const Color(0xFF0E9F6E)],
                  ),
                ),
              ),
              title: Text(
                'Your BMI Result',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Main BMI card
                  _MainBmiCard(calc: calc, profileImage: widget.profileImage)
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 16),

                  // BMI bar
                  _BmiBarCard(calc: calc)
                      .animate()
                      .fadeIn(delay: 150.ms, duration: 400.ms),

                  const SizedBox(height: 16),

                  // Stats
                  _StatsCard(calc: calc)
                      .animate()
                      .fadeIn(delay: 250.ms, duration: 400.ms),

                  const SizedBox(height: 16),

                  // Advice
                  _AdviceCard(calc: calc)
                      .animate()
                      .fadeIn(delay: 350.ms, duration: 400.ms),

                  const SizedBox(height: 24),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saved ? null : _saveResult,
                      icon: Icon(
                        _saved
                            ? Icons.check_circle_rounded
                            : Icons.save_rounded,
                        size: 20,
                      ),
                      label: Text(
                        _saved ? 'Result Saved' : 'Save Result',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _saved
                            ? Colors.grey.shade400
                            : const Color(0xFF0E9F6E),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 450.ms, duration: 400.ms),

                  const SizedBox(height: 12),

                  // Recalculate
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const InputScreen()),
                        (route) => false,
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      label: Text(
                        'Recalculate',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1A56DB),
                        side: const BorderSide(color: Color(0xFF1A56DB)),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _MainBmiCard extends StatelessWidget {
  final BMICalculator calc;
  final File? profileImage;
  const _MainBmiCard({required this.calc, this.profileImage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [calc.categoryColor, calc.categoryColor.withOpacity(0.7)],
        ),
        boxShadow: [
          BoxShadow(
            color: calc.categoryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (profileImage != null)
            Container(
              width: 70,
              height: 70,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                image: DecorationImage(
                  image: FileImage(profileImage!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Text(
            calc.bmiString,
            style: GoogleFonts.nunito(
              fontSize: 72,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1,
            ),
          ),
          Text(
            'kg/m²',
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: Text(
              calc.category.toUpperCase(),
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            calc.weightAdvice,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BmiBarCard extends StatelessWidget {
  final BMICalculator calc;
  const _BmiBarCard({required this.calc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BMI Scale',
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth;
              final dotPos =
                  (calc.bmiProgress * barWidth).clamp(0.0, barWidth - 16);
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1A56DB),
                          Color(0xFF0E9F6E),
                          Color(0xFFF6A723),
                          Color(0xFFF05252),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: dotPos,
                    top: -4,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: calc.categoryColor, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['Under', 'Normal', 'Over', 'Obese']
                .map(
                  (l) => Text(
                    l,
                    style: GoogleFonts.nunito(
                        fontSize: 10, color: Colors.grey.shade400),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final BMICalculator calc;
  const _StatsCard({required this.calc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoRow('Healthy BMI range', '18.5 – 25.0 kg/m²'),
          const Divider(height: 20),
          _InfoRow('Healthy weight for your height', calc.normalWeightRange),
          const Divider(height: 20),
          if (calc.amountToLose > 0)
            _InfoRow('To reach BMI 25, lose',
                '${calc.amountToLose.toStringAsFixed(1)} kg'),
          if (calc.amountToGain > 0)
            _InfoRow('To reach BMI 18.5, gain',
                '${calc.amountToGain.toStringAsFixed(1)} kg'),
          const Divider(height: 20),
          _InfoRow('BMI Prime', calc.bmiPrime.toStringAsFixed(2)),
          const Divider(height: 20),
          _InfoRow('Ponderal Index',
              '${calc.ponderalIndex.toStringAsFixed(1)} kg/m³'),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.nunito(
                fontSize: 13, color: Colors.grey.shade500)),
        Text(value,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111928),
            )),
      ],
    );
  }
}

class _AdviceCard extends StatelessWidget {
  final BMICalculator calc;
  const _AdviceCard({required this.calc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: calc.categoryColor.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: calc.categoryColor.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.tips_and_updates_rounded,
              color: calc.categoryColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              calc.advice,
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: const Color(0xFF374151),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
