import 'package:isar/isar.dart';

import '../models/transaction_record.dart';
import 'transactions_local_datasource.dart';

final class IsarTransactionsLocalDataSource
    implements TransactionsLocalDataSource {
  const IsarTransactionsLocalDataSource(this._isar);

  final Isar _isar;

  IsarCollection<TransactionRecord> get _collection =>
      _isar.collection<TransactionRecord>();

  @override
  Future<List<TransactionRecord>> getAll({int? accountId}) async {
    final records = await _collection.where().findAll();
    if (accountId != null) {
      return records.where((r) => r.accountId == accountId).toList();
    }
    return records;
  }

  @override
  Stream<List<TransactionRecord>> watchAll({int? accountId}) async* {
    yield* _collection.watchLazy(fireImmediately: true).asyncMap((_) {
      return getAll(accountId: accountId);
    });
  }

  @override
  Future<TransactionRecord?> getById(int id) {
    return _collection.get(id);
  }

  @override
  Future<List<TransactionRecord>> getByDateRange(
    DateTime start,
    DateTime end, {
    int? accountId,
  }) async {
    final all = await getAll(accountId: accountId);
    return all.where(
      (r) => (r.date.isAtSameMomentAs(start) || r.date.isAfter(start))
          && r.date.isBefore(end),
    ).toList();
  }

  @override
  Future<int> put(TransactionRecord record) {
    return _isar.writeTxn(() => _collection.put(record));
  }

  @override
  Future<void> delete(int id) {
    return _isar.writeTxn(() => _collection.delete(id));
  }
}
