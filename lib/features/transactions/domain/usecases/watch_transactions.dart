import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

final class WatchTransactions {
  const WatchTransactions(this._repository);

  final TransactionRepository _repository;

  Stream<List<Transaction>> call({int? accountId}) {
    return _repository.watchTransactions(accountId: accountId);
  }
}
