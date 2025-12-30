abstract class FeedServiceInterface {
  /// Get feed items from followed users
  /// [limit] - Maximum number of items to return (default: 50)
  /// [offset] - Number of items to skip for pagination (default: 0)
  Future<List<Map<String, dynamic>>> getFeed({int? limit, int? offset});
}
