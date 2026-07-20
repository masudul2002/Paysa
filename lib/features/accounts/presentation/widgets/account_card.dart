import 'package:flutter/material.dart';
import '../../domain/entities/account.dart';
import 'account_visuals.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({
    super.key,
    required this.account,
    required this.onTap,
    required this.onArchive,
    required this.onDelete,
  });

  final Account account;
  final VoidCallback onTap;
  final Future<bool> Function() onArchive;
  final Future<bool> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accountColor = accountColorFromValue(account.color);
    final balanceText = formatAccountBalance(account.balance, account.currency);

    return Semantics(
      button: true,
      label: '${account.name}, ${account.type.label}, $balanceText',
      child: Dismissible(
        key: ValueKey<int>(account.id),
        direction: account.isArchived
            ? DismissDirection.startToEnd
            : DismissDirection.horizontal,
        background: _SwipeBackground(
          color: colorScheme.error,
          icon: Icons.delete_outline,
          alignment: Alignment.centerLeft,
          label: 'Delete',
        ),
        secondaryBackground: account.isArchived
            ? null
            : _SwipeBackground(
                color: colorScheme.primary,
                icon: Icons.archive_outlined,
                alignment: Alignment.centerRight,
                label: 'Archive',
              ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            return onDelete();
          }
          if (!account.isArchived && direction == DismissDirection.endToStart) {
            return onArchive();
          }
          return false;
        },
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: accountColor.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      accountIconFromKey(account.icon),
                      color: accountColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                account.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (account.isArchived)
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Chip(label: Text('Archived')),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          account.type.label,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (account.description.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            account.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        balanceText,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        account.currency.toUpperCase(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.color,
    required this.icon,
    required this.alignment,
    required this.label,
  });

  final Color color;
  final IconData icon;
  final Alignment alignment;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: alignment == Alignment.centerRight
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
