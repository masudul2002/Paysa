import '../entities/budget.dart';

abstract interface class BudgetRepository {
  Future<Budget> create(Budget budget);
  Future<Budget> update(Budget budget);
  Future<void> archive(int id);
  Future<void> delete(int id);
  Future<Budget?> getById(int id);
  Future<List<Budget>> getAll({BudgetStatus? statusFilter, int? categoryId});
  Stream<List<Budget>> watchAll();
  Future<BudgetProgress> getProgress();
}
