import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/budget.dart';
import '../providers/budget_providers.dart';
import '../../../../app/theme/design_tokens.dart';

class BudgetsPage extends ConsumerWidget {
  const BudgetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(budgetListProvider);
    final progressAsync = ref.watch(budgetProgressProvider);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: SafeArea(
        child: async.when(
          loading: () => const _BudgetSkeleton(),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (budgets) {
            if (budgets.isEmpty) {
              return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.account_balance_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text('No budgets yet', style: tt.titleMedium),
                const SizedBox(height: 8),
                Text('Create a budget to track your spending.',
                  style: tt.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ]));
            }

            return RefreshIndicator(
              onRefresh: () async { ref.invalidate(budgetListProvider); },
              child: ListView(
                padding: const EdgeInsets.all(DesignTokens.space16),
                children: [
                  // Progress overview
                  progressAsync.when(
                    loading: () => const _MiniCard(label: 'Budget Overview', value: '...'),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (p) => _ProgressSummary(progress: p, tt: tt),
                  ),
                  const SizedBox(height: DesignTokens.space20),
                  // Budget cards
                  ...budgets.map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _BudgetCard(budget: b, tt: tt),
                  )),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary({required this.progress, required this.tt});
  final BudgetProgress progress;
  final TextTheme tt;

  @override Widget build(BuildContext ctx) {
    final cs = Theme.of(ctx).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Budget Overview', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(children: [
            _stat('Total', '\$${(progress.totalBudgeted / 100).toStringAsFixed(0)}', cs),
            const SizedBox(width: 16),
            _stat('Spent', '\$${(progress.totalSpent / 100).toStringAsFixed(0)}', cs),
            const SizedBox(width: 16),
            _stat('Remaining', '\$${(progress.remaining / 100).toStringAsFixed(0)}', cs),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            _chip('${progress.onTrack} On track', DesignTokens.income),
            const SizedBox(width: 6),
            _chip('${progress.exceeded} Exceeded', DesignTokens.expense),
          ]),
        ]),
      ),
    );
  }

  Widget _stat(String label, String value, ColorScheme cs) => Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
    Text(value, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
  ]));

  Widget _chip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
    child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
  );
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.budget, required this.tt});
  final Budget budget;
  final TextTheme tt;

  @override Widget build(BuildContext context) {
    final statusColor = switch (budget.status) {
      BudgetStatus.safe => DesignTokens.income,
      BudgetStatus.warning => DesignTokens.warning,
      BudgetStatus.exceeded => DesignTokens.expense,
      BudgetStatus.completed => DesignTokens.info,
      BudgetStatus.archived => DesignTokens.neutral,
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.space16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                child: Text(budget.status.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor)),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(budget.name, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600))),
              Text('\$${(budget.budgetAmountMinor / 100).toStringAsFixed(0)}', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 12),
            ClipRRect(borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: budget.progressPercent / 100, minHeight: 8,
                color: statusColor, backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest)),
            const SizedBox(height: 6),
            Row(children: [
              Text('${budget.progressPercent.toStringAsFixed(0)}% spent', style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w500, color: statusColor)),
              const Spacer(),
              if (!budget.isExceeded)
                Text('\$${(budget.remainingAmountMinor / 100).toStringAsFixed(0)} left', style: tt.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _BudgetSkeleton extends StatelessWidget {
  const _BudgetSkeleton();
  @override Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(DesignTokens.space16),
      itemCount: 3,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Card(
          child: SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2))),
          ),
        ),
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({required this.label, required this.value});
  final String label; final String value;
  @override Widget build(BuildContext context) {
    return Card(child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      ]),
    ));
  }
}
