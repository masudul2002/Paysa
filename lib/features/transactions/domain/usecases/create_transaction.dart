import 'package:paysa/core/app_exception.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

final class CreateTransaction {
  const CreateTransaction(this._repository);

  final TransactionRepository _repository;

  Future<Transaction> call(Transaction transaction) async {
    if (transaction.accountId <= 0) {
      throw AppException('Invalid account.');
    }
    if (transaction.amount <= 0) {
      throw AppException('Amount must be greater than zero.');
    }
    if (transaction.currency.trim().isEmpty) {
      throw AppException('Currency is required.');
    }

    return _repository.createTransaction(transaction);
  }
}
