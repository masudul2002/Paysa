import 'package:flutter/material.dart';

import '../../../accounts/data/models/account_record.dart';
import '../../domain/entities/transaction.dart';
import 'transaction_visuals.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({
    super.key,
    required this.transaction,
    this.accountRecord,
    this.categoryName,
    this.onTap,
    this.onDelete,
  });

  final Transaction transaction;
  final AccountRecord? accountRecord;
  final String? categoryName;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountColor = amountColorFor(transaction);

    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.delete_outline,
          color: theme.colorScheme.onError,
        ),
      ),
      confirmDismiss: (_) async {
        onDelete?.call();
        return false;
      },
      child: Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor: transaction.type == TransactionType.income
                ? Colors.green.withValues(alpha: 0.14)
                : Colors.red.withValues(alpha: 0.14),
            child: Icon(
              transaction.type == TransactionType.income
                  ? Icons.arrow_circle_up
                  : Icons.arrow_circle_down,
              color: amountColor,
            ),
          ),
          title: Text(
            transaction.description.isNotEmpty
                ? transaction.description
                : categoryName ?? 'Transaction',
            style: theme.textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Row(
            children: [
              if (accountRecord != null)
                Text(
                  accountRecord!.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              if (accountRecord != null && categoryName != null)
                Text(
                  ' · ',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              if (categoryName != null)
                Text(
                  categoryName ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatCurrency(transaction.amount, transaction.currency),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: amountColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _formatDate(transaction.date),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
