import 'package:isar/isar.dart';
import '../models/goal_record.dart';
import 'goal_local_datasource.dart';

final class IsarGoalLocalDataSource implements GoalLocalDataSource {
  const IsarGoalLocalDataSource(this._isar);
  final Isar _isar;
  IsarCollection<GoalRecord> get _c => _isar.collection<GoalRecord>();
  @override Future<GoalRecord> put(GoalRecord r) async { final id = await _isar.writeTxn(() => _c.put(r)); return (await _c.get(id))!; }
  @override Future<GoalRecord?> getById(int id) => _c.get(id);
  @override Future<List<GoalRecord>> getAll() async => _c.where().findAll();
  @override Stream<List<GoalRecord>> watchAll() => _c.watchLazy(fireImmediately: true).asyncMap((_) => getAll());
  @override Future<void> delete(int id) => _isar.writeTxn(() => _c.delete(id));
}
