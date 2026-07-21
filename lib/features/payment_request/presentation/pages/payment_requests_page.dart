import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';
import '../../domain/entities/payment_request.dart';
import '../providers/payment_request_providers.dart';
import '../widgets/payment_request_form_sheet.dart';

class PaymentRequestsPage extends ConsumerStatefulWidget {
  const PaymentRequestsPage({super.key});
  @override
  ConsumerState<PaymentRequestsPage> createState() => _PaymentRequestsPageState();
}

class _PaymentRequestsPageState extends ConsumerState<PaymentRequestsPage> {
  final _searchCtrl = TextEditingController();
  bool _showSearch = false;

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(prListProvider);
    final status = ref.watch(prStatusFilterProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: _showSearch ? TextField(controller: _searchCtrl, autofocus: true,
          decoration: const InputDecoration(hintText: 'Search requests...', border: InputBorder.none),
          onChanged: (v) => ref.read(prSearchProvider.notifier).state = v,
        ) : const Text('Payment Requests'),
        actions: [
          if (_showSearch) IconButton(icon: const Icon(Icons.close), onPressed: () {
            setState(() => _showSearch = false); _searchCtrl.clear();
            ref.read(prSearchProvider.notifier).state = '';
          }) else IconButton(icon: const Icon(Icons.search), onPressed: () => setState(() => _showSearch = true)),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _openForm(context), child: const Icon(Icons.add)),
      body: SafeArea(child: Column(children: [
        SizedBox(height: 48, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), children: [
          _chip('All', status == null, () => ref.read(prStatusFilterProvider.notifier).state = null),
          for (final s in PaymentRequestStatus.values)
            _chip(s.label, status == s, () => ref.read(prStatusFilterProvider.notifier).state = s),
        ])),
        const Divider(height: 1),
        Expanded(child: async.when(
          loading: () => const Center(child: LoadingWidget(message: 'Loading...')),
          error: (e, _) => Center(child: AppErrorWidget(title: 'Could not load', details: e.toString())),
          data: (requests) {
            if (requests.isEmpty) {
              return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.receipt_long_outlined, size: 64, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                const SizedBox(height: 16), Text('No payment requests', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8), Text('Create a payment request to get started.', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ]));
            }
            return RefreshIndicator(onRefresh: () async { ref.invalidate(prListProvider); }, child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: requests.length,
              itemBuilder: (_, i) => _buildRequestCard(context, theme, requests[i]),
            ));
          },
        )),
      ])),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) => Padding(padding: const EdgeInsets.only(right: 6),
    child: FilterChip(label: Text(label, style: const TextStyle(fontSize: 11)), selected: selected, onSelected: (_) => onTap(), visualDensity: VisualDensity.compact));

  Widget _buildRequestCard(BuildContext context, ThemeData theme, PaymentRequest r) {
    final statusColor = switch (r.status) {
      PaymentRequestStatus.draft => Colors.grey,
      PaymentRequestStatus.pending => Colors.orange,
      PaymentRequestStatus.partiallyPaid => Colors.blue,
      PaymentRequestStatus.paid => Colors.green,
      PaymentRequestStatus.expired => Colors.red,
      PaymentRequestStatus.cancelled => Colors.grey,
      PaymentRequestStatus.failed => Colors.red,
    };

    return Card(margin: const EdgeInsets.only(bottom: 8), clipBehavior: Clip.antiAlias, child: InkWell(
      onTap: () => _openForm(context, request: r),
      child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Text(r.status.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor))),
          const SizedBox(width: 8),
          Text(r.requestNumber, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const Spacer(),
          Text('USD ${(r.amountMinor / 100).toStringAsFixed(2)}', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 8),
        Text(r.title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        if (r.description != null && r.description!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(r.description!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
        const SizedBox(height: 8),
        Row(children: [
          Icon(Icons.category_outlined, size: 12, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4), Text(r.requestType.label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          if (r.expiresAt != null) ...[const Spacer(),
            Icon(Icons.schedule_outlined, size: 12, color: Colors.red.shade400),
            const SizedBox(width: 4),
            Text('${r.expiresAt!.day.toString().padLeft(2, '0')}/${r.expiresAt!.month.toString().padLeft(2, '0')}',
              style: theme.textTheme.labelSmall?.copyWith(color: Colors.red.shade400)),
          ],
        ]),
      ])),
    ));
  }

  void _openForm(BuildContext context, {PaymentRequest? request}) {
    showModalBottomSheet<void>(context: context, isScrollControlled: true, useSafeArea: true, showDragHandle: true,
      builder: (_) => PaymentRequestFormSheet(initialRequest: request));
  }
}
