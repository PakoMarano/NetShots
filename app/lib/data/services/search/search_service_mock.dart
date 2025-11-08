import 'package:netshots/data/services/search/search_service_interface.dart';

class MockSearchService implements SearchServiceInterface {
  final List<String> _mockUsers = [
    'Marco Rossi',
    'Giulia Bianchi',
    'Alessandro Verdi',
    'Francesca Neri',
    'Luca Ferrari',
    'Sara Romano',
    'Davide Ricci',
    'Elena Conti',
  ];

  MockSearchService();

  @override
  Future<List<String>> searchUsers(String query) async {
    // Simulate a small network delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (query.isEmpty) return [];

    final lower = query.toLowerCase();
    return _mockUsers.where((u) => u.toLowerCase().contains(lower)).toList();
  }
}
