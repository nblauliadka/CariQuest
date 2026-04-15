// lib/shared/models/quest_model.dart

import 'package:equatable/equatable.dart';
import '../../core/constants/app_enums.dart';

class QuestModel extends Equatable {
  final String questId;
  final String seekerUid;
  final String? expertUid;

  // Quest Details
  final String title;
  final String description;
  final String jobdeskDetail;
  final DateTime deadline;

  // Pricing
  final int minBudget;
  final int maxBudget;
  final int? finalPrice;

  // Flags & Status
  final bool isUrgent;
  final double urgentMarkupPct;
  final QuestStatus status;
  final bool expertAccepted;
  final int? negoPrice;
  final String? negoStatus; // 'waiting' | 'accepted' | 'rejected'

  // Revisions
  final int revisionCount;
  final List<String> revisionNotes;

  // Delivery
  final String? previewFileUrl;
  final String? finalFileUrl;

  // Timestamps
  final DateTime createdAt;
  final DateTime? paidAt;
  final DateTime? submittedAt;
  final DateTime? completedAt;

  const QuestModel({
    required this.questId,
    required this.seekerUid,
    this.expertUid,
    required this.title,
    required this.description,
    required this.jobdeskDetail,
    required this.deadline,
    required this.minBudget,
    required this.maxBudget,
    this.finalPrice,
    this.isUrgent = false,
    this.urgentMarkupPct = 0.0,
    this.status = QuestStatus.pending,
    this.expertAccepted = false,
    this.negoPrice,
    this.negoStatus,
    this.revisionCount = 0,
    this.revisionNotes = const [],
    this.previewFileUrl,
    this.finalFileUrl,
    required this.createdAt,
    this.paidAt,
    this.submittedAt,
    this.completedAt,
  });

  QuestModel copyWith({
    String? questId,
    String? seekerUid,
    String? expertUid,
    String? title,
    String? description,
    String? jobdeskDetail,
    DateTime? deadline,
    int? minBudget,
    int? maxBudget,
    int? finalPrice,
    bool? isUrgent,
    double? urgentMarkupPct,
    QuestStatus? status,
    bool? expertAccepted,
    int? negoPrice,
    String? negoStatus,
    int? revisionCount,
    List<String>? revisionNotes,
    String? previewFileUrl,
    String? finalFileUrl,
    DateTime? createdAt,
    DateTime? paidAt,
    DateTime? submittedAt,
    DateTime? completedAt,
  }) {
    return QuestModel(
      questId: questId ?? this.questId,
      seekerUid: seekerUid ?? this.seekerUid,
      expertUid: expertUid ?? this.expertUid,
      title: title ?? this.title,
      description: description ?? this.description,
      jobdeskDetail: jobdeskDetail ?? this.jobdeskDetail,
      deadline: deadline ?? this.deadline,
      minBudget: minBudget ?? this.minBudget,
      maxBudget: maxBudget ?? this.maxBudget,
      finalPrice: finalPrice ?? this.finalPrice,
      isUrgent: isUrgent ?? this.isUrgent,
      urgentMarkupPct: urgentMarkupPct ?? this.urgentMarkupPct,
      status: status ?? this.status,
      expertAccepted: expertAccepted ?? this.expertAccepted,
      negoPrice: negoPrice ?? this.negoPrice,
      negoStatus: negoStatus ?? this.negoStatus,
      revisionCount: revisionCount ?? this.revisionCount,
      revisionNotes: revisionNotes ?? this.revisionNotes,
      previewFileUrl: previewFileUrl ?? this.previewFileUrl,
      finalFileUrl: finalFileUrl ?? this.finalFileUrl,
      createdAt: createdAt ?? this.createdAt,
      paidAt: paidAt ?? this.paidAt,
      submittedAt: submittedAt ?? this.submittedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questId': questId,
      'seekerUid': seekerUid,
      'expertUid': expertUid,
      'title': title,
      'description': description,
      'jobdeskDetail': jobdeskDetail,
      'deadline': deadline.toIso8601String(),
      'minBudget': minBudget,
      'maxBudget': maxBudget,
      'finalPrice': finalPrice,
      'isUrgent': isUrgent,
      'urgentMarkupPct': urgentMarkupPct,
      'status': status.name,
      'expertAccepted': expertAccepted,
      'negoPrice': negoPrice,
      'negoStatus': negoStatus,
      'revisionCount': revisionCount,
      'revisionNotes': revisionNotes,
      'previewFileUrl': previewFileUrl,
      'finalFileUrl': finalFileUrl,
      'createdAt': createdAt.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'submittedAt': submittedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory QuestModel.fromMap(Map<String, dynamic> map, String documentId) {
    return QuestModel(
      questId: documentId,
      seekerUid: map['seekerUid'] ?? '',
      expertUid: map['expertUid'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      jobdeskDetail: map['jobdeskDetail'] ?? '',
      deadline: DateTime.parse(map['deadline']),
      minBudget: map['minBudget']?.toInt() ?? 0,
      maxBudget: map['maxBudget']?.toInt() ?? 0,
      finalPrice: map['finalPrice']?.toInt(),
      isUrgent: map['isUrgent'] ?? false,
      urgentMarkupPct: map['urgentMarkupPct']?.toDouble() ?? 0.0,
      status: QuestStatus.values.firstWhere((e) => e.name == map['status'],
          orElse: () => QuestStatus.pending),
      expertAccepted: map['expertAccepted'] ?? false,
      negoPrice: map['negoPrice']?.toInt(),
      negoStatus: map['negoStatus'],
      revisionCount: map['revisionCount']?.toInt() ?? 0,
      revisionNotes: List<String>.from(map['revisionNotes'] ?? []),
      previewFileUrl: map['previewFileUrl'],
      finalFileUrl: map['finalFileUrl'],
      createdAt: DateTime.parse(map['createdAt']),
      paidAt: map['paidAt'] != null ? DateTime.parse(map['paidAt']) : null,
      submittedAt: map['submittedAt'] != null
          ? DateTime.parse(map['submittedAt'])
          : null,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
        questId,
        seekerUid,
        expertUid,
        title,
        description,
        jobdeskDetail,
        deadline,
        minBudget,
        maxBudget,
        finalPrice,
        isUrgent,
        urgentMarkupPct,
        status,
        expertAccepted,
        negoPrice,
        negoStatus,
        revisionCount,
        revisionNotes,
        previewFileUrl,
        finalFileUrl,
        createdAt,
        paidAt,
        submittedAt,
        completedAt,
      ];
}
