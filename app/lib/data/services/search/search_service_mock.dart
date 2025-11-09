import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:netshots/data/services/search/search_service_interface.dart';
import 'package:netshots/data/models/search_user_model.dart';

class MockSearchService implements SearchServiceInterface {
  final SharedPreferences _prefs;

  final List<String> _mockUsers = [
    'Marco Rossi',
    'Giulia Bianchi',
    'Alessandro Verdi',
    'Francesca Neri',
    'Luca Ferrari',
    'Sara Romano',
    'Davide Ricci',
    'Elena Conti',
  ];

  MockSearchService(this._prefs);

  @override
  Future<List<SearchUser>> searchUsers(String query) async {
    // Simulate a small network delay
    await Future.delayed(const Duration(milliseconds: 300));

    if (query.isEmpty) return [];

    final lower = query.toLowerCase();

    // Determine current user id (if any) so we can exclude the current user
    String? currentUserId;
    try {
      final rawProfile = _prefs.getString('user_profile');
      if (rawProfile != null) {
        final decodedProfile = json.decode(rawProfile);
        if (decodedProfile is Map<String, dynamic>) {
          currentUserId = decodedProfile['userId']?.toString();
        }
      }
      // If still null, try auth email stored by AuthServiceMock and derive id
      if (currentUserId == null) {
        final email = _prefs.getString('user_email');
        if (email != null && email.isNotEmpty) {
          currentUserId = email.split('@').first;
        }
      }
    } catch (_) {
      // ignore parsing errors and proceed without excluding
      currentUserId = null;
    }

    // Start with static mock users
    final results = <SearchUser>[];
    final seen = <String>{};
    for (final u in _mockUsers) {
      if (u.toLowerCase().contains(lower)) {
        final id = u.toLowerCase().replaceAll(' ', '');
        if (currentUserId != null && id == currentUserId) continue;
        if (!seen.contains(id)) {
          results.add(SearchUser(userId: id, displayName: u, profilePicture: null));
          seen.add(id);
        }
      }
    }

    // Also try to pick up profiles stored in SharedPreferences.
    // We look for values that decode to a Map and appear to be a user profile
    // (contain 'firstName' and 'lastName' keys). This lets locally-created
    // profiles surface in search.
    try {
      for (final key in _prefs.getKeys()) {
        final raw = _prefs.getString(key);
        if (raw == null) continue;
        try {
          final decoded = json.decode(raw);
          if (decoded is Map<String, dynamic>) {
            if (decoded.containsKey('firstName') && decoded.containsKey('lastName')) {
              final first = decoded['firstName']?.toString() ?? '';
              final last = decoded['lastName']?.toString() ?? '';
              final display = '${first.trim()} ${last.trim()}'.trim();
              String id = '';
              if (decoded.containsKey('userId')) {
                id = decoded['userId']?.toString() ?? '';
              } else if (decoded.containsKey('email')) {
                id = (decoded['email'] as String).split('@').first;
              } else {
                id = display.toLowerCase().replaceAll(' ', '');
              }

              final picture = decoded['profilePicture']?.toString() ?? decoded['profile_picture']?.toString();

              if (display.isNotEmpty && display.toLowerCase().contains(lower)) {
                if (currentUserId != null && id == currentUserId) continue;
                if (!seen.contains(id)) {
                  results.add(SearchUser(userId: id, displayName: display, profilePicture: picture));
                  seen.add(id);
                }
              }
            }
          }
        } catch (_) {
          // ignore non-json or unexpected shapes
        }
      }
    } catch (_) {
      // ignore prefs iteration errors
    }

    return results.toList();
  }
}
