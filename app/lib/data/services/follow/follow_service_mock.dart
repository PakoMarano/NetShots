import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:netshots/data/services/follow/follow_service_interface.dart';

class FollowServiceMock implements FollowServiceInterface {
  final SharedPreferences _prefs;

  FollowServiceMock(this._prefs);

  String _followingKey(String userId) => 'following:$userId';
  String _followersKey(String userId) => 'followers:$userId';

  List<String> _readList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = json.decode(raw) as List<dynamic>;
      return decoded.map((e) => e as String).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeList(String key, List<String> list) async {
    await _prefs.setString(key, json.encode(list));
  }

  @override
  Future<void> follow(String currentUserId, String targetUserId) async {
    if (currentUserId == targetUserId) {
      // No-op for following self
      return;
    }

    // simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    final followingKey = _followingKey(currentUserId);
    final followersKey = _followersKey(targetUserId);

    final currentFollowing = _readList(followingKey);
    if (!currentFollowing.contains(targetUserId)) {
      currentFollowing.add(targetUserId);
      await _writeList(followingKey, currentFollowing);
    }

    final targetFollowers = _readList(followersKey);
    if (!targetFollowers.contains(currentUserId)) {
      targetFollowers.add(currentUserId);
      await _writeList(followersKey, targetFollowers);
    }
  }

  @override
  Future<void> unfollow(String currentUserId, String targetUserId) async {
    if (currentUserId == targetUserId) return;
    await Future.delayed(const Duration(milliseconds: 200));

    final followingKey = _followingKey(currentUserId);
    final followersKey = _followersKey(targetUserId);

    final currentFollowing = List<String>.from(_readList(followingKey));
    if (currentFollowing.remove(targetUserId)) {
      await _writeList(followingKey, currentFollowing);
    }

    final targetFollowers = List<String>.from(_readList(followersKey));
    if (targetFollowers.remove(currentUserId)) {
      await _writeList(followersKey, targetFollowers);
    }
  }

  @override
  Future<bool> isFollowing(String currentUserId, String targetUserId) async {
    if (currentUserId.isEmpty) return false;
    await Future.delayed(const Duration(milliseconds: 100));
    final currentFollowing = _readList(_followingKey(currentUserId));
    return currentFollowing.contains(targetUserId);
  }

  @override
  Future<List<String>> getFollowers(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _readList(_followersKey(userId));
  }

  @override
  Future<List<String>> getFollowing(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _readList(_followingKey(userId));
  }
}
