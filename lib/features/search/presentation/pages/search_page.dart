import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/shared.dart';
import '../../domain/services/search_service.dart';
import '../providers/search_providers.dart';
import '../../../../app/theme/design_tokens.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});
  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() { _searchCtrl.dispose(); _debounce?.cancel(); super.dispose(); }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).state = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(searchResultsProvider);
    final query = ref.watch(searchQueryProvider);
    final recent = ref.watch(recentSearchesProvider);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search people, transactions, receipts...',
            border: InputBorder.none,
          ),
          onChanged: _onSearchChanged,
        ),
        actions: [
          if (_searchCtrl.text.isNotEmpty)
            IconButton(icon: const Icon(Icons.close), onPressed: () {
              _searchCtrl.clear();
              ref.read(searchQueryProvider.notifier).state = '';
              setState(() {});
            }),
        ],
      ),
      body: SafeArea(
        child: query.trim().length < 2
            ? _buildInitial(recent, tt)
            : resultsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => AppErrorWidget(title: 'Search failed', details: e.toString()),
                data: (groups) {
                  if (groups.isEmpty) return _buildNoResults(tt);
                  return _buildResults(groups, tt);
                },
              ),
      ),
    );
  }

  Widget _buildInitial(List<String> recent, TextTheme tt) {
    if (recent.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.search, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
        const SizedBox(height: 16),
        Text('Search across all your financial data', style: tt.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ]));
    }

    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(children: [
        Text('Recent Searches', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        const Spacer(),
        TextButton(onPressed: () => ref.read(searchServiceProvider).clearRecentSearches(), child: const Text('Clear')),
      ]),
      ...recent.map((q) => ListTile(
        dense: true,
        leading: const Icon(Icons.history, size: 20),
        title: Text(q),
        onTap: () {
          _searchCtrl.text = q;
          ref.read(searchQueryProvider.notifier).state = q;
          setState(() {});
        },
      )),
    ]);
  }

  Widget _buildNoResults(TextTheme tt) {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.search_off, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
      const SizedBox(height: 16),
      Text('No results found', style: tt.titleMedium),
      const SizedBox(height: 8),
      Text('Try adjusting your search query.', style: tt.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
    ]));
  }

  Widget _buildResults(List<SearchResultGroup> groups, TextTheme tt) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      itemBuilder: (_, i) {
        final group = groups[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(group.label, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              if (group.results.length >= 5)
                TextButton(onPressed: () {}, child: const Text('View All', style: TextStyle(fontSize: 12))),
            ]),
            const SizedBox(height: 6),
            ...group.results.map((r) => _ResultTile(result: r)),
          ]),
        );
      },
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.result});
  final SearchResult result;

  @override Widget build(BuildContext context) {
    final icon = _iconFor(result.type);
    final color = _colorFor(result.type);
    final tt = Theme.of(context).textTheme;

    return Card(margin: const EdgeInsets.only(bottom: 6), child: ListTile(
      dense: true,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 18, color: color),
      ),
      title: _highlightMatch(result.title, result.matchField, result.matchStart, result.matchLength, tt),
      subtitle: Text(result.subtitle, style: tt.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: result.trailing.isNotEmpty
          ? Text(result.trailing, style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600))
          : null,
      onTap: () {},
    ));
  }

  Widget _highlightMatch(String text, String? field, int? start, int? len, TextTheme tt) {
    if (start == null || len == null || start < 0 || start + len > text.length) {
      return Text(text, style: tt.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis);
    }
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(style: tt.bodyMedium, children: [
        if (start > 0) TextSpan(text: text.substring(0, start)),
        TextSpan(text: text.substring(start, start + len), style: TextStyle(backgroundColor: Colors.yellow.shade200, fontWeight: FontWeight.w600)),
        if (start + len < text.length) TextSpan(text: text.substring(start + len)),
      ]),
    );
  }

  IconData _iconFor(String type) => switch (type) {
    'transaction' => Icons.swap_horiz, 'person' => Icons.person,
    'account' => Icons.account_balance_wallet, 'ledger' => Icons.receipt_long,
    'payment_request' => Icons.payment, 'receipt' => Icons.receipt,
    _ => Icons.search,
  };

  Color _colorFor(String type) => switch (type) {
    'transaction' => Colors.blue, 'person' => Colors.purple,
    'account' => Colors.teal, 'ledger' => Colors.orange,
    'payment_request' => Colors.indigo, 'receipt' => Colors.green,
    _ => Colors.grey,
  };
}
