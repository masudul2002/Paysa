import 'package:flutter/material.dart';

import '../../domain/entities/account.dart';
import '../providers/accounts_providers.dart';

class AccountFiltersBar extends StatelessWidget {
  const AccountFiltersBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.listFilter,
    required this.onListFilterChanged,
    required this.typeFilter,
    required this.onTypeFilterChanged,
    required this.sortOption,
    required this.onSortChanged,
  });

  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final AccountListFilter listFilter;
  final ValueChanged<AccountListFilter> onListFilterChanged;
  final AccountType? typeFilter;
  final ValueChanged<AccountType?> onTypeFilterChanged;
  final AccountSortOption sortOption;
  final ValueChanged<AccountSortOption> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          initialValue: searchQuery,
          onChanged: onSearchChanged,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search accounts',
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('All'),
              selected: listFilter == AccountListFilter.all,
              onSelected: (_) => onListFilterChanged(AccountListFilter.all),
            ),
            ChoiceChip(
              label: const Text('Active'),
              selected: listFilter == AccountListFilter.active,
              onSelected: (_) => onListFilterChanged(AccountListFilter.active),
            ),
            ChoiceChip(
              label: const Text('Archived'),
              selected: listFilter == AccountListFilter.archived,
              onSelected: (_) => onListFilterChanged(AccountListFilter.archived),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<AccountType?>(
                initialValue: typeFilter,
                decoration: const InputDecoration(
                  labelText: 'Account type',
                ),
                items: [
                  const DropdownMenuItem<AccountType?>(
                    value: null,
                    child: Text('All types'),
                  ),
                  ...AccountType.values.map(
                    (type) => DropdownMenuItem<AccountType?>(
                      value: type,
                      child: Text(type.label),
                    ),
                  ),
                ],
                onChanged: onTypeFilterChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<AccountSortOption>(
                initialValue: sortOption,
                decoration: const InputDecoration(labelText: 'Sort'),
                items: const [
                  DropdownMenuItem(
                    value: AccountSortOption.newest,
                    child: Text('Newest'),
                  ),
                  DropdownMenuItem(
                    value: AccountSortOption.oldest,
                    child: Text('Oldest'),
                  ),
                  DropdownMenuItem(
                    value: AccountSortOption.alphabetical,
                    child: Text('Alphabetical'),
                  ),
                  DropdownMenuItem(
                    value: AccountSortOption.balance,
                    child: Text('Balance'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onSortChanged(value);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
