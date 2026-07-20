import '../models/transaction_record.dart';

abstract interface class TransactionsLocalDataSource {
  Future<List<TransactionRecord>> getAll({int? accountId});

  Stream<List<TransactionRecord>> watchAll({int? accountId});

  Future<TransactionRecord?> getById(int id);

  Future<List<TransactionRecord>> getByDateRange(
    DateTime start,
    DateTime end, {
    int? accountId,
  });

  Future<int> put(TransactionRecord record);

  Future<void> delete(int id);
}
