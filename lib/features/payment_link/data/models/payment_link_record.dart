import 'package:isar/isar.dart';
import '../../domain/entities/payment_link.dart';

part 'payment_link_record.g.dart';

@Collection(inheritance: false)
class PaymentLinkRecord {
  PaymentLinkRecord();

  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String uuid;

  @Index(type: IndexType.value)
  late int paymentRequestId;

  late String provider;

  @Index(unique: true, caseSensitive: false)
  late String token;

  String? shortCode;
  String? url;

  @Enumerated(EnumType.name)
  late PaymentLinkStatus status;

  DateTime? expiresAt;
  DateTime? resolvedAt;

  late int version;
  late DateTime createdAt;
  late DateTime updatedAt;
  DateTime? deletedAt;
}

extension PaymentLinkRecordMapper on PaymentLinkRecord {
  PaymentLink toEntity() => PaymentLink(
    id: id, uuid: uuid, paymentRequestId: paymentRequestId,
    provider: provider, token: token, shortCode: shortCode,
    url: url, status: status, expiresAt: expiresAt,
    resolvedAt: resolvedAt, version: version,
    createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt,
  );
}

extension PaymentLinkEntityMapper on PaymentLink {
  PaymentLinkRecord toRecord() {
    final r = PaymentLinkRecord()
      ..id = id
      ..uuid = uuid.isEmpty ? _generateUuid() : uuid
      ..paymentRequestId = paymentRequestId
      ..provider = provider
      ..token = token
      ..shortCode = shortCode
      ..url = url
      ..status = status
      ..expiresAt = expiresAt
      ..resolvedAt = resolvedAt
      ..version = version
      ..createdAt = createdAt
      ..updatedAt = updatedAt
      ..deletedAt = deletedAt;
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
