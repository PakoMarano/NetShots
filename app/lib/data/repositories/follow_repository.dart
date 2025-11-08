import 'package:netshots/data/services/follow/follow_service_mock.dart';

class FollowRepository {
  final FollowServiceMock _service;

  FollowRepository(this._service);

  Future<void> follow(String me, String target) async {
    await _service.follow(me, target);
  }

  Future<void> unfollow(String me, String target) async {
    await _service.unfollow(me, target);
  }

  Future<bool> isFollowing(String me, String target) async {
    return await _service.isFollowing(me, target);
  }

  Future<List<String>> getFollowers(String userId) async {
    return await _service.getFollowers(userId);
  }

  Future<List<String>> getFollowing(String userId) async {
    return await _service.getFollowing(userId);
  }
}
