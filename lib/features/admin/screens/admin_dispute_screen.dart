// lib/features/admin/screens/admin_dispute_screen.dart
// cloud_firestore removed — mock mode
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/widgets.dart';

final allDisputesProvider =
    StreamProvider.autoDispose<List<DisputeModel>>((ref) {
  // Demo mode: no disputes in mock data
  return Stream.value([]);
});

class AdminDisputeScreen extends ConsumerStatefulWidget {
  const AdminDisputeScreen({super.key});

  @override
  ConsumerState<AdminDisputeScreen> createState() =>
      _AdminDisputeScreenState();
}

class _AdminDisputeScreenState
    extends ConsumerState<AdminDisputeScreen> {
  String _filter = 'open'; // open, resolved, all

  @override
  Widget build(BuildContext context) {
    final disputesAsync = ref.watch(allDisputesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0EFF8),
      body: disputesAsync.when(
        data: (disputes) {
          List<DisputeModel> filtered;
          switch (_filter) {
            case 'open':
              filtered = disputes
                  .where((d) => d.status == DisputeStatus.open)
                  .toList();
              break;
            case 'resolved':
              filtered = disputes
                  .where((d) => d.status == DisputeStatus.resolved)
                  .toList();
              break;
            default:
              filtered = disputes;
          }

          final openCount =
              disputes.where((d) => d.status == DisputeStatus.open).length;

          return CustomScrollView(
            slivers: [
              // ── App bar ──────────────────────────────────────────────
              SliverAppBar(
                pinned: true,
                expandedHeight: 100,
                automaticallyImplyLeading: false,
                backgroundColor: AppColors.primaryDark,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding:
                      const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  title: Row(
                    children: [
                      const Icon(Icons.gavel_rounded,
                          color: Colors.white70, size: 18),
                      const SizedBox(width: 8),
                      const Text('Dispute & Mediasi',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const Spacer(),
                      if (openCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('$openCount aktif',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2D1B69), AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Filter ────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      _filterChip('open', 'Aktif', openCount,
                          Colors.red),
                      const SizedBox(width: 8),
                      _filterChip(
                          'resolved',
                          'Selesai',
                          disputes
                              .where((d) =>
                                  d.status == DisputeStatus.resolved)
                              .length,
                          Colors.green),
                      const SizedBox(width: 8),
                      _filterChip(
                          'all', 'Semua', disputes.length, Colors.grey),
                    ],
                  ),
                ),
              ),

              // ── Empty state ───────────────────────────────────────────
              if (filtered.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.gavel_rounded,
                              size: 48, color: Colors.green),
                        ),
                        const SizedBox(height: 16),
                        const Text('Tidak ada dispute aktif!',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        const SizedBox(height: 6),
                        Text('Platform berjalan lancar 🎉',
                            style: TextStyle(
                                color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _DisputeCard(dispute: filtered[i]),
                      childCount: filtered.length,
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _filterChip(
      String value, String label, int count, Color color) {
    final selected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? color : Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                    color:
                        selected ? Colors.white : Colors.grey.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('$count',
                  style: TextStyle(
                      fontSize: 10,
                      color: selected
                          ? Colors.white
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dispute Card ─────────────────────────────────────────────────────────────
class _DisputeCard extends ConsumerWidget {
  final DisputeModel dispute;
  const _DisputeCard({required this.dispute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOpen = dispute.status == DisputeStatus.open;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isOpen
            ? Border.all(color: Colors.red.withValues(alpha: 0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isOpen
                        ? Colors.red.withValues(alpha: 0.1)
                        : Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isOpen
                        ? Icons.report_problem_rounded
                        : Icons.check_circle_rounded,
                    color: isOpen ? Colors.red : Colors.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dispute #${dispute.disputeId.substring(0, 8).toUpperCase()}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF1A1A2E)),
                      ),
                      Text(
                        dispute.createdAt.toString().substring(0, 16),
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                StatusChip(
                  label:
                      isOpen ? 'AKTIF' : 'SELESAI',
                  color: isOpen ? Colors.red : Colors.green,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, indent: 16, endIndent: 16),
          const SizedBox(height: 12),

          // ── Detail ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                  icon: Icons.assignment_outlined,
                  label: 'Quest ID',
                  value: dispute.questId.length > 16
                      ? '${dispute.questId.substring(0, 8)}...'
                      : dispute.questId,
                ),
                const SizedBox(height: 6),
                _InfoRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Pelapor',
                  value: _maskUid(dispute.reporterUid),
                ),
                const SizedBox(height: 6),
                _InfoRow(
                  icon: Icons.person_off_outlined,
                  label: 'Dilaporkan',
                  value: _maskUid(dispute.reportedUid),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Alasan',
                          style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(
                        dispute.reason,
                        style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF1A1A2E),
                            height: 1.4),
                      ),
                    ],
                  ),
                ),
                if (!isOpen && dispute.resolution != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Resolusi',
                            style: TextStyle(
                                color: Colors.green.shade700,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                          dispute.resolution!,
                          style: const TextStyle(
                              fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Actions ────────────────────────────────────────────────
          if (isOpen)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.block_rounded,
                          color: Colors.red, size: 16),
                      label: const Text('Suspend',
                          style: TextStyle(
                              color: Colors.red, fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () =>
                          _showSuspendDialog(context, dispute),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_rounded,
                          color: Colors.white, size: 16),
                      label: const Text('Tandai Selesai',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () =>
                          _resolveDialog(context, dispute),
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
              child: Text(
                'Diselesaikan: ${dispute.resolvedAt?.toString().substring(0, 10) ?? "-"}',
                style: TextStyle(
                    color: Colors.grey.shade400, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  String _maskUid(String uid) {
    if (uid.length <= 8) return uid;
    return '${uid.substring(0, 4)}...${uid.substring(uid.length - 4)}';
  }

  void _showSuspendDialog(
      BuildContext context, DisputeModel dispute) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Suspend Akun Terlapor',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Akun ${_maskUid(dispute.reportedUid)} akan ditangguhkan dan dispute ditandai selesai.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '⚠️ Tindakan ini tidak dapat dibatalkan kecuali admin mengaktifkan kembali secara manual.',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              // Mock: suspend user in-memory
              try {
                final user = MockData.instance.users
                    .firstWhere((u) => u.uid == dispute.reportedUid);
                MockData.instance.updateUser(user.copyWith(isSuspended: true));
              } catch (_) {}
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Akun berhasil disuspend (Demo).'),
                      backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
  }

  void _resolveDialog(BuildContext context, DisputeModel dispute) {
    final resolutionCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Selesaikan Dispute',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Tambahkan catatan resolusi untuk dispute ini:',
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            TextField(
              controller: resolutionCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Contoh: Kedua pihak sepakat...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              // Mock: just notify success
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Dispute ditandai selesai (Demo).'),
                      backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('Selesaikan'),
          ),
        ],
      ),
    );
  }
}

// ─── Info Row ─────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade400),
        const SizedBox(width: 6),
        Text('$label: ',
            style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
        Text(value,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E))),
      ],
    );
  }
}
