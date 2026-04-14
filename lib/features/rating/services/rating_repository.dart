// lib/features/rating/services/rating_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/failure.dart';
import '../../../shared/models/models.dart';
import '../../../core/mock/mock_data.dart';

final ratingRepositoryProvider = Provider<RatingRepository>((ref) {
  return RatingRepository();
});

class RatingRepository {
  final MockData _db = MockData.instance;

  Future<void> submitReview(ReviewModel review) async {
    final user = _db.getUser(review.revieweeUid);
    if (user != null) {
      final oldAvg = user.ratingAvg;
      final count = user.ratingCount;
      final newCount = count + 1;
      final newAvg = ((oldAvg * count) + review.rating) / newCount;

      _db.updateUser(user.copyWith(
        ratingAvg: newAvg,
        ratingCount: newCount,
      ));
    }
  }
}
