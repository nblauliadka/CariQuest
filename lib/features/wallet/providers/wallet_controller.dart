// lib/features/wallet/providers/wallet_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/wallet_repository.dart';
import '../../../shared/models/models.dart';
import '../../../core/errors/failure.dart';
import '../../../core/constants/app_enums.dart';
import 'package:uuid/uuid.dart';
import '../../auth/providers/auth_controller.dart';

final walletControllerProvider = StateNotifierProvider<WalletController, AsyncValue<void>>((ref) {
  return WalletController(
    repository: ref.watch(walletRepositoryProvider),
    ref: ref,
  );
});

class WalletController extends StateNotifier<AsyncValue<void>> {
  final WalletRepository _repository;
  final Ref ref;

  WalletController({required WalletRepository repository, required this.ref})
      : _repository = repository,
        super(const AsyncValue.data(null));

  Future<void> submitWithdrawRequest({
    required String expertUid,
    required int amount,
    required WithdrawDestination destinationType,
    required String destinationNumber,
  }) async {
    state = const AsyncValue.loading();
    try {
      const fee = 2500; // Flat fee for withdrawal
      final netAmount = amount - fee;

      if (netAmount <= 0) throw const Failure('Minimal penarikan di atas Rp 2.500');

      final withdrawal = WithdrawalModel(
        withdrawalId: const Uuid().v4(),
        expertUid: expertUid,
        amount: amount,
        fee: fee,
        netAmount: netAmount,
        destinationType: destinationType,
        destinationNumber: destinationNumber,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await _repository.requestWithdrawal(withdrawal);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(Failure(e.toString()), st);
    }
  }

  // Simpler method used by the UI
  Future<void> requestWithdrawal({
    required int amount,
    required String destination,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(userProvider).value;
      if (user == null) throw const Failure('User tidak ditemukan');

      const fee = 2500;
      final netAmount = amount - fee;

      if (netAmount <= 0) throw const Failure('Minimal penarikan Rp 10.000');

      final withdrawal = WithdrawalModel(
        withdrawalId: const Uuid().v4(),
        expertUid: user.uid,
        amount: amount,
        fee: fee,
        netAmount: netAmount,
        destinationType: destination.toLowerCase().contains('gopay') 
            ? WithdrawDestination.gopay 
            : destination.toLowerCase().contains('ovo')
                ? WithdrawDestination.ovo
                : destination.toLowerCase().contains('dana')
                    ? WithdrawDestination.dana
                    : WithdrawDestination.mandiri, // fallback to bank
        destinationNumber: destination,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await _repository.requestWithdrawal(withdrawal);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(Failure(e.toString()), st);
    }
  }
}
