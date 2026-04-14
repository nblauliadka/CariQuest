// lib/shared/models/chat_model.dart


class ChatMessage {
  final String messageId;
  final String senderId;
  final String senderName;
  final String text;
  final String? fileUrl;
  final String? fileName;
  final bool isFile;
  final DateTime createdAt;

  ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.text,
    this.fileUrl,
    this.fileName,
    this.isFile = false,
    required this.createdAt,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessage(
      messageId: id,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      text: map['text'] ?? '',
      fileUrl: map['fileUrl'],
      fileName: map['fileName'],
      isFile: map['isFile'] ?? false,
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt'] as DateTime
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'isFile': isFile,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
