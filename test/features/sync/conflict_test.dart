import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/features/sync/domain/conflict/conflict_entities.dart';
import 'package:paysa/features/sync/domain/conflict/conflict_detector.dart';
import 'package:paysa/features/sync/data/conflict/conflict_resolver.dart';

void main() {
  final detector = ConflictDetector();
  final resolver = ConflictResolverEngine();

  group('ConflictDetector', () {
    test('returns null for identical versions', () {
      final conflict = detector.detect(
        id: 'c1', entityType: 'account', entityId: 'a1',
        local: {'version': 1, 'name': 'Bank'},
        remote: {'version': 1, 'name': 'Bank'},
      );
      expect(conflict, isNull);
    });

    test('detects version mismatch', () {
      final conflict = detector.detect(
        id: 'c1', entityType: 'account', entityId: 'a1',
        local: {'version': 2, 'name': 'Bank'},
        remote: {'version': 1, 'name': 'Bank'},
      );
      expect(conflict, isNotNull);
    });

    test('detects deletion conflict', () {
      final conflict = detector.detect(
        id: 'c1', entityType: 'account', entityId: 'a1',
        local: {'version': 2, '_deleted': true},
        remote: {'version': 2, 'name': 'Bank'},
      );
      expect(conflict?.isDeletionConflict, true);
    });

    test('returns null for local-only doc', () {
      final conflicts = detector.detectBatch(
        entityType: 'account',
        localDocs: [{'id': 'a1', 'version': 1, 'name': 'Local'}],
        remoteDocs: [],
      );
      expect(conflicts, isEmpty);
    });

    test('detects batch conflicts', () {
      final conflicts = detector.detectBatch(
        entityType: 'account',
        localDocs: [{'id': 'a1', 'version': 2, 'name': 'Local'}],
        remoteDocs: [{'id': 'a1', 'version': 1, 'name': 'Remote'}],
      );
      expect(conflicts.length, 1);
    });
  });

  group('ConflictResolverEngine', () {
    test('localWins keeps local data', () {
      final conflict = SyncConflict(
        id: 'c1', entityType: 'account', entityId: 'a1',
        localVersion: 2, remoteVersion: 1,
        localData: {'name': 'Local'}, remoteData: {'name': 'Remote'},
        detectedAt: DateTime.now(),
      );
      final resolution = resolver.resolve(conflict, strategy: ConflictStrategy.localWins);
      expect(resolution.winner, 'local');
    });

    test('remoteWins keeps remote data', () {
      final conflict = SyncConflict(
        id: 'c1', entityType: 'account', entityId: 'a1',
        localVersion: 1, remoteVersion: 2,
        localData: {'name': 'Local'}, remoteData: {'name': 'Remote'},
        detectedAt: DateTime.now(),
      );
      final resolution = resolver.resolve(conflict, strategy: ConflictStrategy.remoteWins);
      expect(resolution.winner, 'remote');
    });

    test('latestWins picks newer timestamp', () {
      final conflict = SyncConflict(
        id: 'c1', entityType: 'account', entityId: 'a1',
        localVersion: 1, remoteVersion: 1,
        localData: {'name': 'Old'}, remoteData: {'name': 'New'},
        localUpdatedAt: DateTime(2025, 1, 1),
        remoteUpdatedAt: DateTime(2026, 1, 1),
        detectedAt: DateTime.now(),
      );
      final resolution = resolver.resolve(conflict, strategy: ConflictStrategy.latestWins);
      expect(resolution.winner, 'remote');
    });

    test('resolveBatch handles multiple conflicts', () {
      final conflicts = [
        SyncConflict(id: 'c1', entityType: 'a', entityId: '1', localVersion: 2, remoteVersion: 1, detectedAt: DateTime.now()),
        SyncConflict(id: 'c2', entityType: 'a', entityId: '2', localVersion: 1, remoteVersion: 2, detectedAt: DateTime.now()),
      ];
      final resolutions = resolver.resolveBatch(conflicts, strategy: ConflictStrategy.localWins);
      expect(resolutions.length, 2);
    });
  });

  group('SyncConflict', () {
    test('isIdentical when versions match', () {
      final c = SyncConflict(id: 'c1', entityType: 'a', entityId: '1', localVersion: 1, remoteVersion: 1, detectedAt: DateTime.now());
      expect(c.isIdentical, true);
    });

    test('isDeletionConflict when deletion flags differ', () {
      final c = SyncConflict(id: 'c1', entityType: 'a', entityId: '1', localVersion: 1, remoteVersion: 1, isLocalDeleted: true, isRemoteDeleted: false, detectedAt: DateTime.now());
      expect(c.isDeletionConflict, true);
    });
  });

  group('ConflictStatistics', () {
    test('default values', () {
      final s = ConflictStatistics();
      expect(s.totalConflicts, 0);
      expect(s.unresolvedConflicts, 0);
    });
  });
}
