import '../entities/sync_entities.dart';

abstract interface class SyncService {
  Future<SyncResult> syncAll();
  Future<SyncResult> syncEntity(String entityType);
  Future<SyncState> getState();
  Future<void> setMode(SyncMode mode);
  Future<void> enable();
  Future<void> disable();
  Future<List<SyncRecord>> getPending();
  Future<List<SyncRecord>> getConflicts();
  Future<SyncResult> resolveConflict(int syncRecordId, Map<String, dynamic> resolved, ConflictResolution strategy);
  Stream<SyncState> watchState();
}
