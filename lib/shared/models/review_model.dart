// lib/shared/models/review_model.dart

import 'package:equatable/equatable.dart';

class ReviewModel extends Equatable {
  final String reviewId;
  final String questId;
  final String reviewerUid;
  final String revieweeUid; // Expert or Seeker
  final int rating; // 1-5
  final String? comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.reviewId,
    required this.questId,
    required this.reviewerUid,
    required this.revieweeUid,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'reviewId': reviewId,
      'questId': questId,
      'reviewerUid': reviewerUid,
      'revieweeUid': revieweeUid,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ReviewModel(
      reviewId: documentId,
      questId: map['questId'] ?? '',
      reviewerUid: map['reviewerUid'] ?? '',
      revieweeUid: map['revieweeUid'] ?? '',
      rating: map['rating']?.toInt() ?? 0,
      comment: map['comment'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  @override
  List<Object?> get props => [reviewId, questId, reviewerUid, revieweeUid, rating, comment, createdAt];
}
