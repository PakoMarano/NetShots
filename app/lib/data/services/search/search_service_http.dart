import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:netshots/data/models/search_user_model.dart';
import 'package:netshots/data/services/search/search_service_interface.dart';

class SearchServiceHttp implements SearchServiceInterface {
  final FirebaseAuth _firebaseAuth;
  final String baseUrl;

  SearchServiceHttp(
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
  Future<List<SearchUser>> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/api/search/users').replace(
        queryParameters: {'q': query.trim()},
      );

      final response = await http.get(
        url,
        headers: headers,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = jsonDecode(response.body);
        return results.map((json) => SearchUser.fromMap(json)).toList();
      }

      if (response.statusCode == 401) {
        throw Exception('Authentication failed');
      }

      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['error'] ?? 'Failed to search users');
    } catch (e) {
      throw Exception('Error searching users: $e');
    }
  }
}
