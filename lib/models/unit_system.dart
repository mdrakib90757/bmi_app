/// Unit system enum for supporting both metric and imperial units
enum UnitSystem {
  metric, // kg, cm
  imperial, // lbs, ft/inches
}

extension UnitSystemExtension on UnitSystem {
  /// Get weight unit string
  String get weightUnit => this == UnitSystem.metric ? 'kg' : 'lbs';

  /// Get height unit string for primary height
  String get heightUnit => this == UnitSystem.metric ? 'cm' : 'ft';

  /// Get height unit string for secondary height (inches)
  String get secondaryHeightUnit => 'in';

  /// Get weight label
  String get weightLabel =>
      this == UnitSystem.metric ? 'Weight (kg)' : 'Weight (lbs)';

  /// Get height label for metric
  String get heightLabel =>
      this == UnitSystem.metric ? 'Height (cm)' : 'Height (ft/in)';

  /// Display name for UI
  String get displayName => this == UnitSystem.metric ? 'Metric' : 'Imperial';

  /// Get BMI range display
  String get bmiRangeDisplay => this == UnitSystem.metric ? 'kg/m²' : 'lb/in²';
}
