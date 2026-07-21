import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// SectionHeader
// ---------------------------------------------------------------------------

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.subtitle, this.actionLabel, this.onAction});
  final String title; final String? subtitle; final String? actionLabel; final VoidCallback? onAction;

  @override Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        if (subtitle != null) ...[const SizedBox(height: 2), Text(subtitle!, style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant))],
      ])),
      if (actionLabel != null) TextButton(onPressed: onAction, child: Text(actionLabel!)),
    ]));
  }
}

// ---------------------------------------------------------------------------
// StatCard
// ---------------------------------------------------------------------------

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.label, required this.value, this.valueColor, this.icon, this.subtitle});
  final String label; final String value; final Color? valueColor; final IconData? icon; final String? subtitle;

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[Icon(icon, size: 16, color: theme.colorScheme.primary), const SizedBox(width: 6)],
                Expanded(child: Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: valueColor)),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// LoadingCard
// ---------------------------------------------------------------------------

class LoadingCard extends StatelessWidget {
  const LoadingCard({super.key, this.height = 100});
  final double height;
  @override Widget build(BuildContext context) => Card(margin: EdgeInsets.zero, child: SizedBox(height: height, child: const Center(child: CircularProgressIndicator(strokeWidth: 2))));
}

// ---------------------------------------------------------------------------
// ErrorCard
// ---------------------------------------------------------------------------

class ErrorCard extends StatelessWidget {
  const ErrorCard({super.key, required this.message});
  final String message;
  @override Widget build(BuildContext context) => Card(margin: EdgeInsets.zero, child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
    Icon(Icons.error_outline, size: 18, color: Theme.of(context).colorScheme.error), const SizedBox(width: 8),
    Expanded(child: Text(message, style: Theme.of(context).textTheme.bodySmall)),
  ])));
}

// ---------------------------------------------------------------------------
// EmptyCard
// ---------------------------------------------------------------------------

class EmptyCard extends StatelessWidget {
  const EmptyCard({super.key, required this.message});
  final String message;
  @override Widget build(BuildContext context) => Card(margin: EdgeInsets.zero, child: Padding(padding: const EdgeInsets.all(24), child: Center(
    child: Text(message, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
  )));
}

// ---------------------------------------------------------------------------
// QuickActionButton
// ---------------------------------------------------------------------------

class QuickActionButton extends StatelessWidget {
  const QuickActionButton({super.key, required this.icon, required this.label, required this.color, required this.onTap});
  final IconData icon; final String label; final Color color; final VoidCallback onTap;

  @override Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Semantics(button: true, label: label, child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 12),
          Text(label, style: t.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: color)),
        ]),
      ),
    ));
  }
}

// ---------------------------------------------------------------------------
// ActivityTile
// ---------------------------------------------------------------------------

class ActivityTile extends StatelessWidget {
  const ActivityTile({super.key, required this.icon, required this.iconColor, required this.title, required this.subtitle, required this.trailing});
  final IconData icon; final Color iconColor; final String title; final String subtitle; final String trailing;

  @override Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(margin: EdgeInsets.zero, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Row(children: [
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: iconColor)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: t.textTheme.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(subtitle, style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
      ])),
      const SizedBox(width: 8),
      Text(trailing, style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
    ])));
  }
}
