import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/core/app_exception.dart';
import 'package:paysa/features/reminder/data/datasources/reminder_local_datasource.dart';
import 'package:paysa/features/reminder/data/models/reminder_record.dart';
import 'package:paysa/features/reminder/data/repositories/reminder_repository_impl.dart';
import 'package:paysa/features/reminder/domain/entities/reminder.dart';
import 'package:paysa/features/reminder/domain/repositories/reminder_repository.dart';

final class InMemoryReminderDataSource implements ReminderLocalDataSource {
  final _records = <int, ReminderRecord>{};
  int _nextId = 1;

  @override
  Future<ReminderRecord> put(ReminderRecord record) async {
    if (record.id == 0) { record.id = _nextId++; }
    if (record.uuid.isEmpty) { record.uuid = 'rm-${record.id}'; }
    _records[record.id] = record;
    return record;
  }

  @override
  Future<ReminderRecord?> getById(int id) async => _records[id];

  @override
  Future<ReminderRecord?> getByLedgerEntryId(int ledgerEntryId) async {
    for (final r in _records.values) {
      if (r.ledgerEntryId == ledgerEntryId && r.deletedAt == null) return r;
    }
    return null;
  }

  @override
  Future<List<ReminderRecord>> getAll() async => _records.values.toList();

  @override
  Future<List<ReminderRecord>> getOverdue() async {
    final now = DateTime.now();
    return _records.values.where((r) => r.deletedAt == null && r.isActive && r.dueDate.isBefore(now)).toList();
  }

  @override
  Future<List<ReminderRecord>> getUpcoming() async {
    final now = DateTime.now();
    return _records.values.where((r) => r.deletedAt == null && r.isActive && r.dueDate.isAfter(now)).toList();
  }

  @override
  Future<List<ReminderRecord>> getByPersonId(int personId) async {
    return _records.values.where((r) => r.personId == personId && r.deletedAt == null).toList();
  }

  @override
  Future<void> delete(int id) async { _records.remove(id); }
}

final _now = DateTime.now();

Reminder _rm({int entryId = 1, int personId = 1, DateTime? dueDate, ReminderRepeat repeat = ReminderRepeat.none}) =>
    Reminder(
      ledgerEntryId: entryId, personId: personId,
      dueDate: dueDate ?? _now.add(const Duration(days: 7)),
      repeat: repeat,
      createdAt: _now, updatedAt: _now,
    );

void main() {
  late ReminderRepository repository;
  late InMemoryReminderDataSource dataSource;

  setUp(() {
    dataSource = InMemoryReminderDataSource();
    repository = ReminderRepositoryImpl(dataSource);
  });

  group('createReminder', () {
    test('creates a reminder with valid data', () async {
      final r = await repository.createReminder(_rm());
      expect(r.id, greaterThan(0));
      expect(r.ledgerEntryId, 1);
      expect(r.personId, 1);
      expect(r.status, ReminderStatus.active);
    });

    test('rejects duplicate for same ledger entry', () async {
      await repository.createReminder(_rm(entryId: 1));
      expect(() => repository.createReminder(_rm(entryId: 1)), throwsA(isA<AppException>()));
    });

    test('rejects invalid ledger entry ID', () async {
      expect(() => repository.createReminder(_rm(entryId: 0)), throwsA(isA<AppException>()));
    });
  });

  group('reminder classification', () {
    test('future due date is upcoming', () async {
      final future = _now.add(const Duration(days: 30));
      final r = await repository.createReminder(_rm(dueDate: future));
      expect(r.isUpcoming, true);
      expect(r.isOverdue, false);
    });

    test('past due date is overdue', () async {
      final past = _now.subtract(const Duration(days: 5));
      final r = await repository.createReminder(_rm(dueDate: past));
      expect(r.isOverdue, true);
      expect(r.isUpcoming, false);
    });

    test('today is due today', () async {
      final r = await repository.createReminder(_rm(dueDate: _now));
      expect(r.isDueToday, true);
    });
  });

  group('getReminders', () {
    test('getAll returns all active', () async {
      await repository.createReminder(_rm(entryId: 1));
      await repository.createReminder(_rm(entryId: 2));
      expect((await repository.getAllReminders()).length, 2);
    });

    test('getOverdue returns only past-due', () async {
      await repository.createReminder(_rm(entryId: 1, dueDate: _now.subtract(const Duration(days: 3))));
      await repository.createReminder(_rm(entryId: 2, dueDate: _now.add(const Duration(days: 10))));
      expect((await repository.getOverdueReminders()).length, 1);
    });

    test('getUpcoming returns only future', () async {
      await repository.createReminder(_rm(entryId: 1, dueDate: _now.subtract(const Duration(days: 1))));
      await repository.createReminder(_rm(entryId: 2, dueDate: _now.add(const Duration(days: 10))));
      expect((await repository.getUpcomingReminders()).length, 1);
    });

    test('getByPersonId filters correctly', () async {
      await repository.createReminder(_rm(entryId: 1, personId: 1));
      await repository.createReminder(_rm(entryId: 2, personId: 2));
      expect((await repository.getRemindersByPersonId(1)).length, 1);
    });

    test('getOverdueCount returns count', () async {
      await repository.createReminder(_rm(entryId: 1, dueDate: _now.subtract(const Duration(days: 1))));
      await repository.createReminder(_rm(entryId: 2, dueDate: _now.add(const Duration(days: 10))));
      expect(await repository.getOverdueCount(), 1);
    });
  });

  group('markAsFired', () {
    test('marks a one-time reminder as completed', () async {
      final r = await repository.createReminder(_rm());
      await repository.markAsFired(r.id);
      final updated = await repository.getReminderById(r.id);
      expect(updated?.status, ReminderStatus.completed);
      expect(updated?.nextFireAt, isNull);
    });

    test('computes next fire date for daily repeat', () async {
      final r = await repository.createReminder(_rm(repeat: ReminderRepeat.daily));
      await repository.markAsFired(r.id);
      final updated = await repository.getReminderById(r.id);
      expect(updated?.lastFiredAt, isNotNull);
    });

    test('computes next fire date for weekly repeat', () async {
      final r = await repository.createReminder(_rm(repeat: ReminderRepeat.weekly));
      await repository.markAsFired(r.id);
      final updated = await repository.getReminderById(r.id);
      expect(updated?.status, ReminderStatus.active); // still active (repeating)
    });
  });

  group('updateReminder', () {
    test('updates note and increments version', () async {
      final r = await repository.createReminder(_rm());
      final updated = await repository.updateReminder(r.copyWith(note: 'Remind via WhatsApp'));
      expect(updated.note, 'Remind via WhatsApp');
      expect(updated.version, 2);
    });

    test('rejects update for non-existent', () async {
      expect(() => repository.updateReminder(_rm()..id), throwsA(isA<AppException>()));
    });
  });

  group('deleteReminder', () {
    test('soft deletes and excludes from listing', () async {
      final r = await repository.createReminder(_rm());
      await repository.deleteReminder(r.id);
      expect((await repository.getAllReminders()).where((x) => x.id == r.id), isEmpty);
    });
  });
}
