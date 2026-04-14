// lib/shared/models/dispute_model.dart

import 'package:equatable/equatable.dart';
import '../../core/constants/app_enums.dart';

class DisputeModel extends Equatable {
  final String disputeId;
  final String questId;
  final String reporterUid;
  final String reportedUid;
  
  final String reason;
  final List<String> evidenceUrls;
  
  final DisputeStatus status;
  final String? adminNotes;
  final String? resolution;
  
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const DisputeModel({
    required this.disputeId,
    required this.questId,
    required this.reporterUid,
    required this.reportedUid,
    required this.reason,
    this.evidenceUrls = const [],
    this.status = DisputeStatus.open,
    this.adminNotes,
    this.resolution,
    required this.createdAt,
    this.resolvedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'disputeId': disputeId,
      'questId': questId,
      'reporterUid': reporterUid,
      'reportedUid': reportedUid,
      'reason': reason,
      'evidenceUrls': evidenceUrls,
      'status': status.name,
      'adminNotes': adminNotes,
      'resolution': resolution,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  factory DisputeModel.fromMap(Map<String, dynamic> map, String documentId) {
    return DisputeModel(
      disputeId: documentId,
      questId: map['questId'] ?? '',
      reporterUid: map['reporterUid'] ?? '',
      reportedUid: map['reportedUid'] ?? '',
      reason: map['reason'] ?? '',
      evidenceUrls: List<String>.from(map['evidenceUrls'] ?? []),
      status: DisputeStatus.values.firstWhere((e) => e.name == map['status'], orElse: () => DisputeStatus.open),
      adminNotes: map['adminNotes'],
      resolution: map['resolution'],
      createdAt: DateTime.parse(map['createdAt']),
      resolvedAt: map['resolvedAt'] != null ? DateTime.parse(map['resolvedAt']) : null,
    );
  }

  @override
  List<Object?> get props => [
        disputeId, questId, reporterUid, reportedUid, reason,
        evidenceUrls, status, adminNotes, resolution, createdAt, resolvedAt
      ];
}
