enum BackupStatus { created, restored, failed, expired }

final class BackupMetadata {
  const BackupMetadata({
    this.backupId = '',
    required this.createdAt,
    this.appVersion = '0.3.0-alpha',
    this.schemaVersion = 1,
    this.deviceName,
    this.recordCounts = const {},
    this.checksum = '',
    this.encryptionVersion = 1,
    this.fileSize,
  });

  final String backupId;
  final DateTime createdAt;
  final String appVersion;
  final int schemaVersion;
  final String? deviceName;
  final Map<String, int> recordCounts;
  final String checksum;
  final int encryptionVersion;
  final int? fileSize;
}

final class RestoreResult {
  const RestoreResult({
    required this.success,
    this.restoredCount = 0,
    this.failedCount = 0,
    this.errors = const [],
    this.backupId,
  });
  final bool success;
  final int restoredCount;
  final int failedCount;
  final List<String> errors;
  final String? backupId;
}

final class BackupManifest {
  const BackupManifest({
    this.version = 1,
    this.schemaVersion = 1,
    required this.createdAt,
    this.recordCount = 0,
    this.tables = const [],
  });
  final int version;
  final int schemaVersion;
  final DateTime createdAt;
  final int recordCount;
  final List<String> tables;
}
