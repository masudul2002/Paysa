import 'package:flutter/material.dart';

/// Empty state card.
class EmptyCard extends StatelessWidget {
  const EmptyCard({super.key, required this.message});
  final String message;

  @override Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(message, style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          )),
        ),
      ),
    );
  }
}
