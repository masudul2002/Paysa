import '../../../../core/app_exception.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/accounts_local_datasource.dart';
import '../models/account_record.dart';

final class AccountRepositoryImpl implements AccountRepository {
  const AccountRepositoryImpl(this._localDataSource);

  final AccountsLocalDataSource _localDataSource;

  @override
  Future<Account> createAccount(Account account) async {
    await _ensureUniqueName(account.name);

    final record = account.toRecord();
    final id = await _localDataSource.put(record);
    final saved = await _localDataSource.getById(id);
    if (saved == null) {
      throw AppException('Failed to create account.');
    }
    return saved.toEntity();
  }

  @override
  Future<Account> updateAccount(Account account) async {
    final existing = await _localDataSource.getById(account.id);
    if (existing == null) {
      throw AppException('Account not found.');
    }
    await _ensureUniqueName(account.name, excludeId: account.id);

    final record = account.toRecord();
    await _localDataSource.put(record);
    final saved = await _localDataSource.getById(account.id);
    if (saved == null) {
      throw AppException('Failed to update account.');
    }
    return saved.toEntity();
  }

  @override
  Future<void> deleteAccount(int id) async {
    final existing = await _localDataSource.getById(id);
    if (existing == null) {
      throw AppException('Account not found.');
    }
    await _localDataSource.delete(id);
  }

  @override
  Future<Account> archiveAccount(int id) async {
    final existing = await _localDataSource.getById(id);
    if (existing == null) {
      throw AppException('Account not found.');
    }
    final archived = existing.toEntity().copyWith(
      isArchived: true,
      updatedAt: DateTime.now(),
    );
    await _localDataSource.put(archived.toRecord());
    final saved = await _localDataSource.getById(id);
    if (saved == null) {
      throw AppException('Failed to archive account.');
    }
    return saved.toEntity();
  }

  @override
  Future<List<Account>> getAccounts() => _readAccounts();

  @override
  Future<List<Account>> getActiveAccounts() async {
    final accounts = await _readAccounts();
    return accounts.where((account) => !account.isArchived).toList(growable: false);
  }

  @override
  Future<List<Account>> getArchivedAccounts() async {
    final accounts = await _readAccounts();
    return accounts.where((account) => account.isArchived).toList(growable: false);
  }

  @override
  Stream<List<Account>> watchAccounts() {
    return _localDataSource.watchAll().map(_mapAndSort);
  }

  Future<List<Account>> _readAccounts() async {
    final records = await _localDataSource.getAll();
    return _mapAndSort(records);
  }

  List<Account> _mapAndSort(List<AccountRecord> records) {
    final accounts = records.map((record) => record.toEntity()).toList();
    accounts.sort((left, right) => right.createdAt.compareTo(left.createdAt));
    return accounts;
  }

  Future<void> _ensureUniqueName(String name, {int? excludeId}) async {
    final accounts = await _localDataSource.getAll();
    final normalized = name.trim().toLowerCase();
    final existing = accounts.where((account) {
      return account.name.trim().toLowerCase() == normalized &&
          account.id != excludeId;
    }).toList(growable: false);
    if (existing.isNotEmpty) {
      throw AppException('An account with this name already exists.');
    }
  }
}
