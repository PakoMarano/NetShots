class MatchModel {
  final String id;
  final String userId;
  final bool isVictory;
  final DateTime date;
  final String picture; // non-nullable: picture is required
  final String? notes;
  final double? latitude;
  final double? longitude;
  final double? temperature;
  final String? weatherDescription;

  MatchModel({
    required this.id,
    required this.userId,
    required this.isVictory,
    required this.date,
    required this.picture,
    this.notes,
    this.latitude,
    this.longitude,
    this.temperature,
    this.weatherDescription,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'isVictory': isVictory,
      'date': date.toIso8601String(),
      'picture': picture,
      'notes': notes,
      'latitude': latitude,
      'longitude': longitude,
      'temperature': temperature,
      'weatherDescription': weatherDescription,
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
      latitude: _toDouble(map['latitude']),
      longitude: _toDouble(map['longitude']),
      temperature: _toDouble(map['temperature']),
      weatherDescription: map['weatherDescription'],
    );
  }

  MatchModel copyWith({
    String? id,
    String? userId,
    bool? isVictory,
    DateTime? date,
    String? picture,
    String? notes,
    double? latitude,
    double? longitude,
    double? temperature,
    String? weatherDescription,
  }) {
    return MatchModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      isVictory: isVictory ?? this.isVictory,
      date: date ?? this.date,
      picture: picture ?? this.picture,
      notes: notes ?? this.notes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      temperature: temperature ?? this.temperature,
      weatherDescription: weatherDescription ?? this.weatherDescription,
    );
  }

  @override
  String toString() {
    return 'MatchModel(id: $id, userId: $userId, isVictory: $isVictory, date: $date, picture: $picture, lat: $latitude, lng: $longitude, temp: $temperature, weather: $weatherDescription)';
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
