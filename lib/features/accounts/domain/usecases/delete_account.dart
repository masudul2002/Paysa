import '../repositories/account_repository.dart';

final class DeleteAccount {
  const DeleteAccount(this._repository);

  final AccountRepository _repository;

  Future<void> call(int id) => _repository.deleteAccount(id);
}
