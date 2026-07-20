import 'package:paysa/core/app_exception.dart';
import 'package:paysa/features/people/domain/entities/person.dart';
import '../../domain/entities/ledger.dart';
import '../../domain/repositories/ledger_repository.dart';
import '../datasources/ledger_local_datasource.dart';
import '../models/ledger_record.dart';

final class LedgerRepositoryImpl implements LedgerRepository {
  const LedgerRepositoryImpl(this._dataSource);

  final LedgerLocalDataSource _dataSource;

  // -------------------------------------------------------------------------
  // Ledger CRUD
  // -------------------------------------------------------------------------

  @override
  Future<Ledger> createLedger(Ledger ledger) async {
    if (ledger.personId <= 0) throw AppException('Person ID is required.');
    final existing = await _dataSource.getLedgerByPersonId(ledger.personId);
    if (existing != null) throw AppException('A ledger already exists for this person.');

    final now = DateTime.now();
    final record = ledger.copyWith(
      createdAt: now,
      updatedAt: now,
      version: 1,
    ).toRecord();

    final saved = await _dataSource.putLedger(record);
    return saved.toEntity();
  }

  @override
  Future<Ledger> updateLedger(Ledger ledger) async {
    final existing = await _dataSource.getLedgerById(ledger.id);
    if (existing == null) throw AppException('Ledger not found.');

    final now = DateTime.now();
    final record = ledger.copyWith(
      updatedAt: now,
      version: existing.version + 1,
    ).toRecord();

    final saved = await _dataSource.putLedger(record);
    return saved.toEntity();
  }

  @override
  Future<void> deleteLedger(int ledgerId) async {
    final existing = await _dataSource.getLedgerById(ledgerId);
    if (existing == null) throw AppException('Ledger not found.');

    final now = DateTime.now();
    existing.deletedAt = now;
    await _dataSource.putLedger(existing);
  }

  @override
  Future<Ledger?> getLedgerById(int ledgerId) async {
    final record = await _dataSource.getLedgerById(ledgerId);
    return record?.toEntity();
  }

  @override
  Future<Ledger?> getLedgerByPersonId(int personId) async {
    final record = await _dataSource.getLedgerByPersonId(personId);
    return record?.toEntity();
  }

  @override
  Future<List<Ledger>> getAllLedgers({LedgerStatus? statusFilter}) async {
    var records = await _dataSource.getAllLedgers();
    records = records.where((r) => r.deletedAt == null).toList();

    if (statusFilter != null) {
      records = records.where((r) {
        final s = r.status == PersonStatus.active
            ? LedgerStatus.active
            : (r.status == PersonStatus.archived ? LedgerStatus.archived : LedgerStatus.closed);
        return s == statusFilter;
      }).toList();
    }

    return records.map((r) => r.toEntity()).toList();
  }

  @override
  Stream<List<Ledger>> watchAllLedgers() {
    return _dataSource.watchAllLedgers().map((records) {
      return records
          .where((r) => r.deletedAt == null)
          .map((r) => r.toEntity())
          .toList();
    });
  }

  // -------------------------------------------------------------------------
  // Ledger Entry CRUD
  // -------------------------------------------------------------------------

  @override
  Future<LedgerEntry> createEntry(LedgerEntry entry) async {
    if (entry.amount <= 0) throw AppException('Amount must be greater than zero.');
    if (entry.ledgerId <= 0) throw AppException('Ledger ID is required.');
    if (entry.personId <= 0) throw AppException('Person ID is required.');

    final futureLimit = DateTime.now().add(const Duration(days: 365));
    if (entry.transactionDate.isAfter(futureLimit)) {
      throw AppException('Transaction date cannot be more than 365 days in the future.');
    }

    final now = DateTime.now();
    final record = entry.copyWith(
      createdAt: now,
      updatedAt: now,
      version: 1,
    ).toRecord();

    final saved = await _dataSource.putEntry(record);

    // Update ledger balances
    await _recomputeBalance(entry.ledgerId);

    return saved.toEntity();
  }

  @override
  Future<LedgerEntry> updateEntry(LedgerEntry entry) async {
    final existing = await _dataSource.getEntryById(entry.id);
    if (existing == null) throw AppException('Entry not found.');

    final now = DateTime.now();
    final record = entry.copyWith(
      updatedAt: now,
      version: existing.version + 1,
    ).toRecord();

    final saved = await _dataSource.putEntry(record);
    await _recomputeBalance(entry.ledgerId);
    return saved.toEntity();
  }

  @override
  Future<void> deleteEntry(int entryId) async {
    final existing = await _dataSource.getEntryById(entryId);
    if (existing == null) throw AppException('Entry not found.');

    final now = DateTime.now();
    existing.deletedAt = now;
    await _dataSource.putEntry(existing);
    await _recomputeBalance(existing.ledgerId);
  }

  @override
  Future<LedgerEntry?> getEntryById(int entryId) async {
    final record = await _dataSource.getEntryById(entryId);
    return record?.toEntity();
  }

  @override
  Future<List<LedgerEntry>> getEntries(int ledgerId, {
    LedgerEntryType? typeFilter,
    DateTime? fromDate,
    DateTime? toDate,
    String? searchQuery,
  }) async {
    var entries = await _dataSource.getEntriesByLedger(ledgerId);
    return _filterEntries(entries, typeFilter, fromDate, toDate, searchQuery);
  }

  @override
  Future<List<LedgerEntry>> getEntriesByPerson(int personId, {
    LedgerEntryType? typeFilter,
    DateTime? fromDate,
    DateTime? toDate,
    String? searchQuery,
  }) async {
    var entries = await _dataSource.getEntriesByPerson(personId);
    return _filterEntries(entries, typeFilter, fromDate, toDate, searchQuery);
  }

  @override
  Stream<List<LedgerEntry>> watchEntries(int ledgerId) {
    return _dataSource.watchEntries(ledgerId).map((records) {
      return records.map((r) => r.toEntity()).toList();
    });
  }

  // -------------------------------------------------------------------------
  // Balance computation
  // -------------------------------------------------------------------------

  @override
  Future<LedgerBalance> computeBalance(int ledgerId) async {
    final ledger = await _dataSource.getLedgerById(ledgerId);
    if (ledger == null) throw AppException('Ledger not found.');

    final entries = await _dataSource.getEntriesByLedger(ledgerId);
    final entities = entries.map((e) => e.toEntity()).toList();

    // Starting balance is the opening balance (what the person initially owes)
    int balance = ledger.openingBalance;
    DateTime? lastDate;

    for (final entry in entities) {
      if (entry.isDeleted) continue;
      lastDate = entry.transactionDate;

      // Rules:
      //   Opening Balance (base)
      //   + Receive   → money received from person → their balance decreases
      //   - Give      → money given to person → their balance increases
      //   + Adjustment → correction increasing their balance
      //   - Discount   → write-off decreasing their balance
      //
      // Formula: Balance = Opening + (-Give) - (+Receive) + Adjustment - Discount
      //        or: Balance = Opening + Give_amounts - Receive_amounts + Adjustment - Discount
      //
      // When balance > 0: person owes user (receivable)
      // When balance < 0: user owes person (payable)

      switch (entry.entryType) {
        // Outgoing: user gives/lends/sells. Person owes MORE.
        case LedgerEntryType.give:
        case LedgerEntryType.borrow:
        case LedgerEntryType.sale:
        case LedgerEntryType.purchase:
          balance += entry.amount;

        // Incoming: user receives/is repaid. Person owes LESS.
        case LedgerEntryType.receive:
        case LedgerEntryType.repayment:
          balance -= entry.amount;

        // Adjustment: user corrects balance upward.
        case LedgerEntryType.adjustment:
          balance += entry.amount;

        // Discount: user writes off debt. Person owes LESS.
        case LedgerEntryType.discount:
          balance -= entry.amount;

        // Opening and Manual: no automatic balance effect
        case LedgerEntryType.opening:
        case LedgerEntryType.manual:
          break;
      }
    }

    final int receivable = balance > 0 ? balance : 0;
    final int payable = balance < 0 ? balance.abs() : 0;

    return LedgerBalance(
      currentBalance: balance,
      receivableAmount: receivable,
      payableAmount: payable,
      openingBalance: ledger.openingBalance,
      entryCount: entities.length,
      lastEntryDate: lastDate,
    );
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  List<LedgerEntry> _filterEntries(
    List<LedgerEntryRecord> records,
    LedgerEntryType? typeFilter,
    DateTime? fromDate,
    DateTime? toDate,
    String? searchQuery,
  ) {
    var entries = records
        .where((e) => e.deletedAt == null)
        .map((e) => e.toEntity())
        .toList();

    if (typeFilter != null) {
      entries = entries.where((e) => e.entryType == typeFilter).toList();
    }
    if (fromDate != null) {
      entries = entries.where((e) => e.transactionDate.isAfter(fromDate)).toList();
    }
    if (toDate != null) {
      entries = entries.where((e) => e.transactionDate.isBefore(toDate)).toList();
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      entries = entries.where((e) {
        return (e.description?.toLowerCase().contains(q) ?? false) ||
            (e.notes?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    entries.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    return entries;
  }

  Future<void> _recomputeBalance(int ledgerId) async {
    final ledger = await _dataSource.getLedgerById(ledgerId);
    if (ledger == null) return;

    final balance = await computeBalance(ledgerId);

    final now = DateTime.now();
    ledger.currentBalance = balance.currentBalance;
    ledger.receivableAmount = balance.receivableAmount;
    ledger.payableAmount = balance.payableAmount;
    ledger.lastTransactionAt = balance.lastEntryDate;
    ledger.updatedAt = now;

    await _dataSource.putLedger(ledger);
  }
}
