// lib/features/chat/services/chat_repository.dart

import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../shared/models/chat_model.dart';
import '../../notification/services/notification_repository.dart';
import 'dart:async';

final chatRepositoryProvider = Provider((ref) => ChatRepository());

class ChatRepository {
  final _messages = <String, List<ChatMessage>>{};
  final _controllers = <String, StreamController<List<ChatMessage>>>{};

  Stream<List<ChatMessage>> streamMessages(String questId) {
    if (!_controllers.containsKey(questId)) {
      _controllers[questId] = StreamController<List<ChatMessage>>.broadcast();
      _messages[questId] = [];
    }
    return _controllers[questId]!.stream;
  }

  Future<void> sendMessage({
    required String questId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    final message = ChatMessage(
      messageId: const Uuid().v4(),
      senderId: senderId,
      senderName: senderName,
      text: text,
      createdAt: DateTime.now(),
    );
    
    if (!_messages.containsKey(questId)) {
      _messages[questId] = [];
      _controllers[questId] = StreamController<List<ChatMessage>>.broadcast();
    }
    
    _messages[questId]!.add(message);
    _controllers[questId]!.add(List.from(_messages[questId]!));
  }

  Future<void> sendFile({
    required String questId,
    required String senderId,
    required String senderName,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    final message = ChatMessage(
      messageId: const Uuid().v4(),
      senderId: senderId,
      senderName: senderName,
      text: fileName,
      fileUrl: 'https://mock.com/$fileName',
      fileName: fileName,
      isFile: true,
      createdAt: DateTime.now(),
    );

    if (!_messages.containsKey(questId)) {
      _messages[questId] = [];
      if (!_controllers.containsKey(questId)) {
        _controllers[questId] = StreamController<List<ChatMessage>>.broadcast();
      }
    }

    _messages[questId]!.add(message);
    _controllers[questId]!.add(List.from(_messages[questId]!));
  }
}
