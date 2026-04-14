// lib/features/seeker/screens/seeker_history_transaction_screen.dart

// cloud_firestore removed — using mock data
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/models/models.dart';
import '../../auth/providers/auth_controller.dart';

// ─── Provider ─────────────────────────────────────────────────────────────────

final seekerTransactionHistoryProvider =
    StreamProvider.autoDispose<List<QuestModel>>((ref) {
  final uid = ref.watch(userProvider).value?.uid ?? '';
  if (uid.isEmpty) return const Stream.empty();
  return MockData.instance.questsStream.map((quests) => quests
      .where((q) =>
          q.seekerUid == uid && q.status == QuestStatus.finished)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
});

// ─── Screen ───────────────────────────────────────────────────────────────────

class SeekerHistoryTransactionScreen extends ConsumerWidget {
  const SeekerHistoryTransactionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(seekerTransactionHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: transactionsAsync.when(
        data: (quests) {
          if (quests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('Belum ada transaksi',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // Total pengeluaran
          final total = quests.fold<int>(
              0, (sum, q) => sum + (q.finalPrice ?? q.maxBudget));
          final format = NumberFormat.currency(
              locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

          return Column(
            children: [
              // ─── Total ───────────────────────────────────────────
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.payments_outlined,
                        color: Colors.white, size: 32),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Pengeluaran',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12)),
                        Text(
                          format.format(total),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '${quests.length} transaksi',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),

              // ─── List ─────────────────────────────────────────────
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: quests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final quest = quests[index];
                    return _TransactionCard(quest: quest, format: format);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final QuestModel quest;
  final NumberFormat format;

  const _TransactionCard({required this.quest, required this.format});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline,
                color: Colors.green, size: 20),
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 2),
                Text(
                  'ID: ${quest.questId.substring(0, 8).toUpperCase()}',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '- ${format.format(quest.finalPrice ?? quest.maxBudget)}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('dd MMM yy').format(quest.deadline),
                style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
