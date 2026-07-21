import '../datasources/firestore_account_datasource.dart';

/// Downloads data from Firestore to the local persistence layer.
///
/// Operates at the datasource level — no business logic.
/// Supports incremental sync via lastSync timestamp.
final class FirestoreDownloadService {
  FirestoreDownloadService({
    required this.accounts,
    required this.transactions,
  });

  final FirestoreAccountDatasource accounts;
  final FirestoreTransactionDatasource transactions;

  int _totalDownloaded = 0;
  int _totalFailed = 0;
  int _totalSkipped = 0;
  DateTime? _lastSyncAt;

  /// Download a single document by collection and ID.
  Future<DownloadResult> downloadDocument(String collection, String id) async {
    try {
      final doc = await accounts.getById(collection, id);
      if (doc == null) {
        _totalSkipped++;
        return DownloadResult.skipped(id, 'Document not found');
      }
      _totalDownloaded++;
      return DownloadResult.success(id, doc);
    } catch (e) {
      _totalFailed++;
      return DownloadResult.failure(id, e.toString());
    }
  }

  /// Download all documents from a collection.
  Future<BatchDownloadResult> downloadCollection(String collection) async {
    try {
      final docs = await accounts.getAll(collection);
      _totalDownloaded += docs.length;
      return BatchDownloadResult(
        success: docs.length,
        failed: 0,
        documents: docs,
      );
    } catch (e) {
      _totalFailed++;
      return BatchDownloadResult(success: 0, failed: 1, errors: [e.toString()]);
    }
  }

  /// Download all accounts from Firestore.
  Future<BatchDownloadResult> downloadAllAccounts() => downloadCollection('accounts');

  /// Download all transactions from Firestore.
  Future<BatchDownloadResult> downloadAllTransactions() => downloadCollection('transactions');

  /// Download only documents updated since [since].
  Future<BatchDownloadResult> downloadIncremental({
    required String collection,
    required DateTime since,
  }) async {
    try {
      final all = await accounts.getAll(collection);
      final filtered = all.where((doc) {
        final updated = doc['updatedAt'] as String?;
        if (updated == null) return true;
        final parsed = DateTime.tryParse(updated);
        return parsed == null || parsed.isAfter(since);
      }).toList();

      _totalDownloaded += filtered.length;
      _totalSkipped += all.length - filtered.length;

      return BatchDownloadResult(
        success: filtered.length,
        failed: 0,
        skipped: all.length - filtered.length,
        documents: filtered,
      );
    } catch (e) {
      _totalFailed++;
      return BatchDownloadResult(success: 0, failed: 1, errors: [e.toString()]);
    }
  }

  /// Validate a downloaded document has required fields.
  static bool isValid(Map<String, dynamic> doc, List<String> requiredFields) {
    for (final field in requiredFields) {
      if (doc[field] == null) return false;
    }
    return true;
  }

  /// Update the last sync timestamp.
  void markSynced() => _lastSyncAt = DateTime.now();

  /// Get the last sync time.
  DateTime? get lastSyncAt => _lastSyncAt;

  /// Get download statistics.
  DownloadStatistics getStatistics() => DownloadStatistics(
    downloaded: _totalDownloaded,
    failed: _totalFailed,
    skipped: _totalSkipped,
    lastSyncAt: _lastSyncAt,
  );

  /// Reset all counters.
  void resetStatistics() {
    _totalDownloaded = 0;
    _totalFailed = 0;
    _totalSkipped = 0;
  }
}

final class DownloadResult {
  const DownloadResult._(this.documentId, this.success, this.data, this.errorMessage);

  factory DownloadResult.success(String id, Map<String, dynamic> data) =>
      DownloadResult._(id, true, data, null);

  factory DownloadResult.failure(String id, String error) =>
      DownloadResult._(id, false, null, error);

  factory DownloadResult.skipped(String id, String reason) =>
      DownloadResult._(id, true, null, reason);

  final String documentId;
  final bool success;
  final Map<String, dynamic>? data;
  final String? errorMessage;

  bool get isSkipped => success && data == null;
}

final class BatchDownloadResult {
  const BatchDownloadResult({
    required this.success,
    required this.failed,
    this.skipped = 0,
    this.documents = const [],
    this.errors = const [],
  });
  final int success;
  final int failed;
  final int skipped;
  final List<Map<String, dynamic>> documents;
  final List<String> errors;

  int get total => success + failed + skipped;
  bool get allSucceeded => failed == 0;
}

final class DownloadStatistics {
  const DownloadStatistics({
    required this.downloaded,
    required this.failed,
    required this.skipped,
    this.lastSyncAt,
  });
  final int downloaded;
  final int failed;
  final int skipped;
  final DateTime? lastSyncAt;
}
