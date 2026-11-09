// FanarChatController — GetX controller powering the chat UI.
// Follows the same GetxController + GetIt pattern used across this project.

import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/toast/islamic_toast.dart';
import '../../data/api/fanar_api_config.dart';
import '../../data/models/ai_model.dart';
import '../../data/models/chat_message.dart';
import '../../data/models/conversation.dart';
import '../../data/repository/fanar_repository_impl.dart';
import '../../domain/repositories/fanar_repository.dart';
import '../../domain/usecases/conversation_usecases.dart';
import '../../domain/usecases/send_message_usecase.dart';

enum FanarChatStatus { idle, loading, error, success }

class FanarChatController extends GetxController {
  static FanarChatController get instance =>
      Get.isRegistered<FanarChatController>()
      ? Get.find<FanarChatController>()
      : Get.put(FanarChatController(), permanent: true);

  // ─── Use cases (lazy-initialised so DI is flexible) ──────────────────────

  late final FanarRepository _repository = FanarRepositoryImpl();
  late final _sendMessage = SendMessageUseCase(_repository);
  late final _createConversation = CreateConversationUseCase(_repository);
  late final _getAllConversations = GetAllConversationsUseCase(_repository);
  late final _searchConversations = SearchConversationsUseCase(_repository);
  late final _renameConversation = RenameConversationUseCase(_repository);
  late final _deleteConversation = DeleteConversationUseCase(_repository);
  late final _addMessage = AddMessageUseCase(_repository);
  late final _getMessages = GetMessagesUseCase(_repository);
  late final _deleteMessage = DeleteMessageUseCase(_repository);
  late final _getModels = GetModelsUseCase(_repository);

  // ─── Observable state ────────────────────────────────────────────────────

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxList<Conversation> conversations = <Conversation>[].obs;
  final RxList<AiModel> availableModels = <AiModel>[].obs;
  final Rxn<Conversation> activeConversation = Rxn<Conversation>();

  final Rx<FanarChatStatus> chatStatus = FanarChatStatus.idle.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isTyping = false.obs; // AI "typing" indicator
  final RxString selectedModel = FanarApiConfig.defaultModel.obs;
  final RxString searchQuery = ''.obs;

  // Auto-retry state for 5xx errors.
  int _retryCount = 0;
  static const int _maxRetries = 2;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadConversations();
    _loadModels();
  }

  // ─── Conversations ────────────────────────────────────────────────────────

  Future<void> _loadConversations() async {
    try {
      final list = await _getAllConversations();
      conversations.value = list;
    } catch (e) {
      log('Error loading conversations: $e', name: 'FanarChatController');
    }
  }

  Future<void> startNewConversation() async {
    final conv = await _createConversation('New Chat');
    activeConversation.value = conv;
    messages.clear();
    await _loadConversations();
  }

  Future<void> openConversation(Conversation conv) async {
    activeConversation.value = conv;
    chatStatus.value = FanarChatStatus.loading;
    try {
      final msgs = await _getMessages(conv.id!);
      messages.value = msgs;
      chatStatus.value = FanarChatStatus.idle;
    } catch (e) {
      chatStatus.value = FanarChatStatus.error;
      errorMessage.value = 'Failed to load messages';
    }
  }

  Future<void> renameConversation(int id, String newTitle) async {
    await _renameConversation(id, newTitle);
    await _loadConversations();
    if (activeConversation.value?.id == id) {
      activeConversation.value = activeConversation.value?.copyWith(
        title: newTitle,
      );
    }
  }

  Future<void> deleteConversation(int id) async {
    await _deleteConversation(id);
    if (activeConversation.value?.id == id) {
      activeConversation.value = null;
      messages.clear();
    }
    await _loadConversations();
  }

  Future<void> searchConversations(String query) async {
    searchQuery.value = query;
    if (query.trim().isEmpty) {
      await _loadConversations();
      return;
    }
    final results = await _searchConversations(query);
    conversations.value = results;
  }

  // ─── Sending messages ────────────────────────────────────────────────────

  Future<void> sendUserMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Ensure there's an active conversation.
    if (activeConversation.value == null) {
      await startNewConversation();
    }

    final convId = activeConversation.value!.id!;

    // Persist and display the user message immediately.
    final userMsg = await _addMessage(
      ChatMessage(
        conversationId: convId,
        role: 'user',
        content: text.trim(),
        timestamp: DateTime.now(),
      ),
    );
    messages.add(userMsg);

    // Auto-title the conversation from the first user message.
    if (messages.where((m) => m.role == 'user').length == 1) {
      final title = text.length > 40
          ? '${text.substring(0, 40)}…'
          : text.trim();
      await renameConversation(convId, title);
    }

    // Show AI typing indicator.
    isTyping.value = true;
    chatStatus.value = FanarChatStatus.loading;
    errorMessage.value = '';
    _retryCount = 0;

    await _dispatchToApi(convId);
  }

  Future<void> _dispatchToApi(int convId) async {
    // Get all non-system messages to build context window.
    final history = messages.where((m) => m.role != 'system').toList();

    final result = await _sendMessage(
      history: history,
      model: selectedModel.value,
    );

    await result.fold(
      (failure) async {
        // Retry automatically on server errors — keep typing indicator on.
        if ((failure.code) >= 500 && _retryCount < _maxRetries) {
          _retryCount++;
          log(
            'Server error, retry $_retryCount/$_maxRetries',
            name: 'FanarChatController',
          );
          await Future.delayed(const Duration(seconds: 2));
          await _dispatchToApi(convId);
          return;
        }
        // Final failure — stop indicator and surface error.
        isTyping.value = false;
        chatStatus.value = FanarChatStatus.error;
        errorMessage.value = failure.message;
      },
      (reply) async {
        isTyping.value = false;
        final assistantMsg = await _addMessage(
          ChatMessage(
            conversationId: convId,
            role: 'assistant',
            content: reply,
            timestamp: DateTime.now(),
          ),
        );
        messages.add(assistantMsg);
        chatStatus.value = FanarChatStatus.success;
      },
    );
  }

  // ─── Message actions ─────────────────────────────────────────────────────

  Future<void> deleteMessage(int messageId) async {
    await _deleteMessage(messageId);
    messages.removeWhere((m) => m.id == messageId);
  }

  void copyMessage(String content) {
    Clipboard.setData(ClipboardData(text: content));
    final ctx = Get.context;
    if (ctx != null) {
      IslamicToast.show(
        ctx,
        message: 'Copied to clipboard',
        arabicMessage: 'تم النسخ',
        type: IslamicToastType.success,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> regenerateLastResponse() async {
    // Remove the last assistant message then re-send.
    final msgList = messages.toList();
    ChatMessage? lastAssistant;
    for (int i = msgList.length - 1; i >= 0; i--) {
      if (msgList[i].role == 'assistant') {
        lastAssistant = msgList[i];
        break;
      }
    }
    if (lastAssistant == null) return;

    if (lastAssistant.id != null) {
      await _deleteMessage(lastAssistant.id!);
    }
    messages.remove(lastAssistant);

    // Re-trigger sending with existing history.
    final convId = activeConversation.value?.id;
    if (convId == null) return;

    isTyping.value = true;
    chatStatus.value = FanarChatStatus.loading;
    errorMessage.value = '';
    _retryCount = 0;
    await _dispatchToApi(convId);
  }

  void clearError() {
    chatStatus.value = FanarChatStatus.idle;
    errorMessage.value = '';
  }

  // ─── Models ───────────────────────────────────────────────────────────────

  Future<void> _loadModels() async {
    final models = await _getModels();
    availableModels.value = models;
  }

  void selectModel(String modelId) {
    selectedModel.value = modelId;
  }
}
