// lib/features/profile/screens/widgets/expert_hero_banner.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// cloud_firestore, firebase_storage, file_picker removed — mock mode
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../features/profile/providers/profile_controller.dart';

// Mock: maxVisibleRankProvider always returns 4 (fixed in demo)
final maxVisibleRankProvider = StreamProvider<int>((ref) {
  return Stream.value(4); // demo max rank index
});

// Mock: expertUserDataProvider from MockData
final expertUserDataProvider =
    FutureProvider.family<UserModel?, String>((ref, uid) async {
  if (uid.isEmpty) return null;
  // Data is already preloaded in MockData via authRepo.init()
  // We can't access MockData directly here, so just return null for non-demo uids
  return null;
});

class ExpertHeroBanner extends StatefulWidget {
  final ProfileModel profile;
  final UserModel? user;
  final bool isMe;
  final bool isSeeker;
  final WidgetRef ref;
  final VoidCallback? onContactTap;

  const ExpertHeroBanner({
    super.key,
    required this.profile,
    required this.user,
    required this.isMe,
    required this.isSeeker,
    required this.ref,
    this.onContactTap,
  });

  @override
  State<ExpertHeroBanner> createState() => _ExpertHeroBannerState();
}

class _ExpertHeroBannerState extends State<ExpertHeroBanner> {
  bool _uploadingAvatar = false;

  Future<void> _pickAndUploadAvatar() async {
    if (!widget.isMe) return;
    setState(() => _uploadingAvatar = true);
    try {
      // Demo MVP: simulate avatar upload
      await Future.delayed(const Duration(milliseconds: 600));
      const mockUrl =
          'https://ui-avatars.com/api/?name=Demo+User&background=6C5CE7&color=fff&size=200';
      await widget.ref
          .read(profileControllerProvider.notifier)
          .updateProfile(avatarUrl: mockUrl);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal upload: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  void _showRankListSheet(
      BuildContext context, ExpertRank currentRank, int maxVisibleIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // SESUDAH
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48),
                  const Text(
                    '🏅 Semua Rank',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Ketuk badge rank untuk lihat detail',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: maxVisibleIndex + 1,
                  itemBuilder: (_, i) {
                    final rank = ExpertRank.values[i];
                    final isCurrent = rank == currentRank;
                    final isUnlocked = rank.index <= currentRank.index;
                    final nextExp = rank.nextExp;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? const Color(0xFF4A1A9E).withValues(alpha: 0.08)
                            : isUnlocked
                                ? Colors.green.withValues(alpha: 0.04)
                                : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCurrent
                              ? const Color(0xFF4A1A9E).withValues(alpha: 0.4)
                              : isUnlocked
                                  ? Colors.green.withValues(alpha: 0.3)
                                  : Colors.grey.shade200,
                          width: isCurrent ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? const Color(0xFF4A1A9E)
                                  : isUnlocked
                                      ? Colors.green
                                      : Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: isUnlocked
                                  ? Icon(
                                      isCurrent ? Icons.star : Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : Text(
                                      '${i + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      rank.displayName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: isCurrent
                                            ? const Color(0xFF4A1A9E)
                                            : Colors.black87,
                                      ),
                                    ),
                                    if (isCurrent) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4A1A9E),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'Rank Kamu',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  nextExp != null
                                      ? '${rank.minExp} – ${nextExp - 1} EXP'
                                      : '${rank.minExp} EXP ke atas',
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Fee',
                                style: TextStyle(
                                    color: Colors.grey.shade400, fontSize: 10),
                              ),
                              Text(
                                '${(rank.platformFeeRate * 100).toInt()}%',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isCurrent
                                      ? const Color(0xFF4A1A9E)
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final user = widget.user;
    final rank = user?.rank ?? ExpertRank.newcomer;

    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A1A9E), Color(0xFF6C2BD9), Color(0xFF9B6EE8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                  top: -40,
                  right: -30,
                  child: _Blob(180, Colors.white.withValues(alpha: 0.06))),
              Positioned(
                  bottom: -20,
                  left: 20,
                  child: _Blob(100, Colors.white.withValues(alpha: 0.05))),
              Positioned(
                  top: 60,
                  right: 80,
                  child: _Blob(60, Colors.white.withValues(alpha: 0.04))),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Avatar
                          GestureDetector(
                            onTap: widget.isMe ? _pickAndUploadAvatar : null,
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.25),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: _uploadingAvatar
                                      ? const SizedBox(
                                          width: 88,
                                          height: 88,
                                          child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 3))
                                      : UserAvatar(
                                          imageUrl: profile.avatarUrl,
                                          radius: 44,
                                          rank: rank,
                                          isVerifiedPro: profile.isVerifiedPro,
                                        ),
                                ),
                                if (widget.isMe)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                      ),
                                      child: const Icon(
                                          Icons.camera_alt_rounded,
                                          color: Colors.white,
                                          size: 12),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 24),
                                Text(
                                  profile.displayName.isEmpty
                                      ? 'Expert CariQuest'
                                      : profile.displayName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.3,
                                    shadows: [
                                      Shadow(
                                          color: Colors.black26, blurRadius: 8)
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  children: [
                                    // SESUDAH
                                    GestureDetector(
                                      onTap: () {
                                        final maxVisible = widget.ref
                                                .watch(maxVisibleRankProvider)
                                                .value ??
                                            4;
                                        _showRankListSheet(
                                            context, rank, maxVisible);
                                      },
                                      child: _Badge(
                                        label: rank.displayName,
                                        color:
                                            Colors.white.withValues(alpha: 0.2),
                                        border:
                                            Colors.white.withValues(alpha: 0.4),
                                        textColor: Colors.white,
                                      ),
                                    ),
                                    if (profile.isVerifiedPro)
                                      _Badge(
                                        label: '✓ Verified',
                                        color:
                                            Colors.amber.withValues(alpha: 0.2),
                                        border:
                                            Colors.amber.withValues(alpha: 0.5),
                                        textColor: Colors.amber,
                                        icon: Icons.workspace_premium,
                                      ),
                                    if (user?.isKtmVerified == true)
                                      _Badge(
                                        label: 'KTM ✓',
                                        color:
                                            Colors.green.withValues(alpha: 0.2),
                                        border:
                                            Colors.green.withValues(alpha: 0.4),
                                        textColor: Colors.green,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '🎓 ${user?.faculty ?? 'Universitas Syiah Kuala'}',
                                  style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.7),
                                      fontSize: 12),
                                ),
                                if (user?.major != null)
                                  Text(
                                    '📚 ${user!.major}',
                                    style: TextStyle(
                                        color:
                                            Colors.white.withValues(alpha: 0.6),
                                        fontSize: 11),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Tombol Kirim Quest (seeker only)
                      if (!widget.isMe &&
                          widget.isSeeker &&
                          widget.onContactTap != null) ...[
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: widget.onContactTap,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send_rounded,
                                    color: AppColors.primary, size: 16),
                                SizedBox(width: 8),
                                Text('Kirim Quest Langsung',
                                    style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFFF3F2F8),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
        ),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob(this.size, this.color);
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color, border, textColor;
  final IconData? icon;
  const _Badge({
    required this.label,
    required this.color,
    required this.border,
    required this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor, size: 10),
              const SizedBox(width: 3),
            ],
            Text(label,
                style: TextStyle(
                    color: textColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      );
}
