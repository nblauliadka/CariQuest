// lib/shared/widgets/rank_badge.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_enums.dart';

class RankBadge extends StatelessWidget {
  final ExpertRank rank;
  final bool compact;

  const RankBadge({
    super.key,
    required this.rank,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getRankColor(rank);
    final icon = _getRankIcon(rank);
    final text = rank.displayName.toUpperCase();

    if (compact) {
      return Tooltip(
        message: rank.displayName,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(ExpertRank rank) {
    switch (rank) {
      case ExpertRank.newcomer:
        return const Color(0xFF9E9E9E); // Abu
      case ExpertRank.taskRunner:
        return const Color(0xFF8BC34A); // Hijau muda
      case ExpertRank.juniorWorker:
        return const Color(0xFF03A9F4); // Biru
      case ExpertRank.skilledWorker:
        return const Color(0xFFCD7F32); // Bronze
      case ExpertRank.professional:
        return const Color(0xFFFFC107); // Gold
      case ExpertRank.seniorProfessional:
        return const Color(0xFF00BCD4); // Cyan
      case ExpertRank.specialist:
        return const Color(0xFF9C27B0); // Purple
      case ExpertRank.leadSpecialist:
        return const Color(0xFFE91E63); // Pink
      case ExpertRank.topProfessional:
        return const Color(0xFFFF5722); // Deep orange
      case ExpertRank.industryMaster:
        return const Color(0xFF3F51B5); // Indigo
      case ExpertRank.legendaryWorker:
        return const Color(0xFFFFD700); // Legendary gold
    }
  }

  IconData _getRankIcon(ExpertRank rank) {
    switch (rank) {
      case ExpertRank.newcomer:
        return Icons.person_outline;
      case ExpertRank.taskRunner:
        return Icons.directions_run;
      case ExpertRank.juniorWorker:
        return Icons.star_border;
      case ExpertRank.skilledWorker:
        return Icons.star_half;
      case ExpertRank.professional:
        return Icons.star;
      case ExpertRank.seniorProfessional:
        return Icons.local_fire_department;
      case ExpertRank.specialist:
        return Icons.diamond;
      case ExpertRank.leadSpecialist:
        return Icons.military_tech;
      case ExpertRank.topProfessional:
        return Icons.emoji_events;
      case ExpertRank.industryMaster:
        return Icons.workspace_premium;
      case ExpertRank.legendaryWorker:
        return Icons.auto_awesome;
    }
  }
}
