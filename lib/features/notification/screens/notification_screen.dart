// lib/features/notification/screens/notification_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/notification_model.dart';
import '../../../core/constants/app_enums.dart';
import '../services/notification_repository.dart';
import '../../auth/providers/auth_controller.dart';

// ─── Provider ─────────────────────────────────────────────────────────────────

final notificationsProvider =
    StreamProvider.autoDispose<List<NotificationModel>>((ref) {
  final uid = ref.watch(userProvider).value?.uid ?? '';
  if (uid.isEmpty) return const Stream.empty();
  return ref.watch(notificationRepositoryProvider).streamNotifications(uid);
});

// ─── Screen ───────────────────────────────────────────────────────────────────

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifsAsync = ref.watch(notificationsProvider);
    final uid = ref.watch(userProvider).value?.uid ?? '';
    final notifRepo = ref.read(notificationRepositoryProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: Colors.grey.shade50,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          notifsAsync.when(
            data: (notifs) {
              if (notifs.isEmpty) return const SizedBox();
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  if (value == 'read_all') {
                    await notifRepo.markAllAsRead(uid);
                  } else if (value == 'delete_all') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Hapus Semua Notifikasi'),
                        content: const Text(
                            'Yakin ingin menghapus semua notifikasi?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Hapus',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await notifRepo.deleteAllNotifications(uid);
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'read_all',
                    child: Row(
                      children: [
                        Icon(Icons.done_all, size: 18, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('Tandai semua dibaca'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete_all',
                    child: Row(
                      children: [
                        Icon(Icons.delete_sweep, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Hapus semua',
                            style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: notifsAsync.when(
        data: (notifs) {
          if (notifs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('Belum ada notifikasi',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final notif = notifs[index];
              return Dismissible(
                key: Key(notif.notifId),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.delete_outline,
                      color: Colors.white, size: 24),
                ),
                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Hapus Notifikasi'),
                      content:
                          const Text('Yakin ingin menghapus notifikasi ini?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Hapus',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (_) async {
                  await notifRepo.deleteNotification(notif.notifId);
                },
                child: _NotifTile(
                  notif: notif,
                  onTap: () async {
                    if (!notif.isRead) {
                      await notifRepo.markAsRead(notif.notifId);
                    }
                    if (notif.questId != null && context.mounted) {
                      context.pushNamed(
                        'seekerActiveQuest',
                        pathParameters: {'questId': notif.questId!},
                      );
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

// ─── Notif Tile ───────────────────────────────────────────────────────────────

class _NotifTile extends StatelessWidget {
  final NotificationModel notif;
  final VoidCallback onTap;

  const _NotifTile({required this.notif, required this.onTap});

  IconData get _icon {
    switch (notif.type) {
      case NotificationType.bid:
        return Icons.person_add_outlined;
      case NotificationType.accepted:
        return Icons.check_circle_outline;
      case NotificationType.rejected:
        return Icons.cancel_outlined;
      case NotificationType.paid:
        return Icons.payments_outlined;
      case NotificationType.working:
        return Icons.work_outline;
      case NotificationType.submitted:
        return Icons.upload_file_outlined;
      case NotificationType.finished:
        return Icons.emoji_events_outlined;
      case NotificationType.cancelled:
        return Icons.block_outlined;
      case NotificationType.dispute:
        return Icons.report_problem_outlined;
      case NotificationType.rankUp:
        return Icons.arrow_upward;
      case NotificationType.boost:
        return Icons.rocket_launch_outlined;
      case NotificationType.system:
      case NotificationType.general:
        return Icons.info_outline;
    }
  }

  Color get _color {
    switch (notif.type) {
      case NotificationType.bid:
        return Colors.blue;
      case NotificationType.accepted:
      case NotificationType.finished:
        return Colors.green;
      case NotificationType.rejected:
      case NotificationType.cancelled:
      case NotificationType.dispute:
        return Colors.red;
      case NotificationType.paid:
        return AppColors.primary;
      case NotificationType.working:
      case NotificationType.submitted:
        return Colors.orange;
      case NotificationType.rankUp:
        return Colors.purple;
      case NotificationType.boost:
        return Colors.deepOrange;
      case NotificationType.system:
      case NotificationType.general:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.isRead
              ? Colors.white
              : AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notif.isRead
                ? Colors.grey.shade100
                : AppColors.primary.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, color: _color, size: 20),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.title,
                    style: TextStyle(
                      fontWeight:
                          notif.isRead ? FontWeight.w500 : FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.body,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    timeago.format(notif.createdAt, locale: 'id'),
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                  ),
                ],
              ),
            ),

            // Unread dot
            if (!notif.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
