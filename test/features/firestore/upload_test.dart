import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/features/firestore/data/datasources/firestore_account_datasource.dart';
import 'package:paysa/features/firestore/data/services/firestore_upload_service.dart';

void main() {
  late FirestoreUploadService uploader;

  setUp(() {
    uploader = FirestoreUploadService(
      accounts: FirestoreAccountDatasource(),
      transactions: FirestoreTransactionDatasource(),
    );
  });

  group('uploadDocument', () {
    test('uploads a single document successfully', () async {
      final result = await uploader.uploadDocument('accounts', 'acc1', {'name': 'Bank', 'balance': 50000});
      expect(result.success, true);
      expect(result.documentId, 'acc1');
    });

    test('tracks statistics', () async {
      await uploader.uploadDocument('accounts', 'a1', {'name': 'A'});
      final stats = uploader.getStatistics();
      expect(stats.uploaded, 1);
    });
  });

  group('uploadBatch', () {
    test('uploads multiple documents', () async {
      final docs = [
        {'id': 'tx1', 'amount': 1000},
        {'id': 'tx2', 'amount': 2000},
        {'id': 'tx3', 'amount': 3000},
      ];
      final result = await uploader.uploadBatch('transactions', docs);
      expect(result.success, 3);
      expect(result.allSucceeded, true);
    });

    test('reports failure for missing id', () async {
      final docs = [
        {'amount': 100}, // missing id
      ];
      final result = await uploader.uploadBatch('transactions', docs);
      expect(result.failed, 1);
    });
  });

  group('uploadAllAccounts', () {
    test('uploads account list', () async {
      final accounts = [
        {'id': 'a1', 'name': 'Cash', 'balance': 50000},
        {'id': 'a2', 'name': 'Bank', 'balance': 100000},
      ];
      final result = await uploader.uploadAllAccounts(accounts);
      expect(result.allSucceeded, true);
      expect(result.total, 2);
    });
  });

  group('uploadAllTransactions', () {
    test('uploads transaction list', () async {
      final txs = [
        {'id': 't1', 'type': 'income', 'amount': 50000},
        {'id': 't2', 'type': 'expense', 'amount': 15000},
      ];
      final result = await uploader.uploadAllTransactions(txs);
      expect(result.allSucceeded, true);
      expect(result.total, 2);
    });
  });

  group('resetStatistics', () {
    test('clears all counters', () async {
      await uploader.uploadDocument('accounts', 'a1', {});
      uploader.resetStatistics();
      final stats = uploader.getStatistics();
      expect(stats.uploaded, 0);
      expect(stats.failed, 0);
    });
  });

  group('UploadResult', () {
    test('success result', () {
      final r = UploadResult.success('doc1');
      expect(r.success, true);
      expect(r.documentId, 'doc1');
    });

    test('failure result', () {
      final r = UploadResult.failure('doc1', 'Network error');
      expect(r.success, false);
      expect(r.errorMessage, 'Network error');
    });
  });

  group('BatchUploadResult', () {
    test('allSucceeded when no failures', () {
      final r = const BatchUploadResult(success: 5, failed: 0);
      expect(r.allSucceeded, true);
      expect(r.total, 5);
    });
  });
}
