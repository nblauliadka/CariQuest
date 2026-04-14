// lib/features/quest/screens/quest_detail_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/bid_controller.dart';
import '../providers/quest_controller.dart';

class QuestDetailView extends ConsumerWidget {
  final String questId;
  const QuestDetailView({super.key, required this.questId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questAsync = ref.watch(questStreamProvider(questId));
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detail Quest'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: questAsync.when(
        data: (quest) {
          if (quest == null) {
            return const Center(child: Text('Quest tidak ditemukan'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    StatusChip(status: quest.status),
                    const Spacer(),
                    if (quest.isUrgent) ...[
                      const Icon(Icons.timer_outlined,
                          size: 16, color: Colors.red),
                      const SizedBox(width: 4),
                      const Text('Urgent',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  quest.title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    quest.title,
                    style:
                        const TextStyle(color: AppColors.primary, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.payments_outlined,
                          color: AppColors.primary),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Budget',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(
                            quest.finalPrice != null
                                ? currencyFormat.format(quest.finalPrice)
                                : '${currencyFormat.format(quest.minBudget)} - ${currencyFormat.format(quest.maxBudget)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Deadline',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(
                            DateFormat('dd MMM yyyy').format(quest.deadline),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const _SectionTitle(title: 'Deskripsi'),
                Text(quest.description, style: const TextStyle(height: 1.6)),
                const SizedBox(height: 24),
                const SizedBox(height: 16),
                if (quest.status == QuestStatus.pending) ...[
                  CustomButton(
                    text: 'Ajukan Penawaran (Apply)',
                    onPressed: () => _showBidBottomSheet(context, ref, quest),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Nego Harga',
                    type: ButtonType.outline,
                    onPressed: () => _showNegoBottomSheet(context, ref, quest),
                  ),
                ] else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline,
                            color: Colors.grey.shade500, size: 16),
                        const SizedBox(width: 8),
                        Text('Quest sudah tidak menerima lamaran',
                            style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                const SizedBox(height: 48),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showBidBottomSheet(
      BuildContext context, WidgetRef ref, QuestModel quest) {
    final amountController = TextEditingController();
    final messageController = TextEditingController();
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ajukan Penawaran',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              'Budget: ${currencyFormat.format(quest.minBudget)} - ${currencyFormat.format(quest.maxBudget)}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Harga Penawaran (Rp)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixText: 'Rp ',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Pesan ke Seeker',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Kirim Lamaran',
              onPressed: () async {
                final amount =
                    int.tryParse(amountController.text.replaceAll('.', '')) ??
                        0;
                if (amount <= 0) return;
                await ref.read(bidControllerProvider.notifier).placeBid(
                      questId: quest.questId,
                      bidAmount: amount,
                      message: messageController.text,
                      seekerUid: quest.seekerUid,
                      questTitle: quest.title,
                    );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lamaran berhasil dikirim!')),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showNegoBottomSheet(
      BuildContext context, WidgetRef ref, QuestModel quest) {
    final amountController = TextEditingController();
    final messageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nego Harga',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Harga Nego (Rp)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixText: 'Rp ',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Alasan Nego',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Kirim Nego',
              onPressed: () async {
                final amount =
                    int.tryParse(amountController.text.replaceAll('.', '')) ??
                        0;
                if (amount <= 0) return;
                await ref.read(bidControllerProvider.notifier).placeBid(
                      questId: quest.questId,
                      bidAmount: amount,
                      message: '[NEGO] ${messageController.text}',
                      seekerUid: quest.seekerUid,
                      questTitle: quest.title,
                    );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nego berhasil dikirim!')),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }
}
