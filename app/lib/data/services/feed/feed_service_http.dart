import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:netshots/data/services/feed/feed_service_interface.dart';

class FeedServiceHttp implements FeedServiceInterface {
  final FirebaseAuth _firebaseAuth;
  final String baseUrl;

  FeedServiceHttp(
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
  Future<List<Map<String, dynamic>>> getFeed({int? limit, int? offset}) async {
    try {
      final headers = await _getHeaders();
      
      // Build URL with query parameters
      final queryParams = <String, String>{};
      if (limit != null) {
        queryParams['limit'] = limit.toString();
      }
      if (offset != null) {
        queryParams['offset'] = offset.toString();
      }
      
      final uri = Uri.parse('$baseUrl/api/feed').replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: headers,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> feedData = jsonDecode(response.body);
        return feedData.map((item) => item as Map<String, dynamic>).toList();
      }

      if (response.statusCode == 404) {
        return [];
      }

      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['error'] ?? 'Failed to fetch feed');
    } catch (e) {
      throw Exception('Error fetching feed: $e');
    }
  }
}
