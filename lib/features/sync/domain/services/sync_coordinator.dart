import '../entities/sync_entities.dart';
import '../strategies/conflict_resolvers.dart';
import 'sync_service.dart';

final class DeviceInfo {
  const DeviceInfo({required this.id, required this.name, this.lastSyncedAt});
  final String id;
  final String name;
  final DateTime? lastSyncedAt;
}

final class SyncStatistics {
  const SyncStatistics({
    required this.totalSyncs,
    required this.totalUploads,
    required this.totalDownloads,
    required this.totalConflicts,
    required this.totalErrors,
    this.lastSyncAt,
  });
  final int totalSyncs;
  final int totalUploads;
  final int totalDownloads;
  final int totalConflicts;
  final int totalErrors;
  final DateTime? lastSyncAt;
}

/// Orchestrates multi-device synchronization.
///
/// Manages device registration, sync sessions, and coordinates
/// between the SyncService and the remote SyncProvider.
final class SyncCoordinator {
  SyncCoordinator({
    required this.syncService,
    required this.provider,
    this.resolver = const LatestWinsResolver(),
    this.maxRetries = 3,
  });

  final SyncService syncService;
  final SyncProvider provider;
  final ConflictResolver resolver;
  final int maxRetries;

  final _devices = <DeviceInfo>[];
  int _totalSyncs = 0;
  int _totalUploads = 0;
  int _totalDownloads = 0;
  int _totalConflicts = 0;
  int _totalErrors = 0;
  DateTime? _lastSyncAt;

  /// Register the current device.
  void registerDevice(String id, String name) {
    _devices.removeWhere((d) => d.id == id);
    _devices.add(DeviceInfo(id: id, name: name));
  }

  /// Get list of known devices.
  List<DeviceInfo> get devices => List.unmodifiable(_devices);

  /// Execute a full sync cycle.
  Future<SyncResult> syncAll() async {
    if (!await provider.isConnected()) {
      final connected = await provider.connect();
      if (!connected) return const SyncResult(success: false, errors: ['Connection failed']);
    }

    _totalSyncs++;

    // Pull remote changes first
    final pullResult = await _pullRemote();

    // Push local changes
    final pushResult = await _pushLocal();

    _totalUploads += pushResult.syncedCount;
    _totalConflicts += pullResult.conflictCount + pushResult.conflictCount;
    _totalErrors += pullResult.failedCount + pushResult.failedCount;
    _lastSyncAt = DateTime.now();

    return SyncResult(
      success: true,
      syncedCount: pullResult.syncedCount + pushResult.syncedCount,
      failedCount: _totalErrors,
      conflictCount: _totalConflicts,
    );
  }

  Future<SyncResult> _pullRemote() async {
    final lastSync = _lastSyncAt ?? DateTime(2020, 1, 1);
    final result = await provider.pull('*', lastSync);
    _totalDownloads += result.syncedCount;
    return result;
  }

  Future<SyncResult> _pushLocal() async {
    final pending = await syncService.getPending();
    if (pending.isEmpty) return const SyncResult(success: true);

    // Batch by entity type
    final byType = <String, List<Map<String, dynamic>>>{};
    for (final record in pending) {
      byType.putIfAbsent(record.entityType, () => []);
      if (record.localData != null) {
        byType[record.entityType]!.add({'id': record.entityId, 'data': record.localData});
      }
    }

    int total = 0, failed = 0, conflicts = 0;
    for (final entry in byType.entries) {
      final result = await provider.push(entry.key, entry.value);
      total += result.syncedCount;
      failed += result.failedCount;
      conflicts += result.conflictCount;
    }

    return SyncResult(success: failed == 0, syncedCount: total, failedCount: failed, conflictCount: conflicts);
  }

  /// Resolve a conflict using the configured strategy.
  Future<SyncResult> resolveConflict(int syncRecordId, Map<String, dynamic> local, Map<String, dynamic> remote) async {
    final resolved = resolver.resolve(local, remote);
    final result = await provider.resolve('*', syncRecordId, resolved);
    await syncService.resolveConflict(syncRecordId, resolved, ConflictResolution.latestWins);
    return result;
  }

  /// Get sync statistics.
  SyncStatistics getStatistics() => SyncStatistics(
    totalSyncs: _totalSyncs, totalUploads: _totalUploads,
    totalDownloads: _totalDownloads, totalConflicts: _totalConflicts,
    totalErrors: _totalErrors, lastSyncAt: _lastSyncAt,
  );
}
