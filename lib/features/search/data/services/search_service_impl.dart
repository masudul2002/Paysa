import 'package:collection/collection.dart';
import '../../domain/services/search_service.dart';

/// Implementation of [SearchService] that queries across all domains.
///
/// Uses existing repository callbacks injected via constructor.
final class SearchServiceImpl implements SearchService {
  SearchServiceImpl({
    required this.searchTransactions,
    required this.searchPeople,
    required this.searchAccounts,
    required this.searchLedgerEntries,
    required this.searchPaymentRequests,
    required this.searchReceipts,
  });

  final Future<List<SearchResult>> Function(String query) searchTransactions;
  final Future<List<SearchResult>> Function(String query) searchPeople;
  final Future<List<SearchResult>> Function(String query) searchAccounts;
  final Future<List<SearchResult>> Function(String query) searchLedgerEntries;
  final Future<List<SearchResult>> Function(String query) searchPaymentRequests;
  final Future<List<SearchResult>> Function(String query) searchReceipts;

  final _recentSearches = <String>[];
  static const _maxRecent = 10;

  @override
  Future<List<SearchResultGroup>> search(String query) async {
    if (query.trim().length < 2) return [];
    final q = query.trim();
    saveRecentSearch(q);

    final results = await Future.wait([
      searchTransactions(q),
      searchPeople(q),
      searchAccounts(q),
      searchLedgerEntries(q),
      searchPaymentRequests(q),
      searchReceipts(q),
    ]);

    final groups = <SearchResultGroup>[];
    final labels = ['Transactions', 'People', 'Accounts', 'Ledger', 'Payments', 'Receipts'];
    final types = ['transaction', 'person', 'account', 'ledger', 'payment_request', 'receipt'];

    for (int i = 0; i < results.length; i++) {
      if (results[i].isNotEmpty) {
        groups.add(SearchResultGroup(
          type: types[i],
          label: labels[i],
          results: results[i].take(5).toList(),
        ));
      }
    }

    return groups;
  }

  @override
  Future<List<SearchResult>> searchByType(String type, String query) async {
    final fn = _searchFn(type);
    if (fn == null) return [];
    return fn(query);
  }

  Future<List<SearchResult>> Function(String)? _searchFn(String type) => switch (type) {
    'transaction' => searchTransactions,
    'person' => searchPeople,
    'account' => searchAccounts,
    'ledger' => searchLedgerEntries,
    'payment_request' => searchPaymentRequests,
    'receipt' => searchReceipts,
    _ => null,
  };

  @override
  List<String> getRecentSearches() => List.unmodifiable(_recentSearches);

  @override
  void saveRecentSearch(String query) {
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    if (_recentSearches.length > _maxRecent) {
      _recentSearches.removeLast();
    }
  }

  @override
  void clearRecentSearches() => _recentSearches.clear();
}
