// lib/features/quest/providers/quest_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/quest_repository.dart';
import '../../../shared/models/models.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/errors/failure.dart';
import '../../auth/providers/auth_controller.dart';
import 'package:uuid/uuid.dart';

// Provides a specific quest
final questStreamProvider =
    StreamProvider.family<QuestModel?, String>((ref, questId) {
  return ref.watch(questRepositoryProvider).streamQuest(questId);
});

// Provides available quest feed for EXPERTS
final expertQuestFeedProvider = StreamProvider<List<QuestModel>>((ref) {
  return ref.watch(questRepositoryProvider).streamAvailableQuests();
});

// Provides current Expert's ACTIVE quests (tanpa finished & cancelled)
final expertActiveQuestsProvider = StreamProvider<List<QuestModel>>((ref) {
  final user = ref.watch(userProvider).value;
  if (user == null) return const Stream.empty();
  return ref.read(questRepositoryProvider).streamExpertQuests(user.uid).map(
      (quests) => quests
          .where((q) =>
              q.status != QuestStatus.finished &&
              q.status != QuestStatus.cancelled)
          .toList());
});

// Provides current Expert's quest HISTORY (finished & cancelled)
final expertQuestHistoryProvider = StreamProvider<List<QuestModel>>((ref) {
  final user = ref.watch(userProvider).value;
  if (user == null) return const Stream.empty();
  return ref.read(questRepositoryProvider).streamExpertQuests(user.uid).map(
      (quests) => quests
          .where((q) =>
              q.status == QuestStatus.finished ||
              q.status == QuestStatus.cancelled)
          .toList());
});

// Provides current Seeker's posted quests
final seekerMyQuestsProvider = StreamProvider<List<QuestModel>>((ref) {
  final user = ref.watch(userProvider).value;
  if (user == null) return const Stream.empty();
  return ref.read(questRepositoryProvider).streamSeekerQuests(user.uid);
});

// Quest Actions
final questControllerProvider =
    StateNotifierProvider<QuestController, AsyncValue<void>>((ref) {
  return QuestController(questRepository: ref.watch(questRepositoryProvider));
});

class QuestController extends StateNotifier<AsyncValue<void>> {
  final QuestRepository _questRepository;

  // Simpan questId terakhir untuk direct quest flow
  String? lastQuestId;

  QuestController({required QuestRepository questRepository})
      : _questRepository = questRepository,
        super(const AsyncValue.data(null));

  Future<void> postQuest({
    required String seekerUid,
    required String title,
    required String description,
    required String jobdesk,
    required int minBudget,
    required int maxBudget,
    required DateTime deadline,
    required bool isUrgent,
  }) async {
    state = const AsyncValue.loading();
    try {
      final now = DateTime.now();
      final isActuallyUrgent =
          isUrgent || deadline.difference(now).inHours < 24;
      final markup = isActuallyUrgent ? 0.3 : 0.0;

      final questId = const Uuid().v4();
      lastQuestId = questId;

      final quest = QuestModel(
        questId: questId,
        seekerUid: seekerUid,
        title: title,
        description: description,
        jobdeskDetail: jobdesk,
        minBudget: minBudget,
        maxBudget: (maxBudget * (1 + markup)).round(),
        deadline: deadline,
        isUrgent: isActuallyUrgent,
        urgentMarkupPct: markup,
        createdAt: now,
      );
      await _questRepository.postQuest(quest);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(Failure(e.toString()), st);
    }
  }

  // Post quest langsung assign ke expert tertentu
  Future<void> postQuestDirect({
    required String seekerUid,
    required String expertUid,
    required String title,
    required String description,
    required int fixedPrice,
    required DateTime deadline,
    required bool isUrgent,
  }) async {
    state = const AsyncValue.loading();
    try {
      final now = DateTime.now();
      final isActuallyUrgent =
          isUrgent || deadline.difference(now).inHours < 24;
      final finalPrice =
          isActuallyUrgent ? (fixedPrice * 1.3).round() : fixedPrice;

      final questId = const Uuid().v4();
      lastQuestId = questId;

      final quest = QuestModel(
        questId: questId,
        seekerUid: seekerUid,
        expertUid: expertUid,
        title: title,
        description: description,
        jobdeskDetail: '',
        minBudget: finalPrice,
        maxBudget: finalPrice,
        finalPrice: finalPrice,
        deadline: deadline,
        isUrgent: isActuallyUrgent,
        urgentMarkupPct: isActuallyUrgent ? 0.3 : 0.0,
        createdAt: now,
      );
      await _questRepository.postQuest(quest);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(Failure(e.toString()), st);
    }
  }

  Future<void> updateStatus(String questId, QuestStatus status) async {
    state = const AsyncValue.loading();
    try {
      await _questRepository.updateQuestStatus(questId, status);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(Failure(e.toString()), st);
    }
  }

  Future<void> submitWork(String questId, String fileUrl) async {
    state = const AsyncValue.loading();
    try {
      await _questRepository.submitWork(questId, fileUrl);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(Failure(e.toString()), st);
    }
  }

  Future<void> requestRevision(String questId) async {
    state = const AsyncValue.loading();
    try {
      await _questRepository.requestRevision(questId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(Failure(e.toString()), st);
    }
  }

  Future<void> finishQuest(String questId) async {
    state = const AsyncValue.loading();
    try {
      await _questRepository.finishQuest(questId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(Failure(e.toString()), st);
    }
  }

  Future<void> cancelQuest(String questId) async {
    state = const AsyncValue.loading();
    try {
      await _questRepository.cancelQuest(questId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(Failure(e.toString()), st);
    }
  }

  // Expert terima direct quest → notif seeker untuk bayar
  Future<void> acceptDirectQuest(String questId, String seekerUid,
      {int? finalPrice}) async {
    state = const AsyncValue.loading();
    try {
      await _questRepository.acceptDirectQuest(questId, seekerUid,
          finalPrice: finalPrice);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(Failure(e.toString()), st);
    }
  }

  Future<void> requestNego(
      String questId, String seekerUid, int negoPrice) async {
    state = const AsyncValue.loading();
    try {
      await _questRepository.requestNego(questId, seekerUid, negoPrice);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(Failure(e.toString()), st);
    }
  }

  Future<void> acceptNego(String questId, int negoPrice) async {
    state = const AsyncValue.loading();
    try {
      await _questRepository.acceptNego(questId, negoPrice);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(Failure(e.toString()), st);
    }
  }
}
