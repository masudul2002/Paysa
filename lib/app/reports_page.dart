import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/analytics/domain/entities/analytics_entities.dart';
import '../features/analytics/presentation/providers/analytics_providers.dart';
import '../shared/shared.dart';
import 'theme/design_tokens.dart';
import 'design/design_system.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  Widget _buildOverview(AsyncValue<DashboardSnapshot> dash) {
    if (dash.isLoading) return const _LoadingSection(height: 100);
    if (dash.hasError) return ErrorCard(message: dash.error.toString());
    return _OverviewCards(financial: dash.asData!.value.financial);
  }

  Widget _buildCashFlowAndOutstanding(AsyncValue<CashFlowSummary> cf, AsyncValue<OutstandingSummary> os) {
    return Row(children: [
      Expanded(child: cf.isLoading
          ? const _MiniCard(label: 'Net Flow', value: '...')
          : cf.hasError
              ? const _MiniCard(label: 'Net Flow', value: 'Error')
              : _MiniCard(label: 'Net Flow', value: '\$${(cf.asData!.value.netCashFlow / 100).toStringAsFixed(2)}', color: cf.asData!.value.netCashFlow >= 0 ? null : DesignTokens.expense)),
      const SizedBox(width: 8),
      Expanded(child: os.isLoading
          ? const _MiniCard(label: 'Outstanding', value: '...')
          : os.hasError
              ? const _MiniCard(label: 'Outstanding', value: 'Error')
              : _MiniCard(label: 'Outstanding', value: '\$${(os.asData!.value.netOutstanding / 100).toStringAsFixed(2)}', color: os.asData!.value.netOutstanding >= 0 ? null : DesignTokens.expense)),
    ]);
  }

  Widget _buildCategories(AsyncValue<List<CategorySummary>> cats) {
    if (cats.isLoading) return const _LoadingSection(height: 200);
    if (cats.hasError) return ErrorCard(message: cats.error.toString());
    final list = cats.asData?.value ?? [];
    if (list.isEmpty) return const EmptyCard(message: 'No spending data');
    return Column(children: list.map((c) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _CategoryRow(cat: c))).toList());
  }

  Widget _buildMonthlyTrend(int year) {
    return const EmptyCard(message: 'Enable monthly trends');
  }

  Widget _buildSavingsRate(AsyncValue<DashboardSnapshot> dash) {
    if (dash.isLoading || dash.hasError) return const SizedBox.shrink();
    return _SavingsRateCard(financial: dash.asData!.value.financial);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(dashboardSnapshotProvider);
    final cfAsync = ref.watch(cashFlowProvider(DateRange(
      DateTime(DateTime.now().year, DateTime.now().month, 1), DateTime.now(),
    )));
    final outstandingAsync = ref.watch(outstandingSummaryProvider);
    final catsAsync = ref.watch(topCategoriesProvider);
    final year = DateTime.now().year;

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async { ref.invalidate(dashboardSnapshotProvider); },
          child: ListView(
            padding: const EdgeInsets.all(DesignTokens.space16),
            children: [
              const _PeriodChips(),
              const SizedBox(height: DesignTokens.space20),
              _buildOverview(dashAsync),
              const SizedBox(height: DesignTokens.space24),
              SectionHeader(title: 'Period Summary'),
              const SizedBox(height: DesignTokens.space12),
              _buildCashFlowAndOutstanding(cfAsync, outstandingAsync),
              const SizedBox(height: DesignTokens.space24),
              SectionHeader(title: 'Spending by Category'),
              const SizedBox(height: DesignTokens.space12),
              _buildCategories(catsAsync),
              const SizedBox(height: DesignTokens.space24),
              SectionHeader(title: 'Monthly Trend'),
              const SizedBox(height: DesignTokens.space12),
              _buildMonthlyTrend(year),
              const SizedBox(height: DesignTokens.space32),
              _buildSavingsRate(dashAsync),
              const SizedBox(height: DesignTokens.space24),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Period Selector
// ---------------------------------------------------------------------------

class _PeriodChips extends StatelessWidget {
  const _PeriodChips();

  @override Widget build(BuildContext context) {
    final options = ['Today', 'This Week', 'This Month', 'Last Month', 'Last 3 Months', 'This Year'];
    final icons = [Icons.today, Icons.date_range, Icons.calendar_month, Icons.calendar_month, Icons.date_range, Icons.calendar_today];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Period', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      const SizedBox(height: 6),
      SizedBox(height: 36, child: ListView(scrollDirection: Axis.horizontal, children: List.generate(options.length, (i) {
        final sel = options[i] == 'This Month';
        return Padding(padding: const EdgeInsets.only(right: 6), child: FilterChip(
          label: Text(options[i], style: TextStyle(fontSize: 12, fontWeight: sel ? FontWeight.w600 : FontWeight.normal)),
          selected: sel,
          avatar: Icon(icons[i], size: 14),
          onSelected: (_) {},
          visualDensity: VisualDensity.compact,
        ));
      }))),
    ]);
  }

  static DateTime _computeStart(String label, DateTime now) => switch (label) {
    'Today' => now,
    'This Week' => now.subtract(Duration(days: now.weekday - 1)),
    'This Month' => DateTime(now.year, now.month, 1),
    'Last Month' => DateTime(now.year, now.month - 1, 1),
    'Last 3 Months' => DateTime(now.year, now.month - 3, 1),
    'This Year' => DateTime(now.year, 1, 1),
    _ => DateTime(now.year, now.month, 1),
  };
}

// ---------------------------------------------------------------------------
// Overview Cards
// ---------------------------------------------------------------------------

class _OverviewCards extends StatelessWidget {
  const _OverviewCards({required this.financial});
  final FinancialSnapshot financial;

  @override Widget build(BuildContext context) {
    final income = financial.totalIncome / 100;
    final expense = financial.totalExpense / 100;
    final net = income - expense;
    final rate = income > 0 ? ((net / income) * 100).toStringAsFixed(1) : 'N/A';

    return Column(children: [
      Row(children: [
        Expanded(child: _StatCard(label: 'Income', value: '\$${income.toStringAsFixed(2)}', color: DesignTokens.income, icon: Icons.arrow_circle_up)),
        const SizedBox(width: 8),
        Expanded(child: _StatCard(label: 'Expense', value: '\$${expense.toStringAsFixed(2)}', color: DesignTokens.expense, icon: Icons.arrow_circle_down)),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: _StatCard(label: 'Net Cash Flow', value: '\$${net.toStringAsFixed(2)}', color: net >= 0 ? DesignTokens.income : DesignTokens.expense, icon: Icons.trending_up)),
        const SizedBox(width: 8),
        Expanded(child: _StatCard(label: 'Savings Rate', value: '$rate%', color: DesignTokens.info, icon: Icons.savings_outlined)),
      ]),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, this.color, this.icon});
  final String label; final String value; final Color? color; final IconData? icon;

  @override Widget build(BuildContext context) {
    return Card(margin: EdgeInsets.zero, child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          if (icon != null) Icon(icon, size: 16, color: color ?? Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))),
        ]),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
      ]),
    ));
  }
}

// ---------------------------------------------------------------------------
// Mini Card
// ---------------------------------------------------------------------------

class _MiniCard extends StatelessWidget {
  const _MiniCard({required this.label, required this.value, this.color});
  final String label; final String value; final Color? color;

  @override Widget build(BuildContext context) {
    return Card(margin: EdgeInsets.zero, child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
      ]),
    ));
  }
}

// ---------------------------------------------------------------------------
// Category Row
// ---------------------------------------------------------------------------

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.cat});
  final CategorySummary cat;

  @override Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Card(margin: EdgeInsets.zero, child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(cat.categoryName, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500))),
          Text('\$${(cat.totalAmount / 100).toStringAsFixed(2)}', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: cat.percentage / 100, minHeight: 8,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest)),
        const SizedBox(height: 4),
        Text('${cat.percentage.toStringAsFixed(0)}% of total · ${cat.transactionCount} transactions',
          style: tt.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ]),
    ));
  }
}

// ---------------------------------------------------------------------------
// Month Row
// ---------------------------------------------------------------------------

class _MonthRow extends StatelessWidget {
  const _MonthRow({required this.m});
  final MonthlySummary m;

  @override Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return Card(margin: EdgeInsets.zero, child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          SizedBox(width: 40, child: Text(months[m.month - 1], style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600))),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
              value: m.totalIncome > 0 ? 1.0 : 0, minHeight: 6, color: DesignTokens.income,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            )),
            const SizedBox(height: 2),
            ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
              value: m.totalExpense > 0 ? (m.totalExpense / (m.totalIncome > 0 ? m.totalIncome : 1)).clamp(0, 1) : 0,
              minHeight: 6, color: DesignTokens.expense,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            )),
          ])),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('\$${(m.totalIncome / 100).toStringAsFixed(0)}', style: tt.labelSmall?.copyWith(color: DesignTokens.income, fontWeight: FontWeight.w600)),
            Text('\$${(m.totalExpense / 100).toStringAsFixed(0)}', style: tt.labelSmall?.copyWith(color: DesignTokens.expense)),
          ]),
        ]),
      ]),
    ));
  }
}

// ---------------------------------------------------------------------------
// Savings Rate Card
// ---------------------------------------------------------------------------

class _SavingsRateCard extends StatelessWidget {
  const _SavingsRateCard({required this.financial});
  final FinancialSnapshot financial;

  @override Widget build(BuildContext context) {
    final income = financial.totalIncome / 100;
    final expense = financial.totalExpense / 100;
    final net = income - expense;
    final rate = income > 0 ? (net / income * 100) : 0.0;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(title: 'Savings Rate'),
      const SizedBox(height: 8),
      Card(child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('You save ${rate.toStringAsFixed(1)}% of your income', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Income: \$${income.toStringAsFixed(2)} · Expense: \$${expense.toStringAsFixed(2)} · Net: \$${net.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ])),
          SizedBox(
            width: 72, height: 72,
            child: Stack(alignment: Alignment.center, children: [
              SizedBox(width: 72, height: 72, child: CircularProgressIndicator(
                value: rate / 100, strokeWidth: 6,
                color: rate >= 20 ? DesignTokens.income : (rate >= 10 ? DesignTokens.warning : DesignTokens.expense),
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              )),
              Text('${rate.toStringAsFixed(0)}%', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            ]),
          ),
        ]),
      )),
    ]);
  }
}

// ---------------------------------------------------------------------------
// Loading Section
// ---------------------------------------------------------------------------

class _LoadingSection extends StatelessWidget {
  const _LoadingSection({required this.height});
  final double height;
  @override Widget build(BuildContext context) => SizedBox(height: height, child: const Center(child: CircularProgressIndicator(strokeWidth: 2)));
}

// ---------------------------------------------------------------------------
// Section Header
// ---------------------------------------------------------------------------

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.subtitle, this.actionLabel, this.onAction});
  final String title; final String? subtitle; final String? actionLabel; final VoidCallback? onAction;

  @override Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        if (subtitle != null) Text(subtitle!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ])),
      if (actionLabel != null) TextButton(onPressed: onAction, child: Text(actionLabel!)),
    ]);
  }
}

// ---------------------------------------------------------------------------
// Error Card
// ---------------------------------------------------------------------------

class ErrorCard extends StatelessWidget {
  const ErrorCard({super.key, required this.message});
  final String message;
  @override Widget build(BuildContext context) => Card(margin: EdgeInsets.zero, child: Padding(
    padding: const EdgeInsets.all(16),
    child: Row(children: [Icon(Icons.error_outline, size: 18, color: Theme.of(context).colorScheme.error), const SizedBox(width: 8), Expanded(child: Text(message))]),
  ));
}

// ---------------------------------------------------------------------------
// Empty Card
// ---------------------------------------------------------------------------

class EmptyCard extends StatelessWidget {
  const EmptyCard({super.key, required this.message});
  final String message;
  @override Widget build(BuildContext context) => Card(margin: EdgeInsets.zero, child: Padding(
    padding: const EdgeInsets.all(24), child: Center(child: Text(message, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))),
  ));
}
