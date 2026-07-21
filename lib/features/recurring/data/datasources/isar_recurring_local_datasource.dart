import 'package:isar/isar.dart';
import '../models/recurring_record.dart';
import 'recurring_local_datasource.dart';

final class IsarRecurringLocalDataSource implements RecurringLocalDataSource {
  const IsarRecurringLocalDataSource(this._isar);
  final Isar _isar;
  IsarCollection<RecurringRecord> get _c => _isar.collection<RecurringRecord>();

  @override Future<RecurringRecord> put(RecurringRecord r) async {
    final id = await _isar.writeTxn(() => _c.put(r)); return (await _c.get(id))!;
  }
  @override Future<RecurringRecord?> getById(int id) => _c.get(id);
  @override Future<List<RecurringRecord>> getAll() async => _c.where().findAll();
  @override Stream<List<RecurringRecord>> watchAll() => _c.watchLazy(fireImmediately: true).asyncMap((_) => getAll());
  @override Future<void> delete(int id) => _isar.writeTxn(() => _c.delete(id));
}
