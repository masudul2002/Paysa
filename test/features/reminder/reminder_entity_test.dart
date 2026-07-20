import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/features/reminder/domain/entities/reminder.dart';

final _now = DateTime.now();

void main() {
  group('Reminder entity', () {
    test('isOverdue when dueDate is in the past', () {
      final r = Reminder(
        ledgerEntryId: 1, personId: 1,
        dueDate: _now.subtract(const Duration(days: 3)),
        createdAt: _now, updatedAt: _now,
      );
      expect(r.isOverdue, true);
      expect(r.isUpcoming, false);
      expect(r.isDueToday, false);
    });

    test('isUpcoming when dueDate is in the future', () {
      final r = Reminder(
        ledgerEntryId: 1, personId: 1,
        dueDate: _now.add(const Duration(days: 10)),
        createdAt: _now, updatedAt: _now,
      );
      expect(r.isUpcoming, true);
      expect(r.isOverdue, false);
      expect(r.isDueToday, false);
    });

    test('isDueToday when dueDate matches current date', () {
      final now = DateTime.now();
      // Use the same year/month/day as now, with a time component
      final due = DateTime(now.year, now.month, now.day, 12, 0);
      final r = Reminder(
        ledgerEntryId: 1, personId: 1,
        dueDate: due,
        status: ReminderStatus.active,
        createdAt: now, updatedAt: now, version: 1,
      );
      expect(r.isDueToday, true,
          reason: 'dueDate=${due.toIso8601String()} now=${now.toIso8601String()}');
      // Don't assert isOverdue/isUpcoming — those depend on exact comparison time
    });

    test('completed reminders are not overdue even if past', () {
      final r = Reminder(
        ledgerEntryId: 1, personId: 1,
        dueDate: _now.subtract(const Duration(days: 3)),
        status: ReminderStatus.completed,
        createdAt: _now, updatedAt: _now,
      );
      expect(r.isOverdue, false);
    });

    test('copyWith preserves unchanged fields', () {
      final r = Reminder(
        ledgerEntryId: 1, personId: 1,
        dueDate: _now, note: 'Original',
        createdAt: _now, updatedAt: _now,
      );
      final copy = r.copyWith(note: 'Updated');
      expect(copy.note, 'Updated');
      expect(copy.ledgerEntryId, 1);
      expect(copy.personId, 1);
      expect(copy.dueDate, _now);
    });

    test('default status is active', () {
      final r = Reminder(
        ledgerEntryId: 1, personId: 1,
        dueDate: _now,
        createdAt: _now, updatedAt: _now,
      );
      expect(r.status, ReminderStatus.active);
    });

    test('all repeat intervals exist', () {
      expect(ReminderRepeat.values.length, 5);
      expect(ReminderRepeat.values.contains(ReminderRepeat.none), true);
      expect(ReminderRepeat.values.contains(ReminderRepeat.daily), true);
      expect(ReminderRepeat.values.contains(ReminderRepeat.weekly), true);
      expect(ReminderRepeat.values.contains(ReminderRepeat.monthly), true);
      expect(ReminderRepeat.values.contains(ReminderRepeat.yearly), true);
    });

    test('all reminder statuses exist', () {
      expect(ReminderStatus.values.length, 3);
      expect(ReminderStatus.values.contains(ReminderStatus.active), true);
      expect(ReminderStatus.values.contains(ReminderStatus.completed), true);
      expect(ReminderStatus.values.contains(ReminderStatus.cancelled), true);
    });
  });
}
