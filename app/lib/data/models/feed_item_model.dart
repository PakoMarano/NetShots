import 'package:netshots/data/models/match_model.dart';

class FeedItem {
  final MatchModel match;
  final FeedUser user;

  FeedItem({
    required this.match,
    required this.user,
  });

  factory FeedItem.fromMap(Map<String, dynamic> map) {
    return FeedItem(
      match: MatchModel.fromMap(map['match'] as Map<String, dynamic>),
      user: FeedUser.fromMap(map['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'match': match.toMap(),
      'user': user.toMap(),
    };
  }

  @override
  String toString() {
    return 'FeedItem(user: ${user.displayName}, match: ${match.id}, isVictory: ${match.isVictory})';
  }
}

class FeedUser {
  final String userId;
  final String displayName;
  final String? profilePicture;

  FeedUser({
    required this.userId,
    required this.displayName,
    this.profilePicture,
  });

  factory FeedUser.fromMap(Map<String, dynamic> map) {
    return FeedUser(
      userId: map['userId'] as String,
      displayName: map['displayName'] as String,
      profilePicture: map['profilePicture'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'displayName': displayName,
      'profilePicture': profilePicture,
    };
  }

  @override
  String toString() {
    return 'FeedUser(userId: $userId, displayName: $displayName)';
  }
}
