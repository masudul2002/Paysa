import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/features/sync/domain/entities/sync_entities.dart';
import 'package:paysa/features/sync/data/services/sync_service_impl.dart';

void main() {
  late SyncServiceImpl service;

  setUp(() { service = SyncServiceImpl(); });

  group('syncAll', () {
    test('syncs all pending', () async {
      service.enqueue('transaction', 1, 1);
      service.enqueue('ledger', 2, 1);
      final result = await service.syncAll();
      expect(result.success, true);
      expect((await service.getPending()).length, 0);
    });
  });

  group('enqueue', () {
    test('adds to pending queue', () async {
      service.enqueue('transaction', 1, 1);
      final pending = await service.getPending();
      expect(pending.length, 1);
      expect(pending.first.entityType, 'transaction');
    });
  });

  group('getConflicts', () {
    test('returns empty when no conflicts', () async {
      expect((await service.getConflicts()).length, 0);
    });
  });

  group('resolveConflict', () {
    test('resolves and removes conflict', () async {
      service.enqueue('transaction', 1, 1);
      await service.syncAll(); // processes queue, may create conflicts
      final result = await service.resolveConflict(1, {}, ConflictResolution.latestWins);
      expect(result.success, true);
    });
  });

  group('enable / disable', () {
    test('enable sets isEnabled', () async {
      await service.enable();
      expect((await service.getState()).isEnabled, true);
    });

    test('disable sets isEnabled false', () async {
      await service.disable();
      expect((await service.getState()).isEnabled, false);
    });
  });

  group('setMode', () {
    test('sets sync mode', () async {
      await service.setMode(SyncMode.automatic);
      expect((await service.getState()).mode, SyncMode.automatic);
    });
  });

  group('SyncState', () {
    test('default values', () {
      final s = const SyncState();
      expect(s.isSyncing, false);
      expect(s.isEnabled, false);
    });
  });

  group('SyncRecord', () {
    test('hasConflict when status is conflict', () {
      final r = SyncRecord(status: SyncStatus.conflict, updatedAt: DateTime.now());
      expect(r.hasConflict, true);
    });

    test('shouldRetry when failed with < 3 retries', () {
      final r = SyncRecord(status: SyncStatus.failed, retryCount: 2, updatedAt: DateTime.now());
      expect(r.shouldRetry, true);
    });

    test('should NOT retry when failed with 3 retries', () {
      final r = SyncRecord(status: SyncStatus.failed, retryCount: 3, updatedAt: DateTime.now());
      expect(r.shouldRetry, false);
    });
  });
}
