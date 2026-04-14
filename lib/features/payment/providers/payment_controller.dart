// lib/features/payment/providers/payment_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/errors/failure.dart';
import '../../notification/services/notification_repository.dart';
import '../../quest/services/quest_repository.dart';

final paymentControllerProvider =
    StateNotifierProvider<PaymentController, AsyncValue<void>>((ref) {
  return PaymentController(
    questRepository: ref.watch(questRepositoryProvider),
    notificationRepository: ref.watch(notificationRepositoryProvider),
  );
});

class PaymentController extends StateNotifier<AsyncValue<void>> {
  final QuestRepository _questRepository;
  final NotificationRepository _notif;

  PaymentController({
    required QuestRepository questRepository,
    required NotificationRepository notificationRepository,
  })  : _questRepository = questRepository,
        _notif = notificationRepository,
        super(const AsyncValue.data(null));

  Future<void> confirmPaymentSuccess(String questId) async {
    state = const AsyncValue.loading();
    try {
      // 1. Update status quest ke paid
      await _questRepository.updateQuestStatus(questId, QuestStatus.paid);

      // 2. Update status quest ke working (langsung setelah paid)
      await _questRepository.updateQuestStatus(questId, QuestStatus.working);

      // 3. Ambil data quest untuk tahu expertUid
      final questStream = _questRepository.streamQuest(questId);
      final quest = await questStream.first;

      if (quest != null && quest.expertUid != null) {
        // 4. Notif ke expert: pembayaran masuk, mulai kerja
        await _notif.sendNotification(
          uid: quest.expertUid!,
          title: '💳 Pembayaran Diterima!',
          body:
              'Seeker sudah bayar untuk quest "${quest.title}". Silakan mulai mengerjakan!',
          type: NotificationType.paid,
          questId: questId,
        );

        // 5. Notif ke seeker: konfirmasi pembayaran
        await _notif.sendNotification(
          uid: quest.seekerUid,
          title: '✅ Pembayaran Berhasil!',
          body:
              'Dana untuk quest "${quest.title}" sudah masuk escrow. Expert akan segera mulai bekerja.',
          type: NotificationType.paid,
          questId: questId,
        );
      }

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(Failure(e.toString()), st);
    }
  }
}
