import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';

import '../../../../app/providers/app_providers.dart';
import '../../data/datasources/isar_ledger_local_datasource.dart';
import '../../data/repositories/ledger_repository_impl.dart';
import '../../domain/entities/ledger.dart';
import '../../domain/repositories/ledger_repository.dart';

// ---------------------------------------------------------------------------
// Repository
// ---------------------------------------------------------------------------

final ledgerRepositoryProvider = Provider<LedgerRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return LedgerRepositoryImpl(IsarLedgerLocalDataSource(isar));
});

// ---------------------------------------------------------------------------
// Filter / Sort State
// ---------------------------------------------------------------------------

/// Entry type filter. Null means show all types.
final ledgerEntryTypeFilterProvider =
    StateProvider<LedgerEntryType?>((ref) => null);

/// Date range filter.
final ledgerDateFromProvider = StateProvider<DateTime?>((ref) => null);
final ledgerDateToProvider = StateProvider<DateTime?>((ref) => null);

/// Search query.
final ledgerSearchQueryProvider = StateProvider<String>((ref) => '');

/// Ledger status filter.
final ledgerStatusFilterProvider =
    StateProvider<LedgerStatus?>((ref) => null);

/// Sort field.
enum LedgerSortField { date, amount, entryType, createdAt }

/// Sort direction.
enum LedgerSortDirection { ascending, descending }

/// Sort configuration.
final ledgerSortProvider =
    StateProvider<Map<String, dynamic>>((ref) => <String, dynamic>{
          'field': LedgerSortField.date.name,
          'direction': LedgerSortDirection.descending.name,
        });

/// Currently selected ledger ID.
final selectedLedgerIdProvider = StateProvider<int?>((ref) => null);

// ---------------------------------------------------------------------------
// Ledger List
// ---------------------------------------------------------------------------

/// Streams all non-deleted ledgers.
final ledgerListProvider = StreamProvider.autoDispose<List<Ledger>>((ref) {
  final repository = ref.watch(ledgerRepositoryProvider);
  final statusFilter = ref.watch(ledgerStatusFilterProvider);

  return repository.watchAllLedgers().map((ledgers) {
    var filtered = ledgers.toList();
    if (statusFilter != null) {
      filtered = filtered.where((l) => l.status == statusFilter).toList();
    }
    return filtered;
  });
});

/// Fetches a single ledger by ID.
final ledgerByIdProvider =
    FutureProvider.autoDispose.family<Ledger?, int>((ref, id) {
  final repository = ref.watch(ledgerRepositoryProvider);
  return repository.getLedgerById(id);
});

/// Fetches the ledger for a specific person.
final ledgerByPersonIdProvider =
    FutureProvider.autoDispose.family<Ledger?, int>((ref, personId) {
  final repository = ref.watch(ledgerRepositoryProvider);
  return repository.getLedgerByPersonId(personId);
});

// ---------------------------------------------------------------------------
// Ledger Entries
// ---------------------------------------------------------------------------

/// Streams entries for a specific ledger, with filters and sort applied.
final ledgerEntriesProvider = StreamProvider.autoDispose
    .family<List<LedgerEntry>, int>((ref, ledgerId) {
  final repository = ref.watch(ledgerRepositoryProvider);
  final typeFilter = ref.watch(ledgerEntryTypeFilterProvider);
  final fromDate = ref.watch(ledgerDateFromProvider);
  final toDate = ref.watch(ledgerDateToProvider);
  final searchQuery = ref.watch(ledgerSearchQueryProvider);
  final sortConfig = ref.watch(ledgerSortProvider);

  return repository.watchEntries(ledgerId).map((entries) {
    var filtered = entries.toList();

    if (typeFilter != null) {
      filtered = filtered.where((e) => e.entryType == typeFilter).toList();
    }
    if (fromDate != null) {
      filtered =
          filtered.where((e) => e.transactionDate.isAfter(fromDate)).toList();
    }
    if (toDate != null) {
      filtered =
          filtered.where((e) => e.transactionDate.isBefore(toDate)).toList();
    }
    final query = searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((e) {
        return (e.description?.toLowerCase().contains(query) ?? false) ||
            (e.notes?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    final sortField = LedgerSortField.values.firstWhere(
      (f) => f.name == sortConfig['field'],
      orElse: () => LedgerSortField.date,
    );
    final sortDirection = LedgerSortDirection.values.firstWhere(
      (d) => d.name == sortConfig['direction'],
      orElse: () => LedgerSortDirection.descending,
    );

    filtered.sort((a, b) {
      int cmp;
      switch (sortField) {
        case LedgerSortField.date:
          cmp = a.transactionDate.compareTo(b.transactionDate);
        case LedgerSortField.amount:
          cmp = a.amount.compareTo(b.amount);
        case LedgerSortField.entryType:
          cmp = a.entryType.index.compareTo(b.entryType.index);
        case LedgerSortField.createdAt:
          cmp = a.createdAt.compareTo(b.createdAt);
      }
      return sortDirection == LedgerSortDirection.ascending ? cmp : -cmp;
    });

    return filtered;
  });
});

/// Fetches all entries for a person (across all ledgers).
final ledgerEntriesByPersonProvider =
    FutureProvider.autoDispose.family<List<LedgerEntry>, int>((ref, personId) {
  final repository = ref.watch(ledgerRepositoryProvider);
  return repository.getEntriesByPerson(personId);
});

// ---------------------------------------------------------------------------
// Balance
// ---------------------------------------------------------------------------

/// Computes and streams the balance for a ledger.
final ledgerBalanceProvider =
    FutureProvider.autoDispose.family<LedgerBalance, int>((ref, ledgerId) {
  final repository = ref.watch(ledgerRepositoryProvider);
  return repository.computeBalance(ledgerId);
});

/// Auto-refreshing balance that watches the ledger and recomputes.
final ledgerBalanceStreamProvider =
    StreamProvider.autoDispose.family<LedgerBalance, int>((ref, ledgerId) {
  final repository = ref.watch(ledgerRepositoryProvider);

  return repository.watchEntries(ledgerId).asyncMap((_) {
    return repository.computeBalance(ledgerId);
  });
});

// ---------------------------------------------------------------------------
// Statistics
// ---------------------------------------------------------------------------

/// Summary statistics for a ledger.
final ledgerStatsProvider =
    FutureProvider.autoDispose.family<LedgerStats, int>((ref, ledgerId) {
  final repository = ref.watch(ledgerRepositoryProvider);
  return _computeStats(repository, ledgerId);
});

/// Auto-refreshing version of [ledgerStatsProvider].
final ledgerStatsStreamProvider =
    StreamProvider.autoDispose.family<LedgerStats, int>((ref, ledgerId) {
  final repository = ref.watch(ledgerRepositoryProvider);
  return repository.watchEntries(ledgerId).asyncMap((_) {
    return _computeStats(repository, ledgerId);
  });
});

Future<LedgerStats> _computeStats(LedgerRepository repo, int ledgerId) async {
  final entries = await repo.getEntries(ledgerId);

  int totalGive = 0;
  int totalReceive = 0;
  int totalDiscount = 0;
  int totalSale = 0;
  int totalPurchase = 0;
  int totalAdjustment = 0;
  int entryCount = entries.length;

  for (final e in entries) {
    switch (e.entryType) {
      case LedgerEntryType.give:
      case LedgerEntryType.borrow:
        totalGive += e.amount;
      case LedgerEntryType.receive:
      case LedgerEntryType.repayment:
        totalReceive += e.amount;
      case LedgerEntryType.discount:
        totalDiscount += e.amount;
      case LedgerEntryType.sale:
        totalSale += e.amount;
      case LedgerEntryType.purchase:
        totalPurchase += e.amount;
      case LedgerEntryType.adjustment:
        totalAdjustment += e.amount;
      case LedgerEntryType.opening:
      case LedgerEntryType.manual:
        break;
    }
  }

  return LedgerStats(
    totalGive: totalGive,
    totalReceive: totalReceive,
    totalDiscount: totalDiscount,
    totalSale: totalSale,
    totalPurchase: totalPurchase,
    totalAdjustment: totalAdjustment,
    entryCount: entryCount,
    netFlow: totalGive + totalSale - totalReceive - totalDiscount,
  );
}

/// Aggregate statistics for a ledger.
final class LedgerStats {
  const LedgerStats({
    required this.totalGive,
    required this.totalReceive,
    required this.totalDiscount,
    required this.totalSale,
    required this.totalPurchase,
    required this.totalAdjustment,
    required this.entryCount,
    required this.netFlow,
  });

  final int totalGive;
  final int totalReceive;
  final int totalDiscount;
  final int totalSale;
  final int totalPurchase;
  final int totalAdjustment;
  final int entryCount;
  final int netFlow;

  int get totalTransactions => totalGive + totalReceive + totalSale + totalPurchase;

  String describe() {
    return '${entryCount} entries · '
        'Give: $totalGive · Receive: $totalReceive · '
        'Net: $netFlow';
  }
}

// ---------------------------------------------------------------------------
// Action providers
// ---------------------------------------------------------------------------

typedef CreateEntryFn = Future<LedgerEntry> Function(LedgerEntry entry);
typedef UpdateEntryFn = Future<LedgerEntry> Function(LedgerEntry entry);
typedef DeleteEntryFn = Future<void> Function(int entryId);
typedef DeleteLedgerFn = Future<void> Function(int ledgerId);

final createLedgerEntryProvider = Provider<CreateEntryFn>((ref) {
  final repository = ref.watch(ledgerRepositoryProvider);
  return (LedgerEntry entry) => repository.createEntry(entry);
});

final updateLedgerEntryProvider = Provider<UpdateEntryFn>((ref) {
  final repository = ref.watch(ledgerRepositoryProvider);
  return (LedgerEntry entry) => repository.updateEntry(entry);
});

final deleteLedgerEntryProvider = Provider<DeleteEntryFn>((ref) {
  final repository = ref.watch(ledgerRepositoryProvider);
  return (int entryId) => repository.deleteEntry(entryId);
});

final deleteLedgerProvider = Provider<DeleteLedgerFn>((ref) {
  final repository = ref.watch(ledgerRepositoryProvider);
  return (int ledgerId) => repository.deleteLedger(ledgerId);
});
