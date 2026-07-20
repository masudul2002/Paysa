import '../models/ledger_record.dart';

abstract interface class LedgerLocalDataSource {
  // Ledger
  Future<LedgerRecord> putLedger(LedgerRecord record);
  Future<LedgerRecord?> getLedgerById(int id);
  Future<LedgerRecord?> getLedgerByPersonId(int personId);
  Future<List<LedgerRecord>> getAllLedgers();
  Stream<List<LedgerRecord>> watchAllLedgers();
  Future<void> deleteLedger(int id);

  // LedgerEntry
  Future<LedgerEntryRecord> putEntry(LedgerEntryRecord record);
  Future<LedgerEntryRecord?> getEntryById(int id);
  Future<List<LedgerEntryRecord>> getEntriesByLedger(int ledgerId);
  Future<List<LedgerEntryRecord>> getEntriesByPerson(int personId);
  Stream<List<LedgerEntryRecord>> watchEntries(int ledgerId);
  Future<void> deleteEntry(int id);
}
