// lib/features/expert/screens/expert_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../auth/providers/auth_controller.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/models.dart';
import '../../quest/providers/quest_controller.dart';
import '../../../core/constants/app_enums.dart';

class ExpertDashboardScreen extends ConsumerWidget {
  const ExpertDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final activeQuestsAsync = ref.watch(expertQuestFeedProvider);
    print('questFeed: $activeQuestsAsync');
    final format =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    ref.listen<AsyncValue<UserModel?>>(userProvider, (previous, next) {
      final prevRank = previous?.value?.rank;
      final nextRank = next.value?.rank;
      if (prevRank != null &&
          nextRank != null &&
          nextRank.index > prevRank.index) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Selamat! Rank Naik!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Kerja bagus! Rank kamu meningkat menjadi:',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  RankBadge(rank: nextRank),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Tutup'),
                ),
              ],
            ),
          );
        });
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
      ),
      body: userState.when(
        data: (user) {
          if (user == null) return const SizedBox();

          final displayName = user.displayName.isNotEmpty
              ? user.displayName
              : user.email.split('@')[0];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ─── Welcome Card ────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Halo, $displayName',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Siap cari quest hari ini?',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      RankBadge(rank: user.rank),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Saldo: ${format.format(user.saldoActive)}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          SizedBox(
                            width: 160,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primary,
                                visualDensity: VisualDensity.compact,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () =>
                                  context.pushNamed('expertWalletDashboard'),
                              child: const Text('Dompet',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ─── Stats ───────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        label: 'Proyek',
                        value: user.totalQuestsDone.toString(),
                        icon: Icons.work_outline,
                      ),
                      Container(
                          height: 40, width: 1, color: Colors.grey.shade200),
                      _StatItem(
                        label: 'Rating',
                        value: user.ratingAvg > 0
                            ? user.ratingAvg.toStringAsFixed(1)
                            : '-',
                        icon: Icons.star_outline,
                      ),
                      Container(
                          height: 40, width: 1, color: Colors.grey.shade200),
                      _StatItem(
                        label: 'EXP',
                        value: user.expPoints.toString(),
                        icon: Icons.bolt_outlined,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ─── Quest Aktif ──────────────────────────────────────
                Text(
                  'Quest Aktif',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                activeQuestsAsync.when(
                  data: (quests) {
                    final available = quests
                        .where((q) =>
                            q.status == QuestStatus.pending &&
                            q.expertUid == null)
                        .toList();
                    if (available.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.inbox_outlined,
                                size: 48, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              'Belum ada quest aktif',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () =>
                                  context.goNamed('expertQuestFeed'),
                              child: const Text('Cari Quest Sekarang'),
                            ),
                          ],
                        ),
                      );
                    }
                    return Column(
                      children: available
                          .map((quest) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: QuestCard(
                                  quest: quest,
                                  onTap: () => context.pushNamed(
                                    'expertQuestDetail',
                                    pathParameters: {'questId': quest.questId},
                                  ),
                                ),
                              ))
                          .toList(),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
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
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
