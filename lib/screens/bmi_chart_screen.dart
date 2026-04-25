// lib/screens/bmi_chart_screen.dart
// BMI Progress Chart - shows BMI over time using fl_chart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/results_storage.dart';

class BmiChartScreen extends StatefulWidget {
  const BmiChartScreen({super.key});

  @override
  State<BmiChartScreen> createState() => _BmiChartScreenState();
}

class _BmiChartScreenState extends State<BmiChartScreen> {
  late Future<List<BMIResult>> _future;

  @override
  void initState() {
    super.initState();
    _future = ResultsStorage.getResults();
  }

  Color _colorForBmi(double bmi) {
    if (bmi < 18.5) return const Color(0xFF1A56DB);
    if (bmi < 25) return const Color(0xFF0E9F6E);
    if (bmi < 30) return const Color(0xFFF6A723);
    return const Color(0xFFF05252);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                    colors: [Color(0xFF1A56DB), Color(0xFF0E9F6E)],
                  ),
                ),
              ),
              title: Text(
                'BMI Progress',
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
            child: FutureBuilder<List<BMIResult>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final results = snapshot.data ?? [];

                if (results.length < 2) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Column(
                      children: [
                        Icon(Icons.show_chart_rounded,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'Save at least 2 results\nto see your progress chart',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            color: Colors.grey.shade400,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Prepare chart data
                final sorted = List<BMIResult>.from(results)
                  ..sort((a, b) => a.savedDate.compareTo(b.savedDate));

                final spots = sorted.asMap().entries.map((e) {
                  return FlSpot(e.key.toDouble(), e.value.bmiValue);
                }).toList();

                final minBmi = sorted
                    .map((r) => r.bmiValue)
                    .reduce((a, b) => a < b ? a : b);
                final maxBmi = sorted
                    .map((r) => r.bmiValue)
                    .reduce((a, b) => a > b ? a : b);

                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Chart Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.07),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BMI Over Time',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF111928),
                              ),
                            ),
                            Text(
                              '${sorted.length} records',
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 220,
                              child: LineChart(
                                LineChartData(
                                  minY: (minBmi - 2).clamp(10, 40),
                                  maxY: (maxBmi + 2).clamp(10, 45),
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: 5,
                                    getDrawingHorizontalLine: (value) =>
                                        FlLine(
                                      color: Colors.grey.withOpacity(0.15),
                                      strokeWidth: 1,
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 36,
                                        getTitlesWidget: (val, meta) => Text(
                                          val.toStringAsFixed(0),
                                          style: GoogleFonts.nunito(
                                            fontSize: 10,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (val, meta) {
                                          final idx = val.toInt();
                                          if (idx >= sorted.length ||
                                              idx < 0) {
                                            return const SizedBox();
                                          }
                                          final d = sorted[idx].savedDate;
                                          return Text(
                                            '${d.day}/${d.month}',
                                            style: GoogleFonts.nunito(
                                              fontSize: 9,
                                              color: Colors.grey.shade400,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    rightTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                    topTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                  ),
                                  // BMI zone reference lines
                                  extraLinesData: ExtraLinesData(
                                    horizontalLines: [
                                      HorizontalLine(
                                        y: 18.5,
                                        color: const Color(0xFF1A56DB)
                                            .withOpacity(0.4),
                                        strokeWidth: 1,
                                        dashArray: [6, 4],
                                        label: HorizontalLineLabel(
                                          show: true,
                                          alignment: Alignment.topRight,
                                          labelResolver: (_) => '18.5',
                                          style: GoogleFonts.nunito(
                                            fontSize: 9,
                                            color: const Color(0xFF1A56DB),
                                          ),
                                        ),
                                      ),
                                      HorizontalLine(
                                        y: 25,
                                        color: const Color(0xFF0E9F6E)
                                            .withOpacity(0.4),
                                        strokeWidth: 1,
                                        dashArray: [6, 4],
                                        label: HorizontalLineLabel(
                                          show: true,
                                          alignment: Alignment.topRight,
                                          labelResolver: (_) => '25.0',
                                          style: GoogleFonts.nunito(
                                            fontSize: 9,
                                            color: const Color(0xFF0E9F6E),
                                          ),
                                        ),
                                      ),
                                      HorizontalLine(
                                        y: 30,
                                        color: const Color(0xFFF05252)
                                            .withOpacity(0.4),
                                        strokeWidth: 1,
                                        dashArray: [6, 4],
                                        label: HorizontalLineLabel(
                                          show: true,
                                          alignment: Alignment.topRight,
                                          labelResolver: (_) => '30.0',
                                          style: GoogleFonts.nunito(
                                            fontSize: 9,
                                            color: const Color(0xFFF05252),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: spots,
                                      isCurved: true,
                                      curveSmoothness: 0.35,
                                      color: const Color(0xFF1A56DB),
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      dotData: FlDotData(
                                        show: true,
                                        getDotPainter: (spot, _, __, ___) =>
                                            FlDotCirclePainter(
                                          radius: 5,
                                          color: _colorForBmi(spot.y),
                                          strokeWidth: 2,
                                          strokeColor: Colors.white,
                                        ),
                                      ),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            const Color(0xFF1A56DB)
                                                .withOpacity(0.15),
                                            const Color(0xFF1A56DB)
                                                .withOpacity(0.0),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                  lineTouchData: LineTouchData(
                                    touchTooltipData: LineTouchTooltipData(
                                      getTooltipColor: (spot) => const Color(0xFF1A56DB),
                                      getTooltipItems: (spots) =>
                                          spots.map((s) {
                                        return LineTooltipItem(
                                          'BMI ${s.y.toStringAsFixed(1)}',
                                          GoogleFonts.nunito(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms),

                      const SizedBox(height: 16),

                      // BMI Zone Legend
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BMI Zones',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF374151),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _ZoneTile(color: const Color(0xFF1A56DB),
                                label: 'Underweight', range: '< 18.5'),
                            _ZoneTile(color: const Color(0xFF0E9F6E),
                                label: 'Normal', range: '18.5 – 24.9'),
                            _ZoneTile(color: const Color(0xFFF6A723),
                                label: 'Overweight', range: '25.0 – 29.9'),
                            _ZoneTile(color: const Color(0xFFF05252),
                                label: 'Obese', range: '≥ 30.0'),
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                      const SizedBox(height: 40),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoneTile extends StatelessWidget {
  final Color color;
  final String label;
  final String range;
  const _ZoneTile(
      {required this.color, required this.label, required this.range});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(label,
              style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : const Color(0xFF374151))),
          const Spacer(),
          Text(range,
              style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
