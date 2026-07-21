/// A conflict between local and remote data during sync.
final class SyncConflict {
  const SyncConflict({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.localVersion,
    required this.remoteVersion,
    this.localData,
    this.remoteData,
    this.localUpdatedAt,
    this.remoteUpdatedAt,
    this.isLocalDeleted = false,
    this.isRemoteDeleted = false,
    required this.detectedAt,
  });

  final String id;
  final String entityType;
  final String entityId;
  final int localVersion;
  final int remoteVersion;
  final Map<String, dynamic>? localData;
  final Map<String, dynamic>? remoteData;
  final DateTime? localUpdatedAt;
  final DateTime? remoteUpdatedAt;
  final bool isLocalDeleted;
  final bool isRemoteDeleted;
  final DateTime detectedAt;

  bool get isIdentical => localVersion == remoteVersion;
  bool get isDeletionConflict => isLocalDeleted != isRemoteDeleted;
}

/// The strategy used to resolve a conflict.
enum ConflictStrategy { localWins, remoteWins, latestWins, manual }

/// The result of resolving a conflict.
final class ConflictResolution {
  const ConflictResolution({
    required this.conflictId,
    required this.strategy,
    required this.winner,
    this.resolvedData,
    required this.resolvedAt,
  });

  final String conflictId;
  final ConflictStrategy strategy;
  final String winner; // 'local' or 'remote'
  final Map<String, dynamic>? resolvedData;
  final DateTime resolvedAt;
}

/// Statistics about conflicts in a sync session.
final class ConflictStatistics {
  const ConflictStatistics({
    this.totalConflicts = 0,
    this.resolvedConflicts = 0,
    this.unresolvedConflicts = 0,
    this.byEntity = const {},
  });
  final int totalConflicts;
  final int resolvedConflicts;
  final int unresolvedConflicts;
  final Map<String, int> byEntity;
}
