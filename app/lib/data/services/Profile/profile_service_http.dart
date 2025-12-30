import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:netshots/data/services/profile/profile_service_interface.dart';

class ProfileServiceHttp implements ProfileServiceInterface {
  final FirebaseAuth _firebaseAuth;
  final String baseUrl;

  ProfileServiceHttp(
    this._firebaseAuth, {
    required this.baseUrl,
  });

  /// Get the current Firebase ID token for API requests
  Future<String> _getIdToken() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    final token = await user.getIdToken();
    return token ?? '';
  }

  /// Build Authorization header with Firebase ID token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getIdToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<void> createProfile(Map<String, dynamic> profileData) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/api/profiles');

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(profileData),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['error'] ?? 'Failed to create profile');
    } catch (e) {
      throw Exception('Error creating profile: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/api/profiles/me');

      final response = await http.get(
        url,
        headers: headers,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final profileData = jsonDecode(response.body) as Map<String, dynamic>;
        return profileData;
      }

      if (response.statusCode == 404) {
        return null;
      }

      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['error'] ?? 'Failed to fetch profile');
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getProfileByUserId(String userId) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/api/profiles/$userId');

      final response = await http.get(
        url,
        headers: headers,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final profileData = jsonDecode(response.body) as Map<String, dynamic>;
        return profileData;
      }

      if (response.statusCode == 404) {
        return null;
      }

      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['error'] ?? 'Failed to fetch profile');
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  @override
  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/api/profiles/me');

      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(profileData),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        return;
      }

      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['error'] ?? 'Failed to update profile');
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

  @override
  Future<void> deleteProfile() async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/api/profiles/me');

      final response = await http.delete(
        url,
        headers: headers,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      }

      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['error'] ?? 'Failed to delete profile');
    } catch (e) {
      throw Exception('Error deleting profile: $e');
    }
  }
}
