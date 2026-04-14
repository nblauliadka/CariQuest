// lib/features/admin/screens/admin_dashboard_screen.dart
// cloud_firestore removed — mock mode
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/models/models.dart';
import '../../../features/auth/services/auth_repository.dart';

// ─── Providers (Mock) ────────────────────────────────────────────────────────
final adminAllUsersProvider =
    StreamProvider.autoDispose<List<UserModel>>((ref) {
  return MockData.instance.usersStream;
});

final adminAllQuestsProvider =
    StreamProvider.autoDispose<List<QuestModel>>((ref) {
  return MockData.instance.questsStream;
});

final adminRecentQuestsProvider =
    StreamProvider.autoDispose<List<QuestModel>>((ref) {
  return MockData.instance.questsStream.map((quests) {
    final sorted = [...quests]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(5).toList();
  });
});

final adminRecentUsersProvider =
    StreamProvider.autoDispose<List<UserModel>>((ref) {
  return MockData.instance.usersStream.map((users) {
    final sorted = [...users]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(5).toList();
  });
});


// ─── Screen ───────────────────────────────────────────────────────────────────
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminAllUsersProvider);
    final questsAsync = ref.watch(adminAllQuestsProvider);
    final recentQuestsAsync = ref.watch(adminRecentQuestsProvider);
    final recentUsersAsync = ref.watch(adminRecentUsersProvider);

    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 11
        ? 'Selamat pagi'
        : hour < 15
            ? 'Selamat siang'
            : hour < 18
                ? 'Selamat sore'
                : 'Selamat malam';

    return Scaffold(
      backgroundColor: const Color(0xFFF0EFF8),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminAllUsersProvider);
          ref.invalidate(adminAllQuestsProvider);
          ref.invalidate(adminRecentQuestsProvider);
          ref.invalidate(adminRecentUsersProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── App Bar ──────────────────────────────────────────────
            SliverAppBar(
              pinned: true,
              expandedHeight: 120,
              automaticallyImplyLeading: false,
              backgroundColor: const Color(0xFF1E0F45),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding:
                    const EdgeInsets.fromLTRB(20, 0, 20, 14),
                title: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$greeting, Admin 👋',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                        Text(
                          '${now.day}/${now.month}/${now.year}',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 10),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => ref
                          .read(authRepositoryProvider)
                          .logout(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color:
                                  Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.logout_rounded,
                                color: Colors.white70, size: 14),
                            SizedBox(width: 4),
                            Text('Logout',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0D0628), Color(0xFF2D1B69)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Alert cards ─────────────────────────────────────
                  usersAsync.when(
                    data: (users) {
                      final pendingVerif = users
                          .where((u) =>
                              (u.role == UserRole.expert &&
                                  !u.isKtmVerified) ||
                              (u.role == UserRole.seeker &&
                                  !u.isKtpVerified))
                          .length;
                      if (pendingVerif == 0) return const SizedBox.shrink();
                      return _AlertCard(
                        icon: Icons.pending_actions_rounded,
                        color: Colors.orange,
                        title: '$pendingVerif akun menunggu verifikasi',
                        subtitle:
                            'Tap tab Verifikasi untuk review KTM/KTP',
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  questsAsync.when(
                    data: (quests) {
                      final disputed = quests
                          .where(
                              (q) => q.status == QuestStatus.disputed)
                          .length;
                      if (disputed == 0) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _AlertCard(
                          icon: Icons.gavel_rounded,
                          color: Colors.red,
                          title: '$disputed dispute aktif butuh perhatian',
                          subtitle: 'Tap tab Dispute untuk mediasi',
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 20),

                  // ── User stats ──────────────────────────────────────
                  const _SectionTitle(
                      icon: Icons.people_rounded, title: 'Pengguna'),
                  const SizedBox(height: 10),
                  usersAsync.when(
                    data: (users) {
                      final total = users.length;
                      final experts = users
                          .where((u) => u.role == UserRole.expert)
                          .length;
                      final seekers = users
                          .where((u) => u.role == UserRole.seeker)
                          .length;
                      final pendingVerif = users
                          .where((u) =>
                              (u.role == UserRole.expert &&
                                  !u.isKtmVerified) ||
                              (u.role == UserRole.seeker &&
                                  !u.isKtpVerified))
                          .length;
                      final suspended =
                          users.where((u) => u.isSuspended).length;
                      return Column(
                        children: [
                          Row(children: [
                            Expanded(
                                child: _StatCard(
                                    label: 'Total',
                                    value: '$total',
                                    icon: Icons.people_rounded,
                                    color: AppColors.primary)),
                            const SizedBox(width: 10),
                            Expanded(
                                child: _StatCard(
                                    label: 'Expert',
                                    value: '$experts',
                                    icon: Icons.school_rounded,
                                    color: Colors.blue)),
                          ]),
                          const SizedBox(height: 10),
                          Row(children: [
                            Expanded(
                                child: _StatCard(
                                    label: 'Seeker',
                                    value: '$seekers',
                                    icon: Icons.person_search_rounded,
                                    color: Colors.orange)),
                            const SizedBox(width: 10),
                            Expanded(
                                child: _StatCard(
                                    label: 'Pending Verif',
                                    value: '$pendingVerif',
                                    icon: Icons.pending_actions_rounded,
                                    color: Colors.amber.shade700,
                                    highlight: pendingVerif > 0)),
                          ]),
                          const SizedBox(height: 10),
                          Row(children: [
                            Expanded(
                                child: _StatCard(
                                    label: 'Suspended',
                                    value: '$suspended',
                                    icon: Icons.block_rounded,
                                    color: Colors.red)),
                            const SizedBox(width: 10),
                            const Expanded(child: SizedBox()),
                          ]),
                        ],
                      );
                    },
                    loading: () => const _LoadingBox(),
                    error: (e, _) => _ErrBox(e.toString()),
                  ),

                  const SizedBox(height: 20),

                  // ── Quest stats ─────────────────────────────────────
                  const _SectionTitle(
                      icon: Icons.assignment_rounded, title: 'Quest'),
                  const SizedBox(height: 10),
                  questsAsync.when(
                    data: (quests) {
                      final total = quests.length;
                      final active = quests
                          .where((q) =>
                              q.status == QuestStatus.working ||
                              q.status == QuestStatus.review)
                          .length;
                      final finished = quests
                          .where((q) => q.status == QuestStatus.finished)
                          .length;
                      final disputed = quests
                          .where((q) => q.status == QuestStatus.disputed)
                          .length;
                      final pending = quests
                          .where((q) => q.status == QuestStatus.pending)
                          .length;
                      return Column(
                        children: [
                          Row(children: [
                            Expanded(
                                child: _StatCard(
                                    label: 'Total Quest',
                                    value: '$total',
                                    icon: Icons.assignment_rounded,
                                    color: AppColors.primary)),
                            const SizedBox(width: 10),
                            Expanded(
                                child: _StatCard(
                                    label: 'Aktif',
                                    value: '$active',
                                    icon: Icons.play_circle_rounded,
                                    color: Colors.green)),
                          ]),
                          const SizedBox(height: 10),
                          Row(children: [
                            Expanded(
                                child: _StatCard(
                                    label: 'Selesai',
                                    value: '$finished',
                                    icon: Icons.check_circle_rounded,
                                    color: Colors.teal)),
                            const SizedBox(width: 10),
                            Expanded(
                                child: _StatCard(
                                    label: 'Dispute',
                                    value: '$disputed',
                                    icon: Icons.gavel_rounded,
                                    color: Colors.red,
                                    highlight: disputed > 0)),
                          ]),
                          const SizedBox(height: 10),
                          Row(children: [
                            Expanded(
                                child: _StatCard(
                                    label: 'Pending',
                                    value: '$pending',
                                    icon: Icons.hourglass_empty_rounded,
                                    color: Colors.grey.shade600)),
                            const SizedBox(width: 10),
                            const Expanded(child: SizedBox()),
                          ]),
                        ],
                      );
                    },
                    loading: () => const _LoadingBox(),
                    error: (e, _) => _ErrBox(e.toString()),
                  ),

                  const SizedBox(height: 20),

                  // ── Revenue ─────────────────────────────────────────
                  const _SectionTitle(
                      icon: Icons.payments_rounded,
                      title: 'Pendapatan Platform'),
                  const SizedBox(height: 10),
                  questsAsync.when(
                    data: (quests) {
                      final totalTx = quests
                          .where((q) =>
                              q.status == QuestStatus.finished &&
                              q.finalPrice != null)
                          .fold<int>(0, (s, q) => s + (q.finalPrice ?? 0));
                      final fee = (totalTx * AppConstants.standardFeeRate).toInt();
                      final activeTx = quests
                          .where((q) =>
                              q.status == QuestStatus.paid ||
                              q.status == QuestStatus.working ||
                              q.status == QuestStatus.review)
                          .fold<int>(
                              0,
                              (s, q) =>
                                  s + (q.finalPrice ?? q.maxBudget));
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF1E0F45),
                              Color(0xFF4A1A9E),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Total Komisi (8%)',
                                          style: TextStyle(
                                              color: Colors.white60,
                                              fontSize: 12)),
                                      SizedBox(height: 4),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withValues(alpha: 0.15),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: const Text('Fee 8%',
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11)),
                                ),
                              ],
                            ),
                            Text(_formatRp(fee),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5)),
                            const SizedBox(height: 4),
                            Text(
                                'dari total transaksi selesai ${_formatRp(totalTx)}',
                                style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11)),
                            const SizedBox(height: 16),
                            const Divider(color: Colors.white12),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.lock_rounded,
                                    color: Colors.white54, size: 14),
                                const SizedBox(width: 6),
                                const Text('Dana di Escrow',
                                    style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12)),
                                const Spacer(),
                                Text(_formatRp(activeTx),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    loading: () => const _LoadingBox(),
                    error: (e, _) => _ErrBox(e.toString()),
                  ),

                  const SizedBox(height: 20),

                  // ── Recent Quest ────────────────────────────────────
                  const _SectionTitle(
                      icon: Icons.history_rounded,
                      title: 'Quest Terbaru'),
                  const SizedBox(height: 10),
                  recentQuestsAsync.when(
                    data: (quests) => quests.isEmpty
                        ? Center(
                            child: Text('Belum ada quest',
                                style: TextStyle(
                                    color: Colors.grey.shade400)))
                        : Column(
                            children: quests
                                .map((q) => _RecentQuestTile(quest: q))
                                .toList(),
                          ),
                    loading: () => const _LoadingBox(),
                    error: (e, _) => _ErrBox(e.toString()),
                  ),

                  const SizedBox(height: 20),

                  // ── Recent Users ────────────────────────────────────
                  const _SectionTitle(
                      icon: Icons.person_add_rounded,
                      title: 'User Terbaru'),
                  const SizedBox(height: 10),
                  recentUsersAsync.when(
                    data: (users) => users.isEmpty
                        ? Center(
                            child: Text('Belum ada user',
                                style: TextStyle(
                                    color: Colors.grey.shade400)))
                        : Column(
                            children: users
                                .map((u) => _RecentUserTile(user: u))
                                .toList(),
                          ),
                    loading: () => const _LoadingBox(),
                    error: (e, _) => _ErrBox(e.toString()),
                  ),

                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
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

// ─── Widgets ──────────────────────────────────────────────────────────────────
class _AlertCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle;
  const _AlertCard(
      {required this.icon,
      required this.color,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontSize: 13)),
                  Text(subtitle,
                      style: TextStyle(
                          color: color.withValues(alpha: 0.7),
                          fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: color.withValues(alpha: 0.5)),
          ],
        ),
      );
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: const Color(0xFF4A1A9E), size: 18),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1A1A2E))),
        ],
      );
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final bool highlight;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border:
              highlight ? Border.all(color: color, width: 2) : null,
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
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: highlight ? color : const Color(0xFF1A1A2E))),
                  Text(label,
                      style: TextStyle(
                          fontSize: 10, color: Colors.grey.shade500)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _RecentQuestTile extends StatelessWidget {
  final QuestModel quest;
  const _RecentQuestTile({required this.quest});

  @override
  Widget build(BuildContext context) {
    final statusColor = _sColor(quest.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.assignment_rounded,
                color: statusColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(quest.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Color(0xFF1A1A2E)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(
                    quest.createdAt.toString().substring(0, 10),
                    style: TextStyle(
                        color: Colors.grey.shade400, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              quest.status.name,
              style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Color _sColor(QuestStatus s) {
    switch (s) {
      case QuestStatus.finished:
        return Colors.green;
      case QuestStatus.disputed:
        return Colors.red;
      case QuestStatus.working:
        return Colors.blue;
      default:
        return AppColors.primary;
    }
  }
}

class _RecentUserTile extends StatelessWidget {
  final UserModel user;
  const _RecentUserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final isExpert = user.role == UserRole.expert;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isExpert
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.orange.withValues(alpha: 0.1),
            child: Icon(
              isExpert ? Icons.school_rounded : Icons.person_rounded,
              color: isExpert ? AppColors.primary : Colors.orange,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.email,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Color(0xFF1A1A2E)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(
                    '${isExpert ? "Expert" : "Seeker"} • ${user.createdAt.toString().substring(0, 10)}',
                    style: TextStyle(
                        color: Colors.grey.shade400, fontSize: 11)),
              ],
            ),
          ),
          if (user.isSuspended)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Suspended',
                  style: TextStyle(color: Colors.red, fontSize: 10)),
            ),
        ],
      ),
    );
  }
}

class _LoadingBox extends StatelessWidget {
  const _LoadingBox();

  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
}

class _ErrBox extends StatelessWidget {
  final String msg;
  const _ErrBox(this.msg);

  @override
  Widget build(BuildContext context) => Center(
        child: Text('Error: $msg',
            style: const TextStyle(color: Colors.red)),
      );
}
