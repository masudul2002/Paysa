import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';
import '../../data/services/search_service_impl.dart';
import '../../domain/services/search_service.dart';

final searchServiceProvider = Provider<SearchService>((ref) {
  return SearchServiceImpl(
    searchTransactions: (_) async => [],
    searchPeople: (_) async => [],
    searchAccounts: (_) async => [],
    searchLedgerEntries: (_) async => [],
    searchPaymentRequests: (_) async => [],
    searchReceipts: (_) async => [],
  );
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider.autoDispose<List<SearchResultGroup>>((ref) {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().length < 2) return Future.value([]);
  final service = ref.watch(searchServiceProvider);
  return service.search(query);
});

final recentSearchesProvider = Provider<List<String>>((ref) {
  return ref.watch(searchServiceProvider).getRecentSearches();
});
