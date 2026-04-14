// lib/features/dispute/services/dispute_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/failure.dart';
import '../../../shared/models/models.dart';
import 'dart:async';

final disputeRepositoryProvider = Provider<DisputeRepository>((ref) {
  return DisputeRepository();
});

class DisputeRepository {
  final _disputes = <DisputeModel>[];
  final _controller = StreamController<List<DisputeModel>>.broadcast();

  Future<void> submitDispute(DisputeModel dispute) async {
    _disputes.insert(0, dispute);
    _controller.add(List.from(_disputes));
  }

  Stream<List<DisputeModel>> streamMyDisputes(String uid) {
    return _controller.stream.map((list) => 
        list.where((d) => d.reporterUid == uid).toList());
  }
}
