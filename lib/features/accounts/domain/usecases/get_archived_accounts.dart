import '../entities/account.dart';
import '../repositories/account_repository.dart';

final class GetArchivedAccounts {
  const GetArchivedAccounts(this._repository);

  final AccountRepository _repository;

  Future<List<Account>> call() => _repository.getArchivedAccounts();
}
