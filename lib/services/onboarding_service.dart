import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_profile.dart';

class OnboardingService {
  static const String _userProfileKey = 'user_profile';

  Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = json.encode(profile.toJson());
    await prefs.setString(_userProfileKey, profileJson);
  }

  Future<UserProfile?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_userProfileKey);
    
    if (profileJson != null) {
      final profileMap = json.decode(profileJson) as Map<String, dynamic>;
      return UserProfile.fromJson(profileMap);
    }
    
    return null;
  }

  Future<bool> hasCompletedOnboarding() async {
    final profile = await getUserProfile();
    return profile != null;
  }

  Future<void> clearUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userProfileKey);
  }

  Future<void> resetOnboarding() async {
    await clearUserProfile();
  }
}