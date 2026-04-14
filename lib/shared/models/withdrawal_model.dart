// lib/shared/models/withdrawal_model.dart

import 'package:equatable/equatable.dart';
import '../../core/constants/app_enums.dart';

class WithdrawalModel extends Equatable {
  final String withdrawalId;
  final String expertUid;
  
  final int amount;
  final int fee;
  final int netAmount; // amount - fee
  
  final WithdrawDestination destinationType;
  final String destinationNumber;
  
  final String status; // pending, processed, failed
  
  final DateTime createdAt;
  final DateTime? processedAt;

  const WithdrawalModel({
    required this.withdrawalId,
    required this.expertUid,
    required this.amount,
    required this.fee,
    required this.netAmount,
    required this.destinationType,
    required this.destinationNumber,
    this.status = 'pending',
    required this.createdAt,
    this.processedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'withdrawalId': withdrawalId,
      'expertUid': expertUid,
      'amount': amount,
      'fee': fee,
      'netAmount': netAmount,
      'destinationType': destinationType.name,
      'destinationNumber': destinationNumber,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
    };
  }

  factory WithdrawalModel.fromMap(Map<String, dynamic> map, String documentId) {
    return WithdrawalModel(
      withdrawalId: documentId,
      expertUid: map['expertUid'] ?? '',
      amount: map['amount']?.toInt() ?? 0,
      fee: map['fee']?.toInt() ?? 0,
      netAmount: map['netAmount']?.toInt() ?? 0,
      destinationType: WithdrawDestination.values.firstWhere(
        (e) => e.name == map['destinationType'], 
        orElse: () => WithdrawDestination.bri // Defaulting if not found
      ),
      destinationNumber: map['destinationNumber'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: DateTime.parse(map['createdAt']),
      processedAt: map['processedAt'] != null ? DateTime.parse(map['processedAt']) : null,
    );
  }

  @override
  List<Object?> get props => [
        withdrawalId, expertUid, amount, fee, netAmount,
        destinationType, destinationNumber, status, createdAt, processedAt
      ];
}
