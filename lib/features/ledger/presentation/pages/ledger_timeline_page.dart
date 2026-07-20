import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';
import '../../domain/entities/ledger.dart';
import '../providers/ledger_providers.dart';

/// Full-screen timeline of all ledger entries for a specific ledger.
///
/// Shows each entry as a row with icon, type, amount, running balance,
/// payment method, date, time, description, notes/attachment indicators.
/// Supports swipe-to-delete, responsive layout, and Material 3 theming.
class LedgerTimelinePage extends ConsumerStatefulWidget {
  const LedgerTimelinePage({
    super.key,
    required this.ledgerId,
    this.personName,
  });

  final int ledgerId;
  final String? personName;

  @override
  ConsumerState<LedgerTimelinePage> createState() =>
      _LedgerTimelinePageState();
}

class _LedgerTimelinePageState extends ConsumerState<LedgerTimelinePage> {
  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(ledgerEntriesProvider(widget.ledgerId));
    final balanceAsync = ref.watch(ledgerBalanceStreamProvider(widget.ledgerId));
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.personName ?? 'Ledger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
          IconButton(
            icon: const Icon(Icons.sort_outlined),
            onPressed: () => _showSortMenu(context),
          ),
        ],
      ),
      body: SafeArea(
        child: isWide
            ? _buildWideLayout(context, entriesAsync, balanceAsync)
            : _buildNarrowLayout(context, entriesAsync, balanceAsync),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Narrow layout (phone)
  // --------------------------------------------------------------------------

  Widget _buildNarrowLayout(
    BuildContext context,
    AsyncValue<List<LedgerEntry>> entriesAsync,
    AsyncValue<LedgerBalance> balanceAsync,
  ) {
    return Column(
      children: [
        _buildBalanceHeader(balanceAsync),
        const Divider(height: 1),
        _buildFilterRow(),
        const Divider(height: 1),
        Expanded(child: _buildEntryList(entriesAsync)),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // Wide layout (tablet)
  // --------------------------------------------------------------------------

  Widget _buildWideLayout(
    BuildContext context,
    AsyncValue<List<LedgerEntry>> entriesAsync,
    AsyncValue<LedgerBalance> balanceAsync,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 320,
          child: Column(
            children: [
              _buildBalanceHeader(balanceAsync),
              const Divider(height: 1),
              _buildFilterRow(),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(child: _buildEntryList(entriesAsync)),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // Balance header
  // --------------------------------------------------------------------------

  Widget _buildBalanceHeader(AsyncValue<LedgerBalance> balanceAsync) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: balanceAsync.when(
        loading: () => const SizedBox(
          height: 60,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        error: (e, _) => AppErrorWidget(
          title: 'Could not load balance',
          details: e.toString(),
        ),
        data: (balance) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _balanceStat(
                  'Receivable',
                  balance.receivableAmount,
                  Colors.green.shade700,
                ),
                const SizedBox(width: 16),
                _balanceStat(
                  'Payable',
                  balance.payableAmount,
                  Colors.red.shade700,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Net: ${balance.currentBalance >= 0 ? '+' : ''}'
                  'USD ${(balance.currentBalance / 100).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: balance.currentBalance >= 0
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                ),
                const Spacer(),
                Text(
                  '${balance.entryCount} entries',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _balanceStat(String label, int amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        Text(
          'USD ${(amount / 100).toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // Filter row
  // --------------------------------------------------------------------------

  Widget _buildFilterRow() {
    final typeFilter = ref.watch(ledgerEntryTypeFilterProvider);

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          _filterChip('All', typeFilter == null, () {
            ref.read(ledgerEntryTypeFilterProvider.notifier).state = null;
          }),
          for (final type in LedgerEntryType.values)
            _filterChip(type.label, typeFilter == type, () {
              ref.read(ledgerEntryTypeFilterProvider.notifier).state =
                  typeFilter == type ? null : type;
            }),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        visualDensity: VisualDensity.compact,
        labelStyle: const TextStyle(fontSize: 11),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Entry list
  // --------------------------------------------------------------------------

  Widget _buildEntryList(AsyncValue<List<LedgerEntry>> entriesAsync) {
    return entriesAsync.when(
      loading: () => const Center(
        child: LoadingWidget(message: 'Loading entries...'),
      ),
      error: (e, _) => Center(
        child: AppErrorWidget(
          title: 'Could not load entries',
          details: e.toString(),
        ),
      ),
      data: (entries) {
        if (entries.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No entries yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Record your first Give, Receive, or Sale for this person.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(ledgerEntriesProvider(widget.ledgerId));
          },
          child: ListView.builder(
            itemCount: entries.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (_, index) =>
                _buildEntryRow(entries[index], index, entries),
          ),
        );
      },
    );
  }

  // --------------------------------------------------------------------------
  // Entry row
  // --------------------------------------------------------------------------

  Widget _buildEntryRow(
      LedgerEntry entry, int index, List<LedgerEntry> allEntries) {
    final theme = Theme.of(context);
    final entryColor = _entryColor(entry.entryType);
    final iconData = _entryIcon(entry.entryType);

    // Compute running balance from this point onward (display order is newest first)
    int runningBalance = 0;
    for (int i = allEntries.length - 1; i >= index; i--) {
      final e = allEntries[i];
      if (e.entryType.isOutgoing) {
        runningBalance += e.amount;
      } else if (e.entryType.isIncoming) {
        runningBalance -= e.amount;
      } else if (e.entryType == LedgerEntryType.discount) {
        runningBalance -= e.amount;
      } else if (e.entryType == LedgerEntryType.adjustment) {
        runningBalance += e.amount;
      } else if (e.entryType == LedgerEntryType.manual) {
        runningBalance += e.amount;
      }
    }

    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: Colors.red.shade400,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete entry?'),
            content: Text(
              'Delete ${entry.entryType.label} of '
              'USD ${(entry.amount / 100).toStringAsFixed(2)}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        return confirm ?? false;
      },
      onDismissed: (_) {
        ref.read(deleteLedgerEntryProvider).call(entry.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${entry.entryType.label} deleted')),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon column
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: entryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: entryColor, size: 20),
            ),
            const SizedBox(width: 12),

            // Middle column: type + date/time + description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        entry.entryType.label,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.notes_outlined,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant),
                      ],
                      if (entry.attachmentCount > 0) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.attach_file_outlined,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(entry.transactionDate, entry.transactionTime),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (entry.description != null &&
                      entry.description!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      entry.description!,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Amount + running balance column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'USD ${(entry.amount / 100).toStringAsFixed(2)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: entry.entryType.isIncoming
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${runningBalance >= 0 ? '+' : ''}'
                  'USD ${(runningBalance / 100).toStringAsFixed(2)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: runningBalance >= 0
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Search dialog
  // --------------------------------------------------------------------------

  void _showSearch(BuildContext context) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Search entries'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search by description or notes...',
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (value) {
            ref.read(ledgerSearchQueryProvider.notifier).state = value;
            Navigator.of(ctx).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(ledgerSearchQueryProvider.notifier).state =
                  controller.text;
              Navigator.of(ctx).pop();
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Sort menu
  // --------------------------------------------------------------------------

  void _showSortMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Sort by',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date (newest)'),
              onTap: () {
                ref.read(ledgerSortProvider.notifier).state = {
                  'field': LedgerSortField.date.name,
                  'direction': LedgerSortDirection.descending.name,
                };
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date (oldest)'),
              onTap: () {
                ref.read(ledgerSortProvider.notifier).state = {
                  'field': LedgerSortField.date.name,
                  'direction': LedgerSortDirection.ascending.name,
                };
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Amount (high-low)'),
              onTap: () {
                ref.read(ledgerSortProvider.notifier).state = {
                  'field': LedgerSortField.amount.name,
                  'direction': LedgerSortDirection.descending.name,
                };
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Amount (low-high)'),
              onTap: () {
                ref.read(ledgerSortProvider.notifier).state = {
                  'field': LedgerSortField.amount.name,
                  'direction': LedgerSortDirection.ascending.name,
                };
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Helpers
  // --------------------------------------------------------------------------

  Color _entryColor(LedgerEntryType type) => switch (type) {
        LedgerEntryType.give || LedgerEntryType.borrow => Colors.red,
        LedgerEntryType.receive || LedgerEntryType.repayment => Colors.green,
        LedgerEntryType.sale => Colors.blue,
        LedgerEntryType.purchase => Colors.orange,
        LedgerEntryType.discount => Colors.purple,
        LedgerEntryType.adjustment => Colors.teal,
        LedgerEntryType.opening => Colors.grey,
        LedgerEntryType.manual => Colors.indigo,
      };

  IconData _entryIcon(LedgerEntryType type) => switch (type) {
        LedgerEntryType.opening => Icons.flag_outlined,
        LedgerEntryType.give => Icons.arrow_upward_outlined,
        LedgerEntryType.receive => Icons.arrow_downward_outlined,
        LedgerEntryType.borrow => Icons.arrow_upward_outlined,
        LedgerEntryType.repayment => Icons.arrow_downward_outlined,
        LedgerEntryType.adjustment => Icons.tune_outlined,
        LedgerEntryType.discount => Icons.discount_outlined,
        LedgerEntryType.sale => Icons.shopping_cart_outlined,
        LedgerEntryType.purchase => Icons.shopping_bag_outlined,
        LedgerEntryType.manual => Icons.edit_outlined,
      };

  String _formatDate(DateTime date, String? time) {
    final d =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    if (time != null && time.isNotEmpty) return '$d $time';
    return d;
  }
}
