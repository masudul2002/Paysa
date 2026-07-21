import '../entities/goal.dart';

abstract interface class GoalRepository {
  Future<FinancialGoal> create(FinancialGoal goal);
  Future<FinancialGoal> update(FinancialGoal goal);
  Future<void> archive(int id);
  Future<FinancialGoal> contribute(int goalId, int amountMinor, {int? accountId, String? notes});
  Future<FinancialGoal?> getById(int id);
  Future<List<FinancialGoal>> getAll({GoalStatus? statusFilter});
  Stream<List<FinancialGoal>> watchAll();
  Future<GoalSummary> getSummary();
}
