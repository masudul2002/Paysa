import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/goal.dart';
import '../providers/goal_providers.dart';
import '../../../../app/theme/design_tokens.dart';

class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(goalListProvider);
    final summaryAsync = ref.watch(goalSummaryProvider);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: SafeArea(
        child: async.when(
          loading: () => const _GoalSkeleton(),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (goals) {
            if (goals.isEmpty) {
              return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.flag_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text('No goals yet', style: tt.titleMedium),
                const SizedBox(height: 8),
                Text('Create a financial goal to track your progress.',
                  style: tt.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ]));
            }

            return RefreshIndicator(
              onRefresh: () async { ref.invalidate(goalListProvider); },
              child: ListView(
                padding: const EdgeInsets.all(DesignTokens.space16),
                children: [
                  summaryAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (s) => _SummaryCard(summary: s, tt: tt),
                  ),
                  if (summaryAsync.asData?.value != null) const SizedBox(height: DesignTokens.space20),
                  ...goals.map((g) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _GoalCard(goal: g, tt: tt),
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary, required this.tt});
  final GoalSummary summary;
  final TextTheme tt;

  @override Widget build(BuildContext ctx) {
    final cs = Theme.of(ctx).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Goal Summary', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(children: [
            _stat('Goals', '${summary.totalGoals}', cs),
            const SizedBox(width: 16),
            _stat('Target', '\$${(summary.totalTarget / 100).toStringAsFixed(0)}', cs),
            const SizedBox(width: 16),
            _stat('Saved', '\$${(summary.totalCurrent / 100).toStringAsFixed(0)}', cs),
          ]),
        ]),
      ),
    );
  }

  Widget _stat(String label, String value, ColorScheme cs) => Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
    Text(value, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
  ]));
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal, required this.tt});
  final FinancialGoal goal;
  final TextTheme tt;

  @override Widget build(BuildContext context) {
    final statusColor = switch (goal.status) {
      GoalStatus.onTrack => DesignTokens.income,
      GoalStatus.behind => DesignTokens.expense,
      GoalStatus.completed => DesignTokens.info,
      GoalStatus.archived => DesignTokens.neutral,
      GoalStatus.notStarted => DesignTokens.warning,
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
                child: Text(goal.status.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor)),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(goal.title, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600))),
              Icon(Icons.flag_outlined, color: statusColor, size: 20),
            ]),
            const SizedBox(height: 12),
            ClipRRect(borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: goal.progressPercent / 100, minHeight: 8,
                color: statusColor, backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest)),
            const SizedBox(height: 6),
            Row(children: [
              Text('${goal.progressPercent.toStringAsFixed(0)}% · \$${(goal.currentAmountMinor / 100).toStringAsFixed(0)} of \$${(goal.targetAmountMinor / 100).toStringAsFixed(0)}',
                style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
              const Spacer(),
              if (goal.targetDate != null)
                Text('${goal.remainingDays}d left', style: tt.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _GoalSkeleton extends StatelessWidget {
  const _GoalSkeleton();
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
