// lib/features/seeker/screens/seeker_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_controller.dart';
import '../../quest/providers/quest_controller.dart';
import '../../../shared/models/models.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';

class SeekerDashboardScreen extends ConsumerWidget {
  const SeekerDashboardScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questsAsync = ref.watch(seekerMyQuestsProvider);
    final userAsync = ref.watch(userProvider);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: Colors.grey.shade50,
            surfaceTintColor: Colors.transparent,
            floating: true,
            snap: true,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            automaticallyImplyLeading: false,
            title: null,
            actions: const [],
          ),

          // ── Body ─────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Hero CTA ─────────────────────────────────────────
                // SESUDAH
                questsAsync.when(
                  data: (_) => _HeroCTA(
                    onTap: () => context.pushNamed('seekerPostQuest'),
                    name: userAsync.value?.displayName.isNotEmpty == true
                        ? userAsync.value!.displayName.split(' ').first
                        : userAsync.value?.email.split('@')[0] ?? 'Juragan',
                    greeting: _greeting(),
                  ),
                  loading: () => _HeroCTA(
                    onTap: () => context.pushNamed('seekerPostQuest'),
                    name: '',
                    greeting: _greeting(),
                  ),
                  error: (_, __) => _HeroCTA(
                    onTap: () => context.pushNamed('seekerPostQuest'),
                    name: '',
                    greeting: _greeting(),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Stats ─────────────────────────────────────────────
                questsAsync.when(
                  data: (quests) => _StatsRow(quests: quests),
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
                const SizedBox(height: 20),

                // ── Quest Aktif ───────────────────────────────────────
                questsAsync.when(
                  data: (quests) {
                    final active = quests
                        .where((q) =>
                            q.status == QuestStatus.pending &&
                            q.expertUid == null)
                        .toList();
                    return _QuestSection(
                      quests: active,
                      onPostTap: () => context.pushNamed('seekerPostQuest'),
                      onQuestTap: (quest) {
                        if (quest.status == QuestStatus.pending &&
                            quest.expertUid == null) {
                          context.pushNamed('seekerQuestApplicants',
                              pathParameters: {'questId': quest.questId});
                        } else {
                          context.pushNamed('seekerActiveQuest',
                              pathParameters: {'questId': quest.questId});
                        }
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero CTA ─────────────────────────────────────────────────────────────────
class _HeroCTA extends StatelessWidget {
  final VoidCallback onTap;
  final String name;
  final String greeting;
  const _HeroCTA({
    required this.onTap,
    required this.name,
    required this.greeting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -16,
            top: -16,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            right: 24,
            bottom: -8,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (name.isNotEmpty) ...[
                Text(
                  '$greeting, $name',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              const Text(
                'Ada tugas yang\nperlu dikerjakan?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  height: 1.25,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Temukan expert terbaik di CariQuest',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72), fontSize: 13),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded,
                          color: AppColors.primary, size: 15),
                      SizedBox(width: 6),
                      Text('Post Sekarang',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Stats Row ────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final List<QuestModel> quests;
  const _StatsRow({required this.quests});

  @override
  Widget build(BuildContext context) {
    final active = quests
        .where((q) =>
            q.status == QuestStatus.working || q.status == QuestStatus.review)
        .length;
    final pending = quests.where((q) => q.status == QuestStatus.pending).length;
    final finished =
        quests.where((q) => q.status == QuestStatus.finished).length;

    return Row(
      children: [
        _StatCard(
            label: 'Berjalan',
            value: active,
            icon: Icons.play_circle_rounded,
            color: AppColors.primary),
        const SizedBox(width: 10),
        _StatCard(
            label: 'Menunggu',
            value: pending,
            icon: Icons.hourglass_top_rounded,
            color: AppColors.gold),
        const SizedBox(width: 10),
        _StatCard(
            label: 'Selesai',
            value: finished,
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF2E7D32)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.07),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 17),
              ),
              const SizedBox(height: 8),
              Text(
                '$value',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 22, color: color),
              ),
              Text(label,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
            ],
          ),
        ),
      );
}

// ─── Quest Section ────────────────────────────────────────────────────────────
class _QuestSection extends StatelessWidget {
  final List<QuestModel> quests;
  final VoidCallback onPostTap;
  final void Function(QuestModel) onQuestTap;
  const _QuestSection({
    required this.quests,
    required this.onPostTap,
    required this.onQuestTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Quest Aktif',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF1A1A2E),
              ),
            ),
            if (quests.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${quests.length} quest',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (quests.isEmpty)
          _EmptyState(onTap: onPostTap)
        else
          ...quests.map((q) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _QuestCard(quest: q, onTap: () => onQuestTap(q)),
              )),
      ],
    );
  }
}

// ─── Quest Card ───────────────────────────────────────────────────────────────
class _QuestCard extends StatelessWidget {
  final QuestModel quest;
  final VoidCallback onTap;
  const _QuestCard({required this.quest, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = quest.status;
    final diff = quest.deadline.difference(DateTime.now());
    final isUrgent = quest.isUrgent || diff.inHours <= 24;

    String countdownLabel() {
      if (diff.isNegative) return 'Lewat deadline!';
      if (diff.inHours < 24) {
        return '${diff.inHours}j ${diff.inMinutes % 60}m lagi';
      }
      return '${diff.inDays} hari lagi';
    }

    Color statusColor() {
      switch (status) {
        case QuestStatus.pending:
          return AppColors.gold;
        case QuestStatus.working:
          return AppColors.primary;
        case QuestStatus.review:
          return Colors.blue;
        case QuestStatus.finished:
          return const Color(0xFF2E7D32);
        case QuestStatus.cancelled:
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    String statusLabel() {
      switch (status) {
        case QuestStatus.pending:
          return '⏳ Mencari Expert';
        case QuestStatus.working:
          return '🔨 Dikerjakan';
        case QuestStatus.review:
          return '👀 Review';
        case QuestStatus.finished:
          return '✅ Selesai';
        case QuestStatus.cancelled:
          return '❌ Dibatalkan';
        default:
          return status.name;
      }
    }

    final sc = statusColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isUrgent
              ? Border.all(
                  color: Colors.red.withValues(alpha: 0.25), width: 1.5)
              : null,
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
            // ── Title + status ──────────────────────────────────────
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

            // ── Description ─────────────────────────────────────────
            Text(
              quest.description,
              style: TextStyle(
                  color: Colors.grey.shade600, fontSize: 13, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // ── Meta chips ──────────────────────────────────────────
            Row(
              children: [
                _MetaChip(
                  icon: Icons.payments_outlined,
                  label: 'Rp ${_fmt(quest.minBudget)}–${_fmt(quest.maxBudget)}',
                  color: const Color(0xFF2E7D32),
                ),
                const SizedBox(width: 8),
                _MetaChip(
                  icon: Icons.schedule_rounded,
                  label: countdownLabel(),
                  color: diff.isNegative || diff.inHours < 24
                      ? Colors.red
                      : Colors.grey.shade600,
                ),
                if (isUrgent) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('🔥 Urgent',
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
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

  String _fmt(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}jt';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}rb';
    return v.toString();
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MetaChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      );
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyState({required this.onTap});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.assignment_outlined,
                    size: 44, color: AppColors.primary.withValues(alpha: 0.4)),
              ),
              const SizedBox(height: 14),
              const Text(
                'Belum ada quest aktif',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1A1A2E)),
              ),
              const SizedBox(height: 6),
              Text(
                'Post quest dan mulai cari\nexpert terbaik buat kamu!',
                style: TextStyle(
                    color: Colors.grey.shade500, fontSize: 13, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, color: Colors.white, size: 15),
                      SizedBox(width: 6),
                      Text('Post Quest Sekarang',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
