// lib/features/quest/services/quest_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/errors/failure.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/models/models.dart';
import '../../notification/services/notification_repository.dart';

final questRepositoryProvider = Provider<QuestRepository>((ref) {
  return QuestRepository(
    notificationRepository: ref.watch(notificationRepositoryProvider),
  );
});

class QuestRepository {
  final MockData _db = MockData.instance;
  final NotificationRepository _notif;
  
  static const int maxRevisions = 2;

  QuestRepository({required NotificationRepository notificationRepository})
      : _notif = notificationRepository;

  Future<void> postQuest(QuestModel quest) async {
    _db.addQuest(quest);
  }

  Stream<List<QuestModel>> streamAvailableQuests() {
    return _db.questsStream.map((quests) => 
        quests.where((q) => q.status == QuestStatus.pending).toList());
  }

  Stream<List<QuestModel>> streamSeekerQuests(String seekerUid) {
    return _db.questsStream.map((quests) => 
        quests.where((q) => q.seekerUid == seekerUid).toList());
  }

  Stream<List<QuestModel>> streamExpertQuests(String expertUid) {
    return _db.questsStream.map((quests) => 
        quests.where((q) => q.expertUid == expertUid).toList());
  }

  Stream<QuestModel?> streamQuest(String questId) {
    return _db.questsStream.map((quests) {
      try {
        return quests.firstWhere((q) => q.questId == questId);
      } catch (_) {
        return null;
      }
    });
  }

  Future<void> finishQuest(String questId) async {
    final quest = _db.quests.firstWhere((q) => q.questId == questId);
    
    // Update Quest status
    final updatedQuest = QuestModel(
      questId: quest.questId,
      seekerUid: quest.seekerUid,
      expertUid: quest.expertUid,
      title: quest.title,
      description: quest.description,
      jobdeskDetail: quest.jobdeskDetail,
      deadline: quest.deadline,
      minBudget: quest.minBudget,
      maxBudget: quest.maxBudget,
      finalPrice: quest.finalPrice,
      isUrgent: quest.isUrgent,
      urgentMarkupPct: quest.urgentMarkupPct,
      status: QuestStatus.finished,
      expertAccepted: quest.expertAccepted,
      negoPrice: quest.negoPrice,
      negoStatus: quest.negoStatus,
      revisionCount: quest.revisionCount,
      revisionNotes: quest.revisionNotes,
      previewFileUrl: quest.previewFileUrl,
      finalFileUrl: quest.finalFileUrl,
      createdAt: quest.createdAt,
      paidAt: quest.paidAt,
      submittedAt: quest.submittedAt,
      completedAt: DateTime.now(),
    );
    _db.updateQuest(updatedQuest);

    // Update Expert EXP & Saldo
    if (quest.expertUid != null) {
      final expert = _db.getUser(quest.expertUid!);
      if (expert != null) {
        final newExp = expert.expPoints + 150;
        final updatedExpert = expert.copyWith(
          expPoints: newExp,
          saldoActive: expert.saldoActive + (quest.finalPrice ?? quest.maxBudget),
          totalQuestsDone: expert.totalQuestsDone + 1,
        );
        _db.updateUser(updatedExpert);
      }
    }
  }

  Future<void> updateQuestStatus(String questId, QuestStatus status) async {
    final quest = _db.quests.firstWhere((q) => q.questId == questId);
    _db.updateQuest(QuestModel(
      questId: quest.questId,
      seekerUid: quest.seekerUid,
      expertUid: quest.expertUid,
      title: quest.title,
      description: quest.description,
      jobdeskDetail: quest.jobdeskDetail,
      deadline: quest.deadline,
      minBudget: quest.minBudget,
      maxBudget: quest.maxBudget,
      finalPrice: quest.finalPrice,
      isUrgent: quest.isUrgent,
      status: status,
      createdAt: quest.createdAt,
    ));
  }

  Future<void> cancelQuest(String questId) async {
    await updateQuestStatus(questId, QuestStatus.cancelled);
  }

  Future<void> submitWork(String questId, String fileUrl) async {
    final quest = _db.quests.firstWhere((q) => q.questId == questId);
    _db.updateQuest(QuestModel(
      questId: quest.questId,
      seekerUid: quest.seekerUid,
      expertUid: quest.expertUid,
      title: quest.title,
      description: quest.description,
      jobdeskDetail: quest.jobdeskDetail,
      deadline: quest.deadline,
      minBudget: quest.minBudget,
      maxBudget: quest.maxBudget,
      status: QuestStatus.review,
      createdAt: quest.createdAt,
      finalFileUrl: fileUrl,
      submittedAt: DateTime.now(),
    ));
  }

  Future<void> requestRevision(String questId) async {
    await updateQuestStatus(questId, QuestStatus.working);
  }

  Future<void> acceptDirectQuest(String questId, String seekerUid, {int? finalPrice}) async {
    final quest = _db.quests.firstWhere((q) => q.questId == questId);
    _db.updateQuest(QuestModel(
      questId: quest.questId,
      seekerUid: quest.seekerUid,
      expertUid: quest.expertUid,
      title: quest.title,
      description: quest.description,
      jobdeskDetail: quest.jobdeskDetail,
      deadline: quest.deadline,
      minBudget: quest.minBudget,
      maxBudget: quest.maxBudget,
      status: QuestStatus.working, // jump to working in mock
      expertAccepted: true,
      finalPrice: finalPrice ?? quest.minBudget,
      createdAt: quest.createdAt,
    ));
  }

  Future<void> requestNego(String questId, String seekerUid, int negoPrice) async {
    // Mock implementation
  }

  Future<void> acceptNego(String questId, int negoPrice) async {
    // Mock implementation
  }
}
