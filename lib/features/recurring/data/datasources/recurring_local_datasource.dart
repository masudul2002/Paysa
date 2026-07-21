import '../models/recurring_record.dart';

abstract interface class RecurringLocalDataSource {
  Future<RecurringRecord> put(RecurringRecord r);
  Future<RecurringRecord?> getById(int id);
  Future<List<RecurringRecord>> getAll();
  Stream<List<RecurringRecord>> watchAll();
  Future<void> delete(int id);
}
