import 'package:flutter/material.dart';

import '../../domain/entities/person.dart';
import 'person_visuals.dart';

class PersonCard extends StatelessWidget {
  const PersonCard({
    super.key,
    required this.person,
    this.onTap,
    this.onArchive,
    this.onDelete,
    this.onToggleFavorite,
  });

  final Person person;
  final VoidCallback? onTap;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeColor = personTypeColor(person.type);

    return Dismissible(
      key: ValueKey(person.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        onDelete?.call();
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: Icon(Icons.delete_outline, color: theme.colorScheme.onError),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor: typeColor.withValues(alpha: 0.14),
            child: Icon(
              personTypeIcon(person.type),
              color: typeColor,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  person.name,
                  style: theme.textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (person.isFavorite)
                Icon(Icons.star, size: 16, color: Colors.amber.shade600),
            ],
          ),
          subtitle: Row(
            children: [
              _TypeBadge(type: person.type),
              if (person.phone != null) ...[
                const SizedBox(width: 8),
                Text(
                  person.phone!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (person.openingBalance > 0) ...[
                Text(
                  '${person.currency} ${(person.openingBalance / 100).toStringAsFixed(2)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
                Text(
                  person.openingBalanceDirection.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (person.isArchived)
                Icon(
                  Icons.archive_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

  final PersonType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = personTypeColor(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type.label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
