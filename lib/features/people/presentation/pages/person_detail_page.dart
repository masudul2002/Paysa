import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';
import '../../domain/entities/person.dart';
import '../../../ledger/domain/entities/ledger.dart';
import '../../../ledger/presentation/providers/ledger_providers.dart';
import '../../../ledger/presentation/widgets/give_money_sheet.dart';
import '../../../ledger/presentation/widgets/receive_money_sheet.dart';
import '../../../ledger/presentation/pages/ledger_timeline_page.dart';
import '../providers/people_providers.dart';
import '../widgets/person_visuals.dart';

/// Person detail/profile screen with live ledger data.
class PersonDetailPage extends ConsumerWidget {
  const PersonDetailPage({super.key, required this.personId});

  final int personId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personAsync = ref.watch(personByIdProvider(personId));
    final ledgerAsync = ref.watch(ledgerByPersonIdProvider(personId));

    return personAsync.when(
      loading: () => _scaffold(context, personAsync, const Center(
        child: LoadingWidget(message: 'Loading person...'),
      )),
      error: (err, _) => _scaffold(context, personAsync, Center(
        child: AppErrorWidget(title: 'Could not load person', details: err.toString()),
      )),
      data: (person) {
        if (person == null) {
          return _scaffold(context, personAsync, const Center(
            child: AppErrorWidget(title: 'Person not found'),
          ));
        }
        return _scaffold(context, personAsync, _PersonContentView(
          person: person,
          ledgerAsync: ledgerAsync,
          onGiveMoney: () => _openGiveMoney(context, ref, person),
          onReceiveMoney: () => _openReceiveMoney(context, ref, person),
        ));
      },
    );
  }

  Widget _scaffold(BuildContext context, AsyncValue<Person?> personAsync, Widget body) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Person'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(child: body),
    );
  }

  void _openGiveMoney(BuildContext context, WidgetRef ref, Person person) async {
    final ledger = await ref.read(ledgerByPersonIdProvider(person.id).future);
    if (ledger == null) { _showSnack(context, 'No ledger found'); return; }
    if (!context.mounted) return;
    showModalBottomSheet<void>(
      context: context, isScrollControlled: true, useSafeArea: true,
      showDragHandle: true,
      builder: (_) => GiveMoneySheet(personId: person.id, personName: person.name, ledgerId: ledger.id),
    );
  }

  void _openReceiveMoney(BuildContext context, WidgetRef ref, Person person) async {
    final ledger = await ref.read(ledgerByPersonIdProvider(person.id).future);
    if (ledger == null) { _showSnack(context, 'No ledger found'); return; }
    if (!context.mounted) return;
    showModalBottomSheet<void>(
      context: context, isScrollControlled: true, useSafeArea: true,
      showDragHandle: true,
      builder: (_) => ReceiveMoneySheet(
        personId: person.id, personName: person.name, ledgerId: ledger.id,
        currentBalance: ledger.currentBalance, receivableAmount: ledger.receivableAmount,
        payableAmount: ledger.payableAmount,
      ),
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

// ---------------------------------------------------------------------------
// Content
// ---------------------------------------------------------------------------

class _PersonContentView extends ConsumerWidget {
  const _PersonContentView({
    required this.person,
    required this.ledgerAsync,
    required this.onGiveMoney,
    required this.onReceiveMoney,
  });

  final Person person;
  final AsyncValue<Ledger?> ledgerAsync;
  final VoidCallback onGiveMoney;
  final VoidCallback onReceiveMoney;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final typeColor = personTypeColor(person.type);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isWide ? 24 : 16),
      child: isWide
          ? _buildWideLayout(context, theme, typeColor, ref)
          : _buildNarrowLayout(context, theme, typeColor, ref),
    );
  }

  // --------------------------------------------------------------------------
  // Layouts
  // --------------------------------------------------------------------------

  Widget _buildNarrowLayout(BuildContext context, ThemeData theme, Color typeColor, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, theme, typeColor),
        const SizedBox(height: 20),
        _buildLedgerCards(context, theme, ref),
        const SizedBox(height: 20),
        _buildActions(context, theme),
        const SizedBox(height: 20),
        _buildRecentEntries(context, theme, ref),
        const SizedBox(height: 20),
        _buildNotesSection(context, theme),
        const SizedBox(height: 20),
        _buildPlaceholders(context, theme),
      ],
    );
  }

  Widget _buildWideLayout(BuildContext context, ThemeData theme, Color typeColor, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: Column(children: [
          _buildHeader(context, theme, typeColor),
          const SizedBox(height: 20),
          _buildNotesSection(context, theme),
          const SizedBox(height: 20),
          _buildPlaceholders(context, theme),
        ])),
        const SizedBox(width: 24),
        Expanded(flex: 3, child: Column(children: [
          _buildLedgerCards(context, theme, ref),
          const SizedBox(height: 20),
          _buildActions(context, theme),
          const SizedBox(height: 20),
          _buildRecentEntries(context, theme, ref),
        ])),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // Header
  // --------------------------------------------------------------------------

  Widget _buildHeader(BuildContext context, ThemeData theme, Color typeColor) {
    return Center(
      child: Column(children: [
        Stack(children: [
          CircleAvatar(radius: 52, backgroundColor: typeColor.withValues(alpha: 0.14),
            child: Icon(personTypeIcon(person.type), size: 48, color: typeColor)),
          if (person.isFavorite)
            Positioned(top: 0, right: 0, child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(Icons.star, size: 20, color: Colors.amber.shade600),
            )),
        ]),
        const SizedBox(height: 12),
        Text(person.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
          child: Text(person.type.label, style: theme.textTheme.labelLarge?.copyWith(color: typeColor, fontWeight: FontWeight.w600))),
        if (person.phone != null) ...[const SizedBox(height: 8),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.phone_outlined, size: 16, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 6), Text(person.phone!, style: theme.textTheme.bodyMedium)])],
        if (person.email != null) ...[const SizedBox(height: 4),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.email_outlined, size: 16, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 6), Text(person.email!, style: theme.textTheme.bodyMedium)])],
      ]),
    );
  }

  // --------------------------------------------------------------------------
  // Ledger cards — outstanding, last transaction, balances
  // --------------------------------------------------------------------------

  Widget _buildLedgerCards(BuildContext context, ThemeData theme, WidgetRef ref) {
    return ledgerAsync.when(
      loading: () => Card(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          const CircularProgressIndicator(strokeWidth: 2),
          const SizedBox(width: 12),
          Text('Loading ledger...', style: theme.textTheme.bodySmall),
        ]),
      )),
      error: (_, __) => const SizedBox.shrink(),
      data: (ledger) {
        if (ledger == null) {
          return Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('No ledger yet. Record a transaction to start.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ));
        }

        final outstanding = ledger.currentBalance;
        final lastTx = ledger.lastTransactionAt;

        return Column(children: [
          // Outstanding + Last transaction
          Row(children: [
            Expanded(child: _InfoCard(
              icon: Icons.account_balance_wallet_outlined, label: 'Outstanding',
              value: 'USD ${(outstanding.abs() / 100).toStringAsFixed(2)}',
              valueColor: outstanding >= 0 ? Colors.green.shade700 : Colors.red.shade700,
              subtitle: outstanding >= 0 ? 'They owe you' : 'You owe them',
            )),
            const SizedBox(width: 12),
            Expanded(child: _InfoCard(
              icon: Icons.history_outlined, label: 'Last Transaction',
              value: lastTx != null
                  ? '${lastTx.day.toString().padLeft(2, '0')}/${lastTx.month.toString().padLeft(2, '0')}/${lastTx.year}'
                  : 'None',
            )),
          ]),
          const SizedBox(height: 12),
          // Receivable / Payable breakdown
          Row(children: [
            Expanded(child: _InfoCard(
              icon: Icons.trending_up_outlined, label: 'Receivable',
              value: 'USD ${(ledger.receivableAmount / 100).toStringAsFixed(2)}',
              valueColor: Colors.green.shade700,
            )),
            const SizedBox(width: 12),
            Expanded(child: _InfoCard(
              icon: Icons.trending_down_outlined, label: 'Payable',
              value: 'USD ${(ledger.payableAmount / 100).toStringAsFixed(2)}',
              valueColor: Colors.red.shade700,
            )),
          ]),
        ]);
      },
    );
  }

  // --------------------------------------------------------------------------
  // Quick actions
  // --------------------------------------------------------------------------

  Widget _buildActions(BuildContext context, ThemeData theme) {
    return Row(children: [
      Expanded(child: _ActionCard(
        icon: Icons.arrow_upward_outlined, title: 'Give Money',
        subtitle: 'To ${person.name}', color: Colors.red,
        onTap: onGiveMoney,
      )),
      const SizedBox(width: 12),
      Expanded(child: _ActionCard(
        icon: Icons.arrow_downward_outlined, title: 'Receive Money',
        subtitle: 'From ${person.name}', color: Colors.green,
        onTap: onReceiveMoney,
      )),
    ]);
  }

  // --------------------------------------------------------------------------
  // Recent ledger entries (last 5)
  // --------------------------------------------------------------------------

  Widget _buildRecentEntries(BuildContext context, ThemeData theme, WidgetRef ref) {
    final ledger = ledgerAsync.asData?.value;
    if (ledger == null) return const SizedBox.shrink();

    final entriesAsync = ref.watch(ledgerEntriesProvider(ledger.id));

    return entriesAsync.when(
      loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
      error: (_, __) => const SizedBox.shrink(),
      data: (entries) {
        final recent = entries.take(5).toList();
        if (recent.isEmpty) return const SizedBox.shrink();

        return Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(children: [
                Icon(Icons.receipt_long_outlined, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Recent Ledger Activity', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('All'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => LedgerTimelinePage(
                      ledgerId: ledger.id, personName: person.name,
                    )),
                  ),
                ),
              ]),
            ),
            ...recent.map((e) => _recentEntryRow(context, theme, e)),
          ]),
        );
      },
    );
  }

  Widget _recentEntryRow(BuildContext context, ThemeData theme, LedgerEntry entry) {
    final entryColor = _entryColor(entry.entryType);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: entryColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
          child: Icon(_entryIcon(entry.entryType), size: 16, color: entryColor),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(entry.entryType.label, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
          Text('${entry.transactionDate.day.toString().padLeft(2, '0')}/${entry.transactionDate.month.toString().padLeft(2, '0')}/${entry.transactionDate.year}',
              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ])),
        Text('USD ${(entry.amount / 100).toStringAsFixed(2)}',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: entry.entryType.isIncoming ? Colors.green.shade700 : Colors.red.shade700,
            )),
      ]),
    );
  }

  Color _entryColor(LedgerEntryType t) => switch (t) {
    LedgerEntryType.give || LedgerEntryType.borrow => Colors.red,
    LedgerEntryType.receive || LedgerEntryType.repayment => Colors.green,
    LedgerEntryType.sale => Colors.blue, LedgerEntryType.purchase => Colors.orange,
    LedgerEntryType.discount => Colors.purple, LedgerEntryType.adjustment => Colors.teal,
    LedgerEntryType.opening => Colors.grey, LedgerEntryType.manual => Colors.indigo,
  };

  IconData _entryIcon(LedgerEntryType t) => switch (t) {
    LedgerEntryType.opening => Icons.flag_outlined, LedgerEntryType.give => Icons.arrow_upward_outlined,
    LedgerEntryType.receive => Icons.arrow_downward_outlined, LedgerEntryType.borrow => Icons.arrow_upward_outlined,
    LedgerEntryType.repayment => Icons.arrow_downward_outlined, LedgerEntryType.adjustment => Icons.tune_outlined,
    LedgerEntryType.discount => Icons.discount_outlined, LedgerEntryType.sale => Icons.shopping_cart_outlined,
    LedgerEntryType.purchase => Icons.shopping_bag_outlined, LedgerEntryType.manual => Icons.edit_outlined,
  };

  // --------------------------------------------------------------------------
  // Notes
  // --------------------------------------------------------------------------

  Widget _buildNotesSection(BuildContext context, ThemeData theme) {
    if (person.notes == null || person.notes!.isEmpty) return const SizedBox.shrink();
    return Card(margin: EdgeInsets.zero, child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.notes_outlined, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8), Text('Notes', style: theme.textTheme.titleMedium),
        ]),
        const SizedBox(height: 8),
        Text(person.notes!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ]),
    ));
  }

  // --------------------------------------------------------------------------
  // Placeholders
  // --------------------------------------------------------------------------

  Widget _buildPlaceholders(BuildContext context, ThemeData theme) {
    return Column(children: [
      _PlaceholderSection(icon: Icons.notifications_outlined, title: 'Payment Reminders',
        subtitle: 'Set reminders for due payments.', onTap: () => _snack(context, 'Reminders coming soon')),
      const SizedBox(height: 8),
      _PlaceholderSection(icon: Icons.share_outlined, title: 'Share Statement',
        subtitle: 'Share outstanding balance and ledger history.', onTap: () => _snack(context, 'Sharing coming soon')),
    ]);
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

// ---------------------------------------------------------------------------
// Widgets
// ---------------------------------------------------------------------------

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.label, required this.value, this.valueColor, this.subtitle});
  final IconData icon; final String label; final String value; final Color? valueColor; final String? subtitle;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(margin: EdgeInsets.zero, child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(height: 8),
        Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: valueColor)),
        if (subtitle != null) ...[const SizedBox(height: 2),
          Text(subtitle!, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))],
      ]),
    ));
  }
}

class _PlaceholderSection extends StatelessWidget {
  const _PlaceholderSection({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon; final String title; final String subtitle; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(margin: EdgeInsets.zero, clipBehavior: Clip.antiAlias, child: InkWell(
      onTap: onTap,
      child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
        Container(padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: theme.colorScheme.onPrimaryContainer)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ])),
        Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
      ])),
    ));
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});
  final IconData icon; final String title; final String subtitle; final Color color; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(margin: EdgeInsets.zero, clipBehavior: Clip.antiAlias, child: InkWell(
      onTap: onTap,
      child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
        Container(padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ])),
        Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
      ])),
    ));
  }
}
