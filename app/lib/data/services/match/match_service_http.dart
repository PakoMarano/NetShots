import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:netshots/data/services/match/match_service_interface.dart';

class MatchServiceHttp implements MatchServiceInterface {
  final FirebaseAuth _firebaseAuth;
  final String baseUrl;

  MatchServiceHttp(
    this._firebaseAuth, {
    this.baseUrl = 'http://localhost:5000',
  });

  Future<String> _getIdToken() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    final token = await user.getIdToken();
    return token ?? '';
  }

  Future<Map<String, String>> _headers() async {
    final token = await _getIdToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<void> createMatch(Map<String, dynamic> matchData) async {
    try {
      final headers = await _headers();
      final url = Uri.parse('$baseUrl/api/matches');
      final resp = await http
          .post(url, headers: headers, body: jsonEncode(matchData))
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timeout');
      });

      if (resp.statusCode == 200 || resp.statusCode == 201) return;

      final body = _decode(resp.body);
      throw Exception(body['error'] ?? 'Failed to create match');
    } catch (e) {
      throw Exception('Error creating match: $e');
    }
  }

  @override
  Future<void> deleteMatch(String matchId) async {
    try {
      final headers = await _headers();
      final url = Uri.parse('$baseUrl/api/matches/$matchId');
      final resp = await http
          .delete(url, headers: headers)
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timeout');
      });

      if (resp.statusCode == 200 || resp.statusCode == 204) return;

      final body = _decode(resp.body);
      throw Exception(body['error'] ?? 'Failed to delete match');
    } catch (e) {
      throw Exception('Error deleting match: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllMatches() async {
    try {
      final headers = await _headers();
      final url = Uri.parse('$baseUrl/api/matches');
      final resp = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timeout');
      });

      if (resp.statusCode == 200) {
        final decoded = _decode(resp.body);
        return (decoded as List<dynamic>)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }

      final body = _decode(resp.body);
      throw Exception(body['error'] ?? 'Failed to fetch matches');
    } catch (e) {
      throw Exception('Error fetching matches: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMatchesForUser(String userId) async {
    try {
      final headers = await _headers();
      final url = Uri.parse('$baseUrl/api/matches/user/$userId');
      final resp = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timeout');
      });

      if (resp.statusCode == 200) {
        final decoded = _decode(resp.body);
        return (decoded as List<dynamic>)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }

      final body = _decode(resp.body);
      throw Exception(body['error'] ?? 'Failed to fetch matches');
    } catch (e) {
      throw Exception('Error fetching matches: $e');
    }
  }

  dynamic _decode(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return {};
    }
  }
}
