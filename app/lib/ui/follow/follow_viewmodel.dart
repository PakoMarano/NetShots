import 'package:flutter/material.dart';
import 'package:netshots/data/repositories/follow_repository.dart';
import 'package:netshots/data/repositories/auth_repository.dart';

class FollowViewModel extends ChangeNotifier {
  final FollowRepository _followRepository;
  final AuthRepository _authRepository;

  final Set<String> _following = {};
  final Set<String> _loading = {};

  FollowViewModel(this._followRepository, this._authRepository);

  Future<void> init() async {
    final me = _authRepository.getCurrentUserId() ?? '';
    if (me.isEmpty) return;
    try {
      final list = await _followRepository.getFollowing(me);
      _following.clear();
      _following.addAll(list);
      notifyListeners();
    } catch (_) {
      // ignore - keep empty cache
    }
  }

  bool isFollowing(String targetId) => _following.contains(targetId);

  bool isLoading(String targetId) => _loading.contains(targetId);

  Future<void> toggleFollow(String targetId) async {
    final me = _authRepository.getCurrentUserId() ?? '';
    if (me.isEmpty) return;
    if (_loading.contains(targetId)) return;

    final willFollow = !_following.contains(targetId);

    // optimistic update
    if (willFollow) {
      _following.add(targetId);
    } else {
      _following.remove(targetId);
    }
    _loading.add(targetId);
    notifyListeners();

    try {
      if (willFollow) {
        await _followRepository.follow(me, targetId);
      } else {
        await _followRepository.unfollow(me, targetId);
      }
    } catch (e) {
      // revert on error
      if (willFollow) {
        _following.remove(targetId);
      } else {
        _following.add(targetId);
      }
      rethrow;
    } finally {
      _loading.remove(targetId);
      notifyListeners();
    }
  }
}
