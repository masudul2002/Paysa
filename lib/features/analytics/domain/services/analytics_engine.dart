import '../entities/analytics_entities.dart';

/// Read-only analytics engine.
///
/// All calculations are pure functions.
/// Never modifies data.
/// Cache-friendly design.
abstract interface class AnalyticsEngine {
  /// Today's financial snapshot.
  Future<FinancialSnapshot> getFinancialSnapshot();

  /// Dashboard-level aggregated data.
  Future<DashboardSnapshot> getDashboardSnapshot({int recentCount = 5});

  /// Cash flow for a date range.
  Future<CashFlowSummary> getCashFlow(DateTime start, DateTime end);

  /// Monthly summaries for a year.
  Future<List<MonthlySummary>> getMonthlyTrends(int year);

  /// Outstanding amounts across all People/Ledgers.
  Future<OutstandingSummary> getOutstandingSummary();

  /// Top categories by spending for a period.
  Future<List<CategorySummary>> getTopCategories(DateTime start, DateTime end, {int limit = 5});
}
