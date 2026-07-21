import '../models/goal_record.dart';

abstract interface class GoalLocalDataSource {
  Future<GoalRecord> put(GoalRecord r);
  Future<GoalRecord?> getById(int id);
  Future<List<GoalRecord>> getAll();
  Stream<List<GoalRecord>> watchAll();
  Future<void> delete(int id);
}
