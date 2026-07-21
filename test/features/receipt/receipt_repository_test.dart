import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/core/app_exception.dart';
import 'package:paysa/features/receipt/data/datasources/receipt_local_datasource.dart';
import 'package:paysa/features/receipt/data/models/receipt_record.dart';
import 'package:paysa/features/receipt/data/repositories/receipt_repository_impl.dart';
import 'package:paysa/features/receipt/domain/entities/receipt.dart';
import 'package:paysa/features/receipt/domain/entities/audit_entry.dart';
import 'package:paysa/features/receipt/domain/entities/receipt_defaults.dart';

final class _InMemDS implements ReceiptLocalDataSource {
  final _r = <int, ReceiptRecord>{}; final _a = <int, AuditEntryRecord>{}; int _ri = 1, _ai = 1;
  @override Future<ReceiptRecord> putReceipt(ReceiptRecord r) async {
    if (r.id == 0) r.id = _ri++; if (r.uuid.isEmpty) r.uuid = 'r-${r.id}'; _r[r.id] = r; return r;
  }
  @override Future<ReceiptRecord?> getReceiptById(int id) async => _r[id];
  @override Future<ReceiptRecord?> getByReceiptNumber(String n) async {
    for (final r in _r.values) { if (r.receiptNumber == n) return r; } return null;
  }
  @override Future<List<ReceiptRecord>> getAllReceipts() async => _r.values.toList();
  @override Stream<List<ReceiptRecord>> watchAllReceipts() async* { yield _r.values.toList(); }
  @override Future<AuditEntryRecord> putAudit(AuditEntryRecord r) async {
    if (r.id == 0) r.id = _ai++; if (r.uuid.isEmpty) r.uuid = 'a-${r.id}'; _a[r.id] = r; return r;
  }
  @override Future<AuditEntryRecord?> getAuditById(int id) async => _a[id];
  @override Future<List<AuditEntryRecord>> getAuditByEntity(int eid, String et) async {
    return _a.values.where((r) => r.entityId == eid && r.entityType == et).toList();
  }
  @override Future<List<AuditEntryRecord>> getAllAudits() async => _a.values.toList();
  @override Stream<List<AuditEntryRecord>> watchAllAudits() async* { yield _a.values.toList(); }
}

final _now = DateTime.now();

void main() {
  late ReceiptRepositoryImpl rr;
  late AuditRepositoryImpl ar;

  setUp(() {
    final ds = _InMemDS();
    rr = ReceiptRepositoryImpl(ds);
    ar = AuditRepositoryImpl(ds);
  });

  group('ReceiptRepository', () {
    test('create receipt with auto-generated number', () async {
      final r = await rr.createReceipt(Receipt(amountMinor: 50000, issuedAt: _now, createdAt: _now, updatedAt: _now));
      expect(r.id, greaterThan(0));
      expect(r.receiptNumber.startsWith('RCP-'), true);
      expect(r.status, ReceiptStatus.issued);
    });

    test('rejects zero amount', () async {
      expect(() => rr.createReceipt(Receipt(amountMinor: 0, issuedAt: _now, createdAt: _now, updatedAt: _now)), throwsA(isA<AppException>()));
    });

    test('findByNumber works', () async {
      final r = await rr.createReceipt(Receipt(amountMinor: 1000, issuedAt: _now, createdAt: _now, updatedAt: _now));
      final found = await rr.findByNumber(r.receiptNumber);
      expect(found?.id, r.id);
    });

    test('getAll returns all receipts', () async {
      await rr.createReceipt(Receipt(amountMinor: 1000, issuedAt: _now, createdAt: _now, updatedAt: _now));
      await rr.createReceipt(Receipt(amountMinor: 2000, issuedAt: _now, createdAt: _now, updatedAt: _now));
      final all = await rr.getAll();
      expect(all.length, 2);
    });
  });

  group('AuditRepository', () {
    test('append creates audit entry', () async {
      final a = await ar.append(AuditEntry(
        entityId: 1, entityType: AuditEntityType.receipt, action: AuditAction.receiptIssued,
        actor: const AuditActor(type: 'system'), occurredAt: _now, createdAt: _now,
      ));
      expect(a.id, greaterThan(0));
    });

    test('findByEntity returns entity-specific entries', () async {
      await ar.append(AuditEntry(entityId: 1, entityType: AuditEntityType.receipt, action: AuditAction.receiptIssued, actor: const AuditActor(type: 'system'), occurredAt: _now, createdAt: _now));
      await ar.append(AuditEntry(entityId: 2, entityType: AuditEntityType.paymentRequest, action: AuditAction.created, actor: const AuditActor(type: 'system'), occurredAt: _now, createdAt: _now));
      final r = await ar.findByEntity(AuditEntityType.receipt, 1);
      expect(r.length, 1);
    });

    test('getAll with action filter', () async {
      await ar.append(AuditEntry(entityId: 1, entityType: AuditEntityType.receipt, action: AuditAction.receiptIssued, actor: const AuditActor(type: 'system'), occurredAt: _now, createdAt: _now));
      await ar.append(AuditEntry(entityId: 2, entityType: AuditEntityType.paymentRequest, action: AuditAction.created, actor: const AuditActor(type: 'system'), occurredAt: _now, createdAt: _now));
      final filtered = await ar.getAll(actionFilter: AuditAction.receiptIssued);
      expect(filtered.length, 1);
    });

    test('getAll with limit', () async {
      await ar.append(AuditEntry(entityId: 1, entityType: AuditEntityType.receipt, action: AuditAction.receiptIssued, actor: const AuditActor(type: 'system'), occurredAt: _now, createdAt: _now));
      await ar.append(AuditEntry(entityId: 2, entityType: AuditEntityType.receipt, action: AuditAction.receiptIssued, actor: const AuditActor(type: 'system'), occurredAt: _now, createdAt: _now));
      expect((await ar.getAll(limit: 1)).length, 1);
    });
  });

  group('Receipt entity', () {
    test('isIssued when status is issued', () {
      final r = Receipt(amountMinor: 100, issuedAt: _now, createdAt: _now, updatedAt: _now);
      expect(r.isIssued, true);
      expect(r.isVoided, false);
    });

    test('copyWith preserves fields', () {
      final r = Receipt(amountMinor: 100, issuedAt: _now, createdAt: _now, updatedAt: _now);
      final c = r.copyWith(amountMinor: 200);
      expect(c.amountMinor, 200);
      expect(c.isIssued, true);
    });
  });

  group('ReceiptDefaults', () {
    test('generates correct format', () {
      final n = ReceiptDefaults.generateNumber(DateTime(2026, 7, 20), 1);
      expect(n, 'RCP-20260720-00001');
    });
  });

  group('AuditEntry entity', () {
    test('copyWith works', () {
      final a = AuditEntry(entityId: 1, entityType: AuditEntityType.receipt, action: AuditAction.created, actor: const AuditActor(type: 'user', name: 'Alice'), occurredAt: _now, createdAt: _now);
      final c = a.copyWith(description: 'test');
      expect(c.description, 'test');
    });
  });
}
