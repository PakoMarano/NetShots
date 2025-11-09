class SearchUser {
  final String userId;
  final String displayName;
  final String? profilePicture;

  SearchUser({required this.userId, required this.displayName, this.profilePicture});

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'displayName': displayName,
        'profilePicture': profilePicture,
      };

  factory SearchUser.fromMap(Map<String, dynamic> map) {
    return SearchUser(
      userId: map['userId']?.toString() ?? '',
      displayName: map['displayName']?.toString() ?? '',
      profilePicture: map['profilePicture']?.toString(),
    );
  }
}
