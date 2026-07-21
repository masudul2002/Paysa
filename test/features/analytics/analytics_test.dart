import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/features/analytics/domain/entities/analytics_entities.dart';
import 'package:paysa/features/analytics/data/services/analytics_engine_impl.dart';

final _now = DateTime.now();

Map<String, dynamic> _account({double balance = 0, bool archived = false}) => {
  'id': 1, 'balance': balance, 'isArchived': archived,
};

Map<String, dynamic> _tx({int type = 0, double amount = 0, DateTime? date, String cat = 'Food'}) => {
  'id': 1, 'type': type, 'amount': amount, 'description': 'test',
  'date': date ?? _now, 'categoryName': cat,
};

Map<String, dynamic> _ledger({double recv = 0, double pay = 0}) => {
  'receivableAmount': recv, 'payableAmount': pay,
};

Map<String, dynamic> _person() => {'id': 1, 'name': 'Test'};

Map<String, dynamic> _request({int status = 0}) => {
  'id': 1, 'amountMinor': 1000, 'status': status,
};

Map<String, dynamic> _receipt({int amount = 500}) => {
  'id': 1, 'receiptNumber': 'RCP-001', 'amountMinor': amount,
  'provider': 'cash', 'issuedAt': _now,
};

void main() {
  late AnalyticsEngineImpl engine;

  setUp(() {
    engine = AnalyticsEngineImpl(
      getAccounts: () async => [_account(balance: 150000)],
      getTransactions: ({from, to}) async => [
        _tx(type: 0, amount: 50000, cat: 'Salary'),
        _tx(type: 1, amount: 15000, cat: 'Food'),
        _tx(type: 1, amount: 8000, cat: 'Transport'),
      ],
      getLedgers: () async => [_ledger(recv: 75000, pay: 25000)],
      getPeople: () async => [_person(), _person()],
      getPaymentRequests: ({statusFilter}) async => [
        _request(status: 0), // draft
        _request(status: 1), // pending
        _request(status: 3), // paid
      ],
      getReceipts: () async => [_receipt(), _receipt(amount: 1000)],
    );
  });

  group('FinancialSnapshot', () {
    test('calculates total balance from active accounts', () async {
      final s = await engine.getFinancialSnapshot();
      expect(s.totalBalance, 150000);
      expect(s.accountCount, 1);
    });

    test('calculates income and expense', () async {
      final s = await engine.getFinancialSnapshot();
      expect(s.totalIncome, 50000);
      expect(s.totalExpense, 23000);
    });

    test('receivable and payable from ledgers', () async {
      final s = await engine.getFinancialSnapshot();
      expect(s.totalReceivable, 75000);
      expect(s.totalPayable, 25000);
    });

    test('pending count', () async {
      final s = await engine.getFinancialSnapshot();
      expect(s.pendingPaymentCount, 2);
    });
  });

  group('DashboardSnapshot', () {
    test('includes financial data', () async {
      final d = await engine.getDashboardSnapshot();
      expect(d.financial.totalBalance, 150000);
    });

    test('includes recent transactions', () async {
      final d = await engine.getDashboardSnapshot(recentCount: 5);
      expect(d.recentTransactions.length, 3);
    });

    test('includes recent receipts', () async {
      final d = await engine.getDashboardSnapshot();
      expect(d.recentReceipts.length, 2);
    });
  });

  group('CashFlow', () {
    test('calculates inflow and outflow', () async {
      final c = await engine.getCashFlow(
        _now.subtract(const Duration(days: 30)), _now,
      );
      expect(c.totalInflow, 50000);
      expect(c.totalOutflow, 23000);
      expect(c.netCashFlow, 27000);
    });
  });

  group('MonthlyTrends', () {
    test('returns 12 months', () async {
      final trends = await engine.getMonthlyTrends(_now.year);
      expect(trends.length, 12);
    });
  });

  group('OutstandingSummary', () {
    test('aggregates receivables and payables', () async {
      final o = await engine.getOutstandingSummary();
      expect(o.totalReceivable, 75000);
      expect(o.totalPayable, 25000);
      expect(o.personCount, 2);
    });
  });

  group('TopCategories', () {
    test('returns sorted by amount', () async {
      final cats = await engine.getTopCategories(
        _now.subtract(const Duration(days: 30)), _now,
      );
      expect(cats.length, 2);
      expect(cats.first.categoryName, 'Food');
      expect(cats.first.totalAmount, 15000);
    });
  });

  group('Entity constructors', () {
    test('FinancialSnapshot defaults', () {
      final s = FinancialSnapshot(
        snapshotDate: _now, totalBalance: 0, totalIncome: 0, totalExpense: 0,
        netWorth: 0, totalReceivable: 0, totalPayable: 0,
        accountCount: 0, pendingPaymentCount: 0,
      );
      expect(s.currency, 'USD');
    });

    test('CashFlowSummary defaults', () {
      final c = CashFlowSummary(
        totalInflow: 0, totalOutflow: 0, netCashFlow: 0,
        periodStart: _now, periodEnd: _now,
      );
      expect(c.transactionCount, 0);
    });
  });

  group('Edge cases', () {
    test('empty accounts yield zero balance', () async {
      final e = AnalyticsEngineImpl(
        getAccounts: () async => [],
        getTransactions: ({from, to}) async => [],
        getLedgers: () async => [],
        getPeople: () async => [],
        getPaymentRequests: ({statusFilter}) async => [],
        getReceipts: () async => [],
      );
      final s = await e.getFinancialSnapshot();
      expect(s.totalBalance, 0);
      expect(s.accountCount, 0);
      expect(s.pendingPaymentCount, 0);
    });

    test('archived accounts excluded from total', () async {
      final e = AnalyticsEngineImpl(
        getAccounts: () async => [
          _account(balance: 100),
          _account(balance: 200, archived: true),
        ],
        getTransactions: ({from, to}) async => [],
        getLedgers: () async => [],
        getPeople: () async => [],
        getPaymentRequests: ({statusFilter}) async => [],
        getReceipts: () async => [],
      );
      final s = await e.getFinancialSnapshot();
      expect(s.totalBalance, 100);
      expect(s.accountCount, 1);
    });

    test('empty categories', () async {
      final cats = await engine.getTopCategories(
        _now.subtract(const Duration(days: 30)), _now, limit: 10,
      );
      expect(cats.length, 2);
    });
  });
}
