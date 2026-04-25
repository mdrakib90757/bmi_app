import 'dart:convert';

/// Represents a user profile with personal information and BMI history
class UserProfile {
  final String id;
  final String name;
  final DateTime createdAt;
  final String? photoPath;
  final int age;
  final bool isMale;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.age,
    required this.isMale,
    this.photoPath,
    this.updatedAt,
  });

  /// Create a copy with updated fields
  UserProfile copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    String? photoPath,
    int? age,
    bool? isMale,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      photoPath: photoPath ?? this.photoPath,
      age: age ?? this.age,
      isMale: isMale ?? this.isMale,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'photoPath': photoPath,
        'age': age,
        'isMale': isMale,
      };

  /// Create from JSON map
  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        id: map['id'] as String,
        name: map['name'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: map['updatedAt'] != null
            ? DateTime.parse(map['updatedAt'] as String)
            : null,
        photoPath: map['photoPath'] as String?,
        age: map['age'] as int,
        isMale: map['isMale'] as bool,
      );

  /// Convert to JSON string
  String toJson() => jsonEncode(toMap());

  /// Create from JSON string
  factory UserProfile.fromJson(String json) =>
      UserProfile.fromMap(jsonDecode(json));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'UserProfile(id: $id, name: $name, age: $age, isMale: $isMale)';
}
