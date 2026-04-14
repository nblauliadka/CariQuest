import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/utils/ui_helpers.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/quest_controller.dart';

class ExpertSubmitWorkScreen extends ConsumerStatefulWidget {
  final String questId;
  const ExpertSubmitWorkScreen({super.key, required this.questId});

  @override
  ConsumerState<ExpertSubmitWorkScreen> createState() => _ExpertSubmitWorkScreenState();
}

class _ExpertSubmitWorkScreenState extends ConsumerState<ExpertSubmitWorkScreen> {
  final _fileUrlCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _fileUrlCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    UiHelpers.hideKeyboard(context);
    final url = _fileUrlCtrl.text.trim();
    if (url.isEmpty || !url.startsWith('http')) {
      UiHelpers.showErrorSnackBar(context, 'Masukkan link hasil kerja yang valid (harus dimulai dengan http)');
      return;
    }

    ref.read(questControllerProvider.notifier)
       .submitWork(widget.questId, url)
       .then((_) {
         UiHelpers.showSuccessSnackBar(context, 'Karya berhasil disubmit! Sistem telah menambahkan watermark secara otomatis (Mock).');
         if (context.mounted) context.pop();
       })
       .catchError((e) {
         UiHelpers.showErrorSnackBar(context, e.toString());
       });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(questControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Kirim Hasil Kerja')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.security, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Karya yang dikirim akan secara otomatis ditambahkan Watermark untuk melindungi hak cipta Anda hingga pembayaran selesai.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Link Mock URL Karya', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _fileUrlCtrl,
              decoration: const InputDecoration(
                hintText: 'Misal: https://docs.google.com/xyz',
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 24),
            Text('Catatan Tambahan (Opsional)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Ada pesan untuk klien?',
              ),
            ),
            const SizedBox(height: 48),
            CustomButton(
              text: 'Kirim Sekarang',
              isLoading: isLoading,
              onPressed: _submit,
            )
          ],
        ),
      ),
    );
  }
}
