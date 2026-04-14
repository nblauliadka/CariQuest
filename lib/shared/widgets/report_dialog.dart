// lib/shared/widgets/report_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/dispute/providers/dispute_controller.dart';
import 'custom_button.dart';

class ReportDialog extends ConsumerStatefulWidget {
  final String questId;
  final String reporterUid;
  final String reportedUid;

  const ReportDialog({
    super.key,
    required this.questId,
    required this.reporterUid,
    required this.reportedUid,
  });

  @override
  ConsumerState<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends ConsumerState<ReportDialog> {
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('Laporkan Kendala', style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Jelaskan masalah yang terjadi untuk ditinjau oleh tim admin kami.', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 16),
          TextField(
            controller: _reasonController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Misal: Rating tidak sesuai, Pekerjaan tidak lengkap, dsb.',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        CustomButton(
          text: 'Kirim Laporan',
          width: 150,
          isLoading: _isLoading,
          onPressed: _submitReport,
        ),
      ],
    );
  }

  Future<void> _submitReport() async {
    if (_reasonController.text.trim().isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      await ref.read(disputeControllerProvider.notifier).raiseDispute(
        questId: widget.questId,
        reporterUid: widget.reporterUid,
        reportedUid: widget.reportedUid,
        reason: _reasonController.text,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Laporan berhasil dikirim. Admin akan segera meninjau.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim laporan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
