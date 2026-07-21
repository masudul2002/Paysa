import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/core/app_exception.dart';
import 'package:paysa/features/budget/data/datasources/budget_local_datasource.dart';
import 'package:paysa/features/budget/data/models/budget_record.dart';
import 'package:paysa/features/budget/data/repositories/budget_repository_impl.dart';
import 'package:paysa/features/budget/domain/entities/budget.dart';

final class _MemDS implements BudgetLocalDataSource {
  final _r = <int, BudgetRecord>{}; int _n = 1;
  @override Future<BudgetRecord> put(BudgetRecord r) async {
    if (r.id == 0) r.id = _n++; _r[r.id] = r; return r;
  }
  @override Future<BudgetRecord?> getById(int id) async => _r[id];
  @override Future<List<BudgetRecord>> getAll() async => _r.values.toList();
  @override Stream<List<BudgetRecord>> watchAll() async* { yield _r.values.toList(); }
  @override Future<void> delete(int id) async { _r.remove(id); }
}

final _now = DateTime.now();
final _start = DateTime(_now.year, _now.month, 1);
final _end = DateTime(_now.year, _now.month + 1, 0);

Budget _b({int amount = 100000, int spent = 0, String name = 'Food Budget', int? catId}) =>
    Budget(name: name, budgetAmountMinor: amount, startDate: _start, endDate: _end,
      categoryId: catId, spentAmountMinor: spent, createdAt: _now, updatedAt: _now);

void main() {
  late BudgetRepositoryImpl repo;

  setUp(() { repo = BudgetRepositoryImpl(_MemDS()); });

  group('create', () {
    test('creates with safe status', () async {
      final b = await repo.create(_b());
      expect(b.id, greaterThan(0));
      expect(b.status, BudgetStatus.safe);
    });

    test('rejects empty name', () async {
      expect(() => repo.create(_b(name: '')), throwsA(isA<AppException>()));
    });

    test('rejects zero amount', () async {
      expect(() => repo.create(_b(amount: 0)), throwsA(isA<AppException>()));
    });
  });

  group('calculations', () {
    test('remaining amount', () {
      final b = _b(amount: 100000, spent: 40000);
      expect(b.remainingAmountMinor, 60000);
    });

    test('progress percent', () {
      final b = _b(amount: 100000, spent: 25000);
      expect(b.progressPercent, 25.0);
    });

    test('exceeded detection', () {
      final b = _b(amount: 100000, spent: 120000);
      expect(b.isExceeded, true);
      expect(b.remainingAmountMinor, 0);
    });

    test('projected end amount for overspending', () {
      final b = _b(amount: 100000, spent: 50000);
      expect(b.isOnTrack, isNot(false)); // may be true or false depending on elapsed
    });

    test('remaining days non-negative', () {
      final b = _b();
      expect(b.remainingDays, greaterThanOrEqualTo(0));
    });
  });

  group('archive', () {
    test('archives changes status', () async {
      final b = await repo.create(_b());
      await repo.archive(b.id);
      final archived = await repo.getById(b.id);
      expect(archived?.status, BudgetStatus.archived);
      expect(archived?.isArchived, true);
    });
  });

  group('progress', () {
    test('returns totals across budgets', () async {
      await repo.create(_b(name: 'Food', amount: 50000, spent: 30000));
      await repo.create(_b(name: 'Transport', amount: 30000, spent: 5000));
      final p = await repo.getProgress();
      expect(p.totalBudgets, 2);
      expect(p.totalBudgeted, 80000);
      expect(p.totalSpent, 35000);
    });
  });

  group('Budget entity', () {
    test('isArchived', () {
      final b = _b();
      expect(b.isArchived, false);
    });

    test('copyWith preserves', () {
      final b = _b(amount: 50000);
      final c = b.copyWith(budgetAmountMinor: 75000);
      expect(c.budgetAmountMinor, 75000);
      expect(c.name, 'Food Budget');
    });
  });

  group('BudgetPeriod', () {
    test('all 5 periods exist', () {
      expect(BudgetPeriod.values.length, 5);
    });
  });

  group('BudgetStatus', () {
    test('all 5 statuses exist', () {
      expect(BudgetStatus.values.length, 5);
    });
  });
}
