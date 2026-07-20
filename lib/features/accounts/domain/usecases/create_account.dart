import '../../../../core/app_exception.dart';
import '../entities/account.dart';
import '../repositories/account_repository.dart';

final class CreateAccount {
  const CreateAccount(this._repository);

  final AccountRepository _repository;

  Future<Account> call(Account account) async {
    _validate(account);
    return _repository.createAccount(account);
  }

  void _validate(Account account) {
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
