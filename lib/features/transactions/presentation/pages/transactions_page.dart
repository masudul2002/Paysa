import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_exception.dart';
import '../../../../shared/shared.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transactions_providers.dart';
import '../widgets/transaction_form_sheet.dart';
import '../../../../app/theme/design_tokens.dart';

class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});
  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {
  final _searchCtrl = TextEditingController();
  bool _showSearch = false;

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(transactionsStreamProvider);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchCtrl, autofocus: true,
                decoration: const InputDecoration(hintText: 'Search transactions...', border: InputBorder.none),
                onChanged: (v) => setState(() {}),
              )
            : const Text('Transactions'),
        actions: [
          if (_showSearch)
            IconButton(icon: const Icon(Icons.close), onPressed: () {
              setState(() { _showSearch = false; _searchCtrl.clear(); });
            })
          else
            IconButton(icon: const Icon(Icons.search), onPressed: () => setState(() => _showSearch = true)),
          PopupMenuButton<String>(icon: const Icon(Icons.sort_outlined), onSelected: (_) {},
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'newest', child: Text('Newest')),
              PopupMenuItem(value: 'oldest', child: Text('Oldest')),
              PopupMenuItem(value: 'highest', child: Text('Highest amount')),
              PopupMenuItem(value: 'lowest', child: Text('Lowest amount')),
            ]),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: async.when(
          loading: () => const _TxSkeleton(),
          error: (e, _) => AppErrorWidget(title: 'Could not load', details: e.toString()),
          data: (transactions) {
            final filtered = _showSearch && _searchCtrl.text.isNotEmpty
                ? transactions.where((t) =>
                    t.description.toLowerCase().contains(_searchCtrl.text.toLowerCase()) ||
                    t.currency.toLowerCase().contains(_searchCtrl.text.toLowerCase()))
                    .toList()
                : transactions;

            if (filtered.isEmpty) {
              return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.swap_horiz_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                gap16,
                Text('No transactions', style: tt.titleMedium),
                gap8,
                Text('Tap + to record your first transaction.',
                  style: tt.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ]));
            }

            return RefreshIndicator(
              onRefresh: () async {},
              child: ListView.builder(
                padding: const EdgeInsets.all(DesignTokens.space16),
                itemCount: filtered.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _TxCard(transaction: filtered[i], tt: tt, onTap: () => _openForm(context, t: filtered[i]), onDelete: () => _confirmDelete(context, filtered[i])),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openForm(BuildContext context, {Transaction? t}) {
    showModalBottomSheet<void>(context: context, isScrollControlled: true, useSafeArea: true, showDragHandle: true,
      builder: (_) => TransactionFormSheet(initialTransaction: t));
  }

  Future<void> _confirmDelete(BuildContext context, Transaction tx) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Delete transaction?'),
      content: Text('Delete ${tx.description.isNotEmpty ? tx.description : 'this transaction'}?'),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
      ],
    ));
    if (confirm != true) return;
    try {
      await ref.read(deleteTransactionProvider).call(tx.id);
    } on AppException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}

// ---------------------------------------------------------------------------
// Loading skeleton
// ---------------------------------------------------------------------------

class _TxSkeleton extends StatelessWidget {
  const _TxSkeleton();
  @override Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(DesignTokens.space16),
      itemCount: 5,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Card(
          child: SizedBox(
            height: 72,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2))),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Transaction card
// ---------------------------------------------------------------------------

class _TxCard extends StatelessWidget {
  const _TxCard({required this.transaction, required this.tt, required this.onTap, required this.onDelete});
  final Transaction transaction;
  final TextTheme tt;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? DesignTokens.income : DesignTokens.expense;
    final icon = isIncome ? Icons.arrow_circle_up : Icons.arrow_circle_down;

    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 24),
        color: Colors.red.shade400, child: const Icon(Icons.delete_outline, color: Colors.white)),
      confirmDismiss: (_) async {
        final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
          title: const Text('Delete?'), content: const Text('This cannot be undone.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
          ],
        ));
        return confirm ?? false;
      },
      onDismissed: (_) => onDelete(),
      child: Card(margin: EdgeInsets.zero, clipBehavior: Clip.antiAlias, child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space16, vertical: DesignTokens.space12),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(DesignTokens.radiusMd)),
              child: Icon(icon, color: color, size: 22)),
            gap12,
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(transaction.description.isNotEmpty ? transaction.description : transaction.type.label,
                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
              gap4,
              Row(children: [
                Text(transaction.date.day.toString().padLeft(2, '0') + '/' + transaction.date.month.toString().padLeft(2, '0'),
                  style: tt.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                gap8,
                if (transaction.isPending)
                  Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: DesignTokens.pending.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                    child: Text('Pending', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: DesignTokens.pending))),
              ]),
            ])),
            Text('\$${transaction.amount.toStringAsFixed(2)}',
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: color)),
          ]),
        ),
      )),
    );
  }
}

const gap4 = SizedBox(height: 4);
const gap8 = SizedBox(width: 8);
const gap12 = SizedBox(width: 12);
const gap16 = SizedBox(height: 16);
