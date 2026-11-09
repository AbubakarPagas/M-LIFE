import 'package:either_dart/either.dart';
import 'package:misbah_path/core/services/error_handling_system.dart';

import '../../data/models/chat_message.dart';
import '../repositories/fanar_repository.dart';

class SendMessageUseCase {
  const SendMessageUseCase(this._repository);
  final FanarRepository _repository;

  Future<Either<Failure, String>> call({
    required List<ChatMessage> history,
    required String model,
  }) => _repository.sendMessage(history: history, model: model);
}
