import 'package:paysa/core/app_exception.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/entities/audit_entry.dart';
import '../../domain/repositories/receipt_repository.dart';
import '../datasources/receipt_local_datasource.dart';
import '../models/receipt_record.dart';

final class ReceiptRepositoryImpl implements ReceiptRepository {
  ReceiptRepositoryImpl(this._ds);
  final ReceiptLocalDataSource _ds;
  int _seq = 0;

  @override Future<Receipt> createReceipt(Receipt receipt) async {
    if (receipt.amountMinor <= 0) throw AppException('Amount must be greater than zero.');
    final now = DateTime.now();
    _seq++;
    final r = receipt.copyWith(
      receiptNumber: receipt.receiptNumber.isNotEmpty ? receipt.receiptNumber
          : 'RCP-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${_seq.toString().padLeft(5, '0')}',
      issuedAt: now, createdAt: now, updatedAt: now, version: 1,
    ).toRecord();
    final saved = await _ds.putReceipt(r);
    return saved.toEntity();
  }

  @override Future<Receipt?> findById(int id) async => (await _ds.getReceiptById(id))?.toEntity();
  @override Future<Receipt?> findByNumber(String n) async => (await _ds.getByReceiptNumber(n))?.toEntity();
  @override Future<List<Receipt>> getAll({String? searchQuery, DateTime? from, DateTime? to}) async {
    var all = await _ds.getAllReceipts();
    if (from != null) all = all.where((r) => r.issuedAt.isAfter(from)).toList();
    if (to != null) all = all.where((r) => r.issuedAt.isBefore(to)).toList();
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      all = all.where((r) => r.receiptNumber.toLowerCase().contains(q) || (r.provider.toLowerCase().contains(q))).toList();
    }
    all.sort((a, b) => b.issuedAt.compareTo(a.issuedAt));
    return all.map((r) => r.toEntity()).toList();
  }
  @override Stream<List<Receipt>> watchAll() => _ds.watchAllReceipts().map((l) => l.map((r) => r.toEntity()).toList());
}

final class AuditRepositoryImpl implements AuditRepository {
  AuditRepositoryImpl(this._ds);
  final ReceiptLocalDataSource _ds;

  @override Future<AuditEntry> append(AuditEntry entry) async {
    final now = DateTime.now();
    final r = entry.copyWith(occurredAt: entry.occurredAt != now ? entry.occurredAt : now, createdAt: now, version: 1).toRecord();
    return (await _ds.putAudit(r)).toEntity();
  }
  @override Future<AuditEntry?> findById(int id) async => (await _ds.getAuditById(id))?.toEntity();
  @override Future<List<AuditEntry>> findByEntity(AuditEntityType entityType, int entityId) async {
    final records = await _ds.getAuditByEntity(entityId, entityType.name);
    return records.map((r) => r.toEntity()).toList();
  }
  @override Future<List<AuditEntry>> getAll({AuditAction? actionFilter, int? limit}) async {
    var all = await _ds.getAllAudits();
    if (actionFilter != null) all = all.where((r) => r.action == actionFilter.index).toList();
    all.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    if (limit != null) all = all.take(limit).toList();
    return all.map((r) => r.toEntity()).toList();
  }
  @override Stream<List<AuditEntry>> watchAll() => _ds.watchAllAudits().map((l) => l.map((r) => r.toEntity()).toList());
}
