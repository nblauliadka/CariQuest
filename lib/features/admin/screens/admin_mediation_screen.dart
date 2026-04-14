// cloud_firestore removed — mock mode
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/widgets.dart';

final adminDisputesProvider = StreamProvider.autoDispose<List<DisputeModel>>((ref) {
  // Demo: no disputes in mock data
  return Stream.value([]);
});

class AdminMediationScreen extends ConsumerWidget {
  const AdminMediationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disputesAsync = ref.watch(adminDisputesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard - Mediation'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: disputesAsync.when(
        data: (disputes) {
          if (disputes.isEmpty) {
            return const Center(child: Text('Tidak ada laporan / dispute aktif.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: disputes.length,
            itemBuilder: (context, index) {
              final dispute = disputes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text('Quest ID: ${dispute.questId}',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          StatusChip(
                            label: dispute.status.name.toUpperCase(),
                            color: dispute.status == DisputeStatus.open ? Colors.orange : Colors.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Reporter: ${dispute.reporterUid}'),
                      Text('Reported: ${dispute.reportedUid}'),
                      const SizedBox(height: 8),
                      Text('Alasan:', style: TextStyle(color: Colors.grey.shade600)),
                      Text(dispute.reason, style: const TextStyle(fontStyle: FontStyle.italic)),
                      const SizedBox(height: 16),
                      if (dispute.status == DisputeStatus.open) Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Suspend User',
                              type: ButtonType.secondary,
                              onPressed: () => _showSuspendDialog(context, ref, dispute),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CustomButton(
                              text: 'Tandai Selesai',
                              onPressed: () => _resolveDispute(context, ref, dispute),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showSuspendDialog(BuildContext context, WidgetRef ref, DisputeModel dispute) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Suspend'),
        content: const Text('Apakah Anda yakin ingin menangguhkan (suspend) akun Reported User?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                // Mock: suspend user in MockData
                final db = MockData.instance;
                try {
                  final user = db.users.firstWhere((u) => u.uid == dispute.reportedUid);
                  db.updateUser(user.copyWith(isSuspended: true));
                } catch (_) {}

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Akun berhasil disuspend.')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Suspend', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _resolveDispute(BuildContext context, WidgetRef ref, DisputeModel dispute) async {
    try {
      // Mock: just show success message (disputes not stored in mock)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dispute ditandai selesai.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
