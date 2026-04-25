import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../services/results_storage.dart';

/// Widget to display BMI progress as a line chart
class BMIProgressChart extends StatefulWidget {
  final List<BMIResult> results;
  final String chartType; // 'bmi' or 'weight'

  const BMIProgressChart({
    super.key,
    required this.results,
    this.chartType = 'bmi',
  });

  @override
  State<BMIProgressChart> createState() => _BMIProgressChartState();
}

class _BMIProgressChartState extends State<BMIProgressChart> {
  late List<FlSpot> _spots;
  late double _maxY;
  late double _minY;

  @override
  void initState() {
    super.initState();
    _calculateSpots();
  }

  void _calculateSpots() {
    if (widget.results.isEmpty) {
      _spots = [];
      _maxY = 30;
      _minY = 0;
      return;
    }

    // Sort by date
    final sorted = List<BMIResult>.from(widget.results)
      ..sort((a, b) => a.savedDate.compareTo(b.savedDate));

    // Calculate spots based on chart type
    if (widget.chartType == 'weight') {
      _spots = sorted.asMap().entries.map((e) {
        return FlSpot(e.key.toDouble(), e.value.weight.toDouble());
      }).toList();

      final weights = sorted.map((r) => r.weight).toList();
      _maxY = (weights.reduce((a, b) => a > b ? a : b) + 5).toDouble();
      _minY = (weights.reduce((a, b) => a < b ? a : b) - 5).toDouble();
    } else {
      _spots = sorted.asMap().entries.map((e) {
        return FlSpot(e.key.toDouble(), e.value.bmiValue);
      }).toList();

      final bmis = sorted.map((r) => r.bmiValue).toList();
      _maxY = bmis.reduce((a, b) => a > b ? a : b) + 2;
      _minY =
          (bmis.reduce((a, b) => a < b ? a : b) - 2).clamp(10, double.infinity);
    }
  }

  Color _getColor(double value, String type) {
    if (type == 'weight') {
      return Theme.of(context).colorScheme.primary;
    }

    // BMI colors
    if (value < 18.5) return const Color(0xFF1A56DB); // Underweight - Blue
    if (value < 25.0) return const Color(0xFF0E9F6E); // Normal - Green
    if (value < 30.0) return const Color(0xFFF6A723); // Overweight - Orange
    return const Color(0xFFF05252); // Obese - Red
  }

  String _getBMICategory(double value) {
    if (value < 18.5) return 'Underweight';
    if (value < 25.0) return 'Normal';
    if (value < 30.0) return 'Overweight';
    return 'Obese';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No data to display',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            drawHorizontalLine: true,
            horizontalInterval: null,
            verticalInterval: null,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= widget.results.length) {
                    return const SizedBox();
                  }

                  final sorted = List<BMIResult>.from(widget.results)
                    ..sort((a, b) => a.savedDate.compareTo(b.savedDate));

                  final date = sorted[index].savedDate;
                  return Text(
                    '${date.day}/${date.month}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                        ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                        ),
                  );
                },
                reservedSize: 28,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
              left: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
              right: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
              top: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          minX: 0,
          maxX:
              (widget.results.length - 1).toDouble().clamp(0, double.infinity),
          minY: _minY,
          maxY: _maxY,
          lineBarsData: [
            LineChartBarData(
              spots: _spots,
              isCurved: true,
              color: widget.chartType == 'weight'
                  ? Theme.of(context).colorScheme.primary
                  : _getColor(_spots.last.y, 'bmi'),
              barWidth: 2,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  late Color dotColor;
                  if (widget.chartType == 'weight') {
                    dotColor = Theme.of(context).colorScheme.primary;
                  } else {
                    dotColor = _getColor(spot.y, 'bmi');
                  }

                  return FlDotCirclePainter(
                    radius: 4,
                    color: dotColor,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: widget.chartType == 'weight'
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : _getColor(_spots.last.y, 'bmi').withOpacity(0.1),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              // getTooltipColor:
              //     Theme.of(context).colorScheme.surface.withOpacity(0.8),
              getTooltipColor: (spot) => const Color(0xFF1A56DB),
              tooltipRoundedRadius: 8,
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final index = barSpot.x.toInt();
                  if (index < 0 || index >= widget.results.length) {
                    return null;
                  }

                  final sorted = List<BMIResult>.from(widget.results)
                    ..sort((a, b) => a.savedDate.compareTo(b.savedDate));

                  final result = sorted[index];
                  final value = barSpot.y;

                  late String label;
                  late String subtitle;

                  if (widget.chartType == 'weight') {
                    label = 'Weight: ${value.toStringAsFixed(1)} kg';
                    subtitle = 'BMI: ${result.bmiValue.toStringAsFixed(1)}';
                  } else {
                    label = 'BMI: ${value.toStringAsFixed(1)}';
                    subtitle =
                        '${_getBMICategory(value)} • ${result.weight} kg';
                  }

                  return LineTooltipItem(
                    '$label\n$subtitle',
                    TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(
                        text:
                            '\n${result.savedDate.day}/${result.savedDate.month}/${result.savedDate.year}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                            ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}
