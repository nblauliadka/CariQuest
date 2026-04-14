// lib/features/profile/screens/widgets/expert_content_cards.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../shared/models/models.dart';
import 'profile_card.dart';

class ExpertAboutCard extends StatelessWidget {
  final ProfileModel profile;
  const ExpertAboutCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) => ProfileCard(
        title: '👤 Tentang Saya',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profile.bio.isEmpty
                  ? 'Belum ada bio. Ketuk Edit untuk mulai ceritain dirimu.'
                  : profile.bio,
              style: TextStyle(
                  color: profile.bio.isEmpty
                      ? Colors.grey.shade400
                      : Colors.grey.shade700,
                  height: 1.65,
                  fontSize: 14),
            ),
            if (profile.skillTags.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('⚡ Keahlian',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF1A1A2E))),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: profile.skillTags
                    .map((s) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color:
                                    AppColors.primary.withValues(alpha: 0.2)),
                          ),
                          child: Text(s,
                              style: const TextStyle(
                                  color: AppColors.primaryDark,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      );
}

// ─── Achievements Card ────────────────────────────────────────────────────────
class ExpertAchievementsCard extends StatelessWidget {
  final ProfileModel profile;
  final UserModel? user;
  const ExpertAchievementsCard(
      {super.key, required this.profile, required this.user});

  List<Map<String, String>> _getAchievements() {
    final list = <Map<String, String>>[];
    final done = user?.totalQuestsDone ?? 0;
    final rating = user?.ratingAvg ?? 0;
    final rank = user?.rank;

    if (done >= 1) {
      list.add(
          {'icon': '🎯', 'title': 'Proyek Pertama', 'sub': 'Quest pertama!'});
    }
    if (done >= 3) {
      list.add({'icon': '🔥', 'title': 'On Fire', 'sub': '3 proyek selesai'});
    }
    if (done >= 10) {
      list.add({'icon': '💪', 'title': 'Veteran', 'sub': '10 proyek selesai'});
    }
    if (done >= 25) {
      list.add(
          {'icon': '🚀', 'title': 'Turbo Mode', 'sub': '25 proyek selesai'});
    }
    if (rating >= 4.5) {
      list.add({'icon': '⭐', 'title': 'Top Rated', 'sub': 'Rating ≥ 4.5'});
    }
    if (rating >= 5.0) {
      list.add(
          {'icon': '👑', 'title': 'Perfect Score', 'sub': 'Rating sempurna!'});
    }

    // ✅ GANTI dengan
    const rankAchievements = <ExpertRank, List<String>>{
      ExpertRank.taskRunner: ['🥉', 'Task Runner'],
      ExpertRank.juniorWorker: ['🔰', 'Junior Worker'],
      ExpertRank.skilledWorker: ['🥈', 'Skilled Worker'],
      ExpertRank.professional: ['🥇', 'Professional'],
      ExpertRank.seniorProfessional: ['🌟', 'Senior Pro'],
      ExpertRank.specialist: ['💎', 'Specialist'],
      ExpertRank.leadSpecialist: ['🔱', 'Lead Specialist'],
      ExpertRank.topProfessional: ['🏆', 'Top Pro'],
      ExpertRank.industryMaster: ['⚡', 'Industry Master'],
      ExpertRank.legendaryWorker: ['👑', 'Legendary'],
    };

    if (rank != null && rankAchievements.containsKey(rank)) {
      final entry = rankAchievements[rank]!;
      list.add({'icon': entry[0], 'title': entry[1], 'sub': rank.displayName});
    }

    if (profile.isVerifiedPro) {
      list.add({'icon': '✅', 'title': 'Verified Pro', 'sub': 'Terverifikasi'});
    }
    for (final a in profile.achievements) {
      list.add({'icon': '🏆', 'title': a, 'sub': 'Pencapaian khusus'});
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final achievements = _getAchievements();
    return ProfileCard(
      title: '🏆 Pencapaian',
      child: achievements.isEmpty
          ? Column(
              children: [
                Icon(Icons.emoji_events_outlined,
                    size: 40, color: Colors.grey.shade300),
                const SizedBox(height: 8),
                Text('Selesaikan proyek untuk dapat pencapaian!',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    textAlign: TextAlign.center),
              ],
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: achievements
                  .map((a) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 9),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Colors.amber.withValues(alpha: 0.12),
                            Colors.orange.withValues(alpha: 0.06),
                          ]),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.amber.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(a['icon']!,
                                style: const TextStyle(fontSize: 20)),
                            const SizedBox(height: 3),
                            Text(a['title']!,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A2E))),
                            Text(a['sub']!,
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey.shade500)),
                          ],
                        ),
                      ))
                  .toList(),
            ),
    );
  }
}
