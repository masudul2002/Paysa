import 'package:isar/isar.dart';

import '../models/account_record.dart';
import 'accounts_local_datasource.dart';

final class IsarAccountsLocalDataSource implements AccountsLocalDataSource {
  const IsarAccountsLocalDataSource(this._isar);

  final Isar _isar;

  IsarCollection<AccountRecord> get _collection => _isar.collection<AccountRecord>();

  @override
  Future<List<AccountRecord>> getAll() async {
    return _collection.where().findAll();
  }

  @override
  Stream<List<AccountRecord>> watchAll() {
    return _collection.watchLazy(fireImmediately: true).asyncMap((_) => getAll());
  }

  @override
  Future<AccountRecord?> getById(int id) {
    return _collection.get(id);
  }

  @override
  Future<AccountRecord?> getByName(String name) async {
    final normalized = name.trim().toLowerCase();
    final records = await getAll();
    for (final record in records) {
      if (record.name.trim().toLowerCase() == normalized) {
        return record;
      }
    }
    return null;
  }

  @override
  Future<int> put(AccountRecord record) {
    return _isar.writeTxn(() => _collection.put(record));
  }

  @override
  Future<void> delete(int id) {
    return _isar.writeTxn(() => _collection.delete(id));
  }
}
