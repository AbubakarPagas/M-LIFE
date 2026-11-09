import 'dart:convert';

/// Represents a saved Tasbih counting session.
class TasbihSession {
  final String id;
  final String dhikrName;
  final String dhikrArabic;
  final int targetCount;
  final int totalCount;
  final DateTime date;

  const TasbihSession({
    required this.id,
    required this.dhikrName,
    required this.dhikrArabic,
    required this.targetCount,
    required this.totalCount,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'dhikrName': dhikrName,
    'dhikrArabic': dhikrArabic,
    'targetCount': targetCount,
    'totalCount': totalCount,
    'date': date.toIso8601String(),
  };

  factory TasbihSession.fromMap(Map<String, dynamic> map) => TasbihSession(
    id: map['id'] as String,
    dhikrName: map['dhikrName'] as String,
    dhikrArabic: map['dhikrArabic'] as String,
    targetCount: map['targetCount'] as int,
    totalCount: map['totalCount'] as int,
    date: DateTime.parse(map['date'] as String),
  );

  String toJson() => jsonEncode(toMap());
  factory TasbihSession.fromJson(String source) =>
      TasbihSession.fromMap(jsonDecode(source) as Map<String, dynamic>);

  /// Completion percentage clamped to [0, 1].
  double get completionRate =>
      targetCount > 0 ? (totalCount / targetCount).clamp(0.0, 1.0) : 0.0;

  bool get isCompleted => totalCount >= targetCount;
}
