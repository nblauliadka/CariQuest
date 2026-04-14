// lib/features/profile/screens/widgets/profile_card.dart
import 'package:flutter/material.dart';

/// Generic card container yang dipakai semua widget profil
class ProfileCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? action;
  const ProfileCard({super.key, required this.child, this.title, this.action});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title!,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF1A1A2E))),
                  if (action != null) action!,
                ],
              ),
              const SizedBox(height: 14),
            ],
            child,
          ],
        ),
      );
}
