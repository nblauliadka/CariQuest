// lib/features/payment/services/payment_repository.dart

import '../../../core/errors/failure.dart';
import 'dart:async';

class PaymentRepository {
  Future<String> getSnapToken({
    required String orderId,
    required int amount,
    required String customerName,
    required String customerEmail,
    required String itemName,
  }) async {
    // Return a mock token that would normally open a webview.
    // In our UI, we will skip opening the Midtrans webview and just succeed automatically.
    return 'mock-snap-token-12345';
  }
}
