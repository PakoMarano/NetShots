import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:netshots/data/services/match/match_service_interface.dart';

class MatchServiceMock implements MatchServiceInterface {
  final SharedPreferences _sharedPreferences;
  static const String _matchesKey = 'matches';

  MatchServiceMock(this._sharedPreferences);

  Future<List<Map<String, dynamic>>> _readAll() async {
    final jsonStr = _sharedPreferences.getString(_matchesKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _writeAll(List<Map<String, dynamic>> matches) async {
    final jsonStr = jsonEncode(matches);
    await _sharedPreferences.setString(_matchesKey, jsonStr);
  }

  @override
  Future<void> createMatch(Map<String, dynamic> matchData) async {
    // Simulate latency
    await Future.delayed(Duration(milliseconds: 300));

    final matches = await _readAll();
    // ensure id exists
    final id = matchData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    final record = Map<String, dynamic>.from(matchData)..['id'] = id;
    matches.add(record);
    await _writeAll(matches);
  }

  @override
  Future<void> deleteMatch(String matchId) async {
    await Future.delayed(Duration(milliseconds: 200));
    final matches = await _readAll();
    matches.removeWhere((m) => m['id'] == matchId);
    await _writeAll(matches);
  }

  @override
  Future<List<Map<String, dynamic>>> getAllMatches() async {
    await Future.delayed(Duration(milliseconds: 200));
    return await _readAll();
  }

  @override
  Future<List<Map<String, dynamic>>> getMatchesForUser(String userId) async {
    final all = await _readAll();
    return all.where((m) => m['userId'] == userId).toList();
  }
}
