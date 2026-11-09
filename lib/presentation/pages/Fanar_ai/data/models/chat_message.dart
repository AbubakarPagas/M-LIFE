// Data model for a single chat message.
// Supports the three Fanar API roles: system, user, assistant.

class ChatMessage {
  final int? id;
  final int conversationId;
  final String role; // 'system' | 'user' | 'assistant'
  final String content;
  final DateTime timestamp;

  const ChatMessage({
    this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  // Converts to the JSON shape expected by the Fanar API.
  Map<String, String> toApiMap() => {'role': role, 'content': content};

  // Converts to a map for SQLite storage.
  Map<String, dynamic> toDb() => {
    if (id != null) 'id': id,
    'conversationId': conversationId,
    'role': role,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ChatMessage.fromDb(Map<String, dynamic> map) => ChatMessage(
    id: map['id'] as int?,
    conversationId: map['conversationId'] as int,
    role: map['role'] as String,
    content: map['content'] as String,
    timestamp: DateTime.parse(map['timestamp'] as String),
  );

  ChatMessage copyWith({
    int? id,
    int? conversationId,
    String? role,
    String? content,
    DateTime? timestamp,
  }) => ChatMessage(
    id: id ?? this.id,
    conversationId: conversationId ?? this.conversationId,
    role: role ?? this.role,
    content: content ?? this.content,
    timestamp: timestamp ?? this.timestamp,
  );
}
