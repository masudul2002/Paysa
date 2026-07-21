import '../models/payment_link_record.dart';

abstract interface class PaymentLinkLocalDataSource {
  Future<PaymentLinkRecord> put(PaymentLinkRecord record);
  Future<PaymentLinkRecord?> getById(int id);
  Future<PaymentLinkRecord?> getByToken(String token);
  Future<PaymentLinkRecord?> getByShortCode(String shortCode);
  Future<List<PaymentLinkRecord>> getByPaymentRequest(int paymentRequestId);
  Future<List<PaymentLinkRecord>> getAll();
  Stream<List<PaymentLinkRecord>> watchAll();
  Future<void> delete(int id);
}
