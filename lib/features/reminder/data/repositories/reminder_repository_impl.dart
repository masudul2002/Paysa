import 'package:paysa/core/app_exception.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../datasources/reminder_local_datasource.dart';
import '../models/reminder_record.dart';

final class ReminderRepositoryImpl implements ReminderRepository {
  const ReminderRepositoryImpl(this._dataSource);

  final ReminderLocalDataSource _dataSource;

  @override
  Future<Reminder> createReminder(Reminder reminder) async {
    if (reminder.ledgerEntryId <= 0) throw AppException('Ledger entry ID is required.');
    if (reminder.personId <= 0) throw AppException('Person ID is required.');

    final existing = await _dataSource.getByLedgerEntryId(reminder.ledgerEntryId);
    if (existing != null) throw AppException('A reminder already exists for this ledger entry.');

    final now = DateTime.now();
    final record = reminder.copyWith(
      reminderDate: reminder.reminderDate ?? reminder.dueDate,
      nextFireAt: reminder.reminderDate ?? reminder.dueDate,
      createdAt: now, updatedAt: now, version: 1,
    ).toRecord();

    final saved = await _dataSource.put(record);
    return saved.toEntity();
  }

  @override
  Future<Reminder> updateReminder(Reminder reminder) async {
    final existing = await _dataSource.getById(reminder.id);
    if (existing == null) throw AppException('Reminder not found.');

    final now = DateTime.now();
    final record = reminder.copyWith(updatedAt: now, version: existing.version + 1).toRecord();
    final saved = await _dataSource.put(record);
    return saved.toEntity();
  }

  @override
  Future<void> deleteReminder(int reminderId) async {
    final existing = await _dataSource.getById(reminderId);
    if (existing == null) throw AppException('Reminder not found.');
    existing.deletedAt = DateTime.now();
    await _dataSource.put(existing);
  }

  @override
  Future<Reminder?> getReminderById(int reminderId) async {
    final record = await _dataSource.getById(reminderId);
    return record?.toEntity();
  }

  @override
  Future<Reminder?> getReminderByLedgerEntryId(int ledgerEntryId) async {
    final record = await _dataSource.getByLedgerEntryId(ledgerEntryId);
    return record?.toEntity();
  }

  @override
  Future<List<Reminder>> getAllReminders() async {
    final records = await _dataSource.getAll();
    return records.where((r) => r.deletedAt == null).map((r) => r.toEntity()).toList();
  }

  @override
  Future<List<Reminder>> getOverdueReminders() async {
    final records = await _dataSource.getOverdue();
    return records.map((r) => r.toEntity()).toList();
  }

  @override
  Future<List<Reminder>> getUpcomingReminders() async {
    final records = await _dataSource.getUpcoming();
    return records.map((r) => r.toEntity()).toList();
  }

  @override
  Future<List<Reminder>> getRemindersByPersonId(int personId) async {
    final records = await _dataSource.getByPersonId(personId);
    return records.map((r) => r.toEntity()).toList();
  }

  @override
  Future<int> getOverdueCount() async {
    final overdue = await getOverdueReminders();
    return overdue.length;
  }

  @override
  Future<void> markAsFired(int reminderId) async {
    final existing = await _dataSource.getById(reminderId);
    if (existing == null) throw AppException('Reminder not found.');

    final now = DateTime.now();
    existing.lastFiredAt = now;

    if (existing.repeat > 0) {
      existing.nextFireAt = _nextRepeatDate(existing.dueDate, existing.repeat);
    } else {
      existing.status = 1; // completed
      existing.nextFireAt = null;
    }

    existing.updatedAt = now;
    await _dataSource.put(existing);
  }

  DateTime _nextRepeatDate(DateTime from, int repeat) {
    return switch (repeat) {
      1 => from.add(const Duration(days: 1)),     // daily
      2 => from.add(const Duration(days: 7)),     // weekly
      3 => DateTime(from.year, from.month + 1, from.day), // monthly
      4 => DateTime(from.year + 1, from.month, from.day), // yearly
      _ => from,
    };
  }
}
