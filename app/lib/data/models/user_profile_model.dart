class UserProfile {
  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final DateTime birthDate;
  final Gender gender;
  final String? profilePicture;
  final int victories;
  final int losses;
  final List<String> pictures;
  
  UserProfile({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.gender,
    this.profilePicture,
    this.victories = 0,
    this.losses = 0,
    this.pictures = const [],
  });

  String get fullName => '$firstName $lastName';
  
  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Total number of matches played (victories + losses)
  int get totalMatches => victories + losses;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'birthDate': birthDate.toIso8601String(),
      'gender': gender.toString().split('.').last,
      'profilePicture': profilePicture,
      'victories': victories,
      'losses': losses,
      'pictures': pictures,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userId: map['userId'],
      email: map['email'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      birthDate: DateTime.parse(map['birthDate']),
      gender: Gender.values.firstWhere((e) => e.toString() == 'Gender.${map['gender']}'),
      profilePicture: (map['profilePicture'] == null || (map['profilePicture'] is String && (map['profilePicture'] as String).isEmpty))
          ? null
          : map['profilePicture'] as String,
      victories: map['victories'] is int ? map['victories'] as int : (int.tryParse(map['victories']?.toString() ?? '') ?? 0),
      losses: map['losses'] is int ? map['losses'] as int : (int.tryParse(map['losses']?.toString() ?? '') ?? 0),
      pictures: List<String>.from(map['pictures'] ?? []),
    );
  }

  UserProfile copyWith({
    String? userId,
    String? email,
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    Gender? gender,
    String? profilePicture,
    // When true, explicitly clear the profilePicture (set to null).
    bool clearProfilePicture = false,
    int? victories,
    int? losses,
    List<String>? pictures,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      profilePicture: clearProfilePicture
          ? null
          : (profilePicture ?? this.profilePicture),
      victories: victories ?? this.victories,
      losses: losses ?? this.losses,
      pictures: pictures ?? this.pictures,
    );
  }

  @override
  String toString() {
    return 'UserProfile(userId: $userId, email: $email, firstName: $firstName, lastName: $lastName, age: $age, gender: $gender, victories: $victories, losses: $losses)';
  }
}

enum Gender {
  male,
  female,
  other
}
