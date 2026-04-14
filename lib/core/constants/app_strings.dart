// lib/core/constants/app_strings.dart

abstract class AppStrings {
  // ─── App ──────────────────────────────────────────────────────
  static const String appName = 'CariQuest';
  static const String tagline = 'Dari Skill Jadi Cuan';
  static const String taglineEn = 'Turn Your Skill Into Real Earning';

  // ─── Auth ─────────────────────────────────────────────────────
  static const String login = 'Masuk';
  static const String register = 'Daftar';
  static const String logout = 'Keluar';
  static const String daftarSebagai = 'Daftar Sebagai';
  static const String expert = 'Expert';
  static const String seeker = 'Seeker';
  static const String expertDesc = 'Mahasiswa aktif USK yang ingin menawarkan skill';
  static const String seekerDesc = 'Individu atau bisnis yang butuh jasa profesional';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Konfirmasi Password';
  static const String phoneNumber = 'Nomor WhatsApp';
  static const String verifyEmail = 'Verifikasi Email';
  static const String otpSent = 'Kode OTP telah dikirim ke email kamu';
  static const String enterOtp = 'Masukkan Kode OTP';
  static const String resendOtp = 'Kirim Ulang OTP';
  static const String uploadKtm = 'Upload Foto KTM';
  static const String uploadKtp = 'Upload Foto KTP';
  static const String pendingVerification = 'Menunggu Verifikasi';
  static const String pendingVerificationDesc =
      'Tim kami sedang memverifikasi akun kamu. Proses ini memakan waktu 1x24 jam.';

  // ─── Quest ──────────────────────────────────────────────────────
  static const String questFeed = 'Quest Feed';
  static const String postQuest = 'Buat Quest';
  static const String applyQuest = 'Lamar Quest';
  static const String fastSearch = 'Cari Talent';
  static const String questTitle = 'Judul Quest';
  static const String questDesc = 'Deskripsi Pekerjaan';
  static const String deadline = 'Deadline';
  static const String budget = 'Budget';
  static const String urgent = 'URGENT';
  static const String urgentTag = '🔴 URGENT — Deadline < 24 Jam';

  // ─── Status ───────────────────────────────────────────────────
  static const String statusPending = 'Pending';
  static const String statusPaid = 'Dibayar';
  static const String statusWorking = 'Dikerjakan';
  static const String statusReview = 'Review';
  static const String statusFinished = 'Selesai';
  static const String statusDisputed = 'Sengketa';

  // ─── Rank ─────────────────────────────────────────────────────
  static const String rankBronze = 'Bronze';
  static const String rankSkilled = 'Skilled';
  static const String rankVeteran = 'Veteran';
  static const String rankLegend = 'Legend';
  static const String rankMythic = 'Mythic';

  // ─── Payment ──────────────────────────────────────────────────
  static const String payment = 'Pembayaran';
  static const String paymentMethod = 'Metode Pembayaran';
  static const String qris = 'QRIS';
  static const String virtualAccount = 'Virtual Account';
  static const String escrowLocked = 'Dana Terkunci';
  static const String escrowReleased = 'Dana Dicairkan';
  static const String paymentSuccess = 'Pembayaran Berhasil!';

  // ─── Review ───────────────────────────────────────────────────
  static const String acceptWork = 'Terima Hasil';
  static const String requestRevision = 'Minta Revisi';
  static const String rateExpert = 'Beri Rating Expert';
  static const String rateSeeker = 'Beri Rating Klien';

  // ─── Wallet ───────────────────────────────────────────────────
  static const String saldo = 'Saldo';
  static const String saldoAktif = 'Saldo Aktif';
  static const String saldoPending = 'Saldo Pending';
  static const String withdraw = 'Tarik Dana';
  static const String withdrawMin = 'Minimal penarikan Rp 25.000';

  // ─── Error ────────────────────────────────────────────────────
  static const String errorGeneric = 'Terjadi kesalahan. Coba lagi.';
  static const String errorNetwork = 'Koneksi bermasalah. Periksa internet kamu.';
  static const String errorEmailNotStudent =
      'Gunakan email @mhs.usk.ac.id untuk daftar sebagai Expert';
  static const String errorBannedKeyword =
      'Konten tidak diizinkan. Quest ditolak karena mengandung kata terlarang.';

  // ─── Misc ─────────────────────────────────────────────────────
  static const String loading = 'Memuat...';
  static const String noData = 'Belum ada data';
  static const String save = 'Simpan';
  static const String cancel = 'Batal';
  static const String confirm = 'Konfirmasi';
  static const String next = 'Lanjut';
  static const String back = 'Kembali';
  static const String done = 'Selesai';
  static const String skip = 'Lewati';
}
