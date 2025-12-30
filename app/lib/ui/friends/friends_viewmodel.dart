import 'package:flutter/material.dart';
import 'package:netshots/data/repositories/feed_repository.dart';
import 'package:netshots/data/models/feed_item_model.dart';

class FriendsViewModel extends ChangeNotifier {
  final FeedRepository _feedRepository;

  FriendsViewModel(this._feedRepository);

  List<FeedItem> _feedItems = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasMore = true;
  int _currentOffset = 0;
  static const int _pageSize = 20;

  List<FeedItem> get feedItems => _feedItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  bool get isEmpty => _feedItems.isEmpty && !_isLoading;

  /// Load initial feed items
  Future<void> loadFeed() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    _currentOffset = 0;
    notifyListeners();

    try {
      final items = await _feedRepository.getFeed(limit: _pageSize, offset: 0);
      _feedItems = items;
      _hasMore = items.length >= _pageSize;
      _currentOffset = items.length;
    } catch (e) {
      _errorMessage = 'Impossibile caricare il feed';
      _feedItems = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh feed (pull-to-refresh)
  Future<void> refreshFeed() async {
    _currentOffset = 0;
    _hasMore = true;
    await loadFeed();
  }

  /// Load more feed items (pagination)
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final items = await _feedRepository.getFeed(
        limit: _pageSize,
        offset: _currentOffset,
      );
      _feedItems.addAll(items);
      _hasMore = items.length >= _pageSize;
      _currentOffset += items.length;
    } catch (e) {
      _errorMessage = 'Errore nel caricamento';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
