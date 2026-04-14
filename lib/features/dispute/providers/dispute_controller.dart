// lib/features/dispute/providers/dispute_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/dispute_repository.dart';
import '../../../shared/models/models.dart';
import '../../../core/errors/failure.dart';
import 'package:uuid/uuid.dart';

final disputeControllerProvider = StateNotifierProvider<DisputeController, AsyncValue<void>>((ref) {
  return DisputeController(
    repository: ref.watch(disputeRepositoryProvider),
  );
});

class DisputeController extends StateNotifier<AsyncValue<void>> {
  final DisputeRepository _repository;

  DisputeController({required DisputeRepository repository})
      : _repository = repository,
        super(const AsyncValue.data(null));

  Future<void> raiseDispute({
    required String questId,
    required String reporterUid,
    required String reportedUid,
    required String reason,
    List<String> evidenceUrls = const [],
  }) async {
    state = const AsyncValue.loading();
    try {
      final dispute = DisputeModel(
        disputeId: const Uuid().v4(),
        questId: questId,
        reporterUid: reporterUid,
        reportedUid: reportedUid,
        reason: reason,
        evidenceUrls: evidenceUrls,
        createdAt: DateTime.now(),
      );
      await _repository.submitDispute(dispute);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(Failure(e.toString()), st);
    }
  }
}
