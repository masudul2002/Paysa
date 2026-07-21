import 'package:isar/isar.dart';
import '../models/receipt_record.dart';
import 'receipt_local_datasource.dart';

final class IsarReceiptLocalDataSource implements ReceiptLocalDataSource {
  const IsarReceiptLocalDataSource(this._isar);
  final Isar _isar;
  IsarCollection<ReceiptRecord> get _r => _isar.collection<ReceiptRecord>();
  IsarCollection<AuditEntryRecord> get _a => _isar.collection<AuditEntryRecord>();

  @override Future<ReceiptRecord> putReceipt(ReceiptRecord r) async {
    final id = await _isar.writeTxn(() => _r.put(r)); return (await _r.get(id))!;
  }
  @override Future<ReceiptRecord?> getReceiptById(int id) => _r.get(id);
  @override Future<ReceiptRecord?> getByReceiptNumber(String n) async {
    final all = await _r.where().findAll();
    for (final r in all) { if (r.receiptNumber == n) return r; } return null;
  }
  @override Future<List<ReceiptRecord>> getAllReceipts() async => _r.where().findAll();
  @override Stream<List<ReceiptRecord>> watchAllReceipts() => _r.watchLazy(fireImmediately: true).asyncMap((_) => getAllReceipts());
  @override Future<AuditEntryRecord> putAudit(AuditEntryRecord r) async {
    final id = await _isar.writeTxn(() => _a.put(r)); return (await _a.get(id))!;
  }
  @override Future<AuditEntryRecord?> getAuditById(int id) => _a.get(id);
  @override Future<List<AuditEntryRecord>> getAuditByEntity(int entityId, String entityType) async {
    final all = await _a.where().findAll();
    return all.where((r) => r.entityId == entityId && r.entityType == entityType).toList();
  }
  @override Future<List<AuditEntryRecord>> getAllAudits() async => _a.where().findAll();
  @override Stream<List<AuditEntryRecord>> watchAllAudits() => _a.watchLazy(fireImmediately: true).asyncMap((_) => getAllAudits());
}
