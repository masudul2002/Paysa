import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

final class GetTransactions {
  const GetTransactions(this._repository);

  final TransactionRepository _repository;

  Future<List<Transaction>> call({int? accountId}) {
    return _repository.getTransactions(accountId: accountId);
  }
}
