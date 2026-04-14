// lib/core/constants/app_enums.dart

/// User role in CariQuest
enum UserRole {
  expert,
  seeker,
  admin,
}

/// Expert rank tiers
/// Rank 1-5 visible sekarang, rank 6-11 unlock bertahap
enum ExpertRank {
  newcomer, // 0 EXP
  taskRunner, // 200 EXP
  juniorWorker, // 600 EXP
  skilledWorker, // 1,200 EXP
  professional, // 2,500 EXP
  // ── Hidden ranks (unlock ketika ada yang capai rank sebelumnya) ──
  seniorProfessional, // 10,000 EXP
  specialist, // 30,000 EXP
  leadSpecialist, // 80,000 EXP
  topProfessional, // 200,000 EXP
  industryMaster, // 500,000 EXP
  legendaryWorker, // 1,000,000 EXP
}

/// Quest/Order lifecycle status
enum QuestStatus {
  pending, // Quest posted, belum bayar
  paid, // Sudah bayar, dana di escrow
  working, // Expert sedang kerjakan
  review, // File sudah dikirim, menunggu review
  finished, // Selesai & rating done
  disputed, // Sedang Adu Banding
  cancelled, // Dibatalkan
}

/// Escrow status
enum EscrowStatus {
  locked,
  released,
  refunded,
  partialRefund,
}

/// Payment method
enum PaymentMethod {
  qris,
  bankTransfer,
  virtualAccount,
}

/// Withdrawal destination
enum WithdrawDestination {
  bri,
  bca,
  mandiri,
  gopay,
  ovo,
  dana,
  shopeePay,
}

/// Boost package type
enum BoostPackage {
  lite, // Rp 5.000 / 3 hari
  pro, // Rp 12.000 / 7 hari
  elite, // Rp 20.000 / 14 hari
}

/// Featured Quest package
enum FeaturedQuestPackage {
  standard, // Rp 10.000 / 3 hari
  pro, // Rp 25.000 / 7 hari
}

/// Dispute status
enum DisputeStatus {
  open,
  inReview,
  resolved,
}

/// Notification type
enum NotificationType {
  bid,
  accepted,
  rejected,
  paid,
  working,
  submitted,
  finished,
  cancelled,
  dispute,
  rankUp,
  boost,
  system,
  general,
}

/// App theme mode
enum AppThemeMode {
  light,
  dark,
  system,
}

// ─── ExpertRank Extensions ────────────────────────────────────────────────────

extension ExpertRankX on ExpertRank {
  String get displayName {
    switch (this) {
      case ExpertRank.newcomer:
        return 'Newcomer';
      case ExpertRank.taskRunner:
        return 'Task Runner';
      case ExpertRank.juniorWorker:
        return 'Junior Worker';
      case ExpertRank.skilledWorker:
        return 'Skilled Worker';
      case ExpertRank.professional:
        return 'Professional';
      case ExpertRank.seniorProfessional:
        return 'Senior Professional';
      case ExpertRank.specialist:
        return 'Specialist';
      case ExpertRank.leadSpecialist:
        return 'Lead Specialist';
      case ExpertRank.topProfessional:
        return 'Top Professional';
      case ExpertRank.industryMaster:
        return 'Industry Master';
      case ExpertRank.legendaryWorker:
        return 'Legendary Worker';
    }
  }

  /// EXP minimum untuk rank ini
  int get minExp {
    switch (this) {
      case ExpertRank.newcomer:
        return 0;
      case ExpertRank.taskRunner:
        return 200;
      case ExpertRank.juniorWorker:
        return 600;
      case ExpertRank.skilledWorker:
        return 1200;
      case ExpertRank.professional:
        return 2500;
      case ExpertRank.seniorProfessional:
        return 10000;
      case ExpertRank.specialist:
        return 30000;
      case ExpertRank.leadSpecialist:
        return 80000;
      case ExpertRank.topProfessional:
        return 200000;
      case ExpertRank.industryMaster:
        return 500000;
      case ExpertRank.legendaryWorker:
        return 1000000;
    }
  }

  /// EXP untuk rank berikutnya (null kalau sudah max)
  int? get nextExp {
    final next = nextRank;
    return next?.minExp;
  }

  /// Rank berikutnya
  ExpertRank? get nextRank {
    const all = ExpertRank.values;
    final idx = all.indexOf(this);
    if (idx < all.length - 1) return all[idx + 1];
    return null;
  }

  /// Apakah rank ini visible (rank 1-5)
  bool get isVisible {
    return index <= ExpertRank.professional.index;
  }

  /// Platform fee rate
  double get platformFeeRate {
    if (index >= ExpertRank.specialist.index) return 0.04; // 4%
    if (index >= ExpertRank.seniorProfessional.index) return 0.05; // 5%
    if (index >= ExpertRank.professional.index) return 0.06; // 6%
    return 0.08; // 8%
  }
}

// ─── QuestStatus Extensions ───────────────────────────────────────────────────

extension QuestStatusX on QuestStatus {
  String get displayName {
    switch (this) {
      case QuestStatus.pending:
        return 'Pending';
      case QuestStatus.paid:
        return 'Dibayar';
      case QuestStatus.working:
        return 'Dikerjakan';
      case QuestStatus.review:
        return 'Review';
      case QuestStatus.finished:
        return 'Selesai';
      case QuestStatus.disputed:
        return 'Sengketa';
      case QuestStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  int get stepIndex {
    switch (this) {
      case QuestStatus.pending:
        return 0;
      case QuestStatus.paid:
        return 1;
      case QuestStatus.working:
        return 2;
      case QuestStatus.review:
        return 3;
      case QuestStatus.finished:
        return 4;
      default:
        return 0;
    }
  }
}
