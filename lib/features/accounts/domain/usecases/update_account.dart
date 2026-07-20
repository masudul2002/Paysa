import '../../../../core/app_exception.dart';
import '../entities/account.dart';
import '../repositories/account_repository.dart';

final class UpdateAccount {
  const UpdateAccount(this._repository);

  final AccountRepository _repository;

  Future<Account> call(Account account) async {
    _validate(account);
    return _repository.updateAccount(account);
  }

  void _validate(Account account) {
    if (account.id <= 0) {
      throw AppException('Account id is required.');
    }
    if (account.name.trim().isEmpty) {
      throw AppException('Account name is required.');
    }
    if (account.balance < 0) {
      throw AppException('Account balance must be zero or greater.');
    }
    if (account.currency.trim().isEmpty) {
      throw AppException('Account currency is required.');
    }
  }
}
