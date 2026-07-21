import 'dart:convert';
import 'package:isar/isar.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/entities/audit_entry.dart';

part 'receipt_record.g.dart';

@Collection(inheritance: false)
class ReceiptRecord {
  ReceiptRecord();

  Id id = Isar.autoIncrement;
  @Index(type: IndexType.value) late String uuid;
  @Index(unique: true, caseSensitive: false) late String receiptNumber;
  String? transactionId;
  int? paymentRequestId; int? paymentLinkId;
  late String provider; late DateTime issuedAt;
  late String currencyCode; late int amountMinor;
  late int status; // 0=issued, 1=voided
  String? notes;
  String? linesJson; // JSON array of ReceiptLine
  String? metadataJson; // JSON object
  late int version;
  late DateTime createdAt; late DateTime updatedAt;
}

extension ReceiptRecordMapper on ReceiptRecord {
  Receipt toEntity() => Receipt(
    id: id, uuid: uuid, receiptNumber: receiptNumber,
    transactionId: transactionId, paymentRequestId: paymentRequestId,
    paymentLinkId: paymentLinkId, provider: provider,
    issuedAt: issuedAt, currencyCode: currencyCode,
    amountMinor: amountMinor, status: ReceiptStatus.values[status],
    notes: notes,
    lines: linesJson != null ? (jsonDecode(linesJson!) as List).map((e) => ReceiptLine(
      description: e['description'] as String,
      amountMinor: e['amountMinor'] as int,
      quantity: e['quantity'] as int? ?? 1,
    )).toList() : const [],
    metadata: metadataJson != null ? Map<String, String>.from(jsonDecode(metadataJson!)) : const {},
    version: version, createdAt: createdAt, updatedAt: updatedAt,
  );
}

extension ReceiptEntityMapper on Receipt {
  ReceiptRecord toRecord() {
    final r = ReceiptRecord()
      ..id = id ..uuid = uuid.isEmpty ? _generateUuid() : uuid
      ..receiptNumber = receiptNumber
      ..transactionId = transactionId
      ..paymentRequestId = paymentRequestId
      ..paymentLinkId = paymentLinkId
      ..provider = provider ..issuedAt = issuedAt
      ..currencyCode = currencyCode ..amountMinor = amountMinor
      ..status = status.index ..notes = notes
      ..linesJson = lines.isNotEmpty ? jsonEncode(lines.map((l) => {
        'description': l.description, 'amountMinor': l.amountMinor, 'quantity': l.quantity,
      }).toList()) : null
      ..metadataJson = metadata.isNotEmpty ? jsonEncode(metadata) : null
      ..version = version ..createdAt = createdAt ..updatedAt = updatedAt;
    return r;
  }
}

@Collection(inheritance: false)
class AuditEntryRecord {
  AuditEntryRecord();
  Id id = Isar.autoIncrement;
  @Index(type: IndexType.value) late String uuid;
  @Index(type: IndexType.value) late int entityId;
  late String entityType; // AuditEntityType.name
  @Index(type: IndexType.value) late int action; // AuditAction.index
  late String actorType; late String? actorName; int? actorId;
  String? description; String? oldValue; String? newValue;
  late DateTime occurredAt;
  late int version; late DateTime createdAt;
}

extension AuditEntryRecordMapper on AuditEntryRecord {
  AuditEntry toEntity() => AuditEntry(
    id: id, uuid: uuid, entityId: entityId,
    entityType: AuditEntityType.values.firstWhere((e) => e.name == entityType),
    action: AuditAction.values[action],
    actor: AuditActor(type: actorType, name: actorName, id: actorId),
    description: description, oldValue: oldValue, newValue: newValue,
    occurredAt: occurredAt, version: version, createdAt: createdAt,
  );
}

extension AuditEntryEntityMapper on AuditEntry {
  AuditEntryRecord toRecord() {
    final r = AuditEntryRecord()
      ..id = id ..uuid = uuid.isEmpty ? _generateUuid() : uuid
      ..entityId = entityId ..entityType = entityType.name
      ..action = action.index ..actorType = actor.type
      ..actorName = actor.name ..actorId = actor.id
      ..description = description ..oldValue = oldValue
      ..newValue = newValue ..occurredAt = occurredAt
      ..version = version ..createdAt = createdAt;
    return r;
  }
}

String _generateUuid() {
  final now = DateTime.now().microsecondsSinceEpoch;
  final r1 = (now & 0xFFFFFFFF).toRadixString(16).padLeft(8, '0');
  final r2 = ((now >> 32) & 0xFFFF).toRadixString(16).padLeft(4, '0');
  final r3 = ((now >> 48) & 0x0FFF | 0x4000).toRadixString(16).padLeft(4, '0');
  final r4 = (0x8000 | ((now >> 60) & 0x3FFF)).toRadixString(16).padLeft(4, '0');
  final r5 = (now.abs() & 0xFFFFFFFFFFFF).toRadixString(16).padLeft(12, '0');
  return '$r1-$r2-4$r3-${r4[0]}${r4.substring(1)}-$r5';
}
