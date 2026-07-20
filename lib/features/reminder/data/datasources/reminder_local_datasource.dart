import '../models/reminder_record.dart';

abstract interface class ReminderLocalDataSource {
  Future<ReminderRecord> put(ReminderRecord record);
  Future<ReminderRecord?> getById(int id);
  Future<ReminderRecord?> getByLedgerEntryId(int ledgerEntryId);
  Future<List<ReminderRecord>> getAll();
  Future<List<ReminderRecord>> getOverdue();
  Future<List<ReminderRecord>> getUpcoming();
  Future<List<ReminderRecord>> getByPersonId(int personId);
  Future<void> delete(int id);
}
