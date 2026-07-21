import '../models/receipt_record.dart';

abstract interface class ReceiptLocalDataSource {
  Future<ReceiptRecord> putReceipt(ReceiptRecord r);
  Future<ReceiptRecord?> getReceiptById(int id);
  Future<ReceiptRecord?> getByReceiptNumber(String n);
  Future<List<ReceiptRecord>> getAllReceipts();
  Stream<List<ReceiptRecord>> watchAllReceipts();
  Future<AuditEntryRecord> putAudit(AuditEntryRecord r);
  Future<AuditEntryRecord?> getAuditById(int id);
  Future<List<AuditEntryRecord>> getAuditByEntity(int entityId, String entityType);
  Future<List<AuditEntryRecord>> getAllAudits();
  Stream<List<AuditEntryRecord>> watchAllAudits();
}
