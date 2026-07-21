import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/features/firestore/data/datasources/firestore_account_datasource.dart';
import 'package:paysa/features/firestore/data/services/firestore_download_service.dart';

void main() {
  late FirestoreDownloadService downloader;
  late FirestoreAccountDatasource accountsDS;
  late FirestoreTransactionDatasource txDS;

  setUp(() {
    accountsDS = FirestoreAccountDatasource();
    txDS = FirestoreTransactionDatasource();
    downloader = FirestoreDownloadService(accounts: accountsDS, transactions: txDS);
  });

  group('downloadDocument', () {
    test('downloads existing document', () async {
      await accountsDS.upsert('accounts', 'acc1', {'name': 'Bank', 'balance': 50000});
      final result = await downloader.downloadDocument('accounts', 'acc1');
      expect(result.success, true);
      expect(result.data?['name'], 'Bank');
    });

    test('skips missing document', () async {
      final result = await downloader.downloadDocument('accounts', 'nonexistent');
      expect(result.isSkipped, true);
    });
  });

  group('downloadCollection', () {
    test('downloads all documents', () async {
      await accountsDS.upsert('accounts', 'a1', {'name': 'A'});
      await accountsDS.upsert('accounts', 'a2', {'name': 'B'});
      final result = await downloader.downloadCollection('accounts');
      expect(result.success, 2);
      expect(result.allSucceeded, true);
    });
  });

  group('downloadIncremental', () {
    test('filters by updatedAt', () async {
      final ds = downloader.accounts;
      // upsert adds current timestamp — so use a future date as 'since'
      await ds.upsert('transactions', 'recent', {'amount': 200});

      // Wait briefly so timestamps differ
      await Future.delayed(const Duration(milliseconds: 1));
      final future = DateTime.now().add(const Duration(hours: 1));

      final result = await downloader.downloadIncremental(
        collection: 'transactions',
        since: future,
      );
      expect(result.success, 0); // No docs updated after 'future'
    });
  });

  group('isValid', () {
    test('validates required fields', () {
      final valid = {'id': '1', 'name': 'Test', 'amount': 100};
      expect(FirestoreDownloadService.isValid(valid, ['id', 'name']), true);
      expect(FirestoreDownloadService.isValid(valid, ['id', 'missing']), false);
    });
  });

  group('markSynced / lastSyncAt', () {
    test('tracks sync time', () async {
      await downloader.downloadCollection('accounts');
      downloader.markSynced();
      expect(downloader.lastSyncAt, isNotNull);
    });
  });

  group('getStatistics', () {
    test('returns counts', () async {
      await accountsDS.upsert('accounts', 'a1', {});
      await downloader.downloadCollection('accounts');
      final stats = downloader.getStatistics();
      expect(stats.downloaded, 1);
    });

    test('reset clears counters', () async {
      await accountsDS.upsert('accounts', 'a1', {});
      await downloader.downloadCollection('accounts');
      downloader.resetStatistics();
      expect(downloader.getStatistics().downloaded, 0);
    });
  });

  group('DownloadResult', () {
    test('success', () {
      final r = DownloadResult.success('d1', {'name': 'Test'});
      expect(r.success, true);
      expect(r.isSkipped, false);
    });

    test('skipped', () {
      final r = DownloadResult.skipped('d1', 'Not found');
      expect(r.isSkipped, true);
    });

    test('failure', () {
      final r = DownloadResult.failure('d1', 'Error');
      expect(r.success, false);
    });
  });
}
