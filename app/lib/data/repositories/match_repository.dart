import 'package:netshots/data/models/match_model.dart';
import 'package:netshots/data/services/match/match_service_interface.dart';
import 'package:netshots/data/services/profile/profile_service_interface.dart';

class MatchRepository {
  final MatchServiceInterface _matchService;
  final ProfileServiceInterface _profileService;

  MatchRepository(this._matchService, this._profileService);

  Future<void> addMatch(MatchModel match) async {
    await _matchService.createMatch(match.toMap());
    // Update profile stats (best-effort). 
    // The gallery is derived from matches via `getGalleryFromMatches`.
    try {
      final profile = await _profileService.getProfile();
      if (profile != null && profile['userId'] == match.userId) {
        final victories = (profile['victories'] is int)
            ? profile['victories'] as int
            : (int.tryParse(profile['victories']?.toString() ?? '') ?? 0);
        final losses = (profile['losses'] is int)
            ? profile['losses'] as int
            : (int.tryParse(profile['losses']?.toString() ?? '') ?? 0);

        final newVictories = match.isVictory ? victories + 1 : victories;
        final newLosses = match.isVictory ? losses : losses + 1;

        final updated = Map<String, dynamic>.from(profile)
          ..['victories'] = newVictories
          ..['losses'] = newLosses;

        await _profileService.updateProfile(updated);
      }
    } catch (e) {
      // best-effort: ignore profile update failures in the mock
    }
  }

  Future<void> deleteMatch(String matchId) async {
    try {
      final all = await _matchService.getAllMatches();
      final matchMap = all.firstWhere((m) => m['id'] == matchId, orElse: () => {});
      if (matchMap.isNotEmpty) {
        final match = MatchModel.fromMap(matchMap);
        await _matchService.deleteMatch(matchId);

        final profile = await _profileService.getProfile();
        if (profile != null && profile['userId'] == match.userId) {
          final victories = (profile['victories'] is int)
              ? profile['victories'] as int
              : (int.tryParse(profile['victories']?.toString() ?? '') ?? 0);
          final losses = (profile['losses'] is int)
              ? profile['losses'] as int
              : (int.tryParse(profile['losses']?.toString() ?? '') ?? 0);

          final newVictories = match.isVictory ? (victories - 1).clamp(0, 999999) : victories;
          final newLosses = match.isVictory ? losses : (losses - 1).clamp(0, 999999);

        final updated = Map<String, dynamic>.from(profile)
          ..['victories'] = newVictories
          ..['losses'] = newLosses;

        await _profileService.updateProfile(updated);
        }
        return;
      }
    } catch (e) {
      // ignore and attempt deletion anyway
    }

    await _matchService.deleteMatch(matchId);
  }

  Future<List<MatchModel>> getMatches(String userId) async {
    final maps = await _matchService.getMatchesForUser(userId);
    return maps.map((m) => MatchModel.fromMap(m)).toList();
  }

  /// Derive the user's gallery from their matches.
  /// Returns picture paths/URLs sorted by match date descending.
  /// If [limit] is provided, returns at most that many entries.
  Future<List<String>> getGalleryFromMatches(String userId, {int? limit}) async {
    final matches = await getMatches(userId);
    final pictures = matches
        .where((m) => m.picture.isNotEmpty)
        .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

    final result = pictures.map((m) => m.picture).toList();
    if (limit != null && result.length > limit) {
      return result.sublist(0, limit);
    }
    return result;
  }
}
