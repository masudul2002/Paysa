import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';

import '../../../../../app/providers/app_providers.dart';
import '../../data/datasources/isar_accounts_local_datasource.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/usecases/archive_account.dart';
import '../../domain/usecases/create_account.dart';
import '../../domain/usecases/delete_account.dart';
import '../../domain/usecases/get_accounts.dart';
import '../../domain/usecases/get_active_accounts.dart';
import '../../domain/usecases/get_archived_accounts.dart';
import '../../domain/usecases/update_account.dart';
import '../../domain/usecases/watch_accounts.dart';

enum AccountListFilter { all, active, archived }

enum AccountSortOption { alphabetical, balance, newest, oldest }

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return AccountRepositoryImpl(IsarAccountsLocalDataSource(isar));
});

final createAccountProvider = Provider<CreateAccount>((ref) {
  return CreateAccount(ref.watch(accountRepositoryProvider));
});

final updateAccountProvider = Provider<UpdateAccount>((ref) {
  return UpdateAccount(ref.watch(accountRepositoryProvider));
});

final deleteAccountProvider = Provider<DeleteAccount>((ref) {
  return DeleteAccount(ref.watch(accountRepositoryProvider));
});

final archiveAccountProvider = Provider<ArchiveAccount>((ref) {
  return ArchiveAccount(ref.watch(accountRepositoryProvider));
});

final getAccountsProvider = Provider<GetAccounts>((ref) {
  return GetAccounts(ref.watch(accountRepositoryProvider));
});

final getActiveAccountsProvider = Provider<GetActiveAccounts>((ref) {
  return GetActiveAccounts(ref.watch(accountRepositoryProvider));
});

final getArchivedAccountsProvider = Provider<GetArchivedAccounts>((ref) {
  return GetArchivedAccounts(ref.watch(accountRepositoryProvider));
});

final watchAccountsProvider = Provider<WatchAccounts>((ref) {
  return WatchAccounts(ref.watch(accountRepositoryProvider));
});

final accountSearchQueryProvider = StateProvider.autoDispose<String>((ref) {
  return '';
});

final accountListFilterProvider =
    StateProvider.autoDispose<AccountListFilter>((ref) {
      return AccountListFilter.all;
    });

final accountTypeFilterProvider = StateProvider.autoDispose<AccountType?>((ref) {
  return null;
});

final accountSortProvider = StateProvider.autoDispose<AccountSortOption>((ref) {
  return AccountSortOption.newest;
});

final filteredAccountsProvider = StreamProvider.autoDispose<List<Account>>((ref) {
  final watchAccounts = ref.watch(watchAccountsProvider);
  final query = ref.watch(accountSearchQueryProvider).trim().toLowerCase();
  final listFilter = ref.watch(accountListFilterProvider);
  final typeFilter = ref.watch(accountTypeFilterProvider);
  final sortOption = ref.watch(accountSortProvider);

  return watchAccounts().map((accounts) {
    final filtered = accounts.where((account) {
      final matchesQuery = query.isEmpty ||
          account.name.toLowerCase().contains(query) ||
          account.description.toLowerCase().contains(query) ||
          account.currency.toLowerCase().contains(query);

      final matchesStatus = switch (listFilter) {
        AccountListFilter.all => true,
        AccountListFilter.active => !account.isArchived,
        AccountListFilter.archived => account.isArchived,
      };

      final matchesType = typeFilter == null || account.type == typeFilter;
      return matchesQuery && matchesStatus && matchesType;
    }).toList(growable: false);

    filtered.sort((left, right) {
      return switch (sortOption) {
        AccountSortOption.alphabetical =>
          left.name.toLowerCase().compareTo(right.name.toLowerCase()),
        AccountSortOption.balance => right.balance.compareTo(left.balance),
        AccountSortOption.newest => right.createdAt.compareTo(left.createdAt),
        AccountSortOption.oldest => left.createdAt.compareTo(right.createdAt),
      };
    });

    return filtered;
  });
});
