import 'dart:collection';
import '../../domain/entities/sync_entities.dart';
import '../../domain/services/sync_service.dart';

final class SyncServiceImpl implements SyncService {
  final _queue = Queue<SyncRecord>();
  final _conflicts = <SyncRecord>[];
  SyncState _state = const SyncState();
  int _nextId = 1;

  @override
  Future<SyncResult> syncAll() async {
    _state = SyncState(isSyncing: true, pendingCount: _queue.length, totalCount: _queue.length);
    // Simulate sync — in production, delegates to SyncProvider
    while (_queue.isNotEmpty) {
      final record = _queue.removeFirst();
      if (record.retryCount >= 3) {
        _conflicts.add(record.copyWith(status: SyncStatus.conflict));
      }
    }
    _state = SyncState(isSyncing: false, lastSyncAt: DateTime.now());
    return const SyncResult(success: true);
  }

  @override
  Future<SyncResult> syncEntity(String entityType) async => const SyncResult(success: true);

  @override
  Future<SyncState> getState() async => _state;

  @override
  Future<void> setMode(SyncMode mode) async {
    _state = SyncState(mode: mode, isEnabled: _state.isEnabled);
  }

  @override
  Future<void> enable() async {
    _state = SyncState(isEnabled: true, mode: _state.mode);
  }

  @override
  Future<void> disable() async {
    _state = SyncState(isEnabled: false, mode: _state.mode);
  }

  @override
  Future<List<SyncRecord>> getPending() async => _queue.toList();

  @override
  Future<List<SyncRecord>> getConflicts() async => List.unmodifiable(_conflicts);

  @override
  Future<SyncResult> resolveConflict(int syncRecordId, Map<String, dynamic> resolved, ConflictResolution strategy) async {
    _conflicts.removeWhere((r) => r.id == syncRecordId);
    return const SyncResult(success: true, syncedCount: 1);
  }

  @override
  Stream<SyncState> watchState() async* {
    yield _state;
  }

  /// Add a record to the sync queue (called by repositories on mutation).
  void enqueue(String entityType, int entityId, int localVersion, {Map<String, dynamic>? data}) {
    _queue.add(SyncRecord(
      id: _nextId++,
      entityType: entityType,
      entityId: entityId,
      localVersion: localVersion,
      status: SyncStatus.pending,
      localData: data?.toString(),
      updatedAt: DateTime.now(),
    ));
    _state = SyncState(
      pendingCount: _queue.length,
      totalCount: _queue.length,
      isEnabled: _state.isEnabled,
      mode: _state.mode,
    );
  }
}
