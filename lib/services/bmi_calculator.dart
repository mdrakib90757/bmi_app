import 'package:flutter/material.dart';

class BMICalculator {
  final int height; // in cm
  final int weight; // in kg
  final int age;
  final bool isMale;

  BMICalculator({
    required this.height,
    required this.weight,
    required this.age,
    required this.isMale,
  });

  double get bmiValue {
    final h = height / 100;
    return weight / (h * h);
  }

  String get bmiString => bmiValue.toStringAsFixed(1);

  String get category {
    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25.0) return 'Normal';
    if (bmiValue < 30.0) return 'Overweight';
    return 'Obese';
  }

  Color get categoryColor {
    if (bmiValue < 18.5) return const Color(0xFF1A56DB);
    if (bmiValue < 25.0) return const Color(0xFF0E9F6E);
    if (bmiValue < 30.0) return const Color(0xFFF6A723);
    return const Color(0xFFF05252);
  }

  String get advice {
    if (bmiValue < 18.5) {
      return 'You are underweight. Consider eating more nutritious foods and consulting a dietitian.';
    } else if (bmiValue < 25.0) {
      return 'Great! You have a healthy weight. Keep up your balanced diet and regular exercise.';
    } else if (bmiValue < 30.0) {
      return 'You are slightly overweight. Try reducing calorie intake and increasing physical activity.';
    } else {
      return 'Your BMI indicates obesity. Please consult a doctor for a personalized health plan.';
    }
  }

  String get weightAdvice {
    if (bmiValue < 18.5) return 'You need to gain weight';
    if (bmiValue < 25.0) return 'Your weight is healthy';
    return 'You need to lose weight';
  }

  // Healthy weight range for this height
  String get normalWeightRange {
    final h = height / 100;
    final min = (18.5 * h * h).toStringAsFixed(1);
    final max = (24.9 * h * h).toStringAsFixed(1);
    return '$min - $max kg';
  }

  // How much to lose to reach BMI 25
  double get amountToLose {
    final h = height / 100;
    final idealWeight = 25.0 * h * h;
    final diff = weight - idealWeight;
    return diff > 0 ? diff : 0;
  }

  // How much to gain to reach BMI 18.5
  double get amountToGain {
    final h = height / 100;
    final idealWeight = 18.5 * h * h;
    final diff = idealWeight - weight;
    return diff > 0 ? diff : 0;
  }

  double get bmiPrime => bmiValue / 25;

  double get ponderalIndex {
    final h = height / 100;
    return weight / (h * h * h);
  }

  // BMI progress 0.0 to 1.0 (for gauge, mapped 10–40)
  double get bmiProgress {
    return ((bmiValue.clamp(10.0, 40.0)) - 10) / 30;
  }
}
