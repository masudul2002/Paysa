import '../entities/account.dart';

abstract interface class AccountRepository {
  Future<Account> createAccount(Account account);

  Future<Account> updateAccount(Account account);

  Future<void> deleteAccount(int id);

  Future<Account> archiveAccount(int id);

  Future<List<Account>> getAccounts();

  Future<List<Account>> getActiveAccounts();

  Future<List<Account>> getArchivedAccounts();

  Stream<List<Account>> watchAccounts();
}
