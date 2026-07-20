import 'package:paysa/core/app_exception.dart';
import '../repositories/transaction_repository.dart';

final class DeleteTransaction {
  const DeleteTransaction(this._repository);

  final TransactionRepository _repository;

  Future<void> call(int id) async {
    if (id <= 0) {
      throw AppException('Invalid transaction.');
    }
    return _repository.deleteTransaction(id);
  }
}
