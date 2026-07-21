import '../../domain/entities/analytics_entities.dart';
import '../../domain/services/analytics_engine.dart';

/// Read-only implementation of [AnalyticsEngine].
///
/// All data is read from existing repositories.
/// No mutations performed.
final class AnalyticsEngineImpl implements AnalyticsEngine {
  AnalyticsEngineImpl({
    required this.getAccounts,
    required this.getTransactions,
    required this.getLedgers,
    required this.getPeople,
    required this.getPaymentRequests,
    required this.getReceipts,
  });

  final Future<List<Map<String, dynamic>>> Function() getAccounts;
  final Future<List<Map<String, dynamic>>> Function({DateTime? from, DateTime? to}) getTransactions;
  final Future<List<Map<String, dynamic>>> Function() getLedgers;
  final Future<List<Map<String, dynamic>>> Function() getPeople;
  final Future<List<Map<String, dynamic>>> Function({int? statusFilter}) getPaymentRequests;
  final Future<List<Map<String, dynamic>>> Function() getReceipts;

  @override
  Future<FinancialSnapshot> getFinancialSnapshot() async {
    final accounts = await getAccounts();
    final transactions = await getTransactions();
    final ledgers = await getLedgers();
    final requests = await getPaymentRequests();

    double totalBalance = 0;
    int accountCount = 0;
    for (final a in accounts) {
      if (a['isArchived'] == true) continue;
      totalBalance += (a['balance'] as num?)?.toDouble() ?? 0;
      accountCount++;
    }

    double totalIncome = 0;
    double totalExpense = 0;
    for (final t in transactions) {
      final type = t['type'] as int? ?? 0;
      final amount = (t['amount'] as num?)?.toDouble() ?? 0;
      if (type == 0) totalIncome += amount; // income
      if (type == 1) totalExpense += amount; // expense
    }

    double receivable = 0;
    double payable = 0;
    for (final l in ledgers) {
      receivable += (l['receivableAmount'] as num?)?.toDouble() ?? 0;
      payable += (l['payableAmount'] as num?)?.toDouble() ?? 0;
    }

    int pendingCount = 0;
    for (final r in requests) {
      final status = r['status'] as int? ?? 0;
      if (status <= 1) pendingCount++; // draft or pending
    }

    return FinancialSnapshot(
      snapshotDate: DateTime.now(),
      totalBalance: totalBalance,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netWorth: totalBalance,
      totalReceivable: receivable,
      totalPayable: payable,
      accountCount: accountCount,
      pendingPaymentCount: pendingCount,
    );
  }

  @override
  Future<DashboardSnapshot> getDashboardSnapshot({int recentCount = 5}) async {
    final financial = await getFinancialSnapshot();
    final allTx = await getTransactions();
    final allReceipts = await getReceipts();
    final cats = await getTopCategories(
      DateTime.now().subtract(const Duration(days: 30)),
      DateTime.now(),
    );

    final recentTx = allTx.take(recentCount).map((t) => TransactionSummary(
      id: t['id'] as int? ?? 0,
      type: (t['type'] as int? ?? 0) == 0 ? 'Income' : 'Expense',
      amount: (t['amount'] as num?)?.toDouble() ?? 0,
      description: t['description'] as String? ?? '',
      date: t['date'] as DateTime? ?? DateTime.now(),
    )).toList();

    final recentRc = allReceipts.take(recentCount).map((r) => ReceiptSummary(
      id: r['id'] as int? ?? 0,
      receiptNumber: r['receiptNumber'] as String? ?? '',
      amountMinor: r['amountMinor'] as int? ?? 0,
      provider: r['provider'] as String? ?? '',
      issuedAt: r['issuedAt'] as DateTime? ?? DateTime.now(),
    )).toList();

    return DashboardSnapshot(
      financial: financial,
      recentTransactions: recentTx,
      recentReceipts: recentRc,
      topCategories: cats,
      monthlyTrend: await getMonthlyTrends(DateTime.now().year),
    );
  }

  @override
  Future<CashFlowSummary> getCashFlow(DateTime start, DateTime end) async {
    final txs = await getTransactions(from: start, to: end);
    double inflow = 0, outflow = 0;
    for (final t in txs) {
      final type = t['type'] as int? ?? 0;
      final amount = (t['amount'] as num?)?.toDouble() ?? 0;
      if (type == 0) inflow += amount;
      if (type == 1) outflow += amount;
    }
    return CashFlowSummary(
      totalInflow: inflow, totalOutflow: outflow,
      netCashFlow: inflow - outflow,
      periodStart: start, periodEnd: end,
      transactionCount: txs.length,
    );
  }

  @override
  Future<List<MonthlySummary>> getMonthlyTrends(int year) async {
    final summaries = <MonthlySummary>[];
    for (int m = 1; m <= 12; m++) {
      final start = DateTime(year, m, 1);
      final end = m < 12 ? DateTime(year, m + 1, 1) : DateTime(year + 1, 1, 1);
      final txs = await getTransactions(from: start, to: end);
      double income = 0, expense = 0;
      for (final t in txs) {
        final type = t['type'] as int? ?? 0;
        final amount = (t['amount'] as num?)?.toDouble() ?? 0;
        if (type == 0) income += amount;
        if (type == 1) expense += amount;
      }
      summaries.add(MonthlySummary(
        year: year, month: m,
        totalIncome: income, totalExpense: expense,
        netAmount: income - expense,
      ));
    }
    return summaries;
  }

  @override
  Future<OutstandingSummary> getOutstandingSummary() async {
    final ledgers = await getLedgers();
    final people = await getPeople();
    double receivable = 0, payable = 0;
    for (final l in ledgers) {
      receivable += (l['receivableAmount'] as num?)?.toDouble() ?? 0;
      payable += (l['payableAmount'] as num?)?.toDouble() ?? 0;
    }
    return OutstandingSummary(
      totalReceivable: receivable, totalPayable: payable,
      netOutstanding: receivable - payable,
      personCount: people.length,
    );
  }

  @override
  Future<List<CategorySummary>> getTopCategories(DateTime start, DateTime end, {int limit = 5}) async {
    final txs = await getTransactions(from: start, to: end);
    final map = <String, double>{};
    final count = <String, int>{};
    double total = 0;

    for (final t in txs) {
      if ((t['type'] as int? ?? 0) != 1) continue; // expense only
      final cat = t['categoryName'] as String? ?? 'Uncategorized';
      final amount = (t['amount'] as num?)?.toDouble() ?? 0;
      map[cat] = (map[cat] ?? 0) + amount;
      count[cat] = (count[cat] ?? 0) + 1;
      total += amount;
    }

    final sorted = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).map((e) => CategorySummary(
      categoryName: e.key,
      totalAmount: e.value,
      transactionCount: count[e.key] ?? 0,
      percentage: total > 0 ? (e.value / total) * 100 : 0,
    )).toList();
  }
}
