import '../entities/recurring_transaction.dart';

abstract interface class RecurringRepository {
  Future<RecurringTransaction> create(RecurringTransaction tpl);
  Future<RecurringTransaction> update(RecurringTransaction tpl);
  Future<void> delete(int id);
  Future<RecurringTransaction?> getById(int id);
  Future<List<RecurringTransaction>> getAll({RecurringStatus? statusFilter});
  Stream<List<RecurringTransaction>> watchAll();
  Future<void> activate(int id);
  Future<void> pause(int id);
  Future<void> archive(int id);
  Future<RecurringTransaction> duplicate(int id);
  Future<RecurringTransaction> execute(int id); // creates transaction + updates schedule
  Future<List<RecurringTransaction>> getDue();
  Future<List<RecurringTransaction>> getUpcoming();
}
