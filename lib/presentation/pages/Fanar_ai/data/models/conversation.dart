// Data model for a conversation (chat session).

class Conversation {
  final int? id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Conversation({
    this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toDb() => {
    if (id != null) 'id': id,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Conversation.fromDb(Map<String, dynamic> map) => Conversation(
    id: map['id'] as int?,
    title: map['title'] as String,
    createdAt: DateTime.parse(map['createdAt'] as String),
    updatedAt: DateTime.parse(map['updatedAt'] as String),
  );

  Conversation copyWith({
    int? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Conversation(
    id: id ?? this.id,
    title: title ?? this.title,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
