// lib/services/profile_service.dart
// Multiple Profile support

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String id;
  final String name;
  final String? photoPath;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.name,
    this.photoPath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'photoPath': photoPath ?? '',
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        id: map['id'] ?? '',
        name: map['name'] ?? 'User',
        photoPath: map['photoPath'] == '' ? null : map['photoPath'],
        createdAt: DateTime.parse(
            map['createdAt'] ?? DateTime.now().toIso8601String()),
      );
}

class ProfileService {
  static const String _profilesKey = 'user_profiles';
  static const String _activeProfileKey = 'active_profile_id';

  static Future<List<UserProfile>> getProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_profilesKey) ?? [];
    return jsonList.map((j) {
      try {
        return UserProfile.fromMap(jsonDecode(j));
      } catch (_) {
        return null;
      }
    }).whereType<UserProfile>().toList();
  }

  static Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final profiles = await getProfiles();
    final idx = profiles.indexWhere((p) => p.id == profile.id);
    if (idx >= 0) {
      profiles[idx] = profile;
    } else {
      profiles.add(profile);
    }
    await prefs.setStringList(
        _profilesKey, profiles.map((p) => jsonEncode(p.toMap())).toList());
  }

  static Future<void> deleteProfile(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final profiles = await getProfiles();
    profiles.removeWhere((p) => p.id == id);
    await prefs.setStringList(
        _profilesKey, profiles.map((p) => jsonEncode(p.toMap())).toList());
  }

  static Future<String?> getActiveProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeProfileKey);
  }

  static Future<void> setActiveProfile(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeProfileKey, id);
  }

  static Future<UserProfile?> getActiveProfile() async {
    final id = await getActiveProfileId();
    if (id == null) return null;
    final profiles = await getProfiles();
    try {
      return profiles.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
