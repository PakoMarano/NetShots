abstract class FollowServiceInterface {
  Future<void> follow(String currentUserId, String targetUserId);
  Future<void> unfollow(String currentUserId, String targetUserId);
  Future<bool> isFollowing(String currentUserId, String targetUserId);
  Future<List<String>> getFollowers(String userId);
  Future<List<String>> getFollowing(String userId);
}
