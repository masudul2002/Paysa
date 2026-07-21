enum SyncMode { manual, automatic, background }
enum SyncStatus { pending, syncing, synced, failed, conflict }
enum ConflictResolution { latestWins, manual, merge }

final class SyncRecord {
  const SyncRecord({
    this.id = 0,
    this.entityType = '',
    this.entityId = 0,
    this.localVersion = 0,
    this.remoteVersion,
    this.status = SyncStatus.pending,
    this.localData,
    this.remoteData,
    this.retryCount = 0,
    this.lastError,
    required this.updatedAt,
    this.resolvedAt,
  });

  final int id;
  final String entityType;
  final int entityId;
  final int localVersion;
  final int? remoteVersion;
  final SyncStatus status;
  final String? localData;
  final String? remoteData;
  final int retryCount;
  final String? lastError;
  final DateTime updatedAt;
  final DateTime? resolvedAt;

  bool get hasConflict => status == SyncStatus.conflict;
  bool get shouldRetry => retryCount < 3 && status == SyncStatus.failed;

  SyncRecord copyWith({
    int? id, String? entityType, int? entityId,
    int? localVersion, int? remoteVersion, SyncStatus? status,
    String? localData, String? remoteData,
    int? retryCount, String? lastError,
    DateTime? updatedAt, DateTime? resolvedAt,
  }) => SyncRecord(
    id: id ?? this.id, entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    localVersion: localVersion ?? this.localVersion,
    remoteVersion: remoteVersion ?? this.remoteVersion,
    status: status ?? this.status,
    localData: localData ?? this.localData,
    remoteData: remoteData ?? this.remoteData,
    retryCount: retryCount ?? this.retryCount,
    lastError: lastError ?? this.lastError,
    updatedAt: updatedAt ?? this.updatedAt,
    resolvedAt: resolvedAt ?? this.resolvedAt,
  );
}

final class SyncResult {
  const SyncResult({
    required this.success,
    this.syncedCount = 0,
    this.failedCount = 0,
    this.conflictCount = 0,
    this.errors = const [],
  });
  final bool success;
  final int syncedCount;
  final int failedCount;
  final int conflictCount;
  final List<String> errors;
}

final class SyncState {
  const SyncState({
    this.isSyncing = false,
    this.lastSyncAt,
    this.pendingCount = 0,
    this.totalCount = 0,
    this.mode = SyncMode.manual,
    this.isEnabled = false,
  });
  final bool isSyncing;
  final DateTime? lastSyncAt;
  final int pendingCount;
  final int totalCount;
  final SyncMode mode;
  final bool isEnabled;
}

/// Provider interface for remote sync backends.
///
/// Implementations: FirebaseSyncProvider, SupabaseSyncProvider, RestApiSyncProvider
abstract interface class SyncProvider {
  String get name;
  Future<bool> connect();
  Future<void> disconnect();
  Future<bool> isConnected();
  Future<SyncResult> push(String entityType, List<Map<String, dynamic>> records);
  Future<SyncResult> pull(String entityType, DateTime since);
  Future<SyncResult> resolve(String entityType, int entityId, Map<String, dynamic> resolved);
}
