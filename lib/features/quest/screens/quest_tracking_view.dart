// lib/features/quest/screens/quest_tracking_view.dart

// cloud_firestore removed — using mock data
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../shared/widgets/report_dialog.dart';
import '../../auth/providers/auth_controller.dart';
import '../providers/quest_controller.dart';
import '../services/quest_repository.dart';


final expertProfileProvider =
    FutureProvider.family<ProfileModel?, String>((ref, uid) async {
  if (uid.isEmpty) return null;
  final db = MockData.instance;
  try {
    return db.profiles.firstWhere((p) => p.uid == uid);
  } catch (_) {
    return null;
  }
});

class QuestTrackingView extends ConsumerWidget {
  final String questId;
  const QuestTrackingView({super.key, required this.questId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questAsync = ref.watch(questStreamProvider(questId));
    final user = ref.watch(userProvider).value;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Status Proyek'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: questAsync.when(
        data: (quest) {
          if (quest == null) {
            return const Center(child: Text('Quest tidak ditemukan'));
          }
          final expertAsync =
              ref.watch(expertProfileProvider(quest.expertUid ?? ''));
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TimelineCard(
                    status: quest.status, isDirect: quest.expertUid != null),
                const SizedBox(height: 16),
                _DetailCard(quest: quest, expertProfile: expertAsync.value),
                const SizedBox(height: 16),
                _DeadlineCard(deadline: quest.deadline),
                const SizedBox(height: 16),
                _BudgetCard(quest: quest),
                if (quest.revisionCount > 0) ...[
                  const SizedBox(height: 16),
                  _RevisionCounterCard(
                    revisionCount: quest.revisionCount,
                    maxRevisions: QuestRepository.maxRevisions,
                  ),
                ],
                const SizedBox(height: 24),
                _buildActionButtons(
                    context, ref, quest, user?.role ?? UserRole.seeker, user),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref,
      QuestModel quest, UserRole role, UserModel? user) {
    final status = quest.status;
    final controller = ref.read(questControllerProvider.notifier);
    final isRevisionMaxed = quest.revisionCount >= QuestRepository.maxRevisions;
    final isDirectQuest = quest.expertUid != null;

    // ── Expert Actions ────────────────────────────────────────────────────────
    if (role == UserRole.expert) {
      // Direct quest pending → expert harus terima/tolak dulu
      if (status == QuestStatus.pending && isDirectQuest) {
        return _DirectQuestResponseCard(quest: quest, ref: ref);
      }

      // Working → kirim hasil
      if (status == QuestStatus.working) {
        return CustomButton(
          text: 'Kirim Hasil Kerja',
          icon: Icons.upload_file,
          onPressed: () =>
              controller.submitWork(quest.questId, 'mock_file_url'),
        );
      }
    }

    // ── Seeker Actions ────────────────────────────────────────────────────────
    if (role == UserRole.seeker) {
      // Pending direct quest → tunggu expert terima, bisa chat & batalkan
      if (status == QuestStatus.pending && isDirectQuest) {
        // Kalau expert sudah terima → tampil tombol bayar
        // Ada nego dari expert yang menunggu keputusan seeker
        if (quest.negoStatus == 'waiting' && quest.negoPrice != null) {
          final format = NumberFormat.currency(
              locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.handshake_outlined,
                            color: Colors.orange.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text('Expert Mengajukan Nego!',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                                fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Harga awal',
                                style: TextStyle(
                                    color: Colors.grey.shade500, fontSize: 11)),
                            Text(
                              format
                                  .format(quest.finalPrice ?? quest.maxBudget),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_forward,
                            color: Colors.orange, size: 18),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Harga nego',
                                style: TextStyle(
                                    color: Colors.orange.shade600,
                                    fontSize: 11)),
                            Text(
                              format.format(quest.negoPrice),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.orange.shade700),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Setuju & Bayar ${format.format(quest.negoPrice)}',
                icon: Icons.check_circle_rounded,
                onPressed: () async {
                  await ref
                      .read(questControllerProvider.notifier)
                      .acceptNego(quest.questId, quest.negoPrice!);
                  if (context.mounted) {
                    context.pushNamed(
                      'payment',
                      pathParameters: {'questId': quest.questId},
                      extra: {
                        'amount': quest.negoPrice,
                        'title': quest.title,
                      },
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => _showCancelDialog(context, ref, quest),
                icon: const Icon(Icons.cancel_outlined,
                    size: 16, color: Colors.red),
                label: const Text('Tolak & Batalkan Quest',
                    style: TextStyle(color: Colors.red, fontSize: 13)),
              ),
            ],
          );
        }

// Expert sudah terima, tidak ada nego
        if (quest.expertAccepted) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Expert sudah menerima quest kamu! Lakukan pembayaran untuk memulai.',
                        style: TextStyle(
                            color: Colors.green.shade700, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Bayar Sekarang',
                icon: Icons.payment,
                onPressed: () => context.pushNamed(
                  'payment',
                  pathParameters: {'questId': quest.questId},
                  extra: {
                    'amount': quest.finalPrice ?? quest.maxBudget,
                    'title': quest.title,
                  },
                ),
              ),
            ],
          );
        }
        return Column(
          children: [
            // Info card menunggu
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.hourglass_top_rounded,
                      color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Menunggu expert menerima quest kamu. '
                      'Kamu bisa chat dulu untuk diskusi.',
                      style:
                          TextStyle(color: Colors.blue.shade700, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Hubungi Chat',
              type: ButtonType.outline,
              icon: Icons.chat_outlined,
              onPressed: () => context.pushNamed(
                'chat',
                pathParameters: {'chatId': quest.questId},
                extra: {'questTitle': quest.title},
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => _showCancelDialog(context, ref, quest),
              icon: const Icon(Icons.cancel_outlined,
                  size: 16, color: Colors.red),
              label: const Text('Batalkan Quest',
                  style: TextStyle(color: Colors.red, fontSize: 13)),
            ),
          ],
        );
      }

      // Pending open bid → tombol chat + batalkan biasa
      if (status == QuestStatus.pending && !isDirectQuest) {
        return Column(
          children: [
            CustomButton(
              text: 'Hubungi Chat',
              type: ButtonType.outline,
              icon: Icons.chat_outlined,
              onPressed: () => context.pushNamed(
                'chat',
                pathParameters: {'chatId': quest.questId},
                extra: {'questTitle': quest.title},
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => _showCancelDialog(context, ref, quest),
              icon: const Icon(Icons.cancel_outlined,
                  size: 16, color: Colors.red),
              label: const Text('Batalkan Quest',
                  style: TextStyle(color: Colors.red, fontSize: 13)),
            ),
          ],
        );
      }

      // Paid → menunggu expert mulai kerja
      if (status == QuestStatus.paid) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline,
                  color: Colors.green.shade700, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Pembayaran berhasil! Menunggu expert mulai mengerjakan.',
                  style: TextStyle(color: Colors.green.shade700, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      }

      // Review → selesaikan atau minta revisi
      if (status == QuestStatus.review) {
        return Column(
          children: [
            CustomButton(
              text: 'Selesaikan & Beri Rating',
              icon: Icons.check_circle,
              onPressed: () async {
                await controller.finishQuest(quest.questId);
                if (context.mounted) {
                  context.pushNamed(
                    'seekerRating',
                    pathParameters: {'questId': quest.questId},
                    extra: {
                      'expertUid': quest.expertUid,
                      'seekerUid': quest.seekerUid,
                    },
                  );
                }
              },
            ),
            const SizedBox(height: 12),
            isRevisionMaxed
                ? Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.orange.shade700, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Batas revisi (${QuestRepository.maxRevisions}x) sudah habis. '
                            'Silakan selesaikan atau ajukan komplain.',
                            style: TextStyle(
                                color: Colors.orange.shade700, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  )
                : CustomButton(
                    text:
                        'Minta Revisi (${quest.revisionCount}/${QuestRepository.maxRevisions})',
                    type: ButtonType.outline,
                    icon: Icons.refresh,
                    onPressed: () => _showRevisionDialog(context, ref, quest),
                  ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (context) => ReportDialog(
                  questId: quest.questId,
                  reporterUid: user?.uid ?? '',
                  reportedUid: quest.expertUid ?? '',
                ),
              ),
              icon: const Icon(Icons.report_problem_outlined,
                  size: 16, color: Colors.red),
              label: const Text('Laporkan / Adu Banding',
                  style: TextStyle(color: Colors.red, fontSize: 13)),
            ),
          ],
        );
      }
    }

    // ── Default (working, dll) ─────────────────────────────────────────────────
    return Column(
      children: [
        CustomButton(
          text: 'Hubungi Chat',
          type: ButtonType.outline,
          icon: Icons.chat_outlined,
          onPressed: () => context.pushNamed(
            'chat',
            pathParameters: {'chatId': quest.questId},
            extra: {'questTitle': quest.title},
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () => showDialog(
            context: context,
            builder: (context) => ReportDialog(
              questId: quest.questId,
              reporterUid: user?.uid ?? '',
              reportedUid: role == UserRole.seeker
                  ? (quest.expertUid ?? '')
                  : quest.seekerUid,
            ),
          ),
          icon: const Icon(Icons.report_problem_outlined,
              size: 16, color: Colors.red),
          label: const Text('Laporkan / Adu Banding',
              style: TextStyle(color: Colors.red, fontSize: 13)),
        ),
      ],
    );
  }

  void _showRevisionDialog(
      BuildContext context, WidgetRef ref, QuestModel quest) {
    final remaining = QuestRepository.maxRevisions - quest.revisionCount;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Minta Revisi?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quest akan dikembalikan ke expert untuk direvisi.'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.refresh, color: Colors.orange.shade700, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Revisi ke-${quest.revisionCount + 1} dari ${QuestRepository.maxRevisions}. '
                      'Sisa: ${remaining - 1} kali lagi.',
                      style: TextStyle(
                          color: Colors.orange.shade700, fontSize: 12),
                    ),
                  ),
                ],
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
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(questControllerProvider.notifier)
                  .requestRevision(quest.questId);
            },
            child: const Text('Ya, Minta Revisi'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(
      BuildContext context, WidgetRef ref, QuestModel quest) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Batalkan Quest?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'Quest "${quest.title}" akan dibatalkan dan tidak bisa dikembalikan.',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(questControllerProvider.notifier)
                  .cancelQuest(quest.questId);
              if (context.mounted) context.pop();
            },
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }
}

// ─── Direct Quest Response Card (untuk Expert) ────────────────────────────────

class _DirectQuestResponseCard extends StatelessWidget {
  final QuestModel quest;
  final WidgetRef ref;
  const _DirectQuestResponseCard({required this.quest, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Info card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.08),
                AppColors.primary.withValues(alpha: 0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.person_pin_rounded,
                      color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Quest Langsung Untukmu!',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Seeker memilihmu secara langsung untuk mengerjakan quest ini. '
                'Diskusikan dulu via chat sebelum menerima.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Chat button
        CustomButton(
          text: 'Diskusi via Chat',
          type: ButtonType.outline,
          icon: Icons.chat_outlined,
          onPressed: () => context.pushNamed(
            'chat',
            pathParameters: {'chatId': quest.questId},
            extra: {'questTitle': quest.title},
          ),
        ),
        const SizedBox(height: 12),

        // Terima button
        // SESUDAH
        quest.negoStatus == 'waiting'
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.hourglass_top_rounded,
                        color: Colors.orange.shade700, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Menunggu keputusan seeker...',
                      style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                  ],
                ),
              )
            : quest.expertAccepted
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.hourglass_top_rounded,
                            color: Colors.green.shade700, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Menunggu pembayaran dari seeker...',
                          style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      CustomButton(
                        text: 'Terima Quest',
                        icon: Icons.check_circle_rounded,
                        onPressed: () => _showAcceptDialog(context),
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        text: 'Ajukan Nego Harga',
                        type: ButtonType.outline,
                        icon: Icons.handshake_outlined,
                        onPressed: () => _showNegoDialog(context),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () => _showDeclineDialog(context),
                        icon: const Icon(Icons.cancel_outlined,
                            size: 16, color: Colors.red),
                        label: const Text('Tolak Quest',
                            style: TextStyle(color: Colors.red, fontSize: 13)),
                      ),
                    ],
                  ),
      ],
    );
  }

  void _showAcceptDialog(BuildContext context) {
    final format =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Terima Quest?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text('Biaya yang ditawarkan',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    format.format(quest.finalPrice ?? quest.maxBudget),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Dengan menerima, seeker akan diminta membayar dan kamu mulai mengerjakan setelah pembayaran.',
              style: TextStyle(
                  color: Colors.grey.shade500, fontSize: 12, height: 1.5),
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
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(questControllerProvider.notifier)
                  .acceptDirectQuest(quest.questId, quest.seekerUid);
            },
            child: const Text('Ya, Terima'),
          ),
        ],
      ),
    );
  }

  void _showNegoDialog(BuildContext context) {
    final priceCtrl = TextEditingController();
    final format =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ajukan Nego Harga',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.orange.shade700, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Harga sekarang: ${format.format(quest.finalPrice ?? quest.maxBudget)}',
                      style: TextStyle(
                          color: Colors.orange.shade700, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Harga yang kamu minta (Rp)',
                prefixText: 'Rp ',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Seeker akan mendapat notif dan memutuskan: setuju atau batalkan quest.',
              style: TextStyle(
                  color: Colors.grey.shade500, fontSize: 11, height: 1.5),
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
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final price =
                  int.tryParse(priceCtrl.text.replaceAll('.', '').trim()) ?? 0;
              if (price <= 0) return;
              Navigator.pop(ctx);
              await ref
                  .read(questControllerProvider.notifier)
                  .requestNego(quest.questId, quest.seekerUid, price);
            },
            child: const Text('Kirim Nego'),
          ),
        ],
      ),
    );
  }

  void _showDeclineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tolak Quest?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Quest akan dibatalkan dan seeker akan diberitahu.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(questControllerProvider.notifier)
                  .cancelQuest(quest.questId);
              if (context.mounted) context.pop();
            },
            child: const Text('Ya, Tolak'),
          ),
        ],
      ),
    );
  }
}

// ─── Revision Counter Card ────────────────────────────────────────────────────

class _RevisionCounterCard extends StatelessWidget {
  final int revisionCount;
  final int maxRevisions;
  const _RevisionCounterCard(
      {required this.revisionCount, required this.maxRevisions});

  @override
  Widget build(BuildContext context) {
    final isMaxed = revisionCount >= maxRevisions;
    final color = isMaxed ? Colors.red : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(Icons.refresh, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMaxed ? 'Batas Revisi Habis' : 'Riwayat Revisi',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: color, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  isMaxed
                      ? 'Sudah $revisionCount/$maxRevisions revisi. Selesaikan atau ajukan komplain.'
                      : 'Sudah $revisionCount/$maxRevisions revisi digunakan.',
                  style: TextStyle(
                      color: color.withValues(alpha: 0.8), fontSize: 12),
                ),
              ],
            ),
          ),
          Row(
            children: List.generate(maxRevisions, (i) {
              final used = i < revisionCount;
              return Container(
                margin: const EdgeInsets.only(left: 4),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: used ? color : color.withValues(alpha: 0.2),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Timeline Card ────────────────────────────────────────────────────────────

class _TimelineCard extends StatelessWidget {
  final QuestStatus status;
  final bool isDirect;
  const _TimelineCard({required this.status, this.isDirect = false});

  @override
  Widget build(BuildContext context) {
    final steps = [
      {
        'label': 'Pending',
        'desc': isDirect ? 'Menunggu expert terima' : 'Quest diposting',
        'status': QuestStatus.pending,
      },
      {
        'label': 'Payment',
        'desc': 'Dana di escrow',
        'status': QuestStatus.paid,
      },
      {
        'label': 'Working',
        'desc': 'Expert mengerjakan',
        'status': QuestStatus.working,
      },
      {
        'label': 'Review',
        'desc': 'Menunggu persetujuan',
        'status': QuestStatus.review,
      },
      {
        'label': 'Finished',
        'desc': 'Quest selesai',
        'status': QuestStatus.finished,
      },
    ];

    final currentIndex = steps.indexWhere((s) => s['status'] == status);
    final isCancelled = status == QuestStatus.cancelled;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Progress Quest',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(width: 8),
              if (isDirect)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('DIRECT',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              if (isCancelled) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('DIBATALKAN',
                      style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          if (isCancelled)
            Center(
              child: Column(
                children: [
                  Icon(Icons.cancel, size: 48, color: Colors.red.shade300),
                  const SizedBox(height: 8),
                  Text('Quest telah dibatalkan',
                      style: TextStyle(color: Colors.red.shade400)),
                ],
              ),
            )
          else
            ...List.generate(steps.length, (index) {
              final isCompleted = index <= currentIndex;
              final isCurrent = index == currentIndex;
              final isLast = index == steps.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppColors.primary
                              : Colors.grey.shade200,
                          shape: BoxShape.circle,
                          border: isCurrent
                              ? Border.all(color: AppColors.primary, width: 2)
                              : null,
                        ),
                        child: isCompleted
                            ? const Icon(Icons.check,
                                size: 16, color: Colors.white)
                            : null,
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 36,
                          color: isCompleted
                              ? AppColors.primary
                              : Colors.grey.shade200,
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            steps[index]['label'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isCompleted ? Colors.black87 : Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            steps[index]['desc'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isCurrent ? AppColors.primary : Colors.grey,
                            ),
                          ),
                          if (isCurrent) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('Status Sekarang',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }
}

// ─── Detail Card ──────────────────────────────────────────────────────────────

class _DetailCard extends StatelessWidget {
  final QuestModel quest;
  final ProfileModel? expertProfile;
  const _DetailCard({required this.quest, this.expertProfile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ID: ${quest.questId.substring(0, 8).toUpperCase()}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              StatusChip(status: quest.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(quest.title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.person_outline,
            label: 'Expert',
            value: expertProfile?.displayName ??
                (quest.expertUid != null ? 'Memuat...' : 'Menunggu Expert'),
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.calendar_today,
            label: 'Deadline',
            value: DateFormat('dd MMM yyyy').format(quest.deadline),
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.lock_outline,
            label: 'Dana',
            value: quest.status == QuestStatus.pending
                ? 'Belum Dibayar'
                : 'Terkunci di Escrow',
          ),
        ],
      ),
    );
  }
}

// ─── Deadline Card ────────────────────────────────────────────────────────────

class _DeadlineCard extends StatelessWidget {
  final DateTime deadline;
  const _DeadlineCard({required this.deadline});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final diff = deadline.difference(now);
    final isOverdue = diff.isNegative;
    final days = diff.inDays.abs();
    final hours = diff.inHours.remainder(24).abs();
    final color = isOverdue
        ? Colors.red
        : diff.inHours < 24
            ? Colors.orange
            : Colors.green;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(isOverdue ? Icons.timer_off : Icons.timer,
              color: color, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isOverdue ? 'Deadline Terlewat!' : 'Sisa Waktu',
                  style: TextStyle(
                      color: color, fontSize: 12, fontWeight: FontWeight.w500)),
              Text(
                isOverdue
                    ? '$days hari $hours jam yang lalu'
                    : '$days hari $hours jam lagi',
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Budget Card ──────────────────────────────────────────────────────────────

class _BudgetCard extends StatelessWidget {
  final QuestModel quest;
  const _BudgetCard({required this.quest});

  @override
  Widget build(BuildContext context) {
    final format =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                const Icon(Icons.payments_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                quest.finalPrice != null ? 'Harga Final' : 'Budget Target',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              Text(
                quest.finalPrice != null
                    ? format.format(quest.finalPrice)
                    : '${format.format(quest.minBudget)} - ${format.format(quest.maxBudget)}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary),
              ),
            ],
          ),
          if (quest.isUrgent) ...[
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.bolt, size: 14, color: Colors.red.shade700),
                  Text('URGENT',
                      style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Info Row ─────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Text('$label: ',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        Expanded(
          child: Text(value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
