// lib/features/seeker/screens/seeker_find_expert_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// cloud_firestore removed — using mock data
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/widgets.dart';

// ─── Providers (Mock) ─────────────────────────────────────────────────────────

final allExpertsProvider = StreamProvider.autoDispose<List<UserModel>>((ref) {
  return MockData.instance.usersStream
      .map((users) => users
          .where((u) =>
              u.role == UserRole.expert &&
              u.isKtmVerified &&
              !u.isSuspended)
          .toList());
});

final allExpertProfilesProvider =
    StreamProvider.autoDispose<List<ProfileModel>>((ref) {
  return MockData.instance.profilesStream;
});

// ─── Screen ───────────────────────────────────────────────────────────────────

class SeekerFindExpertScreen extends ConsumerStatefulWidget {
  const SeekerFindExpertScreen({super.key});

  @override
  ConsumerState<SeekerFindExpertScreen> createState() =>
      _SeekerFindExpertScreenState();
}

class _SeekerFindExpertScreenState
    extends ConsumerState<SeekerFindExpertScreen> {
  String _searchQuery = '';
  ExpertRank? _filterRank;

  /// Hanya tampilkan rank yang visible (rank 1-5 + rank yang sudah unlock)
  List<ExpertRank> get _visibleRanks {
    return ExpertRank.values.where((r) => r.isVisible).toList();
  }

  @override
  Widget build(BuildContext context) {
    final expertsAsync = ref.watch(allExpertsProvider);
    final profilesAsync = ref.watch(allExpertProfilesProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Cari Expert'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // ─── Search & Filter ─────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                TextField(
                  onChanged: (v) =>
                      setState(() => _searchQuery = v.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Cari expert berdasarkan nama atau skill...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
                const SizedBox(height: 12),
                // Rank filter — hanya tampil rank yang visible
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _RankChip(
                        label: 'Semua',
                        selected: _filterRank == null,
                        onTap: () => setState(() => _filterRank = null),
                      ),
                      const SizedBox(width: 8),
                      ..._visibleRanks.map((rank) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _RankChip(
                              label: rank.displayName,
                              selected: _filterRank == rank,
                              onTap: () => setState(() => _filterRank = rank),
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── Expert List ─────────────────────────────────────────────
          Expanded(
            child: expertsAsync.when(
              data: (experts) {
                final profiles = profilesAsync.value ?? [];

                var filtered = experts.where((e) {
                  final profile =
                      profiles.where((p) => p.uid == e.uid).firstOrNull;

                  final matchSearch = _searchQuery.isEmpty ||
                      (profile?.displayName
                              .toLowerCase()
                              .contains(_searchQuery) ??
                          false) ||
                      (profile?.skillTags.any(
                              (s) => s.toLowerCase().contains(_searchQuery)) ??
                          false);

                  final matchRank =
                      _filterRank == null || e.rank == _filterRank;

                  return matchSearch && matchRank;
                }).toList();

                filtered.sort((a, b) => b.ratingAvg.compareTo(a.ratingAvg));

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off_outlined,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text('Tidak ada expert ditemukan',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final expert = filtered[index];
                    final profile =
                        profiles.where((p) => p.uid == expert.uid).firstOrNull;

                    return _ExpertCard(
                      expert: expert,
                      profile: profile,
                      onTap: () => context.pushNamed(
                        'seekerExpertProfile',
                        pathParameters: {'expertId': expert.uid},
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Expert Card ──────────────────────────────────────────────────────────────

class _ExpertCard extends StatelessWidget {
  final UserModel expert;
  final ProfileModel? profile;
  final VoidCallback onTap;

  const _ExpertCard({
    required this.expert,
    required this.profile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Tampilkan nama dari profile, fallback ke displayName, fallback ke prefix email
    final name = (profile?.displayName.isNotEmpty == true)
        ? profile!.displayName
        : (expert.displayName.isNotEmpty
            ? expert.displayName
            : expert.email.split('@')[0]);

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
            UserAvatar(
              imageUrl: profile?.avatarUrl ?? '',
              radius: 28,
              rank: expert.rank,
              isVerifiedPro: profile?.isVerifiedPro ?? false,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      RankBadge(rank: expert.rank, compact: true),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: AppColors.gold),
                      const SizedBox(width: 4),
                      Text(
                        expert.ratingAvg > 0
                            ? '${expert.ratingAvg.toStringAsFixed(1)} (${expert.ratingCount}x)'
                            : 'Baru',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.work_outline,
                          size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        '${expert.totalQuestsDone} proyek',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.bolt, size: 14, color: Colors.orange.shade400),
                      const SizedBox(width: 2),
                      Text(
                        '${expert.expPoints} EXP',
                        style: TextStyle(
                            color: Colors.orange.shade400, fontSize: 12),
                      ),
                    ],
                  ),
                  if (profile != null && profile!.skillTags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: profile!.skillTags
                          .take(3)
                          .map((skill) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  skill,
                                  style: const TextStyle(
                                      fontSize: 11, color: AppColors.primary),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// ─── Rank Chip ────────────────────────────────────────────────────────────────

class _RankChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RankChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.transparent : Colors.grey.shade200,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey.shade600,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
