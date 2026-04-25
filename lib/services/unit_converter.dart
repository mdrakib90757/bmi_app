// lib/services/unit_converter.dart
// Unit Switch: kg <-> lbs, cm <-> ft/in

class UnitConverter {
  // Weight
  static double kgToLbs(double kg) => kg * 2.20462;
  static double lbsToKg(double lbs) => lbs / 2.20462;

  // Height
  static double cmToInches(double cm) => cm / 2.54;
  static double inchesToCm(double inches) => inches * 2.54;

  static String cmToFeetInches(double cm) {
    final totalInches = cm / 2.54;
    final feet = totalInches ~/ 12;
    final inches = (totalInches % 12).round();
    return "$feet' $inches\"";
  }

  static double feetInchesToCm(int feet, int inches) {
    return (feet * 12 + inches) * 2.54;
  }
}

// Shared preference key for unit preference
const String kUnitPrefKey = 'use_metric'; // true = kg/cm, false = lbs/ft
