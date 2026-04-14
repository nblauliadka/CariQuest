// lib/features/auth/screens/pending_verification_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/constants.dart';
import '../../../shared/utils/ui_helpers.dart';
import '../providers/auth_controller.dart';
import '../../../shared/models/models.dart';

class PendingVerificationScreen extends ConsumerWidget {
  const PendingVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final authState = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (prev, next) {
      if (next.hasError) {
        UiHelpers.showErrorSnackBar(context, next.error.toString());
      }
    });

    // AUTO-REDIRECT: Ketika userProvider update dan user sudah fully verified
    ref.listen(userProvider, (prev, next) {
      next.whenData((user) {
        if (user == null) return;
        final isEmailVerified = user.isEmailVerified;
        final isSystemVerified =
            (user.role == UserRole.expert && user.isKtmVerified) ||
                (user.role == UserRole.seeker && user.isKtpVerified);

        if (isEmailVerified && isSystemVerified) {
          if (user.role == UserRole.expert) {
            context.go('/expert/dashboard');
          } else {
            context.go('/seeker/dashboard');
          }
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Akun'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Data tidak ditemukan'));
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.mark_email_unread_outlined,
                    size: 100, color: AppColors.primary),
                const SizedBox(height: 32),
                Text(
                  AppStrings.pendingVerification,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  _getVerificationMessage(user),
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                if (!user.isEmailVerified) ...[
                  OutlinedButton.icon(
                    icon: authState.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.refresh),
                    label: const Text('Cek Status Verifikasi Email'),
                    onPressed: authState.isLoading
                        ? null
                        : () {
                            ref
                                .read(authControllerProvider.notifier)
                                .verifyEmailChecked();
                          },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      ref
                          .read(authControllerProvider.notifier)
                          .sendVerificationEmail();
                      UiHelpers.showSuccessSnackBar(
                          context, 'Email verifikasi ulang telah dikirim');
                    },
                    child: const Text('Kirim Ulang Email'),
                  ),
                ] else ...[
                  OutlinedButton.icon(
                    icon: authState.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.refresh),
                    label: const Text('Cek Status Admin'),
                    onPressed: authState.isLoading
                        ? null
                        : () {
                            ref.invalidate(userProvider);
                          },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Halaman ini akan otomatis berpindah\nsetelah admin menyetujui akun kamu.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ]
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  String _getVerificationMessage(UserModel user) {
    if (!user.isEmailVerified) {
      return 'Kami telah mengirimkan link verifikasi ke email:\n${user.email}\n\nSilakan klik link tersebut untuk mengaktifkan akun. Jika tidak masuk, cek folder Spam.';
    }

    if (user.role == UserRole.expert && !user.isKtmVerified) {
      return 'Email berhasil diverifikasi!\n\nTim CariQuest sedang memvalidasi foto KTM kamu. Proses ini maksimal memakan waktu 1x24 Jam.';
    }

    if (user.role == UserRole.seeker && !user.isKtpVerified) {
      return 'Email berhasil diverifikasi!\n\nTim CariQuest sedang memvalidasi identitas KTP kamu. Proses ini memakan waktu 1x24 Jam.';
    }

    return 'Sedang memproses...';
  }
}
