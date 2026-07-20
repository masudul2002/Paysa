import '../models/account_record.dart';

abstract interface class AccountsLocalDataSource {
  Future<List<AccountRecord>> getAll();

  Stream<List<AccountRecord>> watchAll();

  Future<AccountRecord?> getById(int id);

  Future<AccountRecord?> getByName(String name);

  Future<int> put(AccountRecord record);

  Future<void> delete(int id);
}
