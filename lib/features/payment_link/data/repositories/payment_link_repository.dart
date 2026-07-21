import '../../domain/entities/payment_link.dart';

abstract interface class PaymentLinkRepository {
  Future<PaymentLink> create(int paymentRequestId, String provider, {Duration? expiry});
  Future<PaymentLink> activate(int id);
  Future<void> deactivate(int id);
  Future<void> expire(int id);
  Future<void> resolve(int id);
  Future<PaymentLink> regenerate(int id, {Duration? expiry});
  Future<PaymentLink?> getByToken(String token);
  Future<PaymentLink?> getByShortCode(String shortCode);
  Future<List<PaymentLink>> getByPaymentRequest(int paymentRequestId);
  Future<List<PaymentLink>> getActiveLinks(int paymentRequestId);
  Future<List<PaymentLink>> getAll();
  Stream<List<PaymentLink>> watchAll();
}
