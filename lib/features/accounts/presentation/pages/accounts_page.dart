import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_exception.dart';
import '../../../../shared/shared.dart';
import '../../domain/entities/account.dart';
import '../providers/accounts_providers.dart';
import '../widgets/account_card.dart';
import '../widgets/account_filters_bar.dart';
import '../widgets/account_form_sheet.dart';

class AccountsPage extends ConsumerWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(filteredAccountsProvider);
    final searchQuery = ref.watch(accountSearchQueryProvider);
    final listFilter = ref.watch(accountListFilterProvider);
    final typeFilter = ref.watch(accountTypeFilterProvider);
    final sortOption = ref.watch(accountSortProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openFormSheet(context, ref),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(
                title: 'Accounts',
                subtitle: 'Create, edit, archive, and manage your accounts.',
              ),
              const SizedBox(height: 16),
              AccountFiltersBar(
                searchQuery: searchQuery,
                onSearchChanged: (value) =>
                    ref.read(accountSearchQueryProvider.notifier).state = value,
                listFilter: listFilter,
                onListFilterChanged: (value) =>
                    ref.read(accountListFilterProvider.notifier).state = value,
                typeFilter: typeFilter,
                onTypeFilterChanged: (value) =>
                    ref.read(accountTypeFilterProvider.notifier).state = value,
                sortOption: sortOption,
                onSortChanged: (value) =>
                    ref.read(accountSortProvider.notifier).state = value,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: accountsAsync.when(
                    loading: () => const LoadingWidget(
                      message: 'Loading accounts...',
                    ),
                    error: (error, stackTrace) => AppErrorWidget(
                      title: 'Could not load accounts',
                      details: error.toString(),
                    ),
                    data: (accounts) {
                      if (accounts.isEmpty) {
                        return EmptyStateWidget(
                          title: 'No accounts yet',
                          subtitle: 'Tap the + button to create your first account.',
                        );
                      }
                      return ListView.separated(
                        itemCount: accounts.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final account = accounts[index];
                          return AccountCard(
                            account: account,
                            onTap: () => _openFormSheet(
                              context,
                              ref,
                              account: account,
                            ),
                            onArchive: () =>
                                _confirmArchive(context, ref, account),
                            onDelete: () => _confirmDelete(context, ref, account),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openFormSheet(
    BuildContext context,
    WidgetRef ref, {
    Account? account,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => AccountFormSheet(initialAccount: account),
    );
  }

  Future<bool> _confirmArchive(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) async {
    final shouldArchive = await _confirmAction(
      context,
      title: 'Archive account?',
      message: 'This account will remain stored locally but move to archived.',
      confirmLabel: 'Archive',
    );
    if (!shouldArchive) {
      return false;
    }

    try {
      await ref.read(archiveAccountProvider).call(account.id);
      return true;
    } on AppException catch (error) {
      if (context.mounted) _showError(context, error.message);
      return false;
    }
  }

  Future<bool> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) async {
    final shouldDelete = await _confirmAction(
      context,
      title: 'Delete account?',
      message: 'This action cannot be undone.',
      confirmLabel: 'Delete',
    );
    if (!shouldDelete) {
      return false;
    }

    try {
      await ref.read(deleteAccountProvider).call(account.id);
      return true;
    } on AppException catch (error) {
      if (context.mounted) _showError(context, error.message);
      return false;
    }
  }

  Future<bool> _confirmAction(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
