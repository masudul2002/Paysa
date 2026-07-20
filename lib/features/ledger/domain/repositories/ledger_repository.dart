import '../entities/ledger.dart';

abstract interface class LedgerRepository {
  // -------------------------------------------------------------------------
  // Ledger CRUD
  // -------------------------------------------------------------------------

  Future<Ledger> createLedger(Ledger ledger);

  Future<Ledger> updateLedger(Ledger ledger);

  Future<void> deleteLedger(int ledgerId);

  Future<Ledger?> getLedgerById(int ledgerId);

  Future<Ledger?> getLedgerByPersonId(int personId);

  Future<List<Ledger>> getAllLedgers({LedgerStatus? statusFilter});

  Stream<List<Ledger>> watchAllLedgers();

  // -------------------------------------------------------------------------
  // Ledger Entry CRUD
  // -------------------------------------------------------------------------

  Future<LedgerEntry> createEntry(LedgerEntry entry);

  Future<LedgerEntry> updateEntry(LedgerEntry entry);

  Future<void> deleteEntry(int entryId);

  Future<LedgerEntry?> getEntryById(int entryId);

  Future<List<LedgerEntry>> getEntries(int ledgerId, {
    LedgerEntryType? typeFilter,
    DateTime? fromDate,
    DateTime? toDate,
    String? searchQuery,
  });

  Future<List<LedgerEntry>> getEntriesByPerson(int personId, {
    LedgerEntryType? typeFilter,
    DateTime? fromDate,
    DateTime? toDate,
    String? searchQuery,
  });

  Stream<List<LedgerEntry>> watchEntries(int ledgerId);

  // -------------------------------------------------------------------------
  // Balance computation
  // -------------------------------------------------------------------------

  Future<LedgerBalance> computeBalance(int ledgerId);
}
