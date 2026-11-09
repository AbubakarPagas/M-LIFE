// Concrete repository implementation.
// Coordinates the API service and the local database.

import 'package:either_dart/either.dart';
import 'package:misbah_path/core/services/error_handling_system.dart';

import '../../data/api/fanar_api_config.dart';
import '../../data/api/fanar_api_service.dart';
import '../../data/database/fanar_chat_database.dart';
import '../../data/models/ai_model.dart';
import '../../data/models/chat_message.dart';
import '../../data/models/conversation.dart';
import '../../domain/repositories/fanar_repository.dart';

class FanarRepositoryImpl implements FanarRepository {
  FanarRepositoryImpl({
    FanarApiService? apiService,
    FanarChatDatabase? database,
  }) : _api = apiService ?? FanarApiService.instance,
       _db = database ?? FanarChatDatabase.instance;

  final FanarApiService _api;
  final FanarChatDatabase _db;

  // ─── AI ───────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, String>> sendMessage({
    required List<ChatMessage> history,
    required String model,
  }) async {
    // Prepend system message if the history doesn't already start with one.
    final messages = _withSystemPrompt(history);
    return _api.sendMessage(messages: messages, model: model);
  }

  @override
  Future<Either<Failure, List<AiModel>>> getModels() => _api.getModels();

  // ─── Conversations ────────────────────────────────────────────────────────

  @override
  Future<Conversation> createConversation(String title) =>
      _db.insertConversation(
        Conversation(
          title: title,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

  @override
  Future<List<Conversation>> getAllConversations() => _db.getAllConversations();

  @override
  Future<List<Conversation>> searchConversations(String query) =>
      _db.searchConversations(query);

  @override
  Future<void> renameConversation(int id, String newTitle) =>
      _db.updateConversationTitle(id, newTitle);

  @override
  Future<void> deleteConversation(int id) => _db.deleteConversation(id);

  // ─── Messages ─────────────────────────────────────────────────────────────

  @override
  Future<ChatMessage> addMessage(ChatMessage message) =>
      _db.insertMessage(message);

  @override
  Future<List<ChatMessage>> getMessages(int conversationId) =>
      _db.getMessages(conversationId);

  @override
  Future<void> deleteMessage(int id) => _db.deleteMessage(id);

  // ─── Helpers ─────────────────────────────────────────────────────────────

  List<ChatMessage> _withSystemPrompt(List<ChatMessage> history) {
    if (history.isNotEmpty && history.first.role == 'system') return history;
    return [
      ChatMessage(
        conversationId: history.isNotEmpty ? history.first.conversationId : 0,
        role: 'system',
        content: FanarApiConfig.systemPrompt,
        timestamp: DateTime.now(),
      ),
      ...history,
    ];
  }
}
