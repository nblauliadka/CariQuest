// lib/core/mock/mock_data.dart

import 'dart:async';
import '../../shared/models/models.dart';
import '../constants/app_enums.dart';
import 'package:uuid/uuid.dart';

class MockData {
  static final MockData instance = MockData._init();
  MockData._init();

  // Core Data Streams
  final _usersController = StreamController<List<UserModel>>.broadcast();
  final _profilesController = StreamController<List<ProfileModel>>.broadcast();
  final _questsController = StreamController<List<QuestModel>>.broadcast();
  final _notificationsController = StreamController<List<NotificationModel>>.broadcast();
  final _walletsController = StreamController<List<WithdrawalModel>>.broadcast();

  // In-Memory Storage
  List<UserModel> users = [];
  List<ProfileModel> profiles = [];
  List<QuestModel> quests = [];
  List<NotificationModel> notifications = [];
  List<WithdrawalModel> withdrawals = [];
  List<BidModel> bids = [];

  // Stream Getters
  Stream<List<UserModel>> get usersStream => _usersController.stream;
  Stream<List<ProfileModel>> get profilesStream => _profilesController.stream;
  Stream<List<QuestModel>> get questsStream => _questsController.stream;
  Stream<List<NotificationModel>> get notificationsStream => _notificationsController.stream;

  void emitUsers() => _usersController.add(List.from(users));
  void emitProfiles() => _profilesController.add(List.from(profiles));
  void emitQuests() => _questsController.add(List.from(quests));
  void emitNotifications() => _notificationsController.add(List.from(notifications));

  void initDemoData() {
    final now = DateTime.now();

    // 1. Users
    final expertUid = 'demo_expert_1';
    final seekerUid = 'demo_seeker_1';
    final adminUid = 'demo_admin_1';

    users = [
      UserModel(
        uid: adminUid,
        role: UserRole.admin,
        email: 'admin@demo.com',
        phone: '08000000000',
        displayName: 'System Admin',
        isEmailVerified: true,
        isKtmVerified: true,
        isKtpVerified: true,
        createdAt: now.subtract(const Duration(days: 300)),
        lastActive: now,
      ),
      UserModel(
        uid: expertUid,
        role: UserRole.expert,
        email: 'expert@demo.com',
        phone: '08123456789',
        displayName: 'Aldi Firmansyah',
        nim: '2108107010001',
        faculty: 'MIPA',
        major: 'Informatika',
        isEmailVerified: true,
        isKtmVerified: true,
        // Mock MVP showcase: treat demo accounts as fully verified/active.
        isKtpVerified: true,
        rank: ExpertRank.skilledWorker,
        expPoints: 1350,
        totalQuestsDone: 12,
        ratingAvg: 4.8,
        ratingCount: 15,
        saldoActive: 250000,
        saldoPending: 0,
        createdAt: now.subtract(const Duration(days: 30)),
        lastActive: now,
      ),
      UserModel(
        uid: seekerUid,
        role: UserRole.seeker,
        email: 'seeker@demo.com',
        phone: '08987654321',
        displayName: 'Bunga Pratiwi',
        isEmailVerified: true,
        // Mock MVP showcase: treat demo accounts as fully verified/active.
        isKtmVerified: true,
        isKtpVerified: true,
        createdAt: now.subtract(const Duration(days: 20)),
        lastActive: now,
      ),
    ];

    // 2. Profiles
    profiles = [
      ProfileModel(
        uid: expertUid,
        displayName: 'Aldi Firmansyah',
        bio: 'Mobile Developer & UI Designer. Mengerjakan Flutter & Figma.',
        skillTags: ['Flutter', 'UI/UX', 'Figma', 'Dart'],
        isVerifiedPro: true,
      ),
      ProfileModel(
        uid: seekerUid,
        displayName: 'Bunga Pratiwi',
        bio: 'Mahasiswa Manajemen yang butuh bantuan TA.',
      ),
    ];

    // 3. Quests
    final q1 = const Uuid().v4();
    final q2 = const Uuid().v4();
    final q3 = const Uuid().v4();
    final q4 = const Uuid().v4();
    final q5 = const Uuid().v4();

    quests = [
      QuestModel(
        questId: q1,
        seekerUid: seekerUid,
        title: 'Buat Desain UI Mobile App',
        description: 'Butuh 5 screen design untuk aplikasi e-commerce.',
        jobdeskDetail: '- Login\n- Home\n- Cart\n- Checkout\n- Profile',
        deadline: now.add(const Duration(days: 3)),
        minBudget: 150000,
        maxBudget: 300000,
        status: QuestStatus.pending,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      QuestModel(
        questId: q2,
        seekerUid: seekerUid,
        expertUid: expertUid,
        title: 'Bantu Kerjain Laporan Penelitian',
        description: 'Analisis data statistik pakai SPSS.',
        jobdeskDetail: 'Semua data sudah ada, tinggal diolah dan dibaca hasilnya.',
        deadline: now.add(const Duration(days: 1)),
        minBudget: 50000,
        maxBudget: 100000,
        finalPrice: 75000,
        status: QuestStatus.working,
        isUrgent: true,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      QuestModel(
        questId: q3,
        seekerUid: seekerUid,
        expertUid: expertUid,
        title: 'Edit Video Presentasi Tugas Akhir',
        description: 'Potong-potong video dan tambahin subtitle.',
        jobdeskDetail: 'Durasi video awal 15 menit, dipotong jadi 5 menit.',
        deadline: now.subtract(const Duration(hours: 5)),
        minBudget: 75000,
        maxBudget: 150000,
        finalPrice: 100000,
        status: QuestStatus.review,
        submittedAt: now.subtract(const Duration(hours: 1)),
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      QuestModel(
        questId: q4,
        seekerUid: seekerUid,
        expertUid: expertUid,
        title: 'Coding Tugas OOP Java',
        description: 'Buat sistem perpustakaan sederhana.',
        jobdeskDetail: 'CLI app aja, gak usah GUI.',
        deadline: now.subtract(const Duration(days: 2)),
        minBudget: 100000,
        maxBudget: 100000,
        finalPrice: 100000,
        status: QuestStatus.finished,
        completedAt: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      QuestModel(
        questId: q5,
        seekerUid: seekerUid,
        title: 'Translasi Jurnal Bahasa Inggris',
        description: '10 halaman, pakai bahasa akademik yang bagus.',
        jobdeskDetail: 'Bidang biologi.',
        deadline: now.add(const Duration(days: 5)),
        minBudget: 30000,
        maxBudget: 60000,
        status: QuestStatus.pending,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
    ];

    emitUsers();
    emitProfiles();
    emitQuests();
    emitNotifications();
  }

  UserModel? getUser(String uid) {
    try {
      return users.firstWhere((u) => u.uid == uid);
    } catch (_) {
      return null;
    }
  }

  void updateUser(UserModel user) {
    final idx = users.indexWhere((u) => u.uid == user.uid);
    if (idx != -1) {
      users[idx] = user;
      emitUsers();
    }
  }

  void addQuest(QuestModel q) {
    quests.insert(0, q);
    emitQuests();
  }

  void updateQuest(QuestModel q) {
    final idx = quests.indexWhere((x) => x.questId == q.questId);
    if (idx != -1) {
      quests[idx] = q;
      emitQuests();
    }
  }
}
