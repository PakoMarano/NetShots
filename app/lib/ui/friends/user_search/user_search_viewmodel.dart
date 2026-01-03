import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:netshots/data/repositories/search_repository.dart';
import 'package:netshots/data/models/search_user_model.dart';

class UserSearchViewModel extends ChangeNotifier {
  final SearchRepository _searchRepository;

  // Optional debounce to avoid firing too many requests
  Timer? _debounceTimer;

  String _searchQuery = '';
  bool _isSearching = false;
  List<SearchUser> _searchResults = [];

  UserSearchViewModel(this._searchRepository);

  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;
  List<SearchUser> get searchResults => _searchResults;
  bool get hasResults => _searchResults.isNotEmpty;
  bool get isEmpty => _searchQuery.isEmpty;

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();

    // Cancel any pending debounce timer
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      _clearResults();
      return;
    }

    // Debounce actual search call by 200ms (faster response)
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    _isSearching = true;
    notifyListeners();

    // Capture the query at start so stale results can be ignored
    final requestQuery = query;

    try {
  final results = await _searchRepository.searchUsers(requestQuery);

      // If the user typed a new query meanwhile, ignore these results
      if (requestQuery != _searchQuery) return;

  _searchResults = results;
    } catch (e) {
      // On error, clear results (could surface error state if needed)
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void _clearResults() {
    _searchResults = [];
    _isSearching = false;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _debounceTimer?.cancel();
    _clearResults();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
