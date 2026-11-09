// All conversation & message use cases in one file to keep things concise.

import '../../data/models/ai_model.dart';
import '../../data/models/chat_message.dart';
import '../../data/models/conversation.dart';
import '../repositories/fanar_repository.dart';

class CreateConversationUseCase {
  const CreateConversationUseCase(this._repository);
  final FanarRepository _repository;

  Future<Conversation> call(String title) =>
      _repository.createConversation(title);
}

class GetAllConversationsUseCase {
  const GetAllConversationsUseCase(this._repository);
  final FanarRepository _repository;

  Future<List<Conversation>> call() => _repository.getAllConversations();
}

class SearchConversationsUseCase {
  const SearchConversationsUseCase(this._repository);
  final FanarRepository _repository;

  Future<List<Conversation>> call(String query) =>
      _repository.searchConversations(query);
}

class RenameConversationUseCase {
  const RenameConversationUseCase(this._repository);
  final FanarRepository _repository;

  Future<void> call(int id, String newTitle) =>
      _repository.renameConversation(id, newTitle);
}

class DeleteConversationUseCase {
  const DeleteConversationUseCase(this._repository);
  final FanarRepository _repository;

  Future<void> call(int id) => _repository.deleteConversation(id);
}

class AddMessageUseCase {
  const AddMessageUseCase(this._repository);
  final FanarRepository _repository;

  Future<ChatMessage> call(ChatMessage message) =>
      _repository.addMessage(message);
}

class GetMessagesUseCase {
  const GetMessagesUseCase(this._repository);
  final FanarRepository _repository;

  Future<List<ChatMessage>> call(int conversationId) =>
      _repository.getMessages(conversationId);
}

class DeleteMessageUseCase {
  const DeleteMessageUseCase(this._repository);
  final FanarRepository _repository;

  Future<void> call(int id) => _repository.deleteMessage(id);
}

class GetModelsUseCase {
  const GetModelsUseCase(this._repository);
  final FanarRepository _repository;

  Future<List<AiModel>> call() async {
    final result = await _repository.getModels();
    return result.fold((_) => AiModel.defaults, (models) => models);
  }
}
