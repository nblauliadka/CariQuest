// lib/features/notification/services/notification_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/errors/failure.dart';
import '../../../shared/models/notification_model.dart';
import '../../../core/constants/app_enums.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

class NotificationRepository {
  final MockData _db = MockData.instance;

  Stream<List<NotificationModel>> streamNotifications(String uid) {
    return _db.notificationsStream.map((notifs) =>
        notifs.where((n) => n.uid == uid).toList());
  }

  Future<void> sendNotification({
    required String uid,
    required String title,
    required String body,
    required NotificationType type,
    String? questId,
  }) async {
    final notif = NotificationModel(
      notifId: const Uuid().v4(),
      uid: uid,
      title: title,
      body: body,
      type: type,
      questId: questId,
      createdAt: DateTime.now(),
    );
    _db.notifications.insert(0, notif);
    _db.emitNotifications();
  }

  Future<void> markAsRead(String notifId) async {
    final idx = _db.notifications.indexWhere((n) => n.notifId == notifId);
    if (idx != -1) {
      _db.notifications[idx] = _db.notifications[idx].copyWith(isRead: true);
      _db.emitNotifications();
    }
  }

  Future<void> markAllAsRead(String uid) async {
    for (var i = 0; i < _db.notifications.length; i++) {
      if (_db.notifications[i].uid == uid) {
        _db.notifications[i] = _db.notifications[i].copyWith(isRead: true);
      }
    }
    _db.emitNotifications();
  }

  Future<void> deleteNotification(String notifId) async {
    _db.notifications.removeWhere((n) => n.notifId == notifId);
    _db.emitNotifications();
  }

  Future<void> deleteAllNotifications(String uid) async {
    _db.notifications.removeWhere((n) => n.uid == uid);
    _db.emitNotifications();
  }
}
