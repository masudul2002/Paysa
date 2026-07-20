import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';

import '../../../../../app/providers/app_providers.dart';
import '../../data/datasources/isar_transactions_local_datasource.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/create_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../domain/usecases/update_transaction.dart';
import '../../domain/usecases/watch_transactions.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return TransactionRepositoryImpl(IsarTransactionsLocalDataSource(isar));
});

final createTransactionProvider = Provider<CreateTransaction>((ref) {
  return CreateTransaction(ref.watch(transactionRepositoryProvider));
});

final updateTransactionProvider = Provider<UpdateTransaction>((ref) {
  return UpdateTransaction(ref.watch(transactionRepositoryProvider));
});

final deleteTransactionProvider = Provider<DeleteTransaction>((ref) {
  return DeleteTransaction(ref.watch(transactionRepositoryProvider));
});

final getTransactionsProvider = Provider<GetTransactions>((ref) {
  return GetTransactions(ref.watch(transactionRepositoryProvider));
});

final watchTransactionsProvider = Provider<WatchTransactions>((ref) {
  return WatchTransactions(ref.watch(transactionRepositoryProvider));
});

final accountTransactionFilterProvider = StateProvider.autoDispose<int?>((ref) {
  return null;
});

final transactionsStreamProvider =
    StreamProvider.autoDispose<List<Transaction>>((ref) {
  final watchTransactions = ref.watch(watchTransactionsProvider);
  final accountId = ref.watch(accountTransactionFilterProvider);
  return watchTransactions(accountId: accountId);
});
