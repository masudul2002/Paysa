/// A financial snapshot at a specific point in time.
final class FinancialSnapshot {
  const FinancialSnapshot({
    required this.snapshotDate,
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.netWorth,
    required this.totalReceivable,
    required this.totalPayable,
    required this.accountCount,
    required this.pendingPaymentCount,
    this.currency = 'USD',
  });

  final DateTime snapshotDate;
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final double netWorth;
  final double totalReceivable;
  final double totalPayable;
  final int accountCount;
  final int pendingPaymentCount;
  final String currency;
}

/// Dashboard-level aggregated data.
final class DashboardSnapshot {
  const DashboardSnapshot({
    required this.financial,
    required this.recentTransactions,
    required this.recentReceipts,
    required this.topCategories,
    required this.monthlyTrend,
    this.outstandingLoans = 0,
    this.overdueCount = 0,
  });

  final FinancialSnapshot financial;
  final List<TransactionSummary> recentTransactions;
  final List<ReceiptSummary> recentReceipts;
  final List<CategorySummary> topCategories;
  final List<MonthlySummary> monthlyTrend;
  final double outstandingLoans;
  final int overdueCount;
}

final class TransactionSummary {
  const TransactionSummary({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    this.categoryName,
  });
  final int id;
  final String type;
  final double amount;
  final String description;
  final DateTime date;
  final String? categoryName;
}

final class ReceiptSummary {
  const ReceiptSummary({
    required this.id,
    required this.receiptNumber,
    required this.amountMinor,
    required this.provider,
    required this.issuedAt,
  });
  final int id;
  final String receiptNumber;
  final int amountMinor;
  final String provider;
  final DateTime issuedAt;
}

final class CategorySummary {
  const CategorySummary({
    required this.categoryName,
    required this.totalAmount,
    required this.transactionCount,
    this.percentage = 0.0,
  });
  final String categoryName;
  final double totalAmount;
  final int transactionCount;
  final double percentage;
}

final class MonthlySummary {
  const MonthlySummary({
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    this.netAmount = 0,
  });
  final int year;
  final int month;
  final double totalIncome;
  final double totalExpense;
  final double netAmount;
}

final class CashFlowSummary {
  const CashFlowSummary({
    required this.totalInflow,
    required this.totalOutflow,
    required this.netCashFlow,
    required this.periodStart,
    required this.periodEnd,
    this.transactionCount = 0,
  });
  final double totalInflow;
  final double totalOutflow;
  final double netCashFlow;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int transactionCount;
}

final class OutstandingSummary {
  const OutstandingSummary({
    required this.totalReceivable,
    required this.totalPayable,
    required this.netOutstanding,
    required this.personCount,
  });
  final double totalReceivable;
  final double totalPayable;
  final double netOutstanding;
  final int personCount;
}
