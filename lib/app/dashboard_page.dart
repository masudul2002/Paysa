import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/accounts/domain/entities/account.dart';
import '../features/accounts/presentation/providers/accounts_providers.dart';
import '../features/transactions/domain/entities/transaction.dart';
import '../features/transactions/presentation/providers/transactions_providers.dart';
import '../features/transactions/presentation/widgets/transaction_form_sheet.dart';
import '../features/transactions/presentation/widgets/transaction_visuals.dart';
import '../features/accounts/presentation/widgets/account_form_sheet.dart';
import '../shared/shared.dart';
import 'theme/design_tokens.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(filteredAccountsProvider);
    final transactionsAsync = ref.watch(transactionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: DesignTokens.elevationAppBar,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spacingMd),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: DesignTokens.spacingMd),

                // Balance summary
                accountsAsync.when(
                  loading: () => const _BalanceCard(
                    totalBalance: 0,
                    accountCount: 0,
                    currency: 'USD',
                  ),
                  error: (_, __) => const _BalanceCard(
                    totalBalance: 0,
                    accountCount: 0,
                    currency: 'USD',
                  ),
                  data: (accounts) {
                    final activeAccounts = accounts.where((a) => !a.isArchived).toList();
                    final totalBalance = activeAccounts.fold<double>(
                      0,
                      (sum, a) => sum + a.balance,
                    );
                    final currency = activeAccounts.isNotEmpty
                        ? activeAccounts.first.currency
                        : 'USD';
                    return _BalanceCard(
                      totalBalance: totalBalance,
                      accountCount: activeAccounts.length,
                      currency: currency,
                    );
                  },
                ),

                // Quick actions
                const SizedBox(height: DesignTokens.spacingLg),
                Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: DesignTokens.spacingSm),
                Wrap(
                  spacing: DesignTokens.spacingSm,
                  runSpacing: DesignTokens.spacingSm,
                  children: [
                    ActionChip(
                      onPressed: () => _openAccountForm(context, ref),
                      label: const Text('Add Account'),
                      avatar: const Icon(Icons.account_balance_wallet_outlined, size: 18),
                    ),
                    ActionChip(
                      onPressed: () => _openTransactionForm(context, ref),
                      label: const Text('Add Transaction'),
                      avatar: const Icon(Icons.swap_horiz_outlined, size: 18),
                    ),
                  ],
                ),

                // Recent transactions
                const SizedBox(height: DesignTokens.spacingLg),
                Text('Recent Transactions', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: DesignTokens.spacingSm),
                transactionsAsync.when(
                  loading: () => const _RecentTile(
                    child: LoadingWidget(message: 'Loading transactions...'),
                  ),
                  error: (_, __) => const _RecentTile(
                    child: AppErrorWidget(
                      title: 'Could not load transactions',
                      details: '',
                    ),
                  ),
                  data: (transactions) {
                    final recent = transactions.take(5).toList();
                    if (recent.isEmpty) {
                      return const _RecentTile(
                        child: Center(
                          child: Text('No transactions yet'),
                        ),
                      );
                    }
                    return Column(
                      children: recent.map((tx) => _TransactionRow(transaction: tx)).toList(),
                    );
                  },
                ),

                // Account summary
                const SizedBox(height: DesignTokens.spacingLg),
                Text('Accounts', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: DesignTokens.spacingSm),
                accountsAsync.when(
                  loading: () => const LoadingWidget(message: 'Loading accounts...'),
                  error: (_, __) => const AppErrorWidget(
                    title: 'Could not load accounts',
                    details: '',
                  ),
                  data: (accounts) {
                    final active = accounts.where((a) => !a.isArchived).toList();
                    if (active.isEmpty) {
                      return const AppCard(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No active accounts'),
                        ),
                      );
                    }
                    return Column(
                      children: active.map((account) => _AccountRow(account: account)).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openAccountForm(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const AccountFormSheet(),
    );
  }

  void _openTransactionForm(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const TransactionFormSheet(),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.totalBalance,
    required this.accountCount,
    required this.currency,
  });

  final double totalBalance;
  final int accountCount;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: DesignTokens.elevationCard,
      shape: RoundedRectangleBorder(
        borderRadius: DesignTokens.radiusMd,
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total balance', style: textTheme.bodyMedium),
            const SizedBox(height: DesignTokens.spacingSm),
            Text(
              '$currency ${totalBalance.toStringAsFixed(2)}',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: totalBalance >= 0
                    ? Colors.green.shade700
                    : Colors.red.shade700,
              ),
            ),
            const SizedBox(height: DesignTokens.spacingSm),
            Text(
              '$accountCount active account${accountCount == 1 ? '' : 's'}',
              style: textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentTile extends StatelessWidget {
  const _RecentTile({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: DesignTokens.radiusMd,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: child,
    );
  }
}

class _TransactionRow extends ConsumerWidget {
  const _TransactionRow({required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final amountColor = amountColorFor(transaction);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: transaction.type == TransactionType.income
              ? Colors.green.withValues(alpha: 0.14)
              : Colors.red.withValues(alpha: 0.14),
          child: Icon(
            transaction.type == TransactionType.income
                ? Icons.arrow_circle_up
                : Icons.arrow_circle_down,
            size: 18,
            color: amountColor,
          ),
        ),
        title: Text(
          transaction.description.isNotEmpty
              ? transaction.description
              : transaction.type.label,
          style: textTheme.bodyMedium,
        ),
        trailing: Text(
          formatCurrency(transaction.amount, transaction.currency),
          style: textTheme.bodyMedium?.copyWith(
            color: amountColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: account.color.toColor().withValues(alpha: 0.14),
          child: Icon(
            _iconFor(account.icon),
            size: 18,
            color: account.color.toColor(),
          ),
        ),
        title: Text(account.name, style: textTheme.bodyMedium),
        trailing: Text(
          '${account.currency} ${account.balance.toStringAsFixed(2)}',
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String key) {
    return switch (key) {
      'cash' => Icons.money_outlined,
      'bank' => Icons.account_balance_outlined,
      'mobile_banking' => Icons.phone_android_outlined,
      'credit_card' => Icons.credit_card_outlined,
      'savings' => Icons.savings_outlined,
      'investment' => Icons.trending_up_outlined,
      _ => Icons.account_balance_wallet_outlined,
    };
  }
}

extension on int {
  Color toColor() => Color(this);
}
