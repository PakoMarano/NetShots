import 'package:flutter/material.dart';

class UserSearchViewModel extends ChangeNotifier {
  String _searchQuery = '';
  bool _isSearching = false;
  List<String> _searchResults = [];

  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;
  List<String> get searchResults => _searchResults;
  bool get hasResults => _searchResults.isNotEmpty;
  bool get isEmpty => _searchQuery.isEmpty;

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
    
    // Simulate search with a small delay
    if (query.isNotEmpty) {
      _performSearch(query);
    } else {
      _clearResults();
    }
  }

  void _performSearch(String query) async {
    _isSearching = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock search results for now
    _searchResults = _generateMockResults(query);
    _isSearching = false;
    notifyListeners();
  }

  void _clearResults() {
    _searchResults.clear();
    _isSearching = false;
    notifyListeners();
  }

  List<String> _generateMockResults(String query) {
    // Mock data for demonstration
    final mockUsers = [
      'Marco Rossi',
      'Giulia Bianchi', 
      'Alessandro Verdi',
      'Francesca Neri',
      'Luca Ferrari',
      'Sara Romano',
      'Davide Ricci',
      'Elena Conti',
    ];

    // Filter mock users based on query
    return mockUsers
        .where((user) => user.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void clearSearch() {
    _searchQuery = '';
    _clearResults();
  }
}
