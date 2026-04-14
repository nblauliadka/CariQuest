// lib/features/admin/screens/admin_transactions_screen.dart
// cloud_firestore removed — mock mode
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/models/models.dart';

// ─── Provider (Mock) ────────────────────────────────────────────────────────
final adminTransactionsProvider =
    StreamProvider.autoDispose<List<QuestModel>>((ref) {
  final activeStatuses = {
    QuestStatus.paid, QuestStatus.working, QuestStatus.review,
    QuestStatus.finished, QuestStatus.cancelled, QuestStatus.disputed,
  };
  return MockData.instance.questsStream.map((quests) {
    final filtered = quests.where((q) => activeStatuses.contains(q.status)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  });
});


// ─── Screen ───────────────────────────────────────────────────────────────────
class AdminTransactionsScreen extends ConsumerStatefulWidget {
  const AdminTransactionsScreen({super.key});

  @override
  ConsumerState<AdminTransactionsScreen> createState() =>
      _AdminTransactionsScreenState();
}

class _AdminTransactionsScreenState
    extends ConsumerState<AdminTransactionsScreen> {
  String _filter = 'semua'; // semua, berjalan, selesai, dibatalkan, dispute

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(adminTransactionsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0EFF8),
      body: txAsync.when(
        data: (quests) {
          // Filter
          List<QuestModel> filtered;
          switch (_filter) {
            case 'berjalan':
              filtered = quests
                  .where((q) =>
                      q.status == QuestStatus.paid ||
                      q.status == QuestStatus.working ||
                      q.status == QuestStatus.review)
                  .toList();
              break;
            case 'selesai':
              filtered = quests
                  .where((q) => q.status == QuestStatus.finished)
                  .toList();
              break;
            case 'dibatalkan':
              filtered = quests
                  .where((q) => q.status == QuestStatus.cancelled)
                  .toList();
              break;
            case 'dispute':
              filtered = quests
                  .where((q) => q.status == QuestStatus.disputed)
                  .toList();
              break;
            default:
              filtered = quests;
          }

          // Revenue summary
          final totalFinished = quests
              .where((q) =>
                  q.status == QuestStatus.finished && q.finalPrice != null)
              .fold<int>(0, (s, q) => s + (q.finalPrice ?? 0));
          final platformRevenue =
              (totalFinished * AppConstants.standardFeeRate).toInt();

          return CustomScrollView(
            slivers: [
              // ── App bar ────────────────────────────────────────────
              SliverAppBar(
                pinned: true,
                expandedHeight: 140,
                automaticallyImplyLeading: false,
                backgroundColor: AppColors.primaryDark,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding:
                      const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  title: Row(
                    children: [
                      const Icon(Icons.receipt_long_rounded,
                          color: Colors.white70, size: 18),
                      const SizedBox(width: 8),
                      const Text('Transaksi',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text('${filtered.length} data',
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2D1B69), AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20, 16, 20, 50),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Komisi Platform',
                              style: TextStyle(
                                  color: Colors.white60, fontSize: 11)),
                          const SizedBox(height: 4),
                          Text(_formatRp(platformRevenue),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          Text(
                              'dari total transaksi ${_formatRp(totalFinished)}',
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Filter chips ───────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _Chip('semua', 'Semua', quests.length),
                        const SizedBox(width: 8),
                        _Chip(
                            'berjalan',
                            'Berjalan',
                            quests
                                .where((q) =>
                                    q.status == QuestStatus.paid ||
                                    q.status == QuestStatus.working ||
                                    q.status == QuestStatus.review)
                                .length),
                        const SizedBox(width: 8),
                        _Chip(
                            'selesai',
                            'Selesai',
                            quests
                                .where((q) =>
                                    q.status == QuestStatus.finished)
                                .length),
                        const SizedBox(width: 8),
                        _Chip(
                            'dispute',
                            'Dispute',
                            quests
                                .where((q) =>
                                    q.status == QuestStatus.disputed)
                                .length),
                        const SizedBox(width: 8),
                        _Chip(
                            'dibatalkan',
                            'Dibatalkan',
                            quests
                                .where((q) =>
                                    q.status == QuestStatus.cancelled)
                                .length),
                      ].map((w) {
                        if (w is _Chip) {
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _filter = w.value),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _filter == w.value
                                    ? AppColors.primary
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _filter == w.value
                                      ? AppColors.primary
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(w.label,
                                      style: TextStyle(
                                          color: _filter == w.value
                                              ? Colors.white
                                              : Colors.grey.shade700,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500)),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: _filter == w.value
                                          ? Colors.white
                                              .withValues(alpha: 0.3)
                                          : Colors.grey.shade300,
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: Text('${w.count}',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: _filter == w.value
                                                ? Colors.white
                                                : Colors.grey
                                                    .shade600,
                                            fontWeight:
                                                FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return w;
                      }).toList(),
                    ),
                  ),
                ),
              ),

              // ── List ───────────────────────────────────────────────
              if (filtered.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text('Tidak ada transaksi',
                            style: TextStyle(
                                color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _TxCard(quest: filtered[i]),
                      childCount: filtered.length,
                    ),
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

  String _formatRp(int v) {
    if (v == 0) return 'Rp 0';
    final s = v.toString();
    final buf = StringBuffer();
    int c = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (c > 0 && c % 3 == 0) buf.write('.');
      buf.write(s[i]);
      c++;
    }
    return 'Rp ${buf.toString().split('').reversed.join()}';
  }
}

// ─── Chip helper ──────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final String value, label;
  final int count;
  const _Chip(this.value, this.label, this.count);

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

// ─── Transaction Card ─────────────────────────────────────────────────────────
class _TxCard extends StatelessWidget {
  final QuestModel quest;
  const _TxCard({required this.quest});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(quest.status);
    final statusLabel = _statusLabel(quest.status);
    final amount = quest.finalPrice ?? quest.maxBudget;
    final fee = (amount * AppConstants.standardFeeRate).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                      fontSize: 13,
                      color: Color(0xFF1A1A2E)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(statusLabel,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person_outline_rounded,
                  size: 12, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text('Seeker: ${_mask(quest.seekerUid)}',
                  style: TextStyle(
                      color: Colors.grey.shade500, fontSize: 11)),
              if (quest.expertUid != null) ...[
                const SizedBox(width: 12),
                Icon(Icons.school_outlined,
                    size: 12, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text('Expert: ${_mask(quest.expertUid!)}',
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 11)),
              ],
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nilai Transaksi',
                        style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(_formatRp(amount),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF1A1A2E))),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Komisi Platform (8%)',
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    quest.status == QuestStatus.finished
                        ? _formatRp(fee)
                        : '-',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: quest.status == QuestStatus.finished
                            ? Colors.green.shade700
                            : Colors.grey.shade400),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _mask(String uid) {
    if (uid.length <= 8) return uid;
    return '${uid.substring(0, 4)}...${uid.substring(uid.length - 4)}';
  }

  Color _statusColor(QuestStatus s) {
    switch (s) {
      case QuestStatus.finished:
        return Colors.green;
      case QuestStatus.disputed:
        return Colors.red;
      case QuestStatus.cancelled:
        return Colors.grey;
      case QuestStatus.working:
        return Colors.blue;
      case QuestStatus.review:
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }

  String _statusLabel(QuestStatus s) {
    switch (s) {
      case QuestStatus.paid:
        return 'Dibayar';
      case QuestStatus.working:
        return 'Dikerjakan';
      case QuestStatus.review:
        return 'Review';
      case QuestStatus.finished:
        return 'Selesai';
      case QuestStatus.cancelled:
        return 'Dibatalkan';
      case QuestStatus.disputed:
        return 'Dispute';
      default:
        return s.name;
    }
  }

  String _formatRp(int v) {
    if (v == 0) return 'Rp 0';
    final s = v.toString();
    final buf = StringBuffer();
    int c = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (c > 0 && c % 3 == 0) buf.write('.');
      buf.write(s[i]);
      c++;
    }
    return 'Rp ${buf.toString().split('').reversed.join()}';
  }
}
