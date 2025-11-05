import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:netshots/data/services/profile/profile_service_interface.dart';

class ProfileServiceMock implements ProfileServiceInterface {
  final SharedPreferences _sharedPreferences;
  static const String _profileKey = 'user_profile';

  ProfileServiceMock(this._sharedPreferences);

  @override
  Future<void> createProfile(Map<String, dynamic> profileData) async {
    // Simulate a network call
    await Future.delayed(Duration(seconds: 1));

    // Store profile data in SharedPreferences
    final profileJson = jsonEncode(profileData);
    await _sharedPreferences.setString(_profileKey, profileJson);
  }

  @override
  Future<void> deleteProfile() async {
    // Simulate a network call
    await Future.delayed(Duration(seconds: 1));  

    // Remove profile data from SharedPreferences
    await _sharedPreferences.remove(_profileKey);
  }

  @override
  Future<Map<String, dynamic>?> getProfile() async {
    // Simulate a network call
    await Future.delayed(Duration(seconds: 1));

    // Retrieve profile data from SharedPreferences
    final profileJson = _sharedPreferences.getString(_profileKey);

    if (profileJson == null) {
      return null;
    }

    try {
      return jsonDecode(profileJson) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    // Simulate a network call
    await Future.delayed(Duration(seconds: 1));
    
    // Update profile data in SharedPreferences
    final profileJson = jsonEncode(profileData);
    await _sharedPreferences.setString(_profileKey, profileJson);
  }
}