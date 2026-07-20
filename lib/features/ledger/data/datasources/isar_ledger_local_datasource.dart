import 'package:isar/isar.dart';

import '../models/ledger_record.dart';
import 'ledger_local_datasource.dart';

final class IsarLedgerLocalDataSource implements LedgerLocalDataSource {
  const IsarLedgerLocalDataSource(this._isar);

  final Isar _isar;

  IsarCollection<LedgerRecord> get _ledgers => _isar.collection<LedgerRecord>();
  IsarCollection<LedgerEntryRecord> get _entries => _isar.collection<LedgerEntryRecord>();

  // -------------------------------------------------------------------------
  // Ledger
  // -------------------------------------------------------------------------

  @override
  Future<LedgerRecord> putLedger(LedgerRecord record) async {
    final id = await _isar.writeTxn(() => _ledgers.put(record));
    final saved = await _ledgers.get(id);
    if (saved == null) throw Exception('Failed to save ledger.');
    return saved;
  }

  @override
  Future<LedgerRecord?> getLedgerById(int id) => _ledgers.get(id);

  @override
  Future<LedgerRecord?> getLedgerByPersonId(int personId) async {
    final all = await _ledgers.where().findAll();
    for (final r in all) {
      if (r.personId == personId && r.deletedAt == null) return r;
    }
    return null;
  }

  @override
  Future<List<LedgerRecord>> getAllLedgers() async {
    return _ledgers.where().findAll();
  }

  @override
  Stream<List<LedgerRecord>> watchAllLedgers() {
    return _ledgers.watchLazy(fireImmediately: true).asyncMap((_) => getAllLedgers());
  }

  @override
  Future<void> deleteLedger(int id) {
    return _isar.writeTxn(() => _ledgers.delete(id));
  }

  // -------------------------------------------------------------------------
  // LedgerEntry
  // -------------------------------------------------------------------------

  @override
  Future<LedgerEntryRecord> putEntry(LedgerEntryRecord record) async {
    final id = await _isar.writeTxn(() => _entries.put(record));
    final saved = await _entries.get(id);
    if (saved == null) throw Exception('Failed to save ledger entry.');
    return saved;
  }

  @override
  Future<LedgerEntryRecord?> getEntryById(int id) => _entries.get(id);

  @override
  Future<List<LedgerEntryRecord>> getEntriesByLedger(int ledgerId) async {
    final all = await _entries.where().findAll();
    return all.where((e) => e.ledgerId == ledgerId && e.deletedAt == null).toList();
  }

  @override
  Future<List<LedgerEntryRecord>> getEntriesByPerson(int personId) async {
    final all = await _entries.where().findAll();
    return all.where((e) => e.personId == personId && e.deletedAt == null).toList();
  }

  @override
  Stream<List<LedgerEntryRecord>> watchEntries(int ledgerId) {
    return _entries.watchLazy(fireImmediately: true).asyncMap((_) => getEntriesByLedger(ledgerId));
  }

  @override
  Future<void> deleteEntry(int id) {
    return _isar.writeTxn(() => _entries.delete(id));
  }
}
