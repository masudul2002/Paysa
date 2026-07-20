import '../entities/account.dart';
import '../repositories/account_repository.dart';

final class ArchiveAccount {
  const ArchiveAccount(this._repository);

  final AccountRepository _repository;

  Future<Account> call(int id) => _repository.archiveAccount(id);
}
