import 'ledger.dart';

/// A complete statement for a person's ledger, ready for preview and export.
final class Statement {
  const Statement({
    required this.personName,
    required this.personPhone,
    required this.personType,
    required this.createdAt,
    required this.periodStart,
    required this.periodEnd,
    required this.openingBalance,
    required this.closingBalance,
    required this.totalGive,
    required this.totalReceive,
    required this.totalDiscount,
    required this.entryCount,
    required this.entries,
  });

  final String personName;
  final String? personPhone;
  final String personType;
  final DateTime createdAt;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int openingBalance;
  final int closingBalance;
  final int totalGive;
  final int totalReceive;
  final int totalDiscount;
  final int entryCount;
  final List<StatementEntry> entries;

  int get totalOutstanding => closingBalance;
  bool get isSettled => closingBalance == 0;
}

/// A single line in the statement with running balance.
final class StatementEntry {
  const StatementEntry({
    required this.date,
    required this.type,
    required this.description,
    required this.amount,
    required this.runningBalance,
  });

  final DateTime date;
  final String type;
  final String? description;
  final int amount;
  final int runningBalance;
}

/// Generates a [Statement] from a list of ledger entries.
Statement generateStatement({
  required String personName,
  String? personPhone,
  required String personType,
  required int openingBalance,
  required List<LedgerEntry> entries,
  DateTime? periodStart,
  DateTime? periodEnd,
}) {
  final now = DateTime.now();
  final start = periodStart ?? DateTime(2020, 1, 1);
  final end = periodEnd ?? now;

  // Filter entries within the period
  final periodEntries = entries
      .where((e) =>
          !e.isDeleted &&
          !e.transactionDate.isBefore(start) &&
          !e.transactionDate.isAfter(end))
      .toList()
    ..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));

  // Calculate running balance starting from opening balance
  // Balance formula: opening + give/borrow/sale/purchase/adjustment
  //                          - receive/repayment/discount
  int runningBalance = openingBalance;
  final statementEntries = <StatementEntry>[];

  for (final entry in periodEntries) {
    switch (entry.entryType) {
      case LedgerEntryType.give:
      case LedgerEntryType.borrow:
      case LedgerEntryType.sale:
      case LedgerEntryType.purchase:
      case LedgerEntryType.adjustment:
        runningBalance += entry.amount;
      case LedgerEntryType.receive:
      case LedgerEntryType.repayment:
      case LedgerEntryType.discount:
        runningBalance -= entry.amount;
      case LedgerEntryType.opening:
      case LedgerEntryType.manual:
        break;
    }

    statementEntries.add(StatementEntry(
      date: entry.transactionDate,
      type: entry.entryType.label,
      description: entry.description,
      amount: entry.amount,
      runningBalance: runningBalance,
    ));
  }

  // Calculate totals
  int totalGive = 0;
  int totalReceive = 0;
  int totalDiscount = 0;

  for (final entry in periodEntries) {
    switch (entry.entryType) {
      case LedgerEntryType.give:
      case LedgerEntryType.borrow:
      case LedgerEntryType.sale:
      case LedgerEntryType.purchase:
        totalGive += entry.amount;
      case LedgerEntryType.receive:
      case LedgerEntryType.repayment:
        totalReceive += entry.amount;
      case LedgerEntryType.discount:
        totalDiscount += entry.amount;
      case LedgerEntryType.adjustment:
        totalGive += entry.amount;
      case LedgerEntryType.opening:
      case LedgerEntryType.manual:
        break;
    }
  }

  return Statement(
    personName: personName,
    personPhone: personPhone,
    personType: personType,
    createdAt: now,
    periodStart: start,
    periodEnd: end,
    openingBalance: openingBalance,
    closingBalance: runningBalance,
    totalGive: totalGive,
    totalReceive: totalReceive,
    totalDiscount: totalDiscount,
    entryCount: statementEntries.length,
    entries: statementEntries,
  );
}
