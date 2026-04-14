// lib/features/seeker/screens/seeker_post_quest_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/utils/ui_helpers.dart';
import '../../auth/providers/auth_controller.dart';
import '../../quest/providers/quest_controller.dart';

class SeekerPostQuestScreen extends ConsumerStatefulWidget {
  const SeekerPostQuestScreen({super.key});

  @override
  ConsumerState<SeekerPostQuestScreen> createState() =>
      _SeekerPostQuestScreenState();
}

class _SeekerPostQuestScreenState extends ConsumerState<SeekerPostQuestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _minBudgetCtrl = TextEditingController();
  final _maxBudgetCtrl = TextEditingController();

  DateTime? _deadline;
  bool _isUrgent = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _minBudgetCtrl.dispose();
    _maxBudgetCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 3)),
      firstDate: now.add(const Duration(hours: 1)),
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() {
        _deadline = picked;
        final hoursUntil = picked.difference(now).inHours;
        if (hoursUntil <= 24) _isUrgent = true;
      });
    }
  }

  void _onSubmit() {
    UiHelpers.hideKeyboard(context);

    if (_deadline == null) {
      UiHelpers.showErrorSnackBar(context, 'Tentukan deadline terlebih dahulu');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(userProvider).value;
    if (user == null) return;

    final minBudget =
        int.tryParse(_minBudgetCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
            0;
    final maxBudget =
        int.tryParse(_maxBudgetCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
            0;

    ref.read(questControllerProvider.notifier).postQuest(
          seekerUid: user.uid,
          title: _titleCtrl.text.trim(),
          description: '',
          jobdesk: '',
          minBudget: minBudget,
          maxBudget: maxBudget,
          deadline: _deadline!,
          isUrgent: _isUrgent,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(questControllerProvider);

    ref.listen(questControllerProvider, (prev, next) {
      if (next.hasError) {
        UiHelpers.showErrorSnackBar(context, next.error.toString());
      } else if (!next.isLoading && next.hasValue && prev?.isLoading == true) {
        UiHelpers.showSuccessSnackBar(context, 'Quest berhasil diposting!');
        context.pop();
      }
    });

    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Quest Baru'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Info Banner ───────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: AppColors.primary, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Isi info singkat questmu. Detail bisa didiskusikan langsung dengan expert via chat.',
                        style:
                            TextStyle(color: AppColors.primary, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ─── Judul Quest ───────────────────────────────────────────
              _SectionCard(
                title: '📝 Judul Quest',
                child: TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Desain logo startup minimalis',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Judul wajib diisi';
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // ─── Budget ────────────────────────────────────────────────
              _SectionCard(
                title: '💰 Budget',
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _minBudgetCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Minimum',
                          prefixText: 'Rp ',
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Wajib diisi';
                          final val =
                              int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), ''));
                          if (val == null || val < 10000) {
                            return 'Min Rp 10.000';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _maxBudgetCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Maksimum',
                          prefixText: 'Rp ',
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Wajib diisi';
                          final minVal = int.tryParse(_minBudgetCtrl.text
                                  .replaceAll(RegExp(r'[^0-9]'), '')) ??
                              0;
                          final maxVal =
                              int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), ''));
                          if (maxVal == null) return 'Tidak valid';
                          if (maxVal < minVal) return 'Harus > minimum';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ─── Deadline ──────────────────────────────────────────────
              _SectionCard(
                title: '📅 Deadline',
                child: GestureDetector(
                  onTap: _pickDeadline,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade50,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          _deadline == null
                              ? 'Pilih tanggal deadline'
                              : DateFormat('dd MMMM yyyy').format(_deadline!),
                          style: TextStyle(
                            color: _deadline == null
                                ? Colors.grey
                                : Colors.black87,
                            fontWeight: _deadline != null
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ─── Urgent Toggle ─────────────────────────────────────────
              _SectionCard(
                title: '⚡ Tandai Urgent',
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quest Urgent',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Menambah markup 30% untuk memprioritaskan quest kamu',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isUrgent,
                      onChanged: (v) => setState(() => _isUrgent = v),
                      activeThumbColor: AppColors.primary,
                    ),
                  ],
                ),
              ),

              if (_isUrgent) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.bolt, color: Colors.orange.shade700, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Budget maksimum akan otomatis ditambah 30% sebagai biaya urgent',
                          style: TextStyle(
                              color: Colors.orange.shade700, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // ─── Submit Button ─────────────────────────────────────────
              ElevatedButton(
                onPressed: isLoading ? null : _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text('Post Quest Sekarang',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helper Widget ────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
