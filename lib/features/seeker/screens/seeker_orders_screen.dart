// lib/features/seeker/screens/seeker_orders_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../../../shared/models/models.dart';
import '../../quest/providers/quest_controller.dart';

class SeekerOrdersScreen extends ConsumerWidget {
  const SeekerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questsAsync = ref.watch(seekerMyQuestsProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Manage Orders',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF1A1A2E),
          ),
        ),
      ),
      body: questsAsync.when(
        data: (quests) {
          final orders = quests
              .where((q) =>
                  q.status == QuestStatus.working ||
                  q.status == QuestStatus.review ||
                  q.status == QuestStatus.paid)
              .toList();

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.receipt_long_outlined,
                        size: 48,
                        color: AppColors.primary.withValues(alpha: 0.4)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada order aktif',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Quest yang sedang dikerjakan\nakan muncul di sini',
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 13, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final quest = orders[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _OrderCard(
                  quest: quest,
                  onTap: () => context.pushNamed(
                    'seekerActiveQuest',
                    pathParameters: {'questId': quest.questId},
                  ),
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

class _OrderCard extends StatelessWidget {
  final QuestModel quest;
  final VoidCallback onTap;
  const _OrderCard({required this.quest, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = quest.status;
    final diff = quest.deadline.difference(DateTime.now());

    Color statusColor() {
      switch (status) {
        case QuestStatus.paid:
          return Colors.blue;
        case QuestStatus.working:
          return AppColors.primary;
        case QuestStatus.review:
          return AppColors.gold;
        default:
          return Colors.grey;
      }
    }

    String statusLabel() {
      switch (status) {
        case QuestStatus.paid:
          return '💰 Dibayar';
        case QuestStatus.working:
          return '🔨 Dikerjakan';
        case QuestStatus.review:
          return '👀 Review';
        default:
          return status.name;
      }
    }

    String countdownLabel() {
      if (diff.isNegative) return 'Lewat deadline!';
      if (diff.inHours < 24) {
        return '${diff.inHours}j ${diff.inMinutes % 60}m lagi';
      }
      return '${diff.inDays} hari lagi';
    }

    final sc = statusColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: sc.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    quest.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1A1A2E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: sc.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: sc.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    statusLabel(),
                    style: TextStyle(
                        color: sc, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              quest.description,
              style: TextStyle(
                  color: Colors.grey.shade600, fontSize: 13, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.payments_outlined,
                    size: 12, color: Color(0xFF2E7D32)),
                const SizedBox(width: 3),
                Text(
                  'Rp ${_fmt(quest.minBudget)}–${_fmt(quest.maxBudget)}',
                  style: const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 11,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 12),
                Icon(Icons.schedule_rounded,
                    size: 12,
                    color: diff.isNegative || diff.inHours < 24
                        ? Colors.red
                        : Colors.grey.shade600),
                const SizedBox(width: 3),
                Text(
                  countdownLabel(),
                  style: TextStyle(
                      color: diff.isNegative || diff.inHours < 24
                          ? Colors.red
                          : Colors.grey.shade600,
                      fontSize: 11,
                      fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 11, color: Colors.grey.shade400),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _fmt(int v) {
  if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}jt';
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}rb';
  return v.toString();
}
