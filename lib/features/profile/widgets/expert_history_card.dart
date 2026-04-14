// lib/features/profile/screens/widgets/expert_history_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// cloud_firestore removed — using mock data
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../shared/models/models.dart';
import 'profile_card.dart';

final expertQuestHistoryProvider =
    FutureProvider.family<List<QuestModel>, String>((ref, uid) async {
  if (uid.isEmpty) return [];
  final db = MockData.instance;
  return db.quests
      .where((q) => q.expertUid == uid && q.status == QuestStatus.finished)
      .toList()
    ..sort((a, b) => (b.completedAt ?? b.createdAt)
        .compareTo(a.completedAt ?? a.createdAt));
});

final seekerNameProvider =
    FutureProvider.family<String, String>((ref, uid) async {
  if (uid.isEmpty) return '****';
  final db = MockData.instance;
  try {
    final user = db.users.firstWhere((u) => u.uid == uid);
    final name = user.displayName;
    if (name.length >= 2) return '${name.substring(0, 2)}***';
  } catch (_) {}
  return '****';
});

class ExpertHistoryCard extends ConsumerWidget {
  final String expertUid;
  const ExpertHistoryCard({super.key, required this.expertUid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(expertQuestHistoryProvider(expertUid));
    return ProfileCard(
      title: '📋 Riwayat Kerja',
      child: historyAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (_, __) =>
            Text('Gagal memuat', style: TextStyle(color: Colors.grey.shade400)),
        data: (quests) {
          if (quests.isEmpty) {
            return Text('Belum ada riwayat kerja',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14));
          }
          return Column(
            children: quests.take(10).map((q) => _QuestHistoryTile(quest: q)).toList(),
          );
        },
      ),
    );
  }
}

class _QuestHistoryTile extends ConsumerWidget {
  final QuestModel quest;
  const _QuestHistoryTile({required this.quest});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientName = ref.watch(seekerNameProvider(quest.seekerUid)).value ?? '••••';

    return GestureDetector(
      onTap: () => _showDetail(context, quest, clientName),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: Colors.green, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(quest.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF1A1A2E)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('Klien: $clientName',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Selesai',
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 3),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Detail ', style: TextStyle(color: AppColors.primary, fontSize: 10)),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 9, color: AppColors.primary),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, QuestModel quest, String clientName) {
    String fmtPrice(int? price) {
      if (price == null || price == 0) return 'Rp ••.•••';
      if (price >= 1000000) return 'Rp ${(price / 1000000).toStringAsFixed(1)}jt';
      if (price >= 1000) return 'Rp ${(price / 1000).toStringAsFixed(0)}rb';
      return 'Rp $price';
    }

    String fmtDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(quest.title,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E))),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('✅ Selesai',
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(quest.description,
                style: TextStyle(
                    color: Colors.grey.shade600, fontSize: 13, height: 1.5),
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
            const Divider(height: 28),
            _DetailGrid(items: [
              _Item(Icons.person_outline_rounded, 'Klien', clientName, AppColors.primary),
              _Item(Icons.attach_money_rounded, 'Harga Deal', fmtPrice(quest.finalPrice), Colors.green),
              const _Item(Icons.star_rounded, 'Rating', '—', Color(0xFFE6A817)),
              _Item(Icons.loop_rounded, 'Revisi', '${quest.revisionCount}x', Colors.orange),
              _Item(Icons.calendar_today_rounded, 'Deadline', fmtDate(quest.deadline), Colors.blue),
              _Item(Icons.check_circle_rounded, 'Selesai',
                  quest.completedAt != null ? fmtDate(quest.completedAt!) : '—', Colors.teal),
            ]),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF3F2F8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Tutup',
                    style: TextStyle(
                        color: Color(0xFF1A1A2E), fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailGrid extends StatelessWidget {
  final List<_Item> items;
  const _DetailGrid({required this.items});

  @override
  Widget build(BuildContext context) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.5),
        itemBuilder: (_, i) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: items[i].color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: items[i].color.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Icon(items[i].icon, color: items[i].color, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(items[i].label,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                    Text(items[i].value,
                        style: TextStyle(
                            color: items[i].color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _Item {
  final IconData icon;
  final String label, value;
  final Color color;
  const _Item(this.icon, this.label, this.value, this.color);
}
