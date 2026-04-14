// lib/shared/widgets/user_avatar.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_enums.dart';

class UserAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final bool isVerifiedPro;
  final ExpertRank? rank;

  const UserAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 24.0,
    this.isVerifiedPro = false,
    this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey.shade200,
          backgroundImage:
              imageUrl.isNotEmpty ? CachedNetworkImageProvider(imageUrl) : null,
          child: imageUrl.isEmpty
              ? Icon(Icons.person, size: radius, color: Colors.grey.shade500)
              : null,
        ),

        // Verified Pro Badge
        if (isVerifiedPro)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified,
                color: AppColors.primary,
                size: 16,
              ),
            ),
          ),

        // Rank Indicator
        if (rank != null)
          Positioned(
            bottom: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getRankIcon(rank!),
                color: _getRankColor(rank!),
                size: 14,
              ),
            ),
          ),
      ],
    );
  }

  Color _getRankColor(ExpertRank rank) {
    switch (rank) {
      case ExpertRank.newcomer:
        return const Color(0xFF9E9E9E);
      case ExpertRank.taskRunner:
        return const Color(0xFF8BC34A);
      case ExpertRank.juniorWorker:
        return const Color(0xFF03A9F4);
      case ExpertRank.skilledWorker:
        return const Color(0xFFCD7F32);
      case ExpertRank.professional:
        return const Color(0xFFFFC107);
      case ExpertRank.seniorProfessional:
        return const Color(0xFF00BCD4);
      case ExpertRank.specialist:
        return const Color(0xFF9C27B0);
      case ExpertRank.leadSpecialist:
        return const Color(0xFFE91E63);
      case ExpertRank.topProfessional:
        return const Color(0xFFFF5722);
      case ExpertRank.industryMaster:
        return const Color(0xFF3F51B5);
      case ExpertRank.legendaryWorker:
        return const Color(0xFFFFD700);
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
