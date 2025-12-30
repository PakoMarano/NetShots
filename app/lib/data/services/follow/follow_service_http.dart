import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:netshots/data/services/follow/follow_service_interface.dart';

class FollowServiceHttp implements FollowServiceInterface {
  final FirebaseAuth _firebaseAuth;
  final String baseUrl;

  FollowServiceHttp(
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
  Future<void> follow(String currentUserId, String targetUserId) async {
    if (currentUserId == targetUserId) {
      return; // Cannot follow yourself
    }

    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/api/follow/$targetUserId');

      final response = await http.post(
        url,
        headers: headers,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      if (response.statusCode == 401) {
        throw Exception('Authentication failed');
      }

      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['error'] ?? 'Failed to follow user');
    } catch (e) {
      throw Exception('Error following user: $e');
    }
  }

  @override
  Future<void> unfollow(String currentUserId, String targetUserId) async {
    if (currentUserId == targetUserId) {
      return;
    }

    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/api/follow/$targetUserId');

      final response = await http.delete(
        url,
        headers: headers,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200 || response.statusCode == 404) {
        // 404 is acceptable - user wasn't following anyway
        return;
      }

      if (response.statusCode == 401) {
        throw Exception('Authentication failed');
      }

      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['error'] ?? 'Failed to unfollow user');
    } catch (e) {
      throw Exception('Error unfollowing user: $e');
    }
  }

  @override
  Future<bool> isFollowing(String currentUserId, String targetUserId) async {
    if (currentUserId.isEmpty) {
      return false;
    }

    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/api/follow/$targetUserId/is-following');

      final response = await http.get(
        url,
        headers: headers,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['isFollowing'] ?? false;
      }

      if (response.statusCode == 401) {
        throw Exception('Authentication failed');
      }

      return false;
    } catch (e) {
      throw Exception('Error checking follow status: $e');
    }
  }

  @override
  Future<List<String>> getFollowers(String userId) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/api/follow/$userId/followers');

      final response = await http.get(
        url,
        headers: headers,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> result = jsonDecode(response.body);
        return result.map((id) => id.toString()).toList();
      }

      if (response.statusCode == 401) {
        throw Exception('Authentication failed');
      }

      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['error'] ?? 'Failed to get followers');
    } catch (e) {
      throw Exception('Error getting followers: $e');
    }
  }

  @override
  Future<List<String>> getFollowing(String userId) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/api/follow/$userId/following');

      final response = await http.get(
        url,
        headers: headers,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> result = jsonDecode(response.body);
        return result.map((id) => id.toString()).toList();
      }

      if (response.statusCode == 401) {
        throw Exception('Authentication failed');
      }

      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['error'] ?? 'Failed to get following');
    } catch (e) {
      throw Exception('Error getting following: $e');
    }
  }
}
