import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/features/search/data/services/search_service_impl.dart';
import 'package:paysa/features/search/domain/services/search_service.dart';

void main() {
  group('SearchService', () {
    test('empty query returns no results', () async {
      final s = SearchServiceImpl(
        searchTransactions: (_) async => [],
        searchPeople: (_) async => [],
        searchAccounts: (_) async => [],
        searchLedgerEntries: (_) async => [],
        searchPaymentRequests: (_) async => [],
        searchReceipts: (_) async => [],
      );
      final results = await s.search('');
      expect(results, isEmpty);
    });

    test('short query returns no results', () async {
      final s = SearchServiceImpl(
        searchTransactions: (_) async => [],
        searchPeople: (_) async => [],
        searchAccounts: (_) async => [],
        searchLedgerEntries: (_) async => [],
        searchPaymentRequests: (_) async => [],
        searchReceipts: (_) async => [],
      );
      final results = await s.search('a');
      expect(results, isEmpty);
    });

    test('returns grouped results', () async {
      final s = SearchServiceImpl(
        searchTransactions: (q) async => [
          SearchResult(id: 1, type: 'transaction', title: 'Salary', subtitle: 'Income', trailing: '\$5000'),
        ],
        searchPeople: (q) async => [
          SearchResult(id: 1, type: 'person', title: 'Alice', subtitle: 'Customer', trailing: ''),
        ],
        searchAccounts: (_) async => [],
        searchLedgerEntries: (_) async => [],
        searchPaymentRequests: (_) async => [],
        searchReceipts: (_) async => [],
      );
      final groups = await s.search('alice');
      expect(groups.length, 2); // Transactions + People
    });

    test('limits to 5 per group', () async {
      final s = SearchServiceImpl(
        searchTransactions: (q) async => List.generate(10, (i) =>
          SearchResult(id: i, type: 'transaction', title: 'T$i', subtitle: '', trailing: '')),
        searchPeople: (_) async => [],
        searchAccounts: (_) async => [],
        searchLedgerEntries: (_) async => [],
        searchPaymentRequests: (_) async => [],
        searchReceipts: (_) async => [],
      );
      final groups = await s.search('test');
      expect(groups.length, 1);
      expect(groups.first.results.length, 5);
    });

    test('recent searches', () async {
      final s = SearchServiceImpl(
        searchTransactions: (_) async => [],
        searchPeople: (_) async => [],
        searchAccounts: (_) async => [],
        searchLedgerEntries: (_) async => [],
        searchPaymentRequests: (_) async => [],
        searchReceipts: (_) async => [],
      );
      await s.search('salary');
      await s.search('food');
      final recent = s.getRecentSearches();
      expect(recent.length, 2);
      expect(recent.first, 'food'); // most recent first
    });

    test('clear recent searches', () async {
      final s = SearchServiceImpl(
        searchTransactions: (_) async => [],
        searchPeople: (_) async => [],
        searchAccounts: (_) async => [],
        searchLedgerEntries: (_) async => [],
        searchPaymentRequests: (_) async => [],
        searchReceipts: (_) async => [],
      );
      await s.search('test');
      s.clearRecentSearches();
      expect(s.getRecentSearches(), isEmpty);
    });

    test('max 10 recent searches', () async {
      final s = SearchServiceImpl(
        searchTransactions: (_) async => [],
        searchPeople: (_) async => [],
        searchAccounts: (_) async => [],
        searchLedgerEntries: (_) async => [],
        searchPaymentRequests: (_) async => [],
        searchReceipts: (_) async => [],
      );
      for (int i = 0; i < 15; i++) {
        await s.search('q$i');
      }
      expect(s.getRecentSearches().length, 10);
    });

    test('recent searches deduplicates', () async {
      final s = SearchServiceImpl(
        searchTransactions: (_) async => [],
        searchPeople: (_) async => [],
        searchAccounts: (_) async => [],
        searchLedgerEntries: (_) async => [],
        searchPaymentRequests: (_) async => [],
        searchReceipts: (_) async => [],
      );
      await s.search('test');
      await s.search('other');
      await s.search('test');
      expect(s.getRecentSearches().where((x) => x == 'test').length, 1);
    });

    test('searchByType delegates correctly', () async {
      final s = SearchServiceImpl(
        searchTransactions: (q) async => [SearchResult(id: 1, type: 'transaction', title: q, subtitle: '', trailing: '')],
        searchPeople: (_) async => [],
        searchAccounts: (_) async => [],
        searchLedgerEntries: (_) async => [],
        searchPaymentRequests: (_) async => [],
        searchReceipts: (_) async => [],
      );
      final results = await s.searchByType('transaction', 'salary');
      expect(results.length, 1);
      expect(results.first.title, 'salary');
    });

    test('SearchResult copyWith works', () {
      final r = SearchResult(id: 1, type: 'person', title: 'Alice', subtitle: 'Friend', trailing: r'+$50');
      final c = r.copyWith(title: 'Bob');
      expect(c.title, 'Bob');
      expect(c.id, 1);
    });
  });
}
