import '../entities/transaction.dart';

abstract interface class TransactionRepository {
  Future<Transaction> createTransaction(Transaction transaction);

  Future<Transaction> updateTransaction(Transaction transaction);

  Future<void> deleteTransaction(int id);

  Future<List<Transaction>> getTransactions({int? accountId});

  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end, {
    int? accountId,
  });

  Stream<List<Transaction>> watchTransactions({int? accountId});
}
