/// A single search result item.
final class SearchResult {
  const SearchResult({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.matchField,
    this.matchStart,
    this.matchLength,
  });

  final int id;
  final String type; // 'transaction', 'person', 'account', 'ledger', 'payment_request', 'receipt'
  final String title;
  final String subtitle;
  final String trailing;
  final String? matchField;
  final int? matchStart;
  final int? matchLength;

  SearchResult copyWith({
    int? id, String? type, String? title, String? subtitle, String? trailing,
    String? matchField, int? matchStart, int? matchLength,
  }) => SearchResult(
    id: id ?? this.id, type: type ?? this.type,
    title: title ?? this.title, subtitle: subtitle ?? this.subtitle,
    trailing: trailing ?? this.trailing,
    matchField: matchField ?? this.matchField,
    matchStart: matchStart ?? this.matchStart,
    matchLength: matchLength ?? this.matchLength,
  );
}

/// Grouped search results by type.
final class SearchResultGroup {
  const SearchResultGroup({required this.type, required this.label, required this.results});

  final String type;
  final String label;
  final List<SearchResult> results;
}

/// Centralized search service that queries across all repositories.
///
/// Every search goes through this service.
/// No direct repository calls from UI.
abstract interface class SearchService {
  /// Search across all domains. Returns grouped results.
  Future<List<SearchResultGroup>> search(String query);

  /// Search within a specific domain type.
  Future<List<SearchResult>> searchByType(String type, String query);

  /// Get recent search queries.
  List<String> getRecentSearches();

  /// Save a search query to recent list.
  void saveRecentSearch(String query);

  /// Clear all recent searches.
  void clearRecentSearches();
}
