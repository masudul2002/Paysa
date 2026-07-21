import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/core/app_exception.dart';
import 'package:paysa/features/recurring/data/datasources/recurring_local_datasource.dart';
import 'package:paysa/features/recurring/data/models/recurring_record.dart';
import 'package:paysa/features/recurring/data/repositories/recurring_repository_impl.dart';
import 'package:paysa/features/recurring/domain/entities/recurring_transaction.dart';

final class _MemDS implements RecurringLocalDataSource {
  final _r = <int, RecurringRecord>{}; int _n = 1;
  @override Future<RecurringRecord> put(RecurringRecord r) async {
    if (r.id == 0) r.id = _n++; if (r.uuid.isEmpty) r.uuid = 'rt-${r.id}'; _r[r.id] = r; return r;
  }
  @override Future<RecurringRecord?> getById(int id) async => _r[id];
  @override Future<List<RecurringRecord>> getAll() async => _r.values.toList();
  @override Stream<List<RecurringRecord>> watchAll() async* { yield _r.values.toList(); }
  @override Future<void> delete(int id) async { _r.remove(id); }
}

final _now = DateTime.now();

RecurringTransaction _tpl({
  String title = 'Test', int amount = 50000,
  RecurringFrequency freq = RecurringFrequency.monthly,
  RecurringStatus status = RecurringStatus.draft,
}) => RecurringTransaction(
  title: title, amountMinor: amount, transactionType: 1,
  accountId: 1, frequency: freq, status: status,
  createdAt: _now, updatedAt: _now,
);

void main() {
  late RecurringRepositoryImpl repo;

  setUp(() { repo = RecurringRepositoryImpl(_MemDS()); });

  group('create', () {
    test('creates a template', () async {
      final t = await repo.create(_tpl());
      expect(t.id, greaterThan(0));
      expect(t.status, RecurringStatus.draft);
    });

    test('rejects empty title', () async {
      expect(() => repo.create(_tpl(title: '')), throwsA(isA<AppException>()));
    });

    test('rejects zero amount', () async {
      expect(() => repo.create(_tpl(amount: 0)), throwsA(isA<AppException>()));
    });
  });

  group('status lifecycle', () {
    test('activate and pause', () async {
      final t = await repo.create(_tpl());
      await repo.activate(t.id);
      expect((await repo.getById(t.id))?.isActive, true);

      await repo.pause(t.id);
      expect((await repo.getById(t.id))?.status, RecurringStatus.paused);
    });
  });

  group('schedule calculations', () {
    test('monthly schedule calculates next date', () {
      final t = _tpl(freq: RecurringFrequency.monthly);
      final next = t.calculateNextDate(DateTime(2026, 1, 15));
      expect(next, DateTime(2026, 2, 15));
    });

    test('weekly schedule', () {
      final t = _tpl(freq: RecurringFrequency.weekly);
      final next = t.calculateNextDate(DateTime(2026, 1, 1));
      expect(next, DateTime(2026, 1, 8));
    });

    test('daily schedule', () {
      final t = _tpl(freq: RecurringFrequency.daily);
      final next = t.calculateNextDate(DateTime(2026, 1, 1));
      expect(next, DateTime(2026, 1, 2));
    });

    test('yearly schedule', () {
      final t = _tpl(freq: RecurringFrequency.yearly);
      final next = t.calculateNextDate(DateTime(2026, 6, 15));
      expect(next, DateTime(2027, 6, 15));
    });

    test('weekdays skips saturday and sunday', () {
      final t = _tpl(freq: RecurringFrequency.weekdays);
      final fri = DateTime(2026, 7, 24); // Friday
      final next = t.calculateNextDate(fri);
      expect(next?.weekday, lessThanOrEqualTo(5)); // Monday
    });

    test('end date stops execution', () {
      final t = RecurringTransaction(
        title: 'Test', amountMinor: 1000, transactionType: 1,
        accountId: 1, frequency: RecurringFrequency.monthly,
        endDate: DateTime(2025, 12, 31),
        createdAt: _now, updatedAt: _now,
      );
      final next = t.calculateNextDate(DateTime(2026, 1, 1));
      expect(next, isNull);
    });
  });

  group('duplicate', () {
    test('creates a copy with draft status', () async {
      final t = await repo.create(_tpl(title: 'Rent'));
      await repo.activate(t.id);
      final dup = await repo.duplicate(t.id);
      expect(dup.title, 'Rent (copy)');
      expect(dup.status, RecurringStatus.draft);
      expect(dup.id, isNot(t.id));
    });
  });

  group('execute', () {
    test('increments count and updates next date', () async {
      final t = await repo.create(_tpl(freq: RecurringFrequency.monthly));
      await repo.activate(t.id);
      final executed = await repo.execute(t.id);
      expect(executed.executionCount, 1);
      expect(executed.lastExecutionDate, isNotNull);
      expect(executed.nextExecutionDate, isNotNull);
    });
  });

  group('getDue / getUpcoming', () {
    test('due returns active templates past due', () async {
      final t = await repo.create(_tpl());
      await repo.activate(t.id);
      // nextExecutionDate defaults to now, so it's considered "due"
      final due = await repo.getDue();
      expect(due.isNotEmpty, true);
    });
  });

  group('archive / delete', () {
    test('soft delete', () async {
      final t = await repo.create(_tpl());
      await repo.delete(t.id);
      expect((await repo.getAll()).where((x) => x.id == t.id), isEmpty);
    });
  });

  group('RecurringFrequency', () {
    test('all 6 frequencies have labels', () {
      expect(RecurringFrequency.values.length, 6);
      for (final f in RecurringFrequency.values) expect(f.label.isNotEmpty, true);
    });
  });

  group('RecurringStatus', () {
    test('all 5 statuses have labels', () {
      expect(RecurringStatus.values.length, 5);
      for (final s in RecurringStatus.values) expect(s.label.isNotEmpty, true);
    });
  });
}
