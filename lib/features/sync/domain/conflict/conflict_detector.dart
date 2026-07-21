import 'conflict_entities.dart';

/// Detects conflicts between local and remote document versions.
final class ConflictDetector {
  const ConflictDetector();

  /// Compare local and remote versions of the same document.
  /// Returns a [SyncConflict] if a conflict exists, null if identical or compatible.
  SyncConflict? detect({
    required String id,
    required String entityType,
    required String entityId,
    required Map<String, dynamic> local,
    required Map<String, dynamic> remote,
  }) {
    final localVersion = (local['version'] as num?)?.toInt() ?? 0;
    final remoteVersion = (remote['version'] as num?)?.toInt() ?? 0;
    final localDeleted = local['_deleted'] == true;
    final remoteDeleted = remote['_deleted'] == true;

    // No conflict if identical
    if (localVersion == remoteVersion && !localDeleted && !remoteDeleted) return null;

    // No conflict if local is newer and remote hasn't changed
    if (localVersion > remoteVersion && remoteVersion == 0) return null;

    // Parse timestamps
    DateTime? localTime;
    DateTime? remoteTime;
    try {
      if (local['updatedAt'] != null) localTime = DateTime.parse(local['updatedAt'] as String);
      if (remote['updatedAt'] != null) remoteTime = DateTime.parse(remote['updatedAt'] as String);
    } catch (_) {}

    return SyncConflict(
      id: id,
      entityType: entityType,
      entityId: entityId,
      localVersion: localVersion,
      remoteVersion: remoteVersion,
      localData: Map.from(local),
      remoteData: Map.from(remote),
      localUpdatedAt: localTime,
      remoteUpdatedAt: remoteTime,
      isLocalDeleted: localDeleted,
      isRemoteDeleted: remoteDeleted,
      detectedAt: DateTime.now(),
    );
  }

  /// Detect conflicts between lists of local and remote documents.
  List<SyncConflict> detectBatch({
    required String entityType,
    required List<Map<String, dynamic>> localDocs,
    required List<Map<String, dynamic>> remoteDocs,
  }) {
    final conflicts = <SyncConflict>[];
    final remoteById = <String, Map<String, dynamic>>{};
    for (final doc in remoteDocs) {
      final id = doc['id'] as String?;
      if (id != null) remoteById[id] = doc;
    }

    for (final local in localDocs) {
      final id = local['id'] as String?;
      if (id == null) continue;

      // Check local-only documents (no remote version = no conflict)
      final remote = remoteById.remove(id);
      if (remote == null) continue;

      final conflict = detect(
        id: '$entityType:$id',
        entityType: entityType,
        entityId: id,
        local: local,
        remote: remote,
      );
      if (conflict != null) conflicts.add(conflict);
    }

    return conflicts;
  }
}
