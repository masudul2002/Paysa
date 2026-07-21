import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_exception.dart';
import '../../../../shared/shared.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_method_defaults.dart';
import '../providers/payment_method_providers.dart';
import '../widgets/payment_method_form_sheet.dart';

class PaymentMethodsPage extends ConsumerStatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  ConsumerState<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends ConsumerState<PaymentMethodsPage> {
  final _searchCtrl = TextEditingController();
  bool _showSearch = false;

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final methodsAsync = ref.watch(paymentMethodListProvider);
    final searchQuery = ref.watch(paymentMethodSearchProvider);
    final favoritesOnly = ref.watch(paymentMethodFavoritesOnlyProvider);

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchCtrl, autofocus: true,
                decoration: const InputDecoration(hintText: 'Search methods...', border: InputBorder.none),
                onChanged: (v) => ref.read(paymentMethodSearchProvider.notifier).state = v,
              )
            : const Text('Payment Methods'),
        actions: [
          if (_showSearch)
            IconButton(icon: const Icon(Icons.close), onPressed: () {
              setState(() => _showSearch = false);
              _searchCtrl.clear();
              ref.read(paymentMethodSearchProvider.notifier).state = '';
            })
          else
            IconButton(icon: const Icon(Icons.search), onPressed: () => setState(() => _showSearch = true)),
          PopupMenuButton<String>(icon: const Icon(Icons.more_vert), onSelected: (v) {
            if (v == 'favorites') ref.read(paymentMethodFavoritesOnlyProvider.notifier).state = !favoritesOnly;
          }, itemBuilder: (_) => [
            PopupMenuItem(value: 'favorites', child: Text(favoritesOnly ? 'Show all' : 'Favorites only')),
          ]),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add custom method',
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.all(16),
        child: methodsAsync.when(
          loading: () => const Center(child: LoadingWidget(message: 'Loading methods...')),
          error: (e, _) => Center(child: AppErrorWidget(title: 'Could not load', details: e.toString())),
          data: (methods) {
            if (methods.isEmpty) {
              return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.payment_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Text('No payment methods', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('Add a custom payment method.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ]));
            }

            return ListView.separated(
              itemCount: methods.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _methodTile(context, methods[i]),
            );
          },
        ),
      )),
    );
  }

  Widget _methodTile(BuildContext context, PaymentMethod m) {
    final theme = Theme.of(context);
    final color = m.colorValue != null ? Color(m.colorValue!) : theme.colorScheme.primary;

    return Card(margin: EdgeInsets.zero, clipBehavior: Clip.antiAlias, child: InkWell(
      onTap: () => _openForm(context, method: m),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Row(children: [
        Container(width: 40, height: 40,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(m.type.label[0], style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(m.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
            if (!m.isEnabled) ...[const SizedBox(width: 4), Icon(Icons.visibility_off_outlined, size: 14, color: theme.colorScheme.onSurfaceVariant)],
            if (m.isFavorite) ...[const SizedBox(width: 4), Icon(Icons.star, size: 14, color: Colors.amber.shade600)],
          ]),
          const SizedBox(height: 2),
          Text(m.type.label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ])),
        if (m.isBuiltIn)
          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(8)),
            child: Text('System', style: theme.textTheme.labelSmall?.copyWith(fontSize: 9, color: theme.colorScheme.onPrimaryContainer))),
      ])),
    ));
  }

  void _openForm(BuildContext context, {PaymentMethod? method}) {
    showModalBottomSheet<void>(context: context, isScrollControlled: true, useSafeArea: true, showDragHandle: true,
      builder: (_) => PaymentMethodFormSheet(initialMethod: method));
  }
}
