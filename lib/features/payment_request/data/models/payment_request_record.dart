import 'package:isar/isar.dart';
import '../../domain/entities/payment_request.dart';

part 'payment_request_record.g.dart';

@Collection(inheritance: false)
class PaymentRequestRecord {
  PaymentRequestRecord();

  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String uuid;

  @Index(unique: true, caseSensitive: false)
  late String requestNumber;

  late String title;
  String? description;

  @Enumerated(EnumType.name)
  late PaymentRequestType requestType;

  int? personId;
  int? ledgerId;
  int? transactionId;
  late int amountMinor;
  late String currencyCode;

  @Enumerated(EnumType.name)
  late PaymentRequestStatus status;

  DateTime? expiresAt;
  late bool allowPartialPayment;
  late bool allowOverPayment;
  String? createdBy;
  String? lastModifiedBy;
  DateTime? statusChangedAt;

  late int version;
  late DateTime createdAt;
  late DateTime updatedAt;
  DateTime? deletedAt;
  late int syncStatus;
}

extension PaymentRequestRecordMapper on PaymentRequestRecord {
  PaymentRequest toEntity() {
    return PaymentRequest(
      id: id, uuid: uuid, requestNumber: requestNumber,
      title: title, description: description,
      requestType: requestType,
      personId: personId, ledgerId: ledgerId, transactionId: transactionId,
      amountMinor: amountMinor, currencyCode: currencyCode,
      status: status, expiresAt: expiresAt,
      allowPartialPayment: allowPartialPayment,
      allowOverPayment: allowOverPayment,
      createdBy: createdBy, lastModifiedBy: lastModifiedBy,
      statusChangedAt: statusChangedAt,
      version: version,
      createdAt: createdAt, updatedAt: updatedAt,
      deletedAt: deletedAt, syncStatus: syncStatus,
    );
  }
}

extension PaymentRequestEntityMapper on PaymentRequest {
  PaymentRequestRecord toRecord() {
    final r = PaymentRequestRecord()
      ..id = id
      ..uuid = uuid.isEmpty ? _generateUuid() : uuid
      ..requestNumber = requestNumber
      ..title = title
      ..description = description
      ..requestType = requestType
      ..personId = personId
      ..ledgerId = ledgerId
      ..transactionId = transactionId
      ..amountMinor = amountMinor
      ..currencyCode = currencyCode
      ..status = status
      ..expiresAt = expiresAt
      ..allowPartialPayment = allowPartialPayment
      ..allowOverPayment = allowOverPayment
      ..createdBy = createdBy
      ..lastModifiedBy = lastModifiedBy
      ..statusChangedAt = statusChangedAt
      ..version = version
      ..createdAt = createdAt
      ..updatedAt = updatedAt
      ..deletedAt = deletedAt
      ..syncStatus = syncStatus;
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
