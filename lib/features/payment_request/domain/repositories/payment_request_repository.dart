import '../entities/payment_request.dart';

abstract interface class PaymentRequestRepository {
  Future<PaymentRequest> create(PaymentRequest request);
  Future<PaymentRequest> update(PaymentRequest request);
  Future<void> cancel(int id);
  Future<void> expire(int id);
  Future<void> archive(int id);
  Future<void> restore(int id);
  Future<PaymentRequest> duplicate(int id);
  Future<PaymentRequest?> findById(int id);
  Future<PaymentRequest?> findByRequestNumber(String requestNumber);
  Future<List<PaymentRequest>> getAll({PaymentRequestStatus? statusFilter, String? searchQuery});
  Stream<List<PaymentRequest>> watchAll();
}
