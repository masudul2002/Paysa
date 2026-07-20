import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';
import '../../domain/entities/ledger.dart';
import '../../domain/entities/statement.dart';
import '../providers/ledger_providers.dart';

/// Full-screen preview of a person's ledger statement.
///
/// Shows person details, opening/closing balance, full entry timeline
/// with running balance, and summary totals.
/// Ready for future PDF/image export.
class StatementPreviewPage extends ConsumerWidget {
  const StatementPreviewPage({
    super.key,
    required this.personName,
    required this.personPhone,
    required this.personType,
    required this.ledgerId,
  });

  final String personName;
  final String? personPhone;
  final String personType;
  final int ledgerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(ledgerEntriesProvider(ledgerId));
    final balanceAsync = ref.watch(ledgerBalanceProvider(ledgerId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statement'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            tooltip: 'Change period',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export coming soon')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: entriesAsync.when(
          loading: () => const Center(
            child: LoadingWidget(message: 'Generating statement...'),
          ),
          error: (e, _) => Center(
            child: AppErrorWidget(
              title: 'Could not generate statement',
              details: e.toString(),
            ),
          ),
          data: (entries) => balanceAsync.when(
            loading: () => const LoadingWidget(),
            error: (e, _) => AppErrorWidget(
              title: 'Could not load balance',
              details: e.toString(),
            ),
            data: (balance) => _StatementContent(
              personName: personName,
              personPhone: personPhone,
              personType: personType,
              ledgerId: ledgerId,
              entries: entries,
              openingBalance: balance.openingBalance,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatementContent extends StatelessWidget {
  const _StatementContent({
    required this.personName,
    required this.personPhone,
    required this.personType,
    required this.ledgerId,
    required this.entries,
    required this.openingBalance,
  });

  final String personName;
  final String? personPhone;
  final String personType;
  final int ledgerId;
  final List<LedgerEntry> entries;
  final int openingBalance;

  @override
  Widget build(BuildContext context) {
    final statement = generateStatement(
      personName: personName,
      personPhone: personPhone,
      personType: personType,
      openingBalance: openingBalance,
      entries: entries,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, statement),
          const SizedBox(height: 20),
          _buildBalanceSummary(context, statement),
          const SizedBox(height: 20),
          _buildTimeline(context, statement),
          const SizedBox(height: 20),
          _buildFooter(context, statement),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Header
  // --------------------------------------------------------------------------

  Widget _buildHeader(BuildContext context, Statement statement) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Brand
            Text(
              'STATEMENT',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),

            // Person
            Text(
              statement.personName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (statement.personPhone != null) ...[
              const SizedBox(height: 4),
              Text(
                statement.personPhone!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              statement.personType,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),

            const Divider(height: 24),

            // Date
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _dateChip(theme, _fmtDate(statement.periodStart)),
                Icon(Icons.arrow_forward, size: 16,
                    color: theme.colorScheme.onSurfaceVariant),
                _dateChip(theme, _fmtDate(statement.periodEnd)),
              ],
            ),

            const SizedBox(height: 12),

            // Generated date
            Text(
              'Generated ${_fmtDate(statement.createdAt)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateChip(ThemeData theme, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: theme.textTheme.labelMedium),
    );
  }

  // --------------------------------------------------------------------------
  // Balance summary
  // --------------------------------------------------------------------------

  Widget _buildBalanceSummary(BuildContext context, Statement statement) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            theme,
            'Opening Balance',
            statement.openingBalance,
            Colors.grey,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryCard(
            theme,
            'Closing Balance',
            statement.closingBalance,
            statement.closingBalance >= 0 ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(
      ThemeData theme, String label, int amount, Color color) {
    final isPositive = amount >= 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${isPositive ? '' : '-'}USD ${(amount.abs() / 100).toStringAsFixed(2)}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Timeline
  // --------------------------------------------------------------------------

  Widget _buildTimeline(BuildContext context, Statement statement) {
    final theme = Theme.of(context);

    if (statement.entries.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              'No entries in this period.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: theme.colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                SizedBox(width: 80, child: Text('Date',
                    style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600))),
                Expanded(
                  flex: 2,
                  child: Text('Description',
                      style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                ),
                SizedBox(
                  width: 80,
                  child: Text('Amount',
                      textAlign: TextAlign.right,
                      style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                ),
                SizedBox(
                  width: 80,
                  child: Text('Balance',
                      textAlign: TextAlign.right,
                      style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),

          // Table rows
          ...statement.entries.map((e) => _statementRow(theme, e)),

          // Totals
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: theme.dividerColor),
              ),
            ),
            child: Row(
              children: [
                SizedBox(width: 80, child: Text('')),
                Expanded(
                  flex: 2,
                  child: Text(
                    '${statement.entryCount} entries',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    statement.totalGive > 0
                        ? 'USD ${(statement.totalGive / 100).toStringAsFixed(2)}'
                        : '',
                    textAlign: TextAlign.right,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    'USD ${(statement.closingBalance / 100).toStringAsFixed(2)}',
                    textAlign: TextAlign.right,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: statement.closingBalance >= 0
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statementRow(ThemeData theme, StatementEntry entry) {
    final isOutgoing = entry.amount > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '${entry.date.day.toString().padLeft(2, '0')}/${entry.date.month.toString().padLeft(2, '0')}',
              style: theme.textTheme.bodySmall,
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.type,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (entry.description != null && entry.description!.isNotEmpty)
                  Text(
                    entry.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              isOutgoing
                  ? 'USD ${(entry.amount / 100).toStringAsFixed(2)}'
                  : '',
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.red.shade700,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              'USD ${(entry.runningBalance / 100).toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: entry.runningBalance >= 0
                    ? Colors.green.shade700
                    : Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Footer
  // --------------------------------------------------------------------------

  Widget _buildFooter(BuildContext context, Statement statement) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                theme,
                'Total Give',
                statement.totalGive,
                Colors.red.shade700,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                theme,
                'Total Receive',
                statement.totalReceive,
                Colors.green.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                theme,
                'Discount / Write-off',
                statement.totalDiscount,
                Colors.purple.shade700,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                theme,
                'Net Outstanding',
                statement.closingBalance,
                statement.closingBalance >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Generated by Paysa · ${_fmtDate(statement.createdAt)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // Helpers
  // --------------------------------------------------------------------------

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
