// lib/screens/calorie_screen.dart
// BMR + Calorie + Water Intake Calculator

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/bmr_calculator.dart';
import '../services/water_calculator.dart' as w;

class CalorieScreen extends StatefulWidget {
  final int weight;
  final int height;
  final int age;
  final bool isMale;

  const CalorieScreen({
    super.key,
    required this.weight,
    required this.height,
    required this.age,
    required this.isMale,
  });

  @override
  State<CalorieScreen> createState() => _CalorieScreenState();
}

class _CalorieScreenState extends State<CalorieScreen> {
  ActivityLevel _activityLevel = ActivityLevel.sedentary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bmr = BMRCalculator(
      weight: widget.weight,
      height: widget.height,
      age: widget.age,
      isMale: widget.isMale,
    );

    final water = w.WaterCalculator(
      weight: widget.weight,
      level: w.ActivityLevel.values[_activityLevel.index],
    );

    final tdee = bmr.tdee(_activityLevel);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0E9F6E), Color(0xFF1A56DB)],
                  ),
                ),
              ),
              title: Text(
                'Calorie & Water',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BMR Card
                  _InfoCard(
                    title: 'Your Basal Metabolic Rate (BMR)',
                    subtitle: 'Calories your body burns at rest',
                    value: '${bmr.bmr.toStringAsFixed(0)} kcal/day',
                    icon: Icons.local_fire_department_rounded,
                    color: const Color(0xFFF05252),
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 16),

                  // Activity Level Selector
                  _SectionLabel(label: 'Activity Level', isDark: isDark),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
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
                      children: ActivityLevel.values.map((level) {
                        final isSelected = _activityLevel == level;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _activityLevel = level),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.all(6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF0E9F6E)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.directions_run_rounded,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey.shade400,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      level.label,
                                      style: GoogleFonts.nunito(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? Colors.white
                                            : isDark
                                                ? Colors.white70
                                                : const Color(0xFF111928),
                                      ),
                                    ),
                                    Text(
                                      level.description,
                                      style: GoogleFonts.nunito(
                                        fontSize: 11,
                                        color: isSelected
                                            ? Colors.white70
                                            : Colors.grey.shade400,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                if (isSelected)
                                  const Icon(Icons.check_circle_rounded,
                                      color: Colors.white, size: 18),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                  const SizedBox(height: 20),

                  // TDEE + Goals
                  _SectionLabel(label: 'Daily Calorie Goals', isDark: isDark),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _CalorieBox(
                          label: 'Maintain Weight',
                          value: '${tdee.toStringAsFixed(0)}',
                          unit: 'kcal',
                          color: const Color(0xFF0E9F6E),
                          icon: Icons.balance_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CalorieBox(
                          label: 'Lose Weight',
                          value:
                              '${(tdee - 500).clamp(1200, 9999).toStringAsFixed(0)}',
                          unit: 'kcal',
                          color: const Color(0xFFF05252),
                          icon: Icons.trending_down_rounded,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                  const SizedBox(height: 12),

                  _CalorieBox(
                    label: 'Gain Weight',
                    value: '${(tdee + 500).toStringAsFixed(0)}',
                    unit: 'kcal/day',
                    color: const Color(0xFF1A56DB),
                    icon: Icons.trending_up_rounded,
                    fullWidth: true,
                  ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

                  const SizedBox(height: 20),

                  // Water Intake
                  _SectionLabel(label: 'Daily Water Intake', isDark: isDark),
                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A56DB), Color(0xFF0E9F6E)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${water.totalLiters.toStringAsFixed(1)} L',
                              style: GoogleFonts.nunito(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '≈ ${water.totalGlasses} glasses (250ml each)',
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              water.recommendation,
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.85),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.water_drop_rounded,
                          size: 56,
                          color: Colors.white30,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                  const SizedBox(height: 16),

                  // Macros breakdown
                  _MacroCard(tdee: tdee)
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 400.ms),

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

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : const Color(0xFF374151),
        ),
      );
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: color)),
                Text(subtitle,
                    style: GoogleFonts.nunito(
                        fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalorieBox extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final IconData icon;
  final bool fullWidth;

  const _CalorieBox({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: fullWidth
          ? Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(label,
                      style: GoogleFonts.nunito(
                          fontSize: 13, color: Colors.grey.shade500)),
                  Text('$value kcal/day',
                      style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: color)),
                ]),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(height: 8),
                Text(value,
                    style: GoogleFonts.nunito(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: color)),
                Text(unit,
                    style: GoogleFonts.nunito(
                        fontSize: 10, color: Colors.grey.shade400)),
                const SizedBox(height: 4),
                Text(label,
                    style: GoogleFonts.nunito(
                        fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final double tdee;
  const _MacroCard({required this.tdee});

  @override
  Widget build(BuildContext context) {
    // Standard macro split: 50% carbs, 25% protein, 25% fat
    final carbs = ((tdee * 0.50) / 4).toStringAsFixed(0);
    final protein = ((tdee * 0.25) / 4).toStringAsFixed(0);
    final fat = ((tdee * 0.25) / 9).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recommended Macros',
              style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF374151))),
          Text('Based on your maintenance calories',
              style: GoogleFonts.nunito(
                  fontSize: 11, color: Colors.grey.shade400)),
          const SizedBox(height: 14),
          Row(
            children: [
              _MacroItem(label: 'Carbs', value: '${carbs}g',
                  color: const Color(0xFF1A56DB), percent: '50%'),
              const SizedBox(width: 10),
              _MacroItem(label: 'Protein', value: '${protein}g',
                  color: const Color(0xFF0E9F6E), percent: '25%'),
              const SizedBox(width: 10),
              _MacroItem(label: 'Fat', value: '${fat}g',
                  color: const Color(0xFFF6A723), percent: '25%'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String percent;
  const _MacroItem(
      {required this.label,
      required this.value,
      required this.color,
      required this.percent});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(percent,
                style: GoogleFonts.nunito(
                    fontSize: 11, color: color, fontWeight: FontWeight.w600)),
            Text(value,
                style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color)),
            Text(label,
                style: GoogleFonts.nunito(
                    fontSize: 10, color: Colors.grey.shade400)),
          ],
        ),
      ),
    );
  }
}
