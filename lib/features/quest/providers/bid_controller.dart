// lib/features/quest/providers/bid_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../services/bid_repository.dart';
import '../../../shared/models/models.dart';
import '../../../core/errors/failure.dart';
import '../../auth/providers/auth_controller.dart';
import '../../profile/services/profile_repository.dart';

// Stream of bids for a specific quest
final questBidsProvider =
    StreamProvider.family<List<BidModel>, String>((ref, questId) {
  return ref.watch(bidRepositoryProvider).streamBids(questId);
});

final bidControllerProvider =
    StateNotifierProvider<BidController, AsyncValue<void>>((ref) {
  return BidController(
    bidRepository: ref.watch(bidRepositoryProvider),
    ref: ref,
  );
});

class BidController extends StateNotifier<AsyncValue<void>> {
  final BidRepository _bidRepository;
  final Ref _ref;

  BidController({
    required BidRepository bidRepository,
    required Ref ref,
  })  : _bidRepository = bidRepository,
        _ref = ref,
        super(const AsyncValue.data(null));

  Future<void> placeBid({
    required String questId,
    required int bidAmount,
    required String message,
    String? seekerUid,
    String? questTitle,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(userProvider).value;
      if (user == null) throw const Failure('Bukan user terautentikasi');

      final profile =
          await _ref.read(profileRepositoryProvider).getProfile(user.uid);
      if (profile == null) throw const Failure('Profil tidak ditemukan');

      final bid = BidModel(
        bidId: const Uuid().v4(),
        questId: questId,
        expertUid: user.uid,
        bidAmount: bidAmount,
        message: message,
        createdAt: DateTime.now(),
        expertName: profile.displayName,
        expertAvatar: profile.avatarUrl,
        expertRank: user.rank,
        expertRating: user.ratingAvg,
      );

      await _bidRepository.placeBid(bid);
      state = const AsyncValue.data(null);
    } on Failure catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } catch (e, st) {
      state = AsyncValue.error(Failure(e.toString()), st);
    }
  }

  Future<void> acceptBid(String questId, String bidId, String expertUid) async {
    state = const AsyncValue.loading();
    try {
      await _bidRepository.acceptBid(questId, bidId, expertUid);
      state = const AsyncValue.data(null);
    } on Failure catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } catch (e, st) {
      state = AsyncValue.error(Failure(e.toString()), st);
    }
  }
}
