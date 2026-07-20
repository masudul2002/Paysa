import 'package:paysa/core/app_exception.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

final class UpdateTransaction {
  const UpdateTransaction(this._repository);

  final TransactionRepository _repository;

  Future<Transaction> call(Transaction transaction) async {
    if (transaction.id <= 0) {
      throw AppException('Invalid transaction.');
    }
    if (transaction.amount <= 0) {
      throw AppException('Amount must be greater than zero.');
    }

    return _repository.updateTransaction(transaction);
  }
}
