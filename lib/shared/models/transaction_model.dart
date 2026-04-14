// lib/shared/models/transaction_model.dart

import 'package:equatable/equatable.dart';
import '../../core/constants/app_enums.dart';

class TransactionModel extends Equatable {
  final String txId;
  final String questId;
  final String seekerUid;
  final String expertUid;
  
  // Amounts
  final int grossAmount; // Total paid by seeker
  final int platformFee;
  final int expertPayout; // gross - fee
  
  // Payment Details
  final PaymentMethod paymentMethod;
  final String? midtransOrderId;
  final String? midtransTransactionId;
  
  // Status
  final EscrowStatus escrowStatus;
  
  // Timestamps
  final DateTime createdAt;
  final DateTime? releasedAt; // When escrow released to expert
  final DateTime? refundedAt;

  const TransactionModel({
    required this.txId,
    required this.questId,
    required this.seekerUid,
    required this.expertUid,
    required this.grossAmount,
    required this.platformFee,
    required this.expertPayout,
    required this.paymentMethod,
    this.midtransOrderId,
    this.midtransTransactionId,
    this.escrowStatus = EscrowStatus.locked,
    required this.createdAt,
    this.releasedAt,
    this.refundedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'txId': txId,
      'questId': questId,
      'seekerUid': seekerUid,
      'expertUid': expertUid,
      'grossAmount': grossAmount,
      'platformFee': platformFee,
      'expertPayout': expertPayout,
      'paymentMethod': paymentMethod.name,
      'midtransOrderId': midtransOrderId,
      'midtransTransactionId': midtransTransactionId,
      'escrowStatus': escrowStatus.name,
      'createdAt': createdAt.toIso8601String(),
      'releasedAt': releasedAt?.toIso8601String(),
      'refundedAt': refundedAt?.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TransactionModel(
      txId: documentId,
      questId: map['questId'] ?? '',
      seekerUid: map['seekerUid'] ?? '',
      expertUid: map['expertUid'] ?? '',
      grossAmount: map['grossAmount']?.toInt() ?? 0,
      platformFee: map['platformFee']?.toInt() ?? 0,
      expertPayout: map['expertPayout']?.toInt() ?? 0,
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == map['paymentMethod'], 
        orElse: () => PaymentMethod.qris
      ),
      midtransOrderId: map['midtransOrderId'],
      midtransTransactionId: map['midtransTransactionId'],
      escrowStatus: EscrowStatus.values.firstWhere(
        (e) => e.name == map['escrowStatus'], 
        orElse: () => EscrowStatus.locked
      ),
      createdAt: DateTime.parse(map['createdAt']),
      releasedAt: map['releasedAt'] != null ? DateTime.parse(map['releasedAt']) : null,
      refundedAt: map['refundedAt'] != null ? DateTime.parse(map['refundedAt']) : null,
    );
  }

  @override
  List<Object?> get props => [
        txId, questId, seekerUid, expertUid, grossAmount, platformFee,
        expertPayout, paymentMethod, midtransOrderId, midtransTransactionId,
        escrowStatus, createdAt, releasedAt, refundedAt
      ];
}
