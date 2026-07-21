import '../entities/receipt.dart';
import '../entities/audit_entry.dart';

abstract interface class ReceiptRepository {
  Future<Receipt> createReceipt(Receipt receipt);
  Future<Receipt?> findById(int id);
  Future<Receipt?> findByNumber(String receiptNumber);
  Future<List<Receipt>> getAll({String? searchQuery, DateTime? from, DateTime? to});
  Stream<List<Receipt>> watchAll();
}

abstract interface class AuditRepository {
  Future<AuditEntry> append(AuditEntry entry);
  Future<AuditEntry?> findById(int id);
  Future<List<AuditEntry>> findByEntity(AuditEntityType entityType, int entityId);
  Future<List<AuditEntry>> getAll({AuditAction? actionFilter, int? limit});
  Stream<List<AuditEntry>> watchAll();
}
