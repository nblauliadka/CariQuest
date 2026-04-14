// lib/features/auth/screens/register_seeker_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/constants.dart';
import '../../../shared/utils/ui_helpers.dart';
import '../services/auth_repository.dart';

class RegisterSeekerScreen extends ConsumerStatefulWidget {
  const RegisterSeekerScreen({super.key});
  @override
  ConsumerState<RegisterSeekerScreen> createState() =>
      _RegisterSeekerScreenState();
}

class _RegisterSeekerScreenState extends ConsumerState<RegisterSeekerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _obscurePass = true;
  Uint8List? _ktpBytes;
  bool _isUploading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickKtp() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('Upload Foto KTP',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Ambil Foto (Kamera)'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Pilih dari Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() => _ktpBytes = bytes);
      if (mounted) {
        UiHelpers.showSuccessSnackBar(context, 'Foto KTP berhasil dipilih');
      }
    }
  }

  Future<void> _onRegister() async {
    UiHelpers.hideKeyboard(context);
    if (_ktpBytes == null) {
      UiHelpers.showErrorSnackBar(
          context, 'Wajib upload foto KTP untuk verifikasi');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);
    try {
      // 1. Register user → dapat uid
      final uid = await ref.read(authRepositoryProvider).registerSeeker(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text.trim(),
            name: _nameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
          );

      // 2. Upload foto KTP ke Mock Storage
      final bytes = _ktpBytes!;
      await ref.read(authRepositoryProvider).uploadVerificationPhoto(
            uid: uid,
            bytes: bytes,
            role: UserRole.seeker,
          );

      if (mounted) context.goNamed('pendingVerification');
    } catch (e) {
      if (mounted) {
        UiHelpers.showErrorSnackBar(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Seeker')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // KTP Upload Area
                GestureDetector(
                  onTap: _isUploading ? null : _pickKtp,
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.05),
                      border: Border.all(
                        color: _ktpBytes != null
                            ? AppColors.success
                            : AppColors.gold.withOpacity(0.3),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _ktpBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.memory(_ktpBytes!, fit: BoxFit.cover),
                                Container(
                                  color: Colors.black.withOpacity(0.3),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check_circle,
                                          color: Colors.white, size: 36),
                                      SizedBox(height: 8),
                                      Text('KTP Berhasil Dipilih',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                      Text('Tap untuk ganti',
                                          style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.credit_card_outlined,
                                  size: 48, color: AppColors.gold),
                              const SizedBox(height: 12),
                              const Text(AppStrings.uploadKtp,
                                  style: TextStyle(
                                      color: AppColors.goldDark,
                                      fontWeight: FontWeight.bold)),
                              Text('Tap untuk pilih foto dari galeri',
                                  style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap / Nama Bisnis',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email wajib diisi';
                    if (!v.contains('@')) return 'Format email salah';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'WhatsApp Aktif',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (v) => v!.isEmpty ? 'No WA wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscurePass,
                  decoration: InputDecoration(
                    labelText: AppStrings.password,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePass
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.length < 6) ? 'Min 6 karakter' : null,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isUploading ? null : _onRegister,
                  child: _isUploading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            ),
                            SizedBox(width: 12),
                            Text('Mengupload foto KTP...'),
                          ],
                        )
                      : const Text(AppStrings.register),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
