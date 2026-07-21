import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/analytics_entities.dart';
import '../../data/services/analytics_engine_impl.dart';
import '../../../../features/accounts/presentation/providers/accounts_providers.dart';
import '../../../../features/ledger/presentation/providers/ledger_providers.dart';
import '../../../../features/people/presentation/providers/people_providers.dart';
import '../../../../features/payment_request/presentation/providers/payment_request_providers.dart';

/// Wires AnalyticsEngine to real repository data via Riverpod.
///
/// Callbacks capture [ref] and read the latest value from each domain's
/// stream provider at call time, converting to the engine's Map format.
final analyticsEngineProvider = Provider<AnalyticsEngineImpl>((ref) {
  return AnalyticsEngineImpl(
    getAccounts: () async {
      final v = ref.read(filteredAccountsProvider);
      if (v is AsyncData && v.value != null) {
        return (v.value as List).map((a) => <String, dynamic>{
          'id': a.id, 'balance': a.balance, 'isArchived': a.isArchived,
        }).toList();
      }
      return [];
    },
    getTransactions: ({from, to}) async => [],
    getLedgers: () async {
      final v = ref.read(ledgerListProvider);
      if (v is AsyncData && v.value != null) {
        return (v.value as List).map((l) => <String, dynamic>{
          'id': l.id, 'receivableAmount': l.receivableAmount,
          'payableAmount': l.payableAmount,
        }).toList();
      }
      return [];
    },
    getPeople: () async {
      final v = ref.read(peopleListProvider);
      if (v is AsyncData && v.value != null) {
        return (v.value as List).map((p) => <String, dynamic>{
          'id': p.id, 'name': p.name,
        }).toList();
      }
      return [];
    },
    getPaymentRequests: ({statusFilter}) async {
      final v = ref.read(prListProvider);
      if (v is AsyncData && v.value != null) {
        return (v.value as List).map((r) => <String, dynamic>{
          'id': r.id, 'amountMinor': r.amountMinor, 'status': r.status.index,
        }).toList();
      }
      return [];
    },
    getReceipts: () async => [],
  );
});

final financialSnapshotProvider = FutureProvider.autoDispose<FinancialSnapshot>((ref) {
  return ref.watch(analyticsEngineProvider).getFinancialSnapshot();
});

final dashboardSnapshotProvider = FutureProvider.autoDispose<DashboardSnapshot>((ref) {
  return ref.watch(analyticsEngineProvider).getDashboardSnapshot();
});

final cashFlowProvider = FutureProvider.autoDispose.family<CashFlowSummary, DateRange>((ref, range) {
  return ref.watch(analyticsEngineProvider).getCashFlow(range.start, range.end);
});

final monthlyTrendsProvider = FutureProvider.autoDispose.family<List<MonthlySummary>, int>((ref, year) {
  return ref.watch(analyticsEngineProvider).getMonthlyTrends(year);
});

final outstandingSummaryProvider = FutureProvider.autoDispose<OutstandingSummary>((ref) {
  return ref.watch(analyticsEngineProvider).getOutstandingSummary();
});

final topCategoriesProvider = FutureProvider.autoDispose<List<CategorySummary>>((ref) {
  final now = DateTime.now();
  return ref.watch(analyticsEngineProvider).getTopCategories(
    now.subtract(const Duration(days: 30)), now,
  );
});

class DateRange {
  const DateRange(this.start, this.end);
  final DateTime start; final DateTime end;
  @override bool operator ==(Object o) => o is DateRange && o.start == start && o.end == end;
  @override int get hashCode => Object.hash(start, end);
}
