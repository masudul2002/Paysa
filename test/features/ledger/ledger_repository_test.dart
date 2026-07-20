import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/core/app_exception.dart';
import 'package:paysa/features/ledger/data/datasources/ledger_local_datasource.dart';
import 'package:paysa/features/ledger/data/models/ledger_record.dart';
import 'package:paysa/features/ledger/data/repositories/ledger_repository_impl.dart';
import 'package:paysa/features/ledger/domain/entities/ledger.dart';
import 'package:paysa/features/ledger/domain/repositories/ledger_repository.dart';

// ---------------------------------------------------------------------------
// In-memory datasource
// ---------------------------------------------------------------------------

final class InMemoryLedgerLocalDataSource implements LedgerLocalDataSource {
  final _ledgers = <int, LedgerRecord>{};
  final _entries = <int, LedgerEntryRecord>{};
  int _nextLedgerId = 1;
  int _nextEntryId = 1;

  @override
  Future<LedgerRecord> putLedger(LedgerRecord record) async {
    if (record.id == 0) { record.id = _nextLedgerId++; }
    if (record.uuid.isEmpty) { record.uuid = 'ledger-uuid-${record.id}'; }
    _ledgers[record.id] = record;
    return record;
  }

  @override
  Future<LedgerRecord?> getLedgerById(int id) async => _ledgers[id];

  @override
  Future<LedgerRecord?> getLedgerByPersonId(int personId) async {
    for (final r in _ledgers.values) {
      if (r.personId == personId && r.deletedAt == null) return r;
    }
    return null;
  }

  @override
  Future<List<LedgerRecord>> getAllLedgers() async => _ledgers.values.toList();

  @override
  Stream<List<LedgerRecord>> watchAllLedgers() async* {
    yield _ledgers.values.toList();
  }

  @override
  Future<void> deleteLedger(int id) async { _ledgers.remove(id); }

  @override
  Future<LedgerEntryRecord> putEntry(LedgerEntryRecord record) async {
    if (record.id == 0) { record.id = _nextEntryId++; }
    if (record.uuid.isEmpty) { record.uuid = 'entry-uuid-${record.id}'; }
    _entries[record.id] = record;
    return record;
  }

  @override
  Future<LedgerEntryRecord?> getEntryById(int id) async => _entries[id];

  @override
  Future<List<LedgerEntryRecord>> getEntriesByLedger(int ledgerId) async {
    return _entries.values.where((e) => e.ledgerId == ledgerId && e.deletedAt == null).toList();
  }

  @override
  Future<List<LedgerEntryRecord>> getEntriesByPerson(int personId) async {
    return _entries.values.where((e) => e.personId == personId && e.deletedAt == null).toList();
  }

  @override
  Stream<List<LedgerEntryRecord>> watchEntries(int ledgerId) async* {
    yield _entries.values.where((e) => e.ledgerId == ledgerId && e.deletedAt == null).toList();
  }

  @override
  Future<void> deleteEntry(int id) async { _entries.remove(id); }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

final _now = DateTime.now();

Ledger _ledger({int personId = 1}) => Ledger(
  personId: personId, createdAt: _now, updatedAt: _now,
);

LedgerEntry _entry({
  int ledgerId = 1,
  int personId = 1,
  LedgerEntryType type = LedgerEntryType.give,
  int amount = 10000,
  DateTime? date,
}) => LedgerEntry(
  ledgerId: ledgerId,
  personId: personId,
  entryType: type,
  amount: amount,
  transactionDate: date ?? _now,
  createdAt: _now,
  updatedAt: _now,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late LedgerLocalDataSource dataSource;
  late LedgerRepository repository;

  setUp(() {
    dataSource = InMemoryLedgerLocalDataSource();
    repository = LedgerRepositoryImpl(dataSource);
  });

  // ==========================================================================
  // Ledger CRUD
  // ==========================================================================

  group('createLedger', () {
    test('creates a ledger for a person', () async {
      final l = await repository.createLedger(_ledger(personId: 1));
      expect(l.id, greaterThan(0));
      expect(l.personId, 1);
    });

    test('rejects duplicate ledger for same person', () async {
      await repository.createLedger(_ledger(personId: 1));
      expect(
        () => repository.createLedger(_ledger(personId: 1)),
        throwsA(isA<AppException>()),
      );
    });

    test('rejects ledger with invalid person ID', () async {
      expect(
        () => repository.createLedger(_ledger(personId: 0)),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('getLedger', () {
    test('getLedgerById returns correct ledger', () async {
      final l = await repository.createLedger(_ledger(personId: 1));
      final found = await repository.getLedgerById(l.id);
      expect(found?.personId, 1);
    });

    test('getLedgerByPersonId returns correct ledger', () async {
      await repository.createLedger(_ledger(personId: 1));
      final found = await repository.getLedgerByPersonId(1);
      expect(found?.personId, 1);
    });

    test('returns null for missing', () async {
      expect(await repository.getLedgerById(999), isNull);
      expect(await repository.getLedgerByPersonId(999), isNull);
    });
  });

  group('getAllLedgers', () {
    test('returns all active ledgers', () async {
      await repository.createLedger(_ledger(personId: 1));
      await repository.createLedger(_ledger(personId: 2));
      final all = await repository.getAllLedgers();
      expect(all.length, 2);
    });
  });

  // ==========================================================================
  // Entry CRUD
  // ==========================================================================

  group('createEntry', () {
    test('creates an entry and updates balance', () async {
      final l = await repository.createLedger(_ledger(personId: 1));
      final e = await repository.createEntry(_entry(ledgerId: l.id, personId: 1, amount: 50000));

      expect(e.id, greaterThan(0));
      expect(e.amount, 50000);

      final updated = await repository.getLedgerById(l.id);
      expect(updated?.receivableAmount, greaterThan(0));
    });

    test('rejects entry with zero amount', () async {
      expect(
        () => repository.createEntry(_entry(amount: 0)),
        throwsA(isA<AppException>()),
      );
    });

    test('rejects entry with future date beyond 365 days', () async {
      final farFuture = DateTime.now().add(const Duration(days: 400));
      expect(
        () => repository.createEntry(_entry(date: farFuture)),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('getEntries', () {
    test('returns entries for a ledger', () async {
      final l = await repository.createLedger(_ledger(personId: 1));
      await repository.createEntry(_entry(ledgerId: l.id, personId: 1, amount: 50000));
      await repository.createEntry(_entry(ledgerId: l.id, personId: 1, amount: 30000));

      final entries = await repository.getEntries(l.id);
      expect(entries.length, 2);
    });

    test('filters by type', () async {
      final l = await repository.createLedger(_ledger(personId: 1));
      await repository.createEntry(_entry(ledgerId: l.id, personId: 1, type: LedgerEntryType.give));
      await repository.createEntry(_entry(ledgerId: l.id, personId: 1, type: LedgerEntryType.receive));

      final gives = await repository.getEntries(l.id, typeFilter: LedgerEntryType.give);
      expect(gives.length, 1);
      expect(gives.first.entryType, LedgerEntryType.give);
    });

    test('sorted newest first', () async {
      final l = await repository.createLedger(_ledger(personId: 1));
      final old = DateTime(2024, 1, 1);
      final recent = DateTime(2025, 6, 1);
      await repository.createEntry(_entry(ledgerId: l.id, personId: 1, date: old));
      await repository.createEntry(_entry(ledgerId: l.id, personId: 1, date: recent));

      final entries = await repository.getEntries(l.id);
      expect(entries.first.transactionDate, recent);
    });

    test('getEntriesByPerson returns correct entries', () async {
      final l1 = await repository.createLedger(_ledger(personId: 1));
      final l2 = await repository.createLedger(_ledger(personId: 2));
      await repository.createEntry(_entry(ledgerId: l1.id, personId: 1));
      await repository.createEntry(_entry(ledgerId: l2.id, personId: 2));

      final entries = await repository.getEntriesByPerson(1);
      expect(entries.length, 1);
    });
  });

  // ==========================================================================
  // Balance computation
  // ==========================================================================

  group('computeBalance', () {
    test('returns zero for empty ledger', () async {
      final l = await repository.createLedger(_ledger(personId: 1));
      final b = await repository.computeBalance(l.id);
      expect(b.currentBalance, 0);
      expect(b.entryCount, 0);
    });

    test('calculates receivable from give entries', () async {
      final l = await repository.createLedger(_ledger(personId: 1));
      await repository.createEntry(_entry(ledgerId: l.id, personId: 1, type: LedgerEntryType.give, amount: 50000));
      await repository.createEntry(_entry(ledgerId: l.id, personId: 1, type: LedgerEntryType.give, amount: 30000));

      final b = await repository.computeBalance(l.id);
      expect(b.receivableAmount, 80000);
      expect(b.payableAmount, 0);
    });

    test('reduces balance on receive', () async {
      final l = await repository.createLedger(_ledger(personId: 1));
      await repository.createEntry(_entry(ledgerId: l.id, personId: 1, type: LedgerEntryType.give, amount: 50000));
      await repository.createEntry(_entry(ledgerId: l.id, personId: 1, type: LedgerEntryType.receive, amount: 20000));

      final b = await repository.computeBalance(l.id);
      expect(b.receivableAmount, 30000);
    });

    test('calculates payable when receive exceeds give', () async {
      final l = await repository.createLedger(_ledger(personId: 1));
      await repository.createEntry(_entry(ledgerId: l.id, personId: 1, type: LedgerEntryType.receive, amount: 50000));

      final b = await repository.computeBalance(l.id);
      expect(b.receivableAmount, 0);
      expect(b.payableAmount, 50000);
      expect(b.currentBalance, -50000);
    });

    test('apply discount reduces receivable', () async {
      final l = await repository.createLedger(_ledger(personId: 1));
      await repository.createEntry(_entry(ledgerId: l.id, personId: 1, type: LedgerEntryType.give, amount: 50000));
      await repository.createEntry(_entry(ledgerId: l.id, personId: 1, type: LedgerEntryType.discount, amount: 10000));

      final b = await repository.computeBalance(l.id);
      expect(b.receivableAmount, 40000);
    });

    test('handles sale entries', () async {
      final l = await repository.createLedger(_ledger(personId: 1));
      await repository.createEntry(_entry(ledgerId: l.id, personId: 1, type: LedgerEntryType.sale, amount: 20000));

      final b = await repository.computeBalance(l.id);
      expect(b.receivableAmount, 20000);
    });

    test('handles mixed entry types', () async {
      final l = await repository.createLedger(_ledger(personId: 1));
      await repository.createEntry(_entry(ledgerId: l.id, personId: 1, type: LedgerEntryType.give, amount: 50000));
      await repository.createEntry(_entry(ledgerId: l.id, personId: 1, type: LedgerEntryType.receive, amount: 15000));
      await repository.createEntry(_entry(ledgerId: l.id, personId: 1, type: LedgerEntryType.discount, amount: 5000));
      await repository.createEntry(_entry(ledgerId: l.id, personId: 1, type: LedgerEntryType.sale, amount: 30000));

      final b = await repository.computeBalance(l.id);
      // give(50000) + sale(30000) - receive(15000) - discount(5000) = 60000
      expect(b.receivableAmount, 60000);
      expect(b.entryCount, 4);
    });

    test('opening balance is included', () async {
      final l = await repository.createLedger(_ledger(personId: 1));
      // Manually set opening balance on the record
      final ledgerRecord = await dataSource.getLedgerById(l.id);
      ledgerRecord!.openingBalance = 100000;
      await dataSource.putLedger(ledgerRecord);

      final b = await repository.computeBalance(l.id);
      expect(b.openingBalance, 100000);
      expect(b.receivableAmount, 100000);
    });

    test('opening balance plus give equals receivable', () async {
      final l = await repository.createLedger(_ledger(personId: 1));
      final ledgerRecord = await dataSource.getLedgerById(l.id);
      ledgerRecord!.openingBalance = 50000;
      await dataSource.putLedger(ledgerRecord);

      await repository.createEntry(_entry(ledgerId: l.id, personId: 1, type: LedgerEntryType.give, amount: 30000));

      final b = await repository.computeBalance(l.id);
      // opening(50000) + give(30000) = 80000
      expect(b.receivableAmount, 80000);
    });

    test('give minus receive minus discount = net', () async {
      final l = await repository.createLedger(_ledger(personId: 1));
      await repository.createEntry(_entry(ledgerId: l.id, personId: 1, type: LedgerEntryType.give, amount: 100000));
      await repository.createEntry(_entry(ledgerId: l.id, personId: 1, type: LedgerEntryType.receive, amount: 40000));
      await repository.createEntry(_entry(ledgerId: l.id, personId: 1, type: LedgerEntryType.discount, amount: 10000));

      final b = await repository.computeBalance(l.id);
      // give(100000) - receive(40000) - discount(10000) = 50000
      expect(b.receivableAmount, 50000);
    });

    test('borrow increases balance like give', () async {
      final l = await repository.createLedger(_ledger(personId: 1));
      await repository.createEntry(_entry(ledgerId: l.id, personId: 1, type: LedgerEntryType.borrow, amount: 75000));

      final b = await repository.computeBalance(l.id);
      expect(b.receivableAmount, 75000);
    });

    test('repayment decreases balance like receive', () async {
      final l = await repository.createLedger(_ledger(personId: 1));
      await repository.createEntry(_entry(ledgerId: l.id, personId: 1, type: LedgerEntryType.give, amount: 50000));
      await repository.createEntry(_entry(ledgerId: l.id, personId: 1, type: LedgerEntryType.repayment, amount: 20000));

      final b = await repository.computeBalance(l.id);
      // give(50000) - repayment(20000) = 30000
      expect(b.receivableAmount, 30000);
    });

    test('adjustment increases balance', () async {
      final l = await repository.createLedger(_ledger(personId: 1));
      await repository.createEntry(_entry(ledgerId: l.id, personId: 1, type: LedgerEntryType.adjustment, amount: 25000));

      final b = await repository.computeBalance(l.id);
      expect(b.receivableAmount, 25000);
    });

    test('purchase increases balance', () async {
      final l = await repository.createLedger(_ledger(personId: 1));
      await repository.createEntry(_entry(ledgerId: l.id, personId: 1, type: LedgerEntryType.purchase, amount: 40000));

      final b = await repository.computeBalance(l.id);
      expect(b.receivableAmount, 40000);
    });

    test('manual entry does not affect balance', () async {
      final l = await repository.createLedger(_ledger(personId: 1));
      await repository.createEntry(_entry(ledgerId: l.id, personId: 1, type: LedgerEntryType.manual, amount: 50000));

      final b = await repository.computeBalance(l.id);
      expect(b.receivableAmount, 0);
    });

    test('balance auto-updates after entry creation', () async {
      final l = await repository.createLedger(_ledger(personId: 1));
      await repository.createEntry(_entry(ledgerId: l.id, personId: 1, type: LedgerEntryType.give, amount: 50000));

      final updated = await repository.getLedgerById(l.id);
      expect(updated?.receivableAmount, 50000);
    });

    test('balance auto-updates after entry deletion', () async {
      final l = await repository.createLedger(_ledger(personId: 1));
      await repository.createEntry(_entry(ledgerId: l.id, personId: 1, type: LedgerEntryType.give, amount: 50000));
      final e2 = await repository.createEntry(_entry(ledgerId: l.id, personId: 1, type: LedgerEntryType.give, amount: 30000));
      await repository.deleteEntry(e2.id);

      final updated = await repository.getLedgerById(l.id);
      expect(updated?.receivableAmount, 50000);
    });

    test('balance auto-updates after entry update', () async {
      final l = await repository.createLedger(_ledger(personId: 1));
      final e1 = await repository.createEntry(_entry(ledgerId: l.id, personId: 1, type: LedgerEntryType.give, amount: 50000));
      expect((await repository.getLedgerById(l.id))?.receivableAmount, 50000);

      // Update is not financial mutation; entry is re-saved
      await repository.updateEntry(e1.copyWith(notes: 'Updated note'));
      expect((await repository.getLedgerById(l.id))?.receivableAmount, 50000);
    });

    test('zero entries returns zero balance', () async {
      final l = await repository.createLedger(_ledger(personId: 1));
      final b = await repository.computeBalance(l.id);
      expect(b.currentBalance, 0);
      expect(b.receivableAmount, 0);
      expect(b.payableAmount, 0);
      expect(b.entryCount, 0);
    });

    test('large numbers do not overflow', () async {
      final l = await repository.createLedger(_ledger(personId: 1));
      await repository.createEntry(_entry(
        ledgerId: l.id, personId: 1, type: LedgerEntryType.give, amount: 2000000000,
      ));
      await repository.createEntry(_entry(
        ledgerId: l.id, personId: 1, type: LedgerEntryType.give, amount: 2000000000,
      ));

      final b = await repository.computeBalance(l.id);
      expect(b.receivableAmount, 4000000000);
    });
  });

  // ==========================================================================
  // Soft delete
  // ==========================================================================

  group('soft-delete', () {
    test('delete ledger sets deletedAt', () async {
      final l = await repository.createLedger(_ledger(personId: 1));
      await repository.deleteLedger(l.id);
      final all = await repository.getAllLedgers();
      expect(all.where((x) => x.id == l.id).isEmpty, true);
    });

    test('delete entry hides from listing', () async {
      final l = await repository.createLedger(_ledger(personId: 1));
      await repository.createEntry(_entry(ledgerId: l.id, personId: 1));
      final e2 = await repository.createEntry(_entry(ledgerId: l.id, personId: 1));
      await repository.deleteEntry(e2.id);

      final entries = await repository.getEntries(l.id);
      expect(entries.length, 1);
    });

    test('balance recomputes after entry deletion', () async {
      final l = await repository.createLedger(_ledger(personId: 1));
      final e1 = await repository.createEntry(_entry(ledgerId: l.id, personId: 1, type: LedgerEntryType.give, amount: 50000));
      await repository.createEntry(_entry(ledgerId: l.id, personId: 1, type: LedgerEntryType.give, amount: 30000));
      await repository.deleteEntry(e1.id);

      final b = await repository.computeBalance(l.id);
      expect(b.receivableAmount, 30000);
    });
  });
}
