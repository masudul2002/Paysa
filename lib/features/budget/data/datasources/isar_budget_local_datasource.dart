import 'package:isar/isar.dart';
import '../models/budget_record.dart';
import 'budget_local_datasource.dart';

final class IsarBudgetLocalDataSource implements BudgetLocalDataSource {
  const IsarBudgetLocalDataSource(this._isar);
  final Isar _isar;
  IsarCollection<BudgetRecord> get _c => _isar.collection<BudgetRecord>();
  @override Future<BudgetRecord> put(BudgetRecord r) async {
    final id = await _isar.writeTxn(() => _c.put(r)); return (await _c.get(id))!;
  }
  @override Future<BudgetRecord?> getById(int id) => _c.get(id);
  @override Future<List<BudgetRecord>> getAll() async => _c.where().findAll();
  @override Stream<List<BudgetRecord>> watchAll() => _c.watchLazy(fireImmediately: true).asyncMap((_) => getAll());
  @override Future<void> delete(int id) => _isar.writeTxn(() => _c.delete(id));
}
