import '../../domain/conflict/conflict_entities.dart';

/// Resolves sync conflicts based on the configured strategy.
final class ConflictResolverEngine {
  const ConflictResolverEngine();

  /// Resolve a single conflict using the given strategy.
  ConflictResolution resolve(
    SyncConflict conflict, {
    ConflictStrategy strategy = ConflictStrategy.latestWins,
    Map<String, dynamic>? manualData,
  }) {
    switch (strategy) {
      case ConflictStrategy.localWins:
        return _resolve(conflict, 'local', conflict.localData, strategy);

      case ConflictStrategy.remoteWins:
        return _resolve(conflict, 'remote', conflict.remoteData, strategy);

      case ConflictStrategy.latestWins:
        return _resolveLatest(conflict);

      case ConflictStrategy.manual:
        return _resolve(conflict, 'manual', manualData, strategy);
    }
  }

  ConflictResolution _resolve(
    SyncConflict conflict,
    String winner,
    Map<String, dynamic>? data,
    ConflictStrategy strategy,
  ) {
    return ConflictResolution(
      conflictId: conflict.id,
      strategy: strategy,
      winner: winner,
      resolvedData: data != null ? {...data, 'version': conflict.remoteVersion + 1} : null,
      resolvedAt: DateTime.now(),
    );
  }

  ConflictResolution _resolveLatest(SyncConflict conflict) {
    // Compare timestamps
    final localTime = conflict.localUpdatedAt;
    final remoteTime = conflict.remoteUpdatedAt;

    if (localTime != null && remoteTime != null) {
      if (localTime.isAfter(remoteTime)) {
        return _resolve(conflict, 'local', conflict.localData, ConflictStrategy.latestWins);
      }
      return _resolve(conflict, 'remote', conflict.remoteData, ConflictStrategy.latestWins);
    }

    // Fallback to version comparison
    if (conflict.localVersion >= conflict.remoteVersion) {
      return _resolve(conflict, 'local', conflict.localData, ConflictStrategy.latestWins);
    }
    return _resolve(conflict, 'remote', conflict.remoteData, ConflictStrategy.latestWins);
  }

  /// Resolve multiple conflicts using the same strategy.
  List<ConflictResolution> resolveBatch(
    List<SyncConflict> conflicts, {
    ConflictStrategy strategy = ConflictStrategy.latestWins,
  }) {
    return conflicts.map((c) => resolve(c, strategy: strategy)).toList();
  }
}
