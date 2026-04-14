// lib/shared/models/notification_model.dart

import 'package:equatable/equatable.dart';
import '../../core/constants/app_enums.dart';


class NotificationModel extends Equatable {
  final String notifId;
  final String uid;
  final String title;
  final String body;
  final NotificationType type;
  final String? questId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.notifId,
    required this.uid,
    required this.title,
    required this.body,
    required this.type,
    this.questId,
    this.isRead = false,
    required this.createdAt,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      notifId: notifId,
      uid: uid,
      title: title,
      body: body,
      type: type,
      questId: questId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notifId': notifId,
      'uid': uid,
      'title': title,
      'body': body,
      'type': type.name,
      'questId': questId,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      notifId: id,
      uid: map['uid'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => NotificationType.general,
      ),
      questId: map['questId'],
      isRead: map['isRead'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props =>
      [notifId, uid, title, body, type, questId, isRead, createdAt];
}
