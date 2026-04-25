// lib/services/water_calculator.dart
// Daily Water Intake Calculator

class WaterCalculator {
  final int weight; // kg
  final ActivityLevel level;

  WaterCalculator({required this.weight, required this.level});

  // Base: 35ml per kg body weight
  double get baseWaterLiters => (weight * 35) / 1000;

  // Extra water based on activity
  double get activityBonus {
    switch (level) {
      case ActivityLevel.sedentary:
        return 0.0;
      case ActivityLevel.lightlyActive:
        return 0.3;
      case ActivityLevel.moderatelyActive:
        return 0.5;
      case ActivityLevel.veryActive:
        return 0.7;
      case ActivityLevel.extraActive:
        return 1.0;
    }
  }

  double get totalLiters => baseWaterLiters + activityBonus;

  int get totalGlasses => (totalLiters / 0.25).ceil(); // 250ml per glass

  String get recommendation {
    if (totalLiters < 2.0) return 'Drink at least 2 liters daily.';
    if (totalLiters < 3.0) return 'Stay hydrated throughout the day.';
    return 'Keep a water bottle with you always.';
  }
}

enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive,
  extraActive;

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
}
