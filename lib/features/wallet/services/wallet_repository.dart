// lib/features/wallet/services/wallet_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/errors/failure.dart';
import '../../../shared/models/models.dart';
import 'dart:async';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository();
});

class WalletRepository {
  final MockData _db = MockData.instance;
  final _withdrawalsController = StreamController<List<WithdrawalModel>>.broadcast();

  Future<void> requestWithdrawal(WithdrawalModel withdrawal) async {
    final user = _db.getUser(withdrawal.expertUid);
    if (user == null) throw const Failure('Expert tidak ditemukan');
    if (user.saldoActive < withdrawal.amount) throw const Failure('Saldo aktif tidak mencukupi');

    _db.updateUser(user.copyWith(saldoActive: user.saldoActive - withdrawal.amount));
    _db.withdrawals.insert(0, withdrawal);
    _withdrawalsController.add(List.from(_db.withdrawals));
  }

  Stream<List<WithdrawalModel>> streamWithdrawals(String expertUid) {
    return _withdrawalsController.stream.map((list) => 
        list.where((w) => w.expertUid == expertUid).toList());
  }
}
