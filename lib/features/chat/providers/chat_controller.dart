// lib/features/chat/providers/chat_controller.dart
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/chat_repository.dart';
import '../../../shared/models/chat_model.dart';
import '../../../core/errors/failure.dart';

final chatMessagesProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, questId) {
  return ref.watch(chatRepositoryProvider).streamMessages(questId);
});

final chatControllerProvider =
    StateNotifierProvider<ChatController, AsyncValue<void>>((ref) {
  return ChatController(ref.watch(chatRepositoryProvider));
});

class ChatController extends StateNotifier<AsyncValue<void>> {
  final ChatRepository _repo;
  ChatController(this._repo) : super(const AsyncValue.data(null));

  Future<void> sendMessage({
    required String questId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;
    state = const AsyncValue.loading();
    try {
      await _repo.sendMessage(
        questId: questId,
        senderId: senderId,
        senderName: senderName,
        text: text.trim(),
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(Failure(e.toString()), st);
    }
  }

  Future<void> sendFile({
    required String questId,
    required String senderId,
    required String senderName,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repo.sendFile(
        questId: questId,
        senderId: senderId,
        senderName: senderName,
        fileBytes: fileBytes,
        fileName: fileName,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(Failure(e.toString()), st);
    }
  }
}
