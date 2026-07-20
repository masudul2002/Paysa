import '../entities/account.dart';
import '../repositories/account_repository.dart';

final class GetActiveAccounts {
  const GetActiveAccounts(this._repository);

  final AccountRepository _repository;

  Future<List<Account>> call() => _repository.getActiveAccounts();
}
