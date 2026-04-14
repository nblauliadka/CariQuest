// lib/core/constants/app_colors.dart

import 'package:flutter/material.dart';

/// CariQuest Brand Colors
/// Primary: Deep Purple #6C2BD9
/// Accent:  Gold         #F5A623
abstract class AppColors {
  // ─── Brand ───────────────────────────────────────────────────
  static const Color primary = Color(0xFF6C2BD9);
  static const Color primaryLight = Color(0xFF9B6EE8);
  static const Color primaryDark = Color(0xFF4A1A9E);
  static const Color primaryContainer = Color(0xFFEDE8FB);

  static const Color gold = Color(0xFFF5A623);
  static const Color goldLight = Color(0xFFFFC654);
  static const Color goldDark = Color(0xFFC67D00);
  static const Color goldContainer = Color(0xFFFFF3D9);

  // ─── Semantic ─────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ─── Neutral ──────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF0A0A0A);
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // ─── Background ───────────────────────────────────────────────
  static const Color background = Color(0xFFF8F7FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F0FF);
  static const Color cardBg = Color(0xFFFFFFFF);

  // ─── Dark Mode ────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0D0B14);
  static const Color darkSurface = Color(0xFF1A1625);
  static const Color darkCard = Color(0xFF241E35);
  static const Color darkBorder = Color(0xFF2D2640);

  // ─── Rank Colors ──────────────────────────────────────────────
  static const Color rankBronze = Color(0xFFCD7F32);
  static const Color rankSilver = Color(0xFFC0C0C0); // Skilled
  static const Color rankGold = Color(0xFFFFD700);   // Veteran
  static const Color rankPlatinum = Color(0xFFE5E4E2); // Legend
  static const Color rankMythic = Color(0xFF8B0000);  // Mythic

  // ─── Status Colors ────────────────────────────────────────────
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusPaid = Color(0xFF3B82F6);
  static const Color statusWorking = Color(0xFF8B5CF6);
  static const Color statusReview = Color(0xFFF97316);
  static const Color statusFinished = Color(0xFF22C55E);
  static const Color statusDisputed = Color(0xFFEF4444);

  // ─── Gradients ────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B47F0), Color(0xFF6C2BD9), Color(0xFF4A1A9E)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFC654), Color(0xFFF5A623), Color(0xFFC67D00)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C2BD9), Color(0xFF9B6EE8), Color(0xFFF5A623)],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF241E35), Color(0xFF1A1625)],
  );

  static const LinearGradient mythicGradient = LinearGradient(
    colors: [Color(0xFF8B0000), Color(0xFFFF4500), Color(0xFFFFD700)],
  );
}
