// Abstract repository interface (domain layer).
// The presentation layer depends on this, not on the concrete implementation.

import 'package:either_dart/either.dart';
import 'package:misbah_path/core/services/error_handling_system.dart';

import '../../data/models/ai_model.dart';
import '../../data/models/chat_message.dart';
import '../../data/models/conversation.dart';

abstract class FanarRepository {
  // ─── AI ───────────────────────────────────────────────────────────────────

  /// Sends the full conversation [history] to the API and returns the
  /// assistant reply text, or a [Failure].
  Future<Either<Failure, String>> sendMessage({
    required List<ChatMessage> history,
    required String model,
  });

  /// Returns available Fanar models (falls back to defaults on error).
  Future<Either<Failure, List<AiModel>>> getModels();

  // ─── Conversations ────────────────────────────────────────────────────────

  Future<Conversation> createConversation(String title);
  Future<List<Conversation>> getAllConversations();
  Future<List<Conversation>> searchConversations(String query);
  Future<void> renameConversation(int id, String newTitle);
  Future<void> deleteConversation(int id);

  // ─── Messages ─────────────────────────────────────────────────────────────

  Future<ChatMessage> addMessage(ChatMessage message);
  Future<List<ChatMessage>> getMessages(int conversationId);
  Future<void> deleteMessage(int id);
}
