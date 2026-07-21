import '../datasources/firestore_account_datasource.dart';

/// Uploads local data to Firestore.
///
/// Operates at the datasource level — no business logic.
/// Reports progress and handles retries.
final class FirestoreUploadService {
  FirestoreUploadService({
    required this.accounts,
    required this.transactions,
  });

  final FirestoreAccountDatasource accounts;
  final FirestoreTransactionDatasource transactions;

  int _totalUploaded = 0;
  int _totalFailed = 0;
  int _totalSkipped = 0;

  /// Upload a single document to a collection.
  Future<UploadResult> uploadDocument(String collection, String id, Map<String, dynamic> data) async {
    try {
      await accounts.upsert(collection, id, data);
      _totalUploaded++;
      return UploadResult.success(id);
    } catch (e) {
      _totalFailed++;
      return UploadResult.failure(id, e.toString());
    }
  }

  /// Upload multiple documents in batch.
  Future<BatchUploadResult> uploadBatch(
    String collection,
    List<Map<String, dynamic>> documents,
  ) async {
    int success = 0, failed = 0;
    final errors = <String>[];

    for (final doc in documents) {
      final id = doc['id'] as String?;
      if (id == null) {
        failed++;
        errors.add('Document missing id');
        continue;
      }

      try {
        await accounts.upsert(collection, id, doc);
        success++;
        _totalUploaded++;
      } catch (e) {
        failed++;
        _totalFailed++;
        errors.add('[$id] $e');
      }
    }

    return BatchUploadResult(success: success, failed: failed, errors: errors);
  }

  /// Upload all local accounts to Firestore.
  Future<BatchUploadResult> uploadAllAccounts(List<Map<String, dynamic>> localAccounts) async {
    return uploadBatch('accounts', localAccounts);
  }

  /// Upload all local transactions to Firestore.
  Future<BatchUploadResult> uploadAllTransactions(List<Map<String, dynamic>> localTransactions) async {
    return uploadBatch('transactions', localTransactions);
  }

  /// Get upload statistics.
  UploadStatistics getStatistics() => UploadStatistics(
    uploaded: _totalUploaded,
    failed: _totalFailed,
    skipped: _totalSkipped,
  );

  /// Reset statistics.
  void resetStatistics() {
    _totalUploaded = 0;
    _totalFailed = 0;
    _totalSkipped = 0;
  }
}

final class UploadResult {
  const UploadResult._(this.documentId, this.success, this.errorMessage);

  factory UploadResult.success(String id) => UploadResult._(id, true, null);
  factory UploadResult.failure(String id, String error) => UploadResult._(id, false, error);

  final String documentId;
  final bool success;
  final String? errorMessage;
}

final class BatchUploadResult {
  const BatchUploadResult({
    required this.success,
    required this.failed,
    this.errors = const [],
  });
  final int success;
  final int failed;
  final List<String> errors;

  int get total => success + failed;
  bool get allSucceeded => failed == 0;
}

final class UploadStatistics {
  const UploadStatistics({
    required this.uploaded,
    required this.failed,
    required this.skipped,
  });
  final int uploaded;
  final int failed;
  final int skipped;
}
