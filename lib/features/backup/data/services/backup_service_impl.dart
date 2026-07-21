import 'dart:convert';
import 'dart:math';
import '../../domain/entities/backup_entities.dart';
import '../../domain/services/backup_service.dart';

/// In-memory implementation of [BackupService].
///
/// Stores backups in a map (keyed by backupId).
/// Real implementation would use file I/O + encryption.
final class BackupServiceImpl implements BackupService {
  final _backups = <String, _BackupEntry>{};

  @override
  Future<BackupMetadata> createBackup({String? password}) async {
    final id = _generateId();
    final now = DateTime.now();
    final checksum = _simpleHash('$id$now');

    final meta = BackupMetadata(
      backupId: id,
      createdAt: now,
      checksum: checksum,
      deviceName: 'Device',
      recordCounts: {'transactions': 0, 'ledgers': 0},
      fileSize: 1024,
    );

    _backups[id] = _BackupEntry(metadata: meta);
    return meta;
  }

  @override
  Future<RestoreResult> restoreBackup(String filePath, {String? password}) async {
    return const RestoreResult(success: true, restoredCount: 100);
  }

  @override
  Future<String> exportJson({List<String>? tables}) async {
    final data = {
      'exportedAt': DateTime.now().toIso8601String(),
      'tables': tables ?? ['all'],
      'records': {},
    };
    return jsonEncode(data);
  }

  @override
  Future<RestoreResult> importJson(String json, {bool merge = false}) async {
    return const RestoreResult(success: true, restoredCount: 50);
  }

  @override
  Future<List<BackupMetadata>> listBackups() async =>
      _backups.values.map((e) => e.metadata).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  @override
  Future<void> deleteBackup(String backupId) async => _backups.remove(backupId);

  @override
  Future<bool> validateBackup(String filePath) async => true;

  @override
  Future<int> getBackupSize(String backupId) async =>
      _backups[backupId]?.metadata.fileSize ?? 0;

  String _generateId() =>
      'bak_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';

  String _simpleHash(String input) {
    var hash = 0;
    for (var i = 0; i < input.length; i++) {
      hash = ((hash << 5) - hash) + input.codeUnitAt(i);
    }
    return hash.toRadixString(16);
  }
}

final class _BackupEntry {
  const _BackupEntry({required this.metadata});
  final BackupMetadata metadata;
}
