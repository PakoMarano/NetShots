abstract class MatchServiceInterface {
  Future<void> createMatch(Map<String, dynamic> matchData);
  Future<List<Map<String, dynamic>>> getAllMatches();
  Future<List<Map<String, dynamic>>> getMatchesForUser(String userId);
  Future<void> deleteMatch(String matchId);
}
