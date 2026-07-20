import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/features/ledger/domain/entities/ledger.dart';
import 'package:paysa/features/ledger/domain/entities/statement.dart';

final _now = DateTime(2026, 7, 20);

void main() {
  group('generateStatement', () {
    test('empty entries returns zero balance', () {
      final s = generateStatement(
        personName: 'Rafiq Ahmed',
        personType: 'Customer',
        openingBalance: 0,
        entries: [],
      );
      expect(s.openingBalance, 0);
      expect(s.closingBalance, 0);
      expect(s.entries, isEmpty);
      expect(s.entryCount, 0);
    });

    test('opening balance carries through with no entries', () {
      final s = generateStatement(
        personName: 'Rafiq',
        personType: 'Customer',
        openingBalance: 50000,
        entries: [],
      );
      expect(s.openingBalance, 50000);
      expect(s.closingBalance, 50000);
    });

    test('give entries increase running balance', () {
      final s = generateStatement(
        personName: 'Rafiq',
        personType: 'Customer',
        openingBalance: 0,
        entries: [
          _entry(type: LedgerEntryType.give, amount: 50000, date: _now),
        ],
      );
      expect(s.entries.length, 1);
      expect(s.entries.first.runningBalance, 50000);
      expect(s.closingBalance, 50000);
      expect(s.totalGive, 50000);
    });

    test('receive decreases running balance', () {
      final s = generateStatement(
        personName: 'Rafiq',
        personType: 'Customer',
        openingBalance: 50000,
        entries: [
          _entry(type: LedgerEntryType.give, amount: 30000, date: _now.subtract(const Duration(days: 2))),
          _entry(type: LedgerEntryType.receive, amount: 10000, date: _now),
        ],
      );
      expect(s.entries.length, 2);
      // give(30000) → bal 80000, receive(10000) → bal 70000
      expect(s.entries.last.runningBalance, 70000);
      expect(s.closingBalance, 70000);
    });

    test('discount reduces balance', () {
      final s = generateStatement(
        personName: 'Rafiq',
        personType: 'Customer',
        openingBalance: 50000,
        entries: [
          _entry(type: LedgerEntryType.discount, amount: 15000, date: _now),
        ],
      );
      expect(s.closingBalance, 35000);
      expect(s.totalDiscount, 15000);
    });

    test('sale and purchase increase balance', () {
      final s = generateStatement(
        personName: 'Rafiq',
        personType: 'Customer',
        openingBalance: 0,
        entries: [
          _entry(type: LedgerEntryType.sale, amount: 20000, date: _now),
        ],
      );
      expect(s.closingBalance, 20000);
      expect(s.totalGive, 20000);
    });

    test('multiple entry types calculate correct totals', () {
      final s = generateStatement(
        personName: 'Rafiq',
        personType: 'Customer',
        openingBalance: 100000,
        entries: [
          _entry(type: LedgerEntryType.give, amount: 50000, date: _now.subtract(const Duration(days: 10))),
          _entry(type: LedgerEntryType.receive, amount: 30000, date: _now.subtract(const Duration(days: 5))),
          _entry(type: LedgerEntryType.sale, amount: 25000, date: _now.subtract(const Duration(days: 3))),
          _entry(type: LedgerEntryType.discount, amount: 5000, date: _now),
        ],
      );
      // 100000 + 50000 - 30000 + 25000 - 5000 = 140000
      expect(s.closingBalance, 140000);
      expect(s.totalGive, 75000);  // give + sale
      expect(s.totalReceive, 30000);
      expect(s.totalDiscount, 5000);
      expect(s.entryCount, 4);
    });

    test('entries sorted by date ascending', () {
      final s = generateStatement(
        personName: 'Rafiq',
        personType: 'Customer',
        openingBalance: 0,
        entries: [
          _entry(type: LedgerEntryType.give, amount: 20000, date: _now),
          _entry(type: LedgerEntryType.give, amount: 10000, date: _now.subtract(const Duration(days: 1))),
        ],
      );
      expect(s.entries.first.date, _now.subtract(const Duration(days: 1)));
      expect(s.entries.last.date, _now);
    });

    test('date range filtering', () {
      final periodStart = DateTime(2025, 1, 1);
      final periodEnd = DateTime(2025, 12, 31);
      final s = generateStatement(
        personName: 'Rafiq',
        personType: 'Customer',
        openingBalance: 0,
        periodStart: periodStart,
        periodEnd: periodEnd,
        entries: [
          _entry(type: LedgerEntryType.give, amount: 50000, date: DateTime(2024, 6, 15)),  // outside
          _entry(type: LedgerEntryType.give, amount: 30000, date: DateTime(2025, 6, 15)),  // inside
        ],
      );
      expect(s.entries.length, 1);
      expect(s.closingBalance, 30000);
    });

    test('person metadata preserved', () {
      final s = generateStatement(
        personName: 'Rafiq Ahmed',
        personPhone: '+8801712345678',
        personType: 'Customer',
        openingBalance: 0,
        entries: [],
      );
      expect(s.personName, 'Rafiq Ahmed');
      expect(s.personPhone, '+8801712345678');
      expect(s.personType, 'Customer');
    });

    test('adjustment increases balance', () {
      final s = generateStatement(
        personName: 'Rafiq',
        personType: 'Customer',
        openingBalance: 0,
        entries: [
          _entry(type: LedgerEntryType.adjustment, amount: 10000, date: _now),
        ],
      );
      expect(s.closingBalance, 10000);
      expect(s.totalGive, 10000);
    });

    test('closing balance matches last running balance', () {
      final s = generateStatement(
        personName: 'Rafiq',
        personType: 'Customer',
        openingBalance: 0,
        entries: [
          _entry(type: LedgerEntryType.give, amount: 10000, date: _now.subtract(const Duration(days: 2))),
          _entry(type: LedgerEntryType.receive, amount: 3000, date: _now.subtract(const Duration(days: 1))),
          _entry(type: LedgerEntryType.give, amount: 5000, date: _now),
        ],
      );
      expect(s.closingBalance, s.entries.last.runningBalance);
    });

    test('isSettled is true when closing balance is zero', () {
      final s = generateStatement(
        personName: 'Rafiq',
        personType: 'Customer',
        openingBalance: 50000,
        entries: [
          _entry(type: LedgerEntryType.receive, amount: 50000, date: _now),
        ],
      );
      expect(s.isSettled, true);
      expect(s.closingBalance, 0);
    });

    test('borrow treated as outgoing (person owes)', () {
      final s = generateStatement(
        personName: 'Rafiq',
        personType: 'Customer',
        openingBalance: 0,
        entries: [
          _entry(type: LedgerEntryType.borrow, amount: 25000, date: _now),
        ],
      );
      expect(s.closingBalance, 25000);
    });

    test('repayment treated as incoming', () {
      final s = generateStatement(
        personName: 'Rafiq',
        personType: 'Customer',
        openingBalance: 50000,
        entries: [
          _entry(type: LedgerEntryType.repayment, amount: 20000, date: _now),
        ],
      );
      expect(s.closingBalance, 30000);
    });
  });
}

LedgerEntry _entry({
  required LedgerEntryType type,
  required int amount,
  required DateTime date,
}) {
  return LedgerEntry(
    ledgerId: 1,
    personId: 1,
    entryType: type,
    amount: amount,
    transactionDate: date,
    createdAt: date,
    updatedAt: date,
  );
}
