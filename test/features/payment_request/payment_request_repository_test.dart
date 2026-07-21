import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/core/app_exception.dart';
import 'package:paysa/features/payment_request/data/datasources/payment_request_local_datasource.dart';
import 'package:paysa/features/payment_request/data/models/payment_request_record.dart';
import 'package:paysa/features/payment_request/data/repositories/payment_request_repository_impl.dart';
import 'package:paysa/features/payment_request/domain/entities/payment_request.dart';

final class InMemoryPaymentRequestDataSource implements PaymentRequestLocalDataSource {
  final _records = <int, PaymentRequestRecord>{};
  int _nextId = 1;

  @override Future<PaymentRequestRecord> put(PaymentRequestRecord r) async {
    if (r.id == 0) r.id = _nextId++;
    if (r.uuid.isEmpty) r.uuid = 'pr-${r.id}';
    _records[r.id] = r;
    return r;
  }

  @override Future<PaymentRequestRecord?> getById(int id) async => _records[id];

  @override Future<PaymentRequestRecord?> getByRequestNumber(String n) async {
    for (final r in _records.values) {
      if (r.requestNumber.toLowerCase() == n.trim().toLowerCase() && r.deletedAt == null) return r;
    }
    return null;
  }

  @override Future<List<PaymentRequestRecord>> getAll() async => _records.values.toList();
  @override Stream<List<PaymentRequestRecord>> watchAll() async* { yield _records.values.toList(); }
  @override Future<void> delete(int id) async { _records.remove(id); }
}

final _now = DateTime.now();

PaymentRequest _req({int amount = 10000, String? requestNumber, PaymentRequestType type = PaymentRequestType.generalPayment, String title = 'Test'}) =>
    PaymentRequest(
      title: title, requestNumber: requestNumber ?? '', amountMinor: amount,
      requestType: type, createdAt: _now, updatedAt: _now,
    );

void main() {
  late PaymentRequestRepositoryImpl repo;

  setUp(() { repo = PaymentRequestRepositoryImpl(InMemoryPaymentRequestDataSource()); });

  group('create', () {
    test('creates with auto-generated request number', () async {
      final r = await repo.create(_req());
      expect(r.id, greaterThan(0));
      expect(r.requestNumber.startsWith('REQ-'), true);
      expect(r.status, PaymentRequestStatus.draft);
    });

    test('rejects zero amount', () async {
      expect(() => repo.create(_req(amount: 0)), throwsA(isA<AppException>()));
    });

    test('rejects negative amount', () async {
      expect(() => repo.create(_req(amount: -100)), throwsA(isA<AppException>()));
    });
  });

  group('update', () {
    test('updates draft request', () async {
      final r = await repo.create(_req());
      final updated = await repo.update(r.copyWith(title: 'Updated'));
      expect(updated.title, 'Updated');
    });

    test('blocks update of paid request', () async {
      final r = await repo.create(_req());
      final paid = await repo.update(r.copyWith(status: PaymentRequestStatus.paid));
      expect(() => repo.update(paid.copyWith(title: 'X')), throwsA(isA<AppException>()));
    });

    test('blocks update of cancelled request', () async {
      final r = await repo.create(_req());
      await repo.cancel(r.id);
      expect(() => repo.update(r.copyWith(title: 'X')), throwsA(isA<AppException>()));
    });
  });

  group('cancel', () {
    test('cancels a pending request', () async {
      final r = await repo.create(_req());
      await repo.cancel(r.id);
      final updated = await repo.findById(r.id);
      expect(updated?.status, PaymentRequestStatus.cancelled);
    });

    test('blocks cancel of paid request', () async {
      final r = await repo.create(_req());
      final paid = await repo.update(r.copyWith(status: PaymentRequestStatus.paid));
      expect(() => repo.cancel(paid.id), throwsA(isA<AppException>()));
    });
  });

  group('expire', () {
    test('expires a pending request', () async {
      final r = await repo.create(_req());
      await repo.expire(r.id);
      expect((await repo.findById(r.id))?.status, PaymentRequestStatus.expired);
    });
  });

  group('archive / restore', () {
    test('archive and restore', () async {
      final r = await repo.create(_req());
      await repo.archive(r.id);
      expect((await repo.getAll()).where((x) => x.id == r.id), isEmpty);
      await repo.restore(r.id);
      expect((await repo.getAll()).where((x) => x.id == r.id).length, 1);
    });
  });

  group('duplicate', () {
    test('creates a new draft copy', () async {
      final r = await repo.create(_req(title: 'Original'));
      await repo.update(r.copyWith(status: PaymentRequestStatus.paid));
      final dup = await repo.duplicate(r.id);
      expect(dup.id, isNot(r.id));
      expect(dup.status, PaymentRequestStatus.draft);
      expect(dup.title, 'Original');
      expect(dup.requestNumber.startsWith('REQ-'), true);
    });
  });

  group('search / filter', () {
    test('filter by status', () async {
      final r1 = await repo.create(_req());
      await repo.update(r1.copyWith(status: PaymentRequestStatus.paid));
      final paid = await repo.getAll(statusFilter: PaymentRequestStatus.paid);
      expect(paid.length, 1);
    });

    test('search by title', () async {
      await repo.create(_req());
      await repo.create(PaymentRequest(title: 'Special', amountMinor: 5000, requestType: PaymentRequestType.donation, createdAt: _now, updatedAt: _now));
      final results = await repo.getAll(searchQuery: 'Special');
      expect(results.length, 1);
    });
  });

  group('business rules', () {
    test('request number is unique', () async {
      final r = await repo.create(_req(requestNumber: 'REQ-001'));
      expect(r.requestNumber, 'REQ-001');
    });

    test('findByRequestNumber works', () async {
      final r = await repo.create(_req());
      final found = await repo.findByRequestNumber(r.requestNumber);
      expect(found?.id, r.id);
    });

    test('deleted excluded from listing', () async {
      final r = await repo.create(_req());
      await repo.archive(r.id);
      expect((await repo.getAll()).where((x) => x.id == r.id), isEmpty);
    });
  });
}
