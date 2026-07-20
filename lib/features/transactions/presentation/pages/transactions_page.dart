import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_exception.dart';
import '../../../../shared/shared.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transactions_providers.dart';
import '../widgets/transaction_card.dart';
import '../widgets/transaction_form_sheet.dart';

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
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
                title: 'Transactions',
                subtitle: 'Record your income and expenses.',
              ),
              const SizedBox(height: 16),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: transactionsAsync.when(
                    loading: () => const LoadingWidget(
                      message: 'Loading transactions...',
                    ),
                    error: (error, stackTrace) => AppErrorWidget(
                      title: 'Could not load transactions',
                      details: error.toString(),
                    ),
                    data: (transactions) {
                      if (transactions.isEmpty) {
                        return EmptyStateWidget(
                          title: 'No transactions yet',
                          subtitle: 'Tap the + button to record your first transaction.',
                        );
                      }
                      return ListView.separated(
                        itemCount: transactions.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final tx = transactions[index];
                          return TransactionCard(
                            transaction: tx,
                            onTap: () => _openFormSheet(
                              context,
                              ref,
                              transaction: tx,
                            ),
                            onDelete: () =>
                                _confirmDelete(context, ref, tx),
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
    Transaction? transaction,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => TransactionFormSheet(
        initialTransaction: transaction,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Transaction transaction,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: Text(
          'Delete transaction of ${transaction.amount.toStringAsFixed(2)} '
          '${transaction.currency}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete != true) return;

    try {
      await ref.read(deleteTransactionProvider).call(transaction.id);
    } on AppException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    }
  }
}
