// lib/features/profile/screens/expert_profile_view.dart
import 'package:cariquest/features/profile/widgets/direct_quest_sheet.dart';
import 'package:cariquest/features/profile/widgets/expert_content_cards.dart';
import 'package:cariquest/features/profile/widgets/expert_hero_banner.dart';
import 'package:cariquest/features/profile/widgets/expert_history_card.dart';
import 'package:cariquest/features/profile/widgets/expert_rank_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_enums.dart';
import '../../../shared/models/models.dart';
import '../../auth/providers/auth_controller.dart';
import '../providers/profile_controller.dart';
import 'edit_profile_screen.dart';

class ExpertProfileView extends ConsumerWidget {
  final String expertUid;
  const ExpertProfileView({super.key, required this.expertUid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider(expertUid));
    final currentUser = ref.watch(userProvider).value;
    final expertUser = ref.watch(expertUserDataProvider(expertUid)).value;
    final isMe = currentUser?.uid == expertUid;
    final isSeeker = currentUser?.role == UserRole.seeker;
    final displayUser = isMe ? currentUser : expertUser;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F2F8),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        automaticallyImplyLeading: false,
        // SESUDAH
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 16),
            ),
          ),
        ),
        actions: isMe
            ? [
                _TopBtn(
                  label: 'Edit',
                  icon: Icons.edit_rounded,
                  onTap: () {
                    final p = profileAsync.value;
                    if (p != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfileScreen(
                            profile: p,
                            user: displayUser,
                          ),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(width: 8),
              ]
            : [],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Profil tidak ditemukan'));
          }
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: ExpertHeroBanner(
                  profile: profile,
                  user: displayUser,
                  isMe: isMe,
                  isSeeker: isSeeker,
                  ref: ref,
                  onContactTap: (!isMe && isSeeker)
                      ? () => _showDirectQuestSheet(
                            context,
                            ref,
                            expertUid: expertUid,
                            expertName:
                                displayUser?.displayName ?? profile.displayName,
                            currentUser: currentUser!,
                          )
                      : null,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    ExpertRankCard(user: displayUser),
                    ExpertStatsRow(user: displayUser, isMe: isMe),
                    const SizedBox(height: 4),
                    ExpertAboutCard(profile: profile),
                    ExpertHistoryCard(expertUid: expertUid),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDirectQuestSheet(
    BuildContext context,
    WidgetRef ref, {
    required String expertUid,
    required String expertName,
    required UserModel currentUser,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DirectQuestSheet(
        expertUid: expertUid,
        expertName: expertName,
        seekerUid: currentUser.uid,
        ref: ref,
      ),
    );
  }
}

// ─── Top Button ───────────────────────────────────────────────────────────────
// SESUDAH
class _TopBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _TopBtn({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const color = Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
