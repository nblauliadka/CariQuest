// lib/shared/models/bid_model.dart

import 'package:equatable/equatable.dart';
import '../../core/constants/app_enums.dart';

enum BidStatus {
  pending,
  accepted,
  rejected,
}

class BidModel extends Equatable {
  final String bidId;
  final String questId;
  final String expertUid;

  final int bidAmount;
  final String message;
  final DateTime createdAt;

  final String expertName;
  final String expertAvatar;
  final ExpertRank expertRank;
  final double expertRating;

  final BidStatus status;

  const BidModel({
    required this.bidId,
    required this.questId,
    required this.expertUid,
    required this.bidAmount,
    required this.message,
    required this.createdAt,
    required this.expertName,
    required this.expertAvatar,
    required this.expertRank,
    required this.expertRating,
    this.status = BidStatus.pending,
  });

  BidModel copyWith({
    String? bidId,
    String? questId,
    String? expertUid,
    int? bidAmount,
    String? message,
    DateTime? createdAt,
    String? expertName,
    String? expertAvatar,
    ExpertRank? expertRank,
    double? expertRating,
    BidStatus? status,
  }) {
    return BidModel(
      bidId: bidId ?? this.bidId,
      questId: questId ?? this.questId,
      expertUid: expertUid ?? this.expertUid,
      bidAmount: bidAmount ?? this.bidAmount,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      expertName: expertName ?? this.expertName,
      expertAvatar: expertAvatar ?? this.expertAvatar,
      expertRank: expertRank ?? this.expertRank,
      expertRating: expertRating ?? this.expertRating,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bidId': bidId,
      'questId': questId,
      'expertUid': expertUid,
      'bidAmount': bidAmount,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'expertName': expertName,
      'expertAvatar': expertAvatar,
      'expertRank': expertRank.name,
      'expertRating': expertRating,
      'status': status.name,
    };
  }

  factory BidModel.fromMap(Map<String, dynamic> map, String documentId) {
    return BidModel(
      bidId: documentId,
      questId: map['questId'] ?? '',
      expertUid: map['expertUid'] ?? '',
      bidAmount: map['bidAmount']?.toInt() ?? 0,
      message: map['message'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      expertName: map['expertName'] ?? '',
      expertAvatar: map['expertAvatar'] ?? '',
      expertRank: ExpertRank.values.firstWhere(
        (e) => e.name == map['expertRank'],
        orElse: () => ExpertRank.newcomer,
      ),
      expertRating: map['expertRating']?.toDouble() ?? 0.0,
      status: BidStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BidStatus.pending,
      ),
    );
  }

  @override
  List<Object?> get props => [
        bidId,
        questId,
        expertUid,
        bidAmount,
        message,
        createdAt,
        expertName,
        expertAvatar,
        expertRank,
        expertRating,
        status,
      ];
}
