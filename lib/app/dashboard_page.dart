import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/analytics/domain/entities/analytics_entities.dart';
import '../features/analytics/presentation/providers/analytics_providers.dart';
import '../features/accounts/presentation/widgets/account_form_sheet.dart';
import '../features/transactions/presentation/widgets/transaction_form_sheet.dart';
import '../shared/shared.dart';
import 'theme/design_tokens.dart';
import 'design/design_system.dart';
import 'design/widgets/dashboard_cards.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(dashboardSnapshotProvider);
    final cashFlowAsync = ref.watch(cashFlowProvider(DateRange(
      DateTime.now().subtract(const Duration(days: 30)), DateTime.now(),
    )));
    final outstandingAsync = ref.watch(outstandingSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_greeting(), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: dashAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AppErrorWidget(title: 'Could not load', details: e.toString()),
          data: (dash) => RefreshIndicator(
            onRefresh: () async { ref.invalidate(dashboardSnapshotProvider); },
            child: ListView(
              padding: const EdgeInsets.all(DesignTokens.space16),
              children: [
                _BalanceCard(financial: dash.financial),
                const SizedBox(height: DesignTokens.space20),
                _QuickActionsBar(),
                const SizedBox(height: DesignTokens.space24),
                _InsightsRow(financial: dash.financial, month: dash.monthlyTrend),
                const SizedBox(height: DesignTokens.space24),
                Row(children: [
                  Expanded(child: _CashFlowCard(cashFlowAsync: cashFlowAsync)),
                  const SizedBox(width: DesignTokens.space12),
                  Expanded(child: _OutstandingCard(outstandingAsync: outstandingAsync)),
                ]),
                const SizedBox(height: DesignTokens.space24),
                _SectionTitle(title: 'Recent Activity'),
                const SizedBox(height: DesignTokens.space12),
                _RecentActivity(txs: dash.recentTransactions, receipts: dash.recentReceipts),
                const SizedBox(height: DesignTokens.space24),
                _SectionTitle(title: 'Top Categories', subtitle: 'This month'),
                const SizedBox(height: DesignTokens.space12),
                _TopCategories(dash: dash),
                const SizedBox(height: DesignTokens.space32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning ☀️';
    if (h < 17) return 'Good afternoon 🌤️';
    return 'Good evening 🌙';
  }
}

// ---------------------------------------------------------------------------
// Balance Card (Section 2)
// ---------------------------------------------------------------------------

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.financial});
  final FinancialSnapshot financial;

  @override Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final balance = financial.totalBalance / 100;
    final income = financial.totalIncome / 100;
    final expense = financial.totalExpense / 100;
    final net = financial.netWorth / 100;

    return Card(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [c.primaryContainer, c.primaryContainer.withValues(alpha: 0.4)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.space20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('Total Balance', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c.onPrimaryContainer)),
              const Spacer(),
              Icon(Icons.visibility_outlined, size: 18, color: c.onPrimaryContainer),
            ]),
            const SizedBox(height: DesignTokens.space8),
            AnimatedCounter(value: balance, style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: c.onPrimaryContainer)),
            const SizedBox(height: DesignTokens.space16),
            Row(children: [
              _miniStat(context, 'Income', income, DesignTokens.income, Icons.arrow_circle_up),
              const SizedBox(width: DesignTokens.space12),
              _miniStat(context, 'Expense', expense, DesignTokens.expense, Icons.arrow_circle_down),
              const SizedBox(width: DesignTokens.space12),
              _miniStat(context, 'Net Worth', net, net >= 0 ? DesignTokens.income : DesignTokens.expense, Icons.account_balance_wallet),
            ]),
            const SizedBox(height: DesignTokens.space12),
            Row(children: [
              Text('${financial.accountCount} account${financial.accountCount == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: c.onPrimaryContainer.withValues(alpha: 0.7))),
              const SizedBox(width: DesignTokens.space8),
              Text('${financial.pendingPaymentCount} pending',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: DesignTokens.warning)),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _miniStat(BuildContext context, String label, double amount, Color color, IconData icon) {
    return Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color)),
      ]),
      const SizedBox(height: 2),
      Text('\$${amount.toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: color)),
    ]));
  }
}

// ---------------------------------------------------------------------------
// Quick Actions (Section 3)
// ---------------------------------------------------------------------------

class _QuickActionsBar extends StatelessWidget {
  @override Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Expanded(child: _QABtn(context, Icons.arrow_circle_up, 'Income', DesignTokens.income, () {})),
        const SizedBox(width: DesignTokens.space8),
        Expanded(child: _QABtn(context, Icons.arrow_circle_down, 'Expense', DesignTokens.expense, () {})),
        const SizedBox(width: DesignTokens.space8),
        Expanded(child: _QABtn(context, Icons.swap_horiz, 'Transfer', Colors.blue.shade600, () {})),
      ]),
      const SizedBox(height: DesignTokens.space8),
      Row(children: [
        Expanded(child: _QABtn(context, Icons.person_add, 'Person', Colors.purple.shade600, () {})),
        const SizedBox(width: DesignTokens.space8),
        Expanded(child: _QABtn(context, Icons.receipt_long, 'Payment', Colors.teal.shade600, () {})),
        const SizedBox(width: DesignTokens.space8),
        Expanded(child: _QABtn(context, Icons.more_horiz, 'More', Colors.grey.shade600, () {})),
      ]),
    ]);
  }

  Widget _QABtn(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    final s = MediaQuery.of(context).size;
    final pad = s.width > 600 ? 16.0 : 8.0;
    return Semantics(button: true, label: label, child: InkWell(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: EdgeInsets.symmetric(horizontal: pad, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ]),
      ),
    ));
  }
}

// ---------------------------------------------------------------------------
// Insights (Section 8 — feeds into Section 6 chart area)
// ---------------------------------------------------------------------------

class _InsightsRow extends StatelessWidget {
  const _InsightsRow({required this.financial, required this.month});
  final FinancialSnapshot financial;
  final List<MonthlySummary> month;

  @override Widget build(BuildContext context) {
    final current = month.isNotEmpty ? month.last : null;
    final previous = month.length > 1 ? month[month.length - 2] : null;

    String? insight;
    if (current != null && previous != null && previous.totalExpense > 0) {
      final diff = ((current.totalExpense - previous.totalExpense) / previous.totalExpense * 100);
      insight = diff > 0
          ? 'Spending up ${diff.round()}% vs last month'
          : 'Spending down ${diff.abs().round()}% vs last month 🎉';
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (insight != null)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(DesignTokens.space12),
          decoration: BoxDecoration(
            color: DesignTokens.info.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            border: Border.all(color: DesignTokens.info.withValues(alpha: 0.2)),
          ),
          child: Row(children: [
            Icon(PaysaIcons.info, size: 18, color: DesignTokens.info),
            const SizedBox(width: 8),
            Expanded(child: Text(insight, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500))),
          ]),
        ),
    ]);
  }
}

// ---------------------------------------------------------------------------
// Cash Flow + Outstanding cards (Sections 4 + 5)
// ---------------------------------------------------------------------------

class _CashFlowCard extends StatelessWidget {
  const _CashFlowCard({required this.cashFlowAsync});
  final AsyncValue<CashFlowSummary> cashFlowAsync;

  @override Widget build(BuildContext context) {
    return cashFlowAsync.when(
      loading: () => _miniCard(context, 'Cash Flow', '---', Icons.trending_up, Colors.blue),
      error: (_, __) => _miniCard(context, 'Cash Flow', 'Error', Icons.error, Colors.red),
      data: (c) => _miniCard(context, 'Cash Flow', '\$${(c.netCashFlow / 100).toStringAsFixed(0)}',
        c.netCashFlow >= 0 ? Icons.trending_up : Icons.trending_down,
        c.netCashFlow >= 0 ? DesignTokens.income : DesignTokens.expense,
        subtitle: '${c.transactionCount} txns'),
    );
  }
}

class _OutstandingCard extends StatelessWidget {
  const _OutstandingCard({required this.outstandingAsync});
  final AsyncValue<OutstandingSummary> outstandingAsync;

  @override Widget build(BuildContext context) {
    return outstandingAsync.when(
      loading: () => _miniCard(context, 'Outstanding', '---', Icons.people, Colors.teal),
      error: (_, __) => _miniCard(context, 'Outstanding', 'Error', Icons.error, Colors.red),
      data: (o) => _miniCard(context, 'Outstanding', '\$${(o.netOutstanding / 100).toStringAsFixed(0)}',
        o.netOutstanding >= 0 ? Icons.trending_up : Icons.trending_down,
        o.netOutstanding >= 0 ? DesignTokens.income : DesignTokens.expense,
        subtitle: '${o.personCount} people'),
    );
  }
}

Widget _miniCard(BuildContext context, String label, String value, IconData icon, Color color, {String? subtitle}) {
  return Card(child: Padding(
    padding: const EdgeInsets.all(DesignTokens.space16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ]),
      const SizedBox(height: DesignTokens.space8),
      Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
      if (subtitle != null) ...[
        const SizedBox(height: 2),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    ]),
  ));
}

// ---------------------------------------------------------------------------
// Recent Activity (Section 7)
// ---------------------------------------------------------------------------

class _RecentActivity extends StatelessWidget {
  const _RecentActivity({required this.txs, required this.receipts});
  final List<TransactionSummary> txs;
  final List<ReceiptSummary> receipts;

  @override Widget build(BuildContext context) {
    final items = <_ActivityItem>[];
    for (final t in txs) {
      items.add(_ActivityItem(
        icon: t.type == 'Income' ? PaysaIcons.income : PaysaIcons.expense,
        color: t.type == 'Income' ? DesignTokens.income : DesignTokens.expense,
        title: t.description.isNotEmpty ? t.description : t.type,
        subtitle: '${t.date.day}/${t.date.month}',
        trailing: '\$${(t.amount / 100).toStringAsFixed(2)}',
      ));
    }
    for (final r in receipts) {
      items.add(_ActivityItem(
        icon: PaysaIcons.receipt, color: Colors.teal,
        title: r.receiptNumber, subtitle: r.provider,
        trailing: '\$${(r.amountMinor / 100).toStringAsFixed(2)}',
      ));
    }
    items.sort((a, b) => b.subtitle.compareTo(a.subtitle));
    final display = items.take(6).toList();

    if (display.isEmpty) return const EmptyCard(message: 'No recent activity');
    return Column(children: display);
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({required this.icon, required this.color, required this.title, required this.subtitle, required this.trailing});
  final IconData icon; final Color color; final String title; final String subtitle; final String trailing;

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tt = theme.textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.space8),
      child: Card(margin: EdgeInsets.zero, child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space16, vertical: DesignTokens.space12),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: color)),
          const SizedBox(width: DesignTokens.space12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: tt.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(subtitle, style: tt.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ])),
          Text(trailing, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        ]),
      )),
    );
  }
}

// ---------------------------------------------------------------------------
// Top Categories (Section 6 partial)
// ---------------------------------------------------------------------------

class _TopCategories extends StatelessWidget {
  const _TopCategories({required this.dash});
  final DashboardSnapshot dash;

  @override Widget build(BuildContext context) {
    final cats = dash.topCategories;
    if (cats.isEmpty) return const EmptyCard(message: 'No spending data this month');
    return Column(children: cats.map((c) => Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.space8),
      child: _CategoryRow(category: c),
    )).toList());
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category});
  final CategorySummary category;

  @override Widget build(BuildContext context) {
    final t = Theme.of(context);
    final theme = Theme.of(context);
    final tt = theme.textTheme;
    return Card(margin: EdgeInsets.zero, child: Padding(
      padding: const EdgeInsets.all(DesignTokens.space12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(category.categoryName, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500))),
          Text('\$${(category.totalAmount / 100).toStringAsFixed(2)}', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: DesignTokens.space4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: category.percentage / 100,
            minHeight: 6,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
        const SizedBox(height: DesignTokens.space2),
        Text('${category.percentage.toStringAsFixed(0)}% · ${category.transactionCount} txns',
          style: tt.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ]),
    ));
  }
}

// ---------------------------------------------------------------------------
// Section Title helper
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.subtitle});
  final String title; final String? subtitle;

  @override Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
      if (subtitle != null) ...[const SizedBox(height: 2), Text(subtitle!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))],
    ]);
  }
}

// ---------------------------------------------------------------------------
// Animated Counter
// ---------------------------------------------------------------------------

class AnimatedCounter extends StatefulWidget {
  const AnimatedCounter({super.key, required this.value, this.style});
  final double value; final TextStyle? style;
  @override State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  double _display = 0;

  @override void initState() { super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.addListener(() { setState(() => _display = _anim.value * widget.value); });
    _ctrl.forward();
  }

  @override void didUpdateWidget(AnimatedCounter old) {
    if (old.value != widget.value) {
      _display = 0;
      _ctrl.reset();
      _ctrl.forward();
    }
    super.didUpdateWidget(old);
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    return Text('\$${_display.toStringAsFixed(2)}', style: widget.style);
  }
}
