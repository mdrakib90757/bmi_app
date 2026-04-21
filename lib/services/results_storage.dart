import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BMIResult {
  final String bmi;
  final String category;
  final String normalWeightRange;
  final DateTime savedDate;
  final int height;
  final int weight;
  final int age;
  final bool isMale;
  final String advice;
  final double bmiValue;
  final String profileImagePath;

  BMIResult({
    required this.bmi,
    required this.category,
    required this.normalWeightRange,
    required this.savedDate,
    required this.height,
    required this.weight,
    required this.age,
    required this.isMale,
    required this.advice,
    required this.bmiValue,
    this.profileImagePath = '',
  });

  Map<String, dynamic> toMap() => {
        'bmi': bmi,
        'category': category,
        'normalWeightRange': normalWeightRange,
        'savedDate': savedDate.toIso8601String(),
        'height': height,
        'weight': weight,
        'age': age,
        'isMale': isMale,
        'advice': advice,
        'bmiValue': bmiValue,
        'profileImagePath': profileImagePath,
      };

  factory BMIResult.fromMap(Map<String, dynamic> map) => BMIResult(
        bmi: map['bmi'] ?? '',
        category: map['category'] ?? '',
        normalWeightRange: map['normalWeightRange'] ?? '',
        savedDate: DateTime.parse(
            map['savedDate'] ?? DateTime.now().toIso8601String()),
        height: map['height'] ?? 0,
        weight: map['weight'] ?? 0,
        age: map['age'] ?? 0,
        isMale: map['isMale'] ?? true,
        advice: map['advice'] ?? '',
        bmiValue: (map['bmiValue'] ?? 0).toDouble(),
        profileImagePath: map['profileImagePath'] ?? '',
      );
}

class ResultsStorage {
  static const String _key = 'bmi_results';

  static Future<void> saveResult(BMIResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final results = await getResults();
    results.add(result);
    final jsonList = results.map((r) => jsonEncode(r.toMap())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  static Future<List<BMIResult>> getResults() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    return jsonList
        .map((json) {
          try {
            return BMIResult.fromMap(jsonDecode(json));
          } catch (_) {
            return null;
          }
        })
        .whereType<BMIResult>()
        .toList();
  }

  static Future<void> deleteResult(BMIResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final results = await getResults();
    results.removeWhere((r) =>
        r.bmi == result.bmi &&
        r.category == result.category &&
        r.savedDate == result.savedDate);
    final jsonList = results.map((r) => jsonEncode(r.toMap())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  static Future<void> clearResults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
