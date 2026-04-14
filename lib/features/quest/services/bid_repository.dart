// lib/features/quest/services/bid_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/models/models.dart';
import '../../../core/constants/app_enums.dart';
import 'dart:async';

final bidRepositoryProvider = Provider<BidRepository>((ref) {
  return BidRepository();
});

class BidRepository {
  final MockData _db = MockData.instance;
  final _bidsController = StreamController<List<BidModel>>.broadcast();

  Future<void> placeBid(BidModel bid) async {
    _db.bids.insert(0, bid);
    _bidsController.add(List.from(_db.bids));
  }

  Stream<List<BidModel>> streamBids(String questId) {
    return _bidsController.stream.map((bids) => 
        bids.where((b) => b.questId == questId).toList());
  }

  Future<void> acceptBid(String questId, String bidId, String expertUid) async {
    final acceptedBid = _db.bids.firstWhere((b) => b.bidId == bidId);
    
    // update all bids
    for (var i = 0; i < _db.bids.length; i++) {
      if (_db.bids[i].questId == questId) {
        if (_db.bids[i].bidId == bidId) {
          _db.bids[i] = _db.bids[i].copyWith(status: BidStatus.accepted);
        } else {
          _db.bids[i] = _db.bids[i].copyWith(status: BidStatus.rejected);
        }
      }
    }
    _bidsController.add(List.from(_db.bids));

    // Update quest
    final quest = _db.quests.firstWhere((q) => q.questId == questId);
    _db.updateQuest(quest.copyWith(
      expertUid: expertUid,
      status: QuestStatus.working, // Directly to working in mock
      finalPrice: acceptedBid.bidAmount,
    ));
  }
}
