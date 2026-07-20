import '../entities/reminder.dart';

abstract interface class ReminderRepository {
  Future<Reminder> createReminder(Reminder reminder);
  Future<Reminder> updateReminder(Reminder reminder);
  Future<void> deleteReminder(int reminderId);
  Future<Reminder?> getReminderById(int reminderId);
  Future<Reminder?> getReminderByLedgerEntryId(int ledgerEntryId);
  Future<List<Reminder>> getAllReminders();
  Future<List<Reminder>> getOverdueReminders();
  Future<List<Reminder>> getUpcomingReminders();
  Future<List<Reminder>> getRemindersByPersonId(int personId);
  Future<int> getOverdueCount();
  Future<void> markAsFired(int reminderId);
}
