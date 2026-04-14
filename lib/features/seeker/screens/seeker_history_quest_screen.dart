// lib/features/seeker/screens/seeker_history_quest_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../../../shared/models/models.dart';
import '../../quest/providers/quest_controller.dart';

class SeekerHistoryQuestScreen extends ConsumerWidget {
  const SeekerHistoryQuestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questsAsync = ref.watch(seekerMyQuestsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Riwayat Quest'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: questsAsync.when(
        data: (quests) {
          // Hanya tampilkan yang selesai atau dibatalkan
          final history = quests
              .where((q) =>
                  q.status == QuestStatus.finished ||
                  q.status == QuestStatus.cancelled)
              .toList();

          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('Belum ada riwayat quest',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final quest = history[index];
              return _HistoryQuestCard(
                quest: quest,
                onTap: () => context.pushNamed(
                  'seekerActiveQuest',
                  pathParameters: {'questId': quest.questId},
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

class _HistoryQuestCard extends StatelessWidget {
  final QuestModel quest;
  final VoidCallback onTap;

  const _HistoryQuestCard({required this.quest, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final format =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final isFinished = quest.status == QuestStatus.finished;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Status Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isFinished
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFinished ? Icons.check_circle : Icons.cancel,
                color: isFinished ? Colors.green : Colors.red,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quest.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isFinished ? 'Selesai' : 'Dibatalkan',
                    style: TextStyle(
                      color: isFinished ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quest.finalPrice != null
                        ? format.format(quest.finalPrice)
                        : '${format.format(quest.minBudget)} - ${format.format(quest.maxBudget)}',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                ],
              ),
            ),

            // Date
            Text(
              DateFormat('dd MMM yy').format(quest.deadline),
              style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
