// lib/features/profile/screens/widgets/direct_quest_sheet.dart
import 'package:cariquest/features/quest/providers/quest_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class DirectQuestSheet extends StatefulWidget {
  final String expertUid;
  final String expertName;
  final String seekerUid;
  final WidgetRef ref;

  const DirectQuestSheet({
    super.key,
    required this.expertUid,
    required this.expertName,
    required this.seekerUid,
    required this.ref,
  });

  @override
  State<DirectQuestSheet> createState() => _DirectQuestSheetState();
}

class _DirectQuestSheetState extends State<DirectQuestSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  DateTime _deadline = DateTime.now().add(const Duration(days: 7));
  bool _isUrgent = false;
  bool _loading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final price = int.tryParse(_priceCtrl.text.replaceAll('.', '')) ?? 0;

    if (title.isEmpty || desc.isEmpty || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua field terlebih dahulu')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await widget.ref.read(questControllerProvider.notifier).postQuestDirect(
            seekerUid: widget.seekerUid,
            expertUid: widget.expertUid,
            title: title,
            description: desc,
            fixedPrice: price,
            deadline: _deadline,
            isUrgent: _isUrgent,
          );

      if (!mounted) return;
      Navigator.pop(context);

      final questId =
          widget.ref.read(questControllerProvider.notifier).lastQuestId ?? '';
      if (questId.isNotEmpty) {
        context.pushNamed(
          'chat',
          pathParameters: {'chatId': questId},
          extra: {'questTitle': title},
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.send_rounded,
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Kirim Quest Langsung',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF1A1A2E))),
                      Text('ke ${widget.expertName}',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const _Label('Judul Quest'),
            _Field(
                controller: _titleCtrl,
                hint: 'Contoh: Desain poster acara kampus'),
            const SizedBox(height: 14),

            const _Label('Deskripsi Singkat'),
            _Field(
                controller: _descCtrl,
                hint: 'Jelaskan kebutuhan kamu secara singkat...',
                maxLines: 3),
            const SizedBox(height: 14),

            const _Label('Biaya Pengerjaan (Rp)'),
            _Field(
                controller: _priceCtrl,
                hint: '150000',
                keyboardType: TextInputType.number),
            const SizedBox(height: 14),

            const _Label('Deadline'),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _deadline,
                  firstDate: DateTime.now().add(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _deadline = picked);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Text(
                      '${_deadline.day}/${_deadline.month}/${_deadline.year}',
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF1A1A2E)),
                    ),
                    const Spacer(),
                    Text('Ketuk untuk ganti',
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 11)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Urgent toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _isUrgent ? Colors.red.shade50 : const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color:
                        _isUrgent ? Colors.red.shade200 : Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.bolt_rounded,
                      color: _isUrgent
                          ? Colors.red.shade600
                          : Colors.grey.shade400,
                      size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tandai sebagai Urgent',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: _isUrgent
                                    ? Colors.red.shade700
                                    : const Color(0xFF1A1A2E))),
                        Text('Prioritas lebih tinggi, ada markup harga',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _isUrgent,
                    onChanged: (v) => setState(() => _isUrgent = v),
                    // ignore: deprecated_member_use
                    activeColor: Colors.red,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(
                  _loading ? 'Mengirim...' : 'Kirim Quest & Buka Chat',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF1A1A2E))),
      );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  const _Field({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          filled: true,
          fillColor: const Color(0xFFF5F6FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      );
}
