import '../entities/backup_entities.dart';

/// Centralized backup service interface.
///
/// Handles backup creation, restore, export, and import.
/// Storage layer is abstracted for future cloud support.
abstract interface class BackupService {
  /// Create a full backup of all application data.
  Future<BackupMetadata> createBackup({String? password});

  /// Restore from a backup file.
  Future<RestoreResult> restoreBackup(String filePath, {String? password});

  /// Export data in JSON format.
  Future<String> exportJson({List<String>? tables});

  /// Import data from JSON.
  Future<RestoreResult> importJson(String json, {bool merge = false});

  /// List all backup files.
  Future<List<BackupMetadata>> listBackups();

  /// Delete a backup file.
  Future<void> deleteBackup(String backupId);

  /// Validate a backup file's integrity.
  Future<bool> validateBackup(String filePath);

  /// Get backup file size.
  Future<int> getBackupSize(String backupId);
}
