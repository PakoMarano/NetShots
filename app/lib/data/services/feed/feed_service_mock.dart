import 'package:netshots/data/services/feed/feed_service_interface.dart';

class FeedServiceMock implements FeedServiceInterface {
  FeedServiceMock();

  @override
  Future<List<Map<String, dynamic>>> getFeed({int? limit, int? offset}) async {
    // Simulate a network call
    await Future.delayed(const Duration(seconds: 1));

    final mockFeedItems = <Map<String, dynamic>>[
      {
        'match': {
          'id': 'match_1',
          'userId': 'user_123',
          'isVictory': true,
          'date': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
          'picture': 'https://via.placeholder.com/400',
          'notes': 'Grande partita!',
        },
        'user': {
          'userId': 'user_123',
          'displayName': 'Mario Rossi',
          'profilePicture': 'https://via.placeholder.com/150',
        },
      },
      {
        'match': {
          'id': 'match_2',
          'userId': 'user_456',
          'isVictory': false,
          'date': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
          'picture': 'https://via.placeholder.com/400',
          'notes': null,
        },
        'user': {
          'userId': 'user_456',
          'displayName': 'Laura Bianchi',
          'profilePicture': 'https://via.placeholder.com/150',
        },
      },
      {
        'match': {
          'id': 'match_3',
          'userId': 'user_789',
          'isVictory': true,
          'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          'picture': 'https://via.placeholder.com/400',
          'notes': 'Ottima prestazione',
        },
        'user': {
          'userId': 'user_789',
          'displayName': 'Giovanni Verdi',
          'profilePicture': null,
        },
      },
      {
        'match': {
          'id': 'match_4',
          'userId': 'user_123',
          'isVictory': true,
          'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
          'picture': 'https://via.placeholder.com/400',
          'notes': 'Bellissimo scatto',
        },
        'user': {
          'userId': 'user_123',
          'displayName': 'Mario Rossi',
          'profilePicture': 'https://via.placeholder.com/150',
        },
      },
    ];

    // Apply pagination
    final effectiveLimit = limit ?? 50;
    final effectiveOffset = offset ?? 0;
    
    final start = effectiveOffset;
    final end = (effectiveOffset + effectiveLimit).clamp(0, mockFeedItems.length);
    
    if (start >= mockFeedItems.length) {
      return [];
    }
    
    return mockFeedItems.sublist(start, end);
  }
}
