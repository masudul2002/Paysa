import '../models/payment_method_record.dart';

abstract interface class PaymentMethodLocalDataSource {
  Future<PaymentMethodRecord> put(PaymentMethodRecord record);
  Future<PaymentMethodRecord?> getById(int id);
  Future<List<PaymentMethodRecord>> getAll();
  Stream<List<PaymentMethodRecord>> watchAll();
  Future<void> delete(int id);
}
