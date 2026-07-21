import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/analytics_entities.dart';
import '../../data/services/analytics_engine_impl.dart';

final analyticsEngineProvider = Provider<AnalyticsEngineImpl>((ref) {
  return AnalyticsEngineImpl(
    getAccounts: () async => [],
    getTransactions: ({from, to}) async => [],
    getLedgers: () async => [],
    getPeople: () async => [],
    getPaymentRequests: ({statusFilter}) async => [],
    getReceipts: () async => [],
  );
});

final financialSnapshotProvider = FutureProvider.autoDispose<FinancialSnapshot>((ref) {
  return ref.watch(analyticsEngineProvider).getFinancialSnapshot();
});

final dashboardSnapshotProvider = FutureProvider.autoDispose<DashboardSnapshot>((ref) {
  return ref.watch(analyticsEngineProvider).getDashboardSnapshot();
});

final cashFlowProvider = FutureProvider.autoDispose.family<CashFlowSummary, _DateRange>((ref, range) {
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

class _DateRange {
  const _DateRange(this.start, this.end);
  final DateTime start;
  final DateTime end;

  @override bool operator ==(Object o) => o is _DateRange && o.start == start && o.end == end;
  @override int get hashCode => Object.hash(start, end);
}
