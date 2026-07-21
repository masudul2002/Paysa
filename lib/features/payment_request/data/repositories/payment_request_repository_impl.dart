import 'package:paysa/core/app_exception.dart';
import '../../domain/entities/payment_request.dart';
import '../../domain/repositories/payment_request_repository.dart';
import '../datasources/payment_request_local_datasource.dart';
import '../models/payment_request_record.dart';

final class PaymentRequestRepositoryImpl implements PaymentRequestRepository {
  PaymentRequestRepositoryImpl(this._ds);

  final PaymentRequestLocalDataSource _ds;
  int _numberCounter = 0;

  @override Future<PaymentRequest> create(PaymentRequest r) async {
    if (r.amountMinor <= 0) throw AppException('Amount must be greater than zero.');
    _numberCounter = DateTime.now().millisecondsSinceEpoch;

    final now = DateTime.now();
    final record = r.copyWith(
      requestNumber: r.requestNumber.isNotEmpty ? r.requestNumber : _nextNumber(),
      status: PaymentRequestStatus.draft,
      statusChangedAt: now,
      version: 1, createdAt: now, updatedAt: now,
    ).toRecord();
    final saved = await _ds.put(record);
    return saved.toEntity();
  }

  @override Future<PaymentRequest> update(PaymentRequest r) async {
    final existing = await _ds.getById(r.id);
    if (existing == null) throw AppException('Payment request not found.');
    if (!existing.status.isEditable) throw AppException('Cannot edit a ${existing.status.label} request.');

    final now = DateTime.now();
    final record = r.copyWith(updatedAt: now, version: existing.version + 1).toRecord();
    final saved = await _ds.put(record);
    return saved.toEntity();
  }

  @override Future<void> cancel(int id) async {
    final existing = await _ds.getById(id);
    if (existing == null) throw AppException('Payment request not found.');
    if (existing.status == PaymentRequestStatus.paid) throw AppException('Cannot cancel a paid request.');
    if (existing.status == PaymentRequestStatus.cancelled) return;
    existing.status = PaymentRequestStatus.cancelled;
    existing.statusChangedAt = DateTime.now();
    await _ds.put(existing);
  }

  @override Future<void> expire(int id) async {
    final existing = await _ds.getById(id);
    if (existing == null) throw AppException('Payment request not found.');
    if (existing.status.isTerminal) return;
    existing.status = PaymentRequestStatus.expired;
    existing.statusChangedAt = DateTime.now();
    await _ds.put(existing);
  }

  @override Future<void> archive(int id) async {
    final existing = await _ds.getById(id);
    if (existing == null) throw AppException('Payment request not found.');
    existing.deletedAt = DateTime.now();
    await _ds.put(existing);
  }

  @override Future<void> restore(int id) async {
    final existing = await _ds.getById(id);
    if (existing == null) throw AppException('Payment request not found.');
    existing.deletedAt = null;
    await _ds.put(existing);
  }

  @override Future<PaymentRequest> duplicate(int id) async {
    final existing = await _ds.getById(id);
    if (existing == null) throw AppException('Payment request not found.');

    final now = DateTime.now();
    final copy = existing.toEntity().copyWith(
      id: 0, uuid: '', requestNumber: _nextNumber(),
      status: PaymentRequestStatus.draft,
      statusChangedAt: now, version: 1,
      createdAt: now, updatedAt: now, deletedAt: null,
    ).toRecord();
    final saved = await _ds.put(copy);
    return saved.toEntity();
  }

  @override Future<PaymentRequest?> findById(int id) async {
    final r = await _ds.getById(id);
    return r?.toEntity();
  }

  @override Future<PaymentRequest?> findByRequestNumber(String n) async {
    final r = await _ds.getByRequestNumber(n);
    return r?.toEntity();
  }

  @override Future<List<PaymentRequest>> getAll({PaymentRequestStatus? statusFilter, String? searchQuery}) async {
    var all = await _ds.getAll();
    all = all.where((r) => r.deletedAt == null).toList();

    if (statusFilter != null) all = all.where((r) => r.status == statusFilter).toList();
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      all = all.where((r) =>
        r.title.toLowerCase().contains(q) ||
        r.requestNumber.toLowerCase().contains(q)
      ).toList();
    }

    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all.map((r) => r.toEntity()).toList();
  }

  @override Stream<List<PaymentRequest>> watchAll() {
    return _ds.watchAll().map((records) {
      return records.where((r) => r.deletedAt == null).map((r) => r.toEntity()).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  String _nextNumber() => 'REQ-${_numberCounter++}';
}
