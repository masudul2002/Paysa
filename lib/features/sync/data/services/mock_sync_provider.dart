import '../../domain/entities/sync_entities.dart';

/// Mock [SyncProvider] for testing and MVP.
///
/// Simulates a remote sync backend without network calls.
final class MockSyncProvider implements SyncProvider {
  final _store = <String, List<Map<String, dynamic>>>{};
  bool _connected = false;

  @override String get name => 'mock';

  @override Future<bool> connect() async { _connected = true; return true; }
  @override Future<void> disconnect() async { _connected = false; }
  @override Future<bool> isConnected() async => _connected;

  @override Future<SyncResult> push(String entityType, List<Map<String, dynamic>> records) async {
    _store.putIfAbsent(entityType, () => []);
    for (final r in records) {
      _store[entityType]!.removeWhere((e) => e['id'] == r['id']);
      _store[entityType]!.add(r);
    }
    return SyncResult(success: true, syncedCount: records.length);
  }

  @override Future<SyncResult> pull(String entityType, DateTime since) async {
    final results = _store[entityType] ?? [];
    return SyncResult(success: true, syncedCount: results.length);
  }

  @override Future<SyncResult> resolve(String entityType, int entityId, Map<String, dynamic> resolved) async {
    _store.putIfAbsent(entityType, () => []);
    _store[entityType]!.removeWhere((e) => e['id'] == entityId);
    _store[entityType]!.add(resolved);
    return const SyncResult(success: true, syncedCount: 1);
  }
}
