import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/features/backup/domain/entities/backup_entities.dart';
import 'package:paysa/features/backup/data/services/backup_service_impl.dart';

void main() {
  late BackupServiceImpl service;

  setUp(() { service = BackupServiceImpl(); });

  group('createBackup', () {
    test('creates backup with metadata', () async {
      final meta = await service.createBackup();
      expect(meta.backupId.isNotEmpty, true);
      expect(meta.checksum.isNotEmpty, true);
      expect(meta.schemaVersion, 1);
    });
  });

  group('listBackups', () {
    test('returns created backups', () async {
      await service.createBackup();
      await service.createBackup();
      final list = await service.listBackups();
      expect(list.length, 2);
    });
  });

  group('deleteBackup', () {
    test('removes backup from list', () async {
      await service.createBackup();
      final list = await service.listBackups();
      await service.deleteBackup(list.first.backupId);
      expect((await service.listBackups()).length, 0);
    });
  });

  group('exportJson', () {
    test('exports valid JSON', () async {
      final json = await service.exportJson();
      expect(json, contains('exportedAt'));
      expect(json, contains('tables'));
    });

    test('exports with filtered tables', () async {
      final json = await service.exportJson(tables: ['transactions', 'ledgers']);
      expect(json, contains('transactions'));
      expect(json, contains('ledgers'));
    });
  });

  group('importJson', () {
    test('returns success result', () async {
      final result = await service.importJson('{"test": true}');
      expect(result.success, true);
      expect(result.restoredCount, 50);
    });
  });

  group('restoreBackup', () {
    test('returns success with counts', () async {
      final result = await service.restoreBackup('/tmp/backup.paysa');
      expect(result.success, true);
      expect(result.restoredCount, 100);
    });
  });

  group('validateBackup', () {
    test('returns true for valid', () async {
      expect(await service.validateBackup('/tmp/test.bak'), true);
    });
  });

  group('getBackupSize', () {
    test('returns file size for existing backup', () async {
      await service.createBackup();
      final list = await service.listBackups();
      final size = await service.getBackupSize(list.first.backupId);
      expect(size, greaterThan(0));
    });
  });

  group('BackupMetadata', () {
    test('default values', () {
      final m = BackupMetadata(createdAt: DateTime.now());
      expect(m.appVersion, '0.3.0-alpha');
      expect(m.schemaVersion, 1);
      expect(m.encryptionVersion, 1);
    });
  });

  group('RestoreResult', () {
    test('success result', () {
      final r = const RestoreResult(success: true, restoredCount: 50);
      expect(r.success, true);
      expect(r.failedCount, 0);
    });

    test('failure result with errors', () {
      final r = const RestoreResult(success: false, failedCount: 3, errors: ['err1', 'err2']);
      expect(r.success, false);
      expect(r.errors.length, 2);
    });
  });
}
