// lib/services/bmr_calculator.dart
// BMR & Daily Calorie Calculator (Mifflin-St Jeor Equation)

class BMRCalculator {
  final int weight; // kg
  final int height; // cm
  final int age;
  final bool isMale;

  BMRCalculator({
    required this.weight,
    required this.height,
    required this.age,
    required this.isMale,
  });

  // Mifflin-St Jeor BMR
  double get bmr {
    if (isMale) {
      return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  // TDEE by activity level
  double tdee(ActivityLevel level) => bmr * level.multiplier;

  // Calories to lose 0.5kg/week
  double get caloriesForWeightLoss => tdee(ActivityLevel.sedentary) - 500;

  // Calories to gain 0.5kg/week
  double get caloriesForWeightGain => tdee(ActivityLevel.sedentary) + 500;
}

enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive,
  extraActive;

  double get multiplier {
    switch (this) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.lightlyActive:
        return 1.375;
      case ActivityLevel.moderatelyActive:
        return 1.55;
      case ActivityLevel.veryActive:
        return 1.725;
      case ActivityLevel.extraActive:
        return 1.9;
    }
  }

  String get label {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Sedentary';
      case ActivityLevel.lightlyActive:
        return 'Lightly Active';
      case ActivityLevel.moderatelyActive:
        return 'Moderately Active';
      case ActivityLevel.veryActive:
        return 'Very Active';
      case ActivityLevel.extraActive:
        return 'Extra Active';
    }
  }

  String get description {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Little or no exercise';
      case ActivityLevel.lightlyActive:
        return 'Light exercise 1–3 days/week';
      case ActivityLevel.moderatelyActive:
        return 'Moderate exercise 3–5 days/week';
      case ActivityLevel.veryActive:
        return 'Hard exercise 6–7 days/week';
      case ActivityLevel.extraActive:
        return 'Very hard exercise + physical job';
    }
  }
}
