// lib/features/profile/screens/widgets/expert_rank_card.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../shared/models/models.dart';
import 'profile_card.dart';

class ExpertRankCard extends StatelessWidget {
  final UserModel? user;
  const ExpertRankCard({super.key, required this.user});

  static const _thresholds = {
    ExpertRank.newcomer: 3,
    ExpertRank.taskRunner: 8,
    ExpertRank.juniorWorker: 15,
    ExpertRank.skilledWorker: 25,
    ExpertRank.professional: 50,
    ExpertRank.seniorProfessional: 100,
    ExpertRank.specialist: 200,
    ExpertRank.leadSpecialist: 350,
    ExpertRank.topProfessional: 500,
    ExpertRank.industryMaster: 750,
    ExpertRank.legendaryWorker: 1000,
  };

  @override
  Widget build(BuildContext context) {
    if (user == null) return const SizedBox(height: 8);
    final rank = user!.rank;
    final isMax = rank == ExpertRank.legendaryWorker;
    final total = _thresholds[rank] ?? 3;
    final done = user!.totalQuestsDone;
    final prog = (done / total).clamp(0.0, 1.0);

    String nextName() {
      final idx = ExpertRank.values.indexOf(rank);
      return idx < ExpertRank.values.length - 1
          ? ExpertRank.values[idx + 1].displayName
          : 'Max';
    }

    return ProfileCard(
      child: Row(
        children: [
          SizedBox(
            width: 52, height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: prog,
                  strokeWidth: 5,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
                Text('${(prog * 100).toInt()}%',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMax ? '👑 Rank Tertinggi!' : 'Menuju ${nextName()}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF1A1A2E)),
                ),
                const SizedBox(height: 4),
                Text(
                  isMax
                      ? '$done proyek selesai total'
                      : '$done dari $total proyek · ${total - done} lagi',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: prog,
                    minHeight: 6,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stats Row ────────────────────────────────────────────────────────────────
class ExpertStatsRow extends StatelessWidget {
  final UserModel? user;
  final bool isMe;
  const ExpertStatsRow({super.key, required this.user, required this.isMe});

  String _fmt(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}jt';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}rb';
    return v.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          _Stat(icon: Icons.work_rounded, value: '${user!.totalQuestsDone}',
              label: 'Proyek', color: AppColors.primary),
          const SizedBox(width: 8),
          _Stat(
            icon: Icons.star_rounded,
            value: user!.ratingAvg > 0 ? user!.ratingAvg.toStringAsFixed(1) : '-',
            label: 'Rating',
            color: const Color(0xFFE6A817),
            suffix: user!.ratingAvg > 0 ? '⭐' : '',
          ),
          const SizedBox(width: 8),
          _Stat(icon: Icons.bolt_rounded, value: '${user!.expPoints}',
              label: 'EXP', color: const Color(0xFF7B1FA2)),
          if (isMe) ...[
            const SizedBox(width: 8),
            _Stat(
              icon: Icons.account_balance_wallet_rounded,
              value: 'Rp ${_fmt(user!.saldoActive)}',
              label: 'Saldo',
              color: const Color(0xFF00838F),
              small: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  final String suffix;
  final bool small;
  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.suffix = '',
    this.small = false,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: color.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 15),
              ),
              const SizedBox(height: 7),
              Text('$value$suffix',
                  style: TextStyle(
                      color: const Color(0xFF1A1A2E),
                      fontWeight: FontWeight.bold,
                      fontSize: small ? 10 : 13),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
            ],
          ),
        ),
      );
}
