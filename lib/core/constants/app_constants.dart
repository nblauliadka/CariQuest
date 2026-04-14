// lib/core/constants/app_constants.dart

abstract class AppConstants {
  // ─── App Info ──────────────────────────────────────────────────
  static const String appName = 'CariQuest';
  static const String appTagline = 'Dari Skill Jadi Cuan';
  static const String appVersion = '1.0.0';
  static const String expertEmailDomain = '@mhs.usk.ac.id';
  static const String devEmailDomain = '@dev.cq';
  static const String universityName = 'Universitas Syiah Kuala';

  // ─── Rank Thresholds ───────────────────────────────────────────
  static const int bronzeMinProjects = 0;
  static const int skilledMinProjects = 3;
  static const double skilledMinRating = 4.0;
  static const int veteranMinProjects = 10;
  static const double veteranMinRating = 4.5;
  static const int legendMinProjects = 25;
  static const double legendMinRating = 4.7;
  static const int mythicMinProjects = 50;
  static const double mythicMinRating = 4.8;

  // ─── Platform Fee ──────────────────────────────────────────────
  static const double standardFeeRate = 0.08; // 8%
  static const double premiumFeeRate = 0.05; // 5% (Legend/Mythic)

  // ─── Urgent Tag ────────────────────────────────────────────────
  static const int urgentDeadlineHours = 24;
  static const double urgentMarkupMin = 0.30; // 30%
  static const double urgentMarkupMax = 0.50; // 50%

  // ─── Auto-Accept ───────────────────────────────────────────────
  static const int autoAcceptHours = 72; // 3x24 jam

  // ─── Withdraw ──────────────────────────────────────────────────
  static const int withdrawMinAmount = 25000; // Rp 25.000
  static const int withdrawMaxPerDay = 2000000; // Rp 2.000.000
  static const int withdrawFeeBankTransfer = 2500;
  static const int withdrawFeeEwallet = 1000;

  // ─── Revision ──────────────────────────────────────────────────
  static const int maxRevisions = 2;

  // ─── Cancellation ──────────────────────────────────────────────
  static const double cancelBefore = 1.0; // 100% refund
  static const double cancelBelow50 = 0.30; // expert gets 30%
  static const double cancelAbove50 = 0.60; // expert gets 60%
  static const double cancelAfterSubmit = 1.0; // expert gets 100%

  // ─── Boost Packages ────────────────────────────────────────────
  static const int boostLitePrice = 5000;
  static const int boostLiteDays = 3;
  static const int boostProPrice = 12000;
  static const int boostProDays = 7;
  static const int boostElitePrice = 20000;
  static const int boostEliteDays = 14;

  // ─── Verified Pro Badge ────────────────────────────────────────
  static const int verifiedProActivationPrice = 15000;
  static const int verifiedProRenewalPrice = 10000;
  static const int verifiedProRenewalMonths = 6;

  // ─── Featured Quest ────────────────────────────────────────────
  static const int featuredQuestPrice = 10000;
  static const int featuredQuestDays = 3;
  static const int featuredQuestProPrice = 25000;
  static const int featuredQuestProDays = 7;

  // ─── Anti-Fraud Keyword List ───────────────────────────────────
  static const List<String> bannedKeywords = [
    'skripsi',
    'tugas akhir',
    ' ta ',
    'joki',
    'ujian',
    'kerjakan ujian',
    'jawab soal ujian',
  ];

  // ─── Firestore Collections ─────────────────────────────────────
  static const String colUsers = 'users';
  static const String colProfiles = 'profiles';
  static const String colQuests = 'quests';
  static const String colBids = 'bids'; // Subcollection of quests
  static const String colTransactions = 'transactions';
  static const String colReviews = 'reviews';
  static const String colDisputes = 'disputes';
  static const String colWithdrawals = 'withdrawals';
  // Midtrans Sandbox (Placeholders - TODO: Move to .env for production)
  static const String midtransClientKey = 'SB-Mid-client-xxxxxxxxxx';
  static const String midtransServerKey = 'SB-Mid-server-xxxxxxxxxx';
  static const String midtransBaseUrl =
      'https://app.sandbox.midtrans.com/snap/v1/transactions';
  static const String colBoosts = 'boosts';
  static const String colChats = 'chats';
  static const String colMessages = 'messages';
  static const String colNotifications = 'notifications';

  // ─── SharedPreferences Keys ────────────────────────────────────
  static const String prefThemeMode = 'theme_mode';
  static const String prefUserRole = 'user_role';
  static const String prefOnboardingDone = 'onboarding_done';
  static const String prefDeviceId = 'device_id';

  // ─── Timeouts & Durations ─────────────────────────────────────
  static const Duration otpResendCooldown = Duration(seconds: 60);
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration splashDuration = Duration(milliseconds: 2500);

  // ─── Pagination ───────────────────────────────────────────────
  static const int questPageSize = 10;
  static const int seekerPageSize = 10;
}
