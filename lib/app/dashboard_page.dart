import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/analytics/domain/entities/analytics_entities.dart';
import '../features/analytics/presentation/providers/analytics_providers.dart';
import '../shared/shared.dart';
import 'theme/design_tokens.dart';
import 'theme/app_colors.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(dashboardSnapshotProvider);
    final cfAsync = ref.watch(cashFlowProvider(DateRange(
      DateTime.now().subtract(const Duration(days: 30)), DateTime.now(),
    )));
    final oustandingAsync = ref.watch(outstandingSummaryProvider);
    final pc = ref.watch(themeColorProvider);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_greeting(), style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: dashAsync.when(
          loading: () => const _DashboardSkeleton(),
          error: (e, _) => AppErrorWidget(title: 'Dashboard unavailable', details: e.toString()),
          data: (dash) => RefreshIndicator(
            onRefresh: () async { ref.invalidate(dashboardSnapshotProvider); },
            child: ListView(
              padding: const EdgeInsets.all(DesignTokens.space16),
              children: [
                _BalanceCard(financial: dash.financial, pc: pc),
                gap16,
                _QuickActionsGrid(),
                gap24,
                _InsightTile(
                  financial: dash.financial,
                  months: dash.monthlyTrend,
                  pc: pc,
                  tt: tt,
                ),
                gap24,
                _MiniSummaryRow(cfAsync: cfAsync, outstandingAsync: oustandingAsync, pc: pc, tt: tt),
                gap24,
                _RecentSection(
                  title: 'Recent Activity',
                  transactions: dash.recentTransactions,
                  receipts: dash.recentReceipts,
                  tt: tt,
                  pc: pc,
                ),
                gap24,
                _CategoriesSection(
                  categories: dash.topCategories,
                  tt: tt,
                  pc: pc,
                ),
                gap32,
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const gap4 = SizedBox(height: 4);
const gap8 = SizedBox(height: 8);
const gap12 = SizedBox(height: 12);
const gap16 = SizedBox(height: 16);
const gap24 = SizedBox(height: 24);
const gap32 = SizedBox(height: 32);

// ---------------------------------------------------------------------------
// Theme color provider
// ---------------------------------------------------------------------------

final themeColorProvider = Provider<PaysaColors>((ref) {
  return const PaysaColors(
    income: DesignTokens.income,
    expense: DesignTokens.expense,
    pending: DesignTokens.pending,
    receivable: DesignTokens.receivable,
    payable: DesignTokens.payable,
  );
});

// ---------------------------------------------------------------------------
// Loading skeleton
// ---------------------------------------------------------------------------

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(DesignTokens.space16),
      children: List.generate(5, (_) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Card(
          child: SizedBox(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
            ),
          ),
        ),
      )),
    );
  }
}

// ---------------------------------------------------------------------------
// Balance card with gradient
// ---------------------------------------------------------------------------

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.financial, required this.pc});
  final FinancialSnapshot financial;
  final PaysaColors pc;

  @override Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final balance = financial.totalBalance / 100;
    final income = financial.totalIncome / 100;
    final expense = financial.totalExpense / 100;

    return Card(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [c.primaryContainer, c.primaryContainer.withValues(alpha: 0.3)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.space20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Total Balance', style: tt.labelLarge?.copyWith(color: c.onPrimaryContainer)),
            gap8,
            Text('\$${balance.toStringAsFixed(2)}',
              style: tt.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: c.onPrimaryContainer)),
            gap16,
            Row(children: [
              _miniStat(tt, 'Income', '\$${income.toStringAsFixed(0)}', pc.income),
              gap12,
              _miniStat(tt, 'Expense', '\$${expense.toStringAsFixed(0)}', pc.expense),
              gap12,
              _miniStat(tt, 'Accounts', '${financial.accountCount}', c.onPrimaryContainer),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _miniStat(TextTheme tt, String label, String value, Color color) {
    return Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: tt.labelSmall?.copyWith(color: color)),
      Text(value, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: color)),
    ]));
  }
}

// ---------------------------------------------------------------------------
// Quick actions grid
// ---------------------------------------------------------------------------

class _QuickActionsGrid extends StatelessWidget {
  @override Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Expanded(child: _qaBtn(context, Icons.arrow_circle_up, 'Income', DesignTokens.income)),
        gap12,
        Expanded(child: _qaBtn(context, Icons.arrow_circle_down, 'Expense', DesignTokens.expense)),
        gap12,
        Expanded(child: _qaBtn(context, Icons.swap_horiz, 'Transfer', Colors.blue)),
      ]),
      gap8,
      Row(children: [
        Expanded(child: _qaBtn(context, Icons.receipt_long_outlined, 'Payment', Colors.teal)),
        gap12,
        Expanded(child: _qaBtn(context, Icons.people_outlined, 'Person', Colors.purple)),
        gap12,
        Expanded(child: _qaBtn(context, Icons.more_horiz, 'More', Colors.grey)),
      ]),
    ]);
  }

  Widget _qaBtn(BuildContext context, IconData icon, String label, Color color) {
    return Semantics(button: true, label: label, child: InkWell(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      onTap: () {},
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 20),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ]),
      ),
    ));
  }
}

// ---------------------------------------------------------------------------
// Insight tile
// ---------------------------------------------------------------------------

class _InsightTile extends StatelessWidget {
  const _InsightTile({required this.financial, required this.months, required this.pc, required this.tt});
  final FinancialSnapshot financial;
  final List<MonthlySummary> months;
  final PaysaColors pc;
  final TextTheme tt;

  @override Widget build(BuildContext context) {
    final current = months.isNotEmpty ? months.last : null;
    final previous = months.length > 1 ? months[months.length - 2] : null;
    String msg = '';
    if (current != null && previous != null && previous.totalExpense > 0) {
      final diff = ((current.totalExpense - previous.totalExpense) / previous.totalExpense * 100).round();
      msg = diff > 0 ? 'Spending up $diff% vs last month' : 'Spending down ${diff.abs()}% vs last month';
    }
    if (msg.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(DesignTokens.space12),
      decoration: BoxDecoration(
        color: DesignTokens.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(color: DesignTokens.info.withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        Icon(Icons.info_outline, size: 18, color: DesignTokens.info),
        gap12,
        Expanded(child: Text(msg, style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w500))),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
// Cash flow + outstanding mini cards
// ---------------------------------------------------------------------------

class _MiniSummaryRow extends StatelessWidget {
  const _MiniSummaryRow({required this.cfAsync, required this.outstandingAsync, required this.pc, required this.tt});
  final AsyncValue<CashFlowSummary> cfAsync;
  final AsyncValue<OutstandingSummary> outstandingAsync;
  final PaysaColors pc;
  final TextTheme tt;

  @override Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: _miniCard(context, 'Cash Flow', cfAsync.when(
        loading: () => '...',
        error: (_, __) => 'Error',
        data: (c) => '\$${(c.netCashFlow / 100).toStringAsFixed(0)}',
      ), pc.income, tt)),
      gap12,
      Expanded(child: _miniCard(context, 'Outstanding', outstandingAsync.when(
        loading: () => '...',
        error: (_, __) => 'Error',
        data: (o) => '\$${(o.netOutstanding / 100).toStringAsFixed(0)}',
      ), pc.receivable, tt)),
    ]);
  }

  Widget _miniCard(BuildContext context, String label, String value, Color color, TextTheme tt) {
    return Card(child: Padding(
      padding: const EdgeInsets.all(DesignTokens.space16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: tt.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        gap8,
        Text(value, style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
      ]),
    ));
  }
}

// ---------------------------------------------------------------------------
// Recent section
// ---------------------------------------------------------------------------

class _RecentSection extends StatelessWidget {
  const _RecentSection({required this.title, required this.transactions, required this.receipts, required this.tt, required this.pc});
  final String title;
  final List<TransactionSummary> transactions;
  final List<ReceiptSummary> receipts;
  final TextTheme tt;
  final PaysaColors pc;

  @override Widget build(BuildContext context) {
    final items = <_ActivityItem>[];
    for (final t in transactions) {
      items.add(_ActivityItem(
        icon: t.type == 'Income' ? Icons.arrow_circle_up : Icons.arrow_circle_down,
        color: t.type == 'Income' ? pc.income : pc.expense,
        title: t.description.isNotEmpty ? t.description : t.type,
        subtitle: '${t.date.day}/${t.date.month}',
        trailing: '\$${(t.amount / 100).toStringAsFixed(2)}',
      ));
    }
    if (items.isEmpty) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        gap12,
        Card(child: Padding(padding: const EdgeInsets.all(24), child: Center(
          child: Text('No activity yet', style: tt.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ))),
      ]);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
      gap12,
      ...items.take(5).map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _activityRow(context, item, tt),
      )),
    ]);
  }
}

class _ActivityItem {
  const _ActivityItem({required this.icon, required this.color, required this.title, required this.subtitle, required this.trailing});
  final IconData icon; final Color color; final String title; final String subtitle; final String trailing;
}

Widget _activityRow(BuildContext context, _ActivityItem item, TextTheme tt) {
  return Card(margin: EdgeInsets.zero, child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space16, vertical: DesignTokens.space12),
    child: Row(children: [
      Container(padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: item.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
        child: Icon(item.icon, size: 18, color: item.color)),
      gap12,
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(item.title, style: tt.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(item.subtitle, style: tt.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ])),
      Text(item.trailing, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
    ]),
  ));
}

// ---------------------------------------------------------------------------
// Categories section
// ---------------------------------------------------------------------------

class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection({required this.categories, required this.tt, required this.pc});
  final List<CategorySummary> categories;
  final TextTheme tt;
  final PaysaColors pc;

  @override Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Top Categories', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
      gap12,
      ...categories.map((c) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _categoryRow(context, c, tt),
      )),
    ]);
  }
}

Widget _categoryRow(BuildContext context, CategorySummary cat, TextTheme tt) {
  return Card(margin: EdgeInsets.zero, child: Padding(
    padding: const EdgeInsets.all(DesignTokens.space12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(cat.categoryName, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500))),
        Text('\$${(cat.totalAmount / 100).toStringAsFixed(2)}', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
      ]),
      gap4,
      ClipRRect(borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(value: cat.percentage / 100, minHeight: 6,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest)),
      gap4,
      Text('${cat.percentage.toStringAsFixed(0)}% · ${cat.transactionCount} txns',
        style: tt.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
    ]),
  ));
}

