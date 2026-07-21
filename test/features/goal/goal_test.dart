import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/core/app_exception.dart';
import 'package:paysa/features/goal/data/datasources/goal_local_datasource.dart';
import 'package:paysa/features/goal/data/models/goal_record.dart';
import 'package:paysa/features/goal/data/repositories/goal_repository_impl.dart';
import 'package:paysa/features/goal/domain/entities/goal.dart';

final class _MemDS implements GoalLocalDataSource {
  final _r = <int, GoalRecord>{}; int _n = 1;
  @override Future<GoalRecord> put(GoalRecord r) async { if (r.id == 0) r.id = _n++; _r[r.id] = r; return r; }
  @override Future<GoalRecord?> getById(int id) async => _r[id];
  @override Future<List<GoalRecord>> getAll() async => _r.values.toList();
  @override Stream<List<GoalRecord>> watchAll() async* { yield _r.values.toList(); }
  @override Future<void> delete(int id) async { _r.remove(id); }
}

final _now = DateTime.now();
FinancialGoal _g({int target = 1000000, int current = 0, String title = 'Emergency Fund', GoalType type = GoalType.emergencyFund}) =>
    FinancialGoal(title: title, goalType: type, targetAmountMinor: target, currentAmountMinor: current, createdAt: _now, updatedAt: _now);

void main() {
  late GoalRepositoryImpl repo;
  setUp(() { repo = GoalRepositoryImpl(_MemDS()); });

  group('create', () {
    test('creates with notStarted status', () async {
      final g = await repo.create(_g());
      expect(g.id, greaterThan(0)); expect(g.status, GoalStatus.notStarted);
    });
    test('rejects empty title', () async { expect(() => repo.create(_g(title: '')), throwsA(isA<AppException>())); });
    test('rejects zero target', () async { expect(() => repo.create(_g(target: 0)), throwsA(isA<AppException>())); });
  });

  group('calculations', () {
    test('remaining amount', () { final g = _g(target: 100000, current: 30000); expect(g.remainingAmount, 70000); });
    test('progress percent', () { final g = _g(target: 100000, current: 25000); expect(g.progressPercent, 25.0); });
    test('completed goal', () { final g = _g(target: 50000, current: 50000); expect(g.isCompleted, false); }); // status, not current
    test('required monthly saving', () { final g = _g(target: 120000, current: 0); expect(g.requiredMonthlySaving, greaterThan(0)); });
  });

  group('contribute', () {
    test('adds amount and updates status', () async {
      final g = await repo.create(_g(target: 100000, current: 20000));
      final updated = await repo.contribute(g.id, 50000);
      expect(updated.currentAmountMinor, 70000);
      expect(updated.status, GoalStatus.onTrack);
    });
    test('completes goal when target reached', () async {
      final g = await repo.create(_g(target: 100000, current: 80000));
      final updated = await repo.contribute(g.id, 20000);
      expect(updated.status, GoalStatus.completed);
    });
    test('rejects zero contribution', () async {
      final g = await repo.create(_g());
      expect(() => repo.contribute(g.id, 0), throwsA(isA<AppException>()));
    });
  });

  group('archive', () {
    test('archives goal', () async {
      final g = await repo.create(_g()); await repo.archive(g.id);
      expect((await repo.getById(g.id))?.isArchived, true);
    });
  });

  group('summary', () {
    test('returns totals', () async {
      await repo.create(_g(target: 50000, current: 10000));
      await repo.create(_g(target: 30000, current: 5000, title: 'Vacation', type: GoalType.vacation));
      final s = await repo.getSummary();
      expect(s.totalGoals, 2); expect(s.totalTarget, 80000); expect(s.totalCurrent, 15000);
    });
  });

  group('enums', () {
    test('9 goal types', () { expect(GoalType.values.length, 9); });
    test('3 priorities', () { expect(GoalPriority.values.length, 3); });
    test('5 statuses', () { expect(GoalStatus.values.length, 5); });
  });
}
