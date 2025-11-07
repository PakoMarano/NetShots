class MatchModel {
  final String id;
  final String userId;
  final bool isVictory;
  final DateTime date;
  final String picture; // non-nullable: picture is required
  final String? notes;

  MatchModel({
    required this.id,
    required this.userId,
    required this.isVictory,
    required this.date,
    required this.picture,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'isVictory': isVictory,
      'date': date.toIso8601String(),
      'picture': picture,
      'notes': notes,
    };
  }

  factory MatchModel.fromMap(Map<String, dynamic> map) {
    return MatchModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      isVictory: map['isVictory'] is bool
          ? map['isVictory'] as bool
          : (map['isVictory']?.toString() == 'true'),
      date: map['date'] is String
          ? DateTime.parse(map['date'])
          : DateTime.tryParse((map['date'] ?? '').toString()) ?? DateTime.now(),
      // picture is required: coerce to empty string if missing to avoid runtime crash,
      // but the UI should ensure a non-empty picture is always provided when creating a match.
      picture: (map['picture'] is String) ? (map['picture'] as String) : '',
      notes: map['notes'],
    );
  }

  MatchModel copyWith({
    String? id,
    String? userId,
    bool? isVictory,
    DateTime? date,
    String? picture,
    String? notes,
  }) {
    return MatchModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      isVictory: isVictory ?? this.isVictory,
      date: date ?? this.date,
      picture: picture ?? this.picture,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'MatchModel(id: $id, userId: $userId, isVictory: $isVictory, date: $date, picture: $picture)';
  }
}
