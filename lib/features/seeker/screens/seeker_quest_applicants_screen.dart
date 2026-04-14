// lib/features/seeker/screens/seeker_quest_applicants_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../quest/providers/bid_controller.dart';
import '../../quest/providers/quest_controller.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../core/constants/app_colors.dart';

class SeekerQuestApplicantsScreen extends ConsumerWidget {
  final String questId;

  const SeekerQuestApplicantsScreen({super.key, required this.questId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bidsAsync = ref.watch(questBidsProvider(questId));
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pelamar Quest'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          // ─── Tombol Batalkan Quest ──────────────────────────────────
          TextButton.icon(
            onPressed: () => _showCancelDialog(context, ref),
            icon: const Icon(Icons.cancel_outlined,
                color: Colors.white70, size: 18),
            label: const Text('Batalkan',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
          ),
        ],
      ),
      body: bidsAsync.when(
        data: (bids) {
          if (bids.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('Belum ada pelamar.',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(
                    'Tunggu sebentar, expert akan segera melamar!',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: bids.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final bid = bids[index];
              return _ApplicantCard(
                bid: bid,
                format: currencyFormat,
                onAccept: () => _showAcceptConfirmation(context, ref, bid),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Batalkan Quest?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Quest akan dibatalkan dan tidak bisa dikembalikan. Pelamar yang sudah melamar akan diberitahu.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(questControllerProvider.notifier)
                  .cancelQuest(questId);
              if (context.mounted) context.pop();
            },
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }

  void _showAcceptConfirmation(
      BuildContext context, WidgetRef ref, dynamic bid) {
    final format =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Konfirmasi Harga Deal',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Expert: ${bid.expertName}',
                style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text('Harga Deal',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    format.format(bid.bidAmount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (bid.message.isNotEmpty)
              Text(bid.message,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(height: 8),
            Text(
              'Dengan menekan "Deal & Bayar", kamu setuju dengan harga ini dan akan diarahkan ke halaman pembayaran.',
              style: TextStyle(
                  color: Colors.grey.shade500, fontSize: 11, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              await ref.read(bidControllerProvider.notifier).acceptBid(
                    bid.questId,
                    bid.bidId,
                    bid.expertUid,
                  );
              if (context.mounted) {
                Navigator.pop(context);
                context.pushNamed(
                  'payment',
                  pathParameters: {'questId': bid.questId},
                  extra: {
                    'amount': bid.bidAmount,
                    'title': 'Pembayaran Quest #${bid.questId.substring(0, 6)}',
                  },
                );
              }
            },
            child: const Text('Deal & Bayar 💰'),
          ),
        ],
      ),
    );
  }
}

// ─── Applicant Card ───────────────────────────────────────────────────────────

class _ApplicantCard extends StatelessWidget {
  final dynamic bid;
  final NumberFormat format;
  final VoidCallback onAccept;

  const _ApplicantCard({
    required this.bid,
    required this.format,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(
                imageUrl: bid.expertAvatar,
                rank: bid.expertRank,
                radius: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bid.expertName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: AppColors.gold),
                        const SizedBox(width: 4),
                        Text(
                          bid.expertRating.toString(),
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              RankBadge(rank: bid.expertRank, compact: true),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Penawaran:',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            format.format(bid.bidAmount),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(bid.message, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Pilih Expert',
            onPressed: onAccept,
          ),
        ],
      ),
    );
  }
}
