// lib/features/seeker/screens/seeker_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_controller.dart';
import 'seeker_edit_profile_screen.dart';
import 'seeker_history_quest_screen.dart';
import 'seeker_history_transaction_screen.dart';
import 'seeker_change_password_screen.dart';
import '../../../core/l10n/language_provider.dart';
import '../../../core/l10n/app_strings.dart';
import 'package:go_router/go_router.dart';

class SeekerSettingsScreen extends ConsumerWidget {
  const SeekerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).value;
    final s = ref.watch(languageProvider);

    // SESUDAH
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 16),
          onPressed: () => context.pop(),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // ─── Header ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                        child: Center(
                          child: Text(
                            (user?.displayName.isNotEmpty == true
                                    ? user!.displayName[0]
                                    : user?.email[0] ?? 'S')
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.displayName.isNotEmpty == true
                            ? user!.displayName
                            : user?.email.split('@')[0] ?? 'Seeker',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: const Text(
                          'Seeker',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Menu ─────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Account ─────────────────────────────────────────
                _SectionLabel(label: s.account),
                _MenuTile(
                  icon: Icons.person_outline,
                  title: s.editProfile,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SeekerEditProfileScreen())),
                ),
                _MenuTile(
                  icon: Icons.lock_outline,
                  title: s.changePassword,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SeekerChangePasswordScreen())),
                ),
                _MenuTile(
                  icon: Icons.logout,
                  title: s.logout,
                  isRed: true,
                  onTap: () => _showLogoutDialog(context, ref, s),
                ),
                const SizedBox(height: 16),

                // ── Preferences ─────────────────────────────────────
                _SectionLabel(label: s.preferences),
                // SESUDAH
                _MenuTile(
                  icon: Icons.language_outlined,
                  title: s.language,
                  trailing: Text(
                    ref.watch(languageProvider.notifier).isEnglish
                        ? 'English'
                        : 'Indonesia',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  ),
                  onTap: () => _showLanguageDialog(context, ref),
                ),
                _MenuTile(
                  icon: Icons.palette_outlined,
                  title: s.appearance,
                  trailing: Text(s.system,
                      style:
                          TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                  onTap: () {},
                ),
                const SizedBox(height: 16),

                // ── Invite ──────────────────────────────────────────
                _SectionLabel(label: s.inviteFriends),
                _MenuTile(
                  icon: Icons.people_outline,
                  title: s.inviteFriends,
                  onTap: () {
                    Share.share(
                      'Hei! Coba CariQuest, platform untuk cari expert terbaik. Download sekarang!',
                      subject: 'CariQuest - Cari Expert Terbaik',
                    );
                  },
                ),
                const SizedBox(height: 16),

                // ── Riwayat ─────────────────────────────────────────
                _SectionLabel(label: s.history),
                _MenuTile(
                  icon: Icons.receipt_long_outlined,
                  title: s.transactionHistory,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const SeekerHistoryTransactionScreen())),
                ),
                _MenuTile(
                  icon: Icons.history,
                  title: s.questHistory,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SeekerHistoryQuestScreen())),
                ),
                const SizedBox(height: 16),

                // ── Lainnya ─────────────────────────────────────────
                _SectionLabel(label: s.others),
                _MenuTile(
                  icon: Icons.help_outline,
                  title: s.helpFaq,
                  onTap: () {},
                ),
                _MenuTile(
                  icon: Icons.shield_outlined,
                  title: s.privacyPolicy,
                  onTap: () {},
                ),
                _MenuTile(
                  icon: Icons.info_outline,
                  title: s.aboutUs,
                  trailing: Text('v1.0.0',
                      style:
                          TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                  onTap: () {},
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(
      BuildContext context, WidgetRef ref, AppStrings s) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title:
            Text(s.logout, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(s.logoutConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.logout),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final isEn = ref.read(languageProvider.notifier).isEnglish;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title:
            const Text('Bahasa', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Indonesia'),
              leading: Radio<String>(
                value: 'id',
                groupValue: isEn ? 'en' : 'id',
                onChanged: (_) {
                  ref.read(languageProvider.notifier).setLanguage('id');
                  Navigator.pop(ctx);
                },
              ),
            ),
            ListTile(
              title: const Text('English'),
              leading: Radio<String>(
                value: 'en',
                groupValue: isEn ? 'en' : 'id',
                onChanged: (_) {
                  ref.read(languageProvider.notifier).setLanguage('en');
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      );
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool isRed;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
    this.isRed = false,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(icon,
              color: isRed ? Colors.red : AppColors.primary, size: 22),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isRed ? Colors.red : Colors.black87,
            ),
          ),
          trailing: trailing ??
              Icon(Icons.chevron_right, color: Colors.grey.shade300, size: 20),
          onTap: onTap,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
}
