import 'package:paysa/core/app_exception.dart';

import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transactions_local_datasource.dart';
import '../models/transaction_record.dart';

final class TransactionRepositoryImpl implements TransactionRepository {
  const TransactionRepositoryImpl(this._localDataSource);

  final TransactionsLocalDataSource _localDataSource;

  @override
  Future<Transaction> createTransaction(Transaction transaction) async {
    final record = transaction.toRecord();
    final id = await _localDataSource.put(record);
    final saved = await _localDataSource.getById(id);
    if (saved == null) {
      throw AppException('Failed to create transaction.');
    }
    return saved.toEntity();
  }

  @override
  Future<Transaction> updateTransaction(Transaction transaction) async {
    final existing = await _localDataSource.getById(transaction.id);
    if (existing == null) {
      throw AppException('Transaction not found.');
    }

    final record = transaction.toRecord();
    await _localDataSource.put(record);
    final saved = await _localDataSource.getById(transaction.id);
    if (saved == null) {
      throw AppException('Failed to update transaction.');
    }
    return saved.toEntity();
  }

  @override
  Future<void> deleteTransaction(int id) async {
    final existing = await _localDataSource.getById(id);
    if (existing == null) {
      throw AppException('Transaction not found.');
    }
    await _localDataSource.delete(id);
  }

  @override
  Future<List<Transaction>> getTransactions({int? accountId}) async {
    final records = await _localDataSource.getAll(accountId: accountId);
    return records.map((r) => r.toEntity()).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end, {
    int? accountId,
  }) async {
    final records = await _localDataSource.getByDateRange(
      start,
      end,
      accountId: accountId,
    );
    return records.map((r) => r.toEntity()).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Stream<List<Transaction>> watchTransactions({int? accountId}) {
    return _localDataSource.watchAll(accountId: accountId).map((records) {
      return records.map((r) => r.toEntity()).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    });
  }
}
