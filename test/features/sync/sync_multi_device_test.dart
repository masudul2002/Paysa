import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/features/sync/data/services/mock_sync_provider.dart';
import 'package:paysa/features/sync/data/services/sync_service_impl.dart';
import 'package:paysa/features/sync/domain/entities/sync_entities.dart';
import 'package:paysa/features/sync/domain/services/sync_coordinator.dart';
import 'package:paysa/features/sync/domain/strategies/conflict_resolvers.dart';

void main() {
  group('ConflictResolver', () {
    final local = {'id': 1, 'name': 'Alice', 'updatedAt': '2026-07-20'};
    final remote = {'id': 1, 'name': 'Bob', 'updatedAt': '2026-07-21'};

    test('LatestWinsResolver picks newest', () {
      final r = const LatestWinsResolver().resolve(local, remote);
      expect(r['name'], 'Bob');
    });

    test('KeepLocalResolver preserves local', () {
      final r = const KeepLocalResolver().resolve(local, remote);
      expect(r['name'], 'Alice');
    });

    test('KeepRemoteResolver uses remote', () {
      final r = const KeepRemoteResolver().resolve(local, remote);
      expect(r['name'], 'Bob');
    });

    test('MergeResolver combines fields', () {
      final r = const MergeResolver().resolve(local, {'extra': 'val'});
      expect(r['name'], 'Alice');
      expect(r['extra'], 'val');
    });
  });

  group('MockSyncProvider', () {
    test('connect and disconnect', () async {
      final p = MockSyncProvider();
      expect(await p.isConnected(), false);
      await p.connect();
      expect(await p.isConnected(), true);
      await p.disconnect();
      expect(await p.isConnected(), false);
    });

    test('push and pull', () async {
      final p = MockSyncProvider();
      await p.connect();
      final pushResult = await p.push('transaction', [
        {'id': 1, 'amount': 50000},
        {'id': 2, 'amount': 30000},
      ]);
      expect(pushResult.syncedCount, 2);

      final pullResult = await p.pull('transaction', DateTime(2020, 1, 1));
      expect(pullResult.syncedCount, 2);
    });

    test('resolve updates record', () async {
      final p = MockSyncProvider();
      await p.connect();
      await p.push('transaction', [{'id': 1, 'amount': 100}]);
      await p.resolve('transaction', 1, {'id': 1, 'amount': 200, 'resolved': true});
      final pullResult = await p.pull('transaction', DateTime(2020, 1, 1));
      expect(pullResult.syncedCount, 1);
    });
  });

  group('SyncCoordinator', () {
    test('registerDevice adds device', () {
      final svc = SyncServiceImpl();
      final p = MockSyncProvider();
      final coord = SyncCoordinator(syncService: svc, provider: p);
      coord.registerDevice('d1', 'Phone');
      coord.registerDevice('d2', 'Tablet');
      expect(coord.devices.length, 2);
    });

    test('syncAll with mock provider', () async {
      final svc = SyncServiceImpl();
      svc.enqueue('transaction', 1, 1);
      svc.enqueue('ledger', 2, 1);

      final p = MockSyncProvider();
      final coord = SyncCoordinator(syncService: svc, provider: p);
      final result = await coord.syncAll();
      expect(result.success, true);
    });

    test('getStatistics returns counts', () async {
      final svc = SyncServiceImpl();
      final p = MockSyncProvider();
      final coord = SyncCoordinator(syncService: svc, provider: p);
      await coord.syncAll();
      final stats = coord.getStatistics();
      expect(stats.totalSyncs, 1);
    });
  });

  group('DeviceInfo', () {
    test('constructor', () {
      final d = DeviceInfo(id: 'd1', name: 'Phone');
      expect(d.name, 'Phone');
    });
  });

  group('SyncStatistics', () {
    test('default values', () {
      final s = const SyncStatistics(totalSyncs: 0, totalUploads: 0, totalDownloads: 0, totalConflicts: 0, totalErrors: 0);
      expect(s.totalSyncs, 0);
    });
  });
}
