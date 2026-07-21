import '../models/budget_record.dart';

abstract interface class BudgetLocalDataSource {
  Future<BudgetRecord> put(BudgetRecord r);
  Future<BudgetRecord?> getById(int id);
  Future<List<BudgetRecord>> getAll();
  Stream<List<BudgetRecord>> watchAll();
  Future<void> delete(int id);
}
