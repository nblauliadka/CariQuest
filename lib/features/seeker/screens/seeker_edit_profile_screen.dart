// lib/features/seeker/screens/seeker_edit_profile_screen.dart

// cloud_firestore removed — using mock data
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/utils/ui_helpers.dart';
import '../../../core/mock/mock_data.dart';
import '../../auth/providers/auth_controller.dart';

class SeekerEditProfileScreen extends ConsumerStatefulWidget {
  const SeekerEditProfileScreen({super.key});

  @override
  ConsumerState<SeekerEditProfileScreen> createState() =>
      _SeekerEditProfileScreenState();
}

class _SeekerEditProfileScreenState
    extends ConsumerState<SeekerEditProfileScreen> {
  final _nameCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider).value;
    _nameCtrl.text = user?.displayName ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    UiHelpers.hideKeyboard(context);
    if (_nameCtrl.text.trim().isEmpty) {
      UiHelpers.showErrorSnackBar(context, 'Nama tidak boleh kosong');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = ref.read(userProvider).value;
      if (user == null) return;

      // Mock: directly update in-memory user
      final db = MockData.instance;
      db.updateUser(user.copyWith(displayName: _nameCtrl.text.trim()));

      if (mounted) {
        UiHelpers.showSuccessSnackBar(context, 'Nama berhasil diperbarui!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        UiHelpers.showErrorSnackBar(context, 'Gagal menyimpan: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).value;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Avatar ───────────────────────────────────────────────
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  (user?.displayName.isNotEmpty == true
                          ? user!.displayName[0]
                          : user?.email[0] ?? 'S')
                      .toUpperCase(),
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 36,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ─── Form ─────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
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
                  // Nama
                  const Text('Nama',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      hintText: 'Masukkan nama kamu',
                      prefixIcon: const Icon(Icons.person_outline),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Email (read only)
                  const Text('Email',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: user?.email ?? '',
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: const Icon(Icons.lock_outline,
                          size: 16, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // No HP (read only)
                  const Text('Nomor HP',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: user?.phone ?? '',
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: const Icon(Icons.lock_outline,
                          size: 16, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Email dan No HP tidak dapat diubah',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ─── Save Button ──────────────────────────────────────────
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text('Simpan Perubahan',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
