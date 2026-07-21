import '../models/payment_request_record.dart';

abstract interface class PaymentRequestLocalDataSource {
  Future<PaymentRequestRecord> put(PaymentRequestRecord record);
  Future<PaymentRequestRecord?> getById(int id);
  Future<PaymentRequestRecord?> getByRequestNumber(String requestNumber);
  Future<List<PaymentRequestRecord>> getAll();
  Stream<List<PaymentRequestRecord>> watchAll();
  Future<void> delete(int id);
}
