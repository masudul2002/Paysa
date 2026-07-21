import 'package:isar/isar.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_method_type.dart';

part 'payment_method_record.g.dart';

@Collection(inheritance: false)
class PaymentMethodRecord {
  PaymentMethodRecord();

  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String uuid;

  @Index(unique: true, caseSensitive: false)
  late String name;

  @Enumerated(EnumType.name)
  late PaymentMethodType type;

  String? description;
  String? iconKey;
  int? colorValue;
  int? linkedAccountId;
  late bool isBuiltIn;
  late bool isEnabled;
  late bool isFavorite;
  late int sortOrder;
  late int version;
  late DateTime createdAt;
  late DateTime updatedAt;
  DateTime? deletedAt;
  late int syncStatus;

  String? validate() {
    if (name.trim().isEmpty) return 'Name is required.';
    if (name.trim().length > 50) return 'Name must be under 50 characters.';
    return null;
  }
}

extension PaymentMethodRecordMapper on PaymentMethodRecord {
  PaymentMethod toEntity() {
    return PaymentMethod(
      id: id, uuid: uuid, name: name, type: type,
      iconKey: iconKey, colorValue: colorValue,
      linkedAccountId: linkedAccountId,
      isBuiltIn: isBuiltIn, isEnabled: isEnabled, isFavorite: isFavorite,
      sortOrder: sortOrder, version: version,
      createdAt: createdAt, updatedAt: updatedAt,
      deletedAt: deletedAt, syncStatus: syncStatus,
    );
  }
}

extension PaymentMethodEntityMapper on PaymentMethod {
  PaymentMethodRecord toRecord() {
    final record = PaymentMethodRecord()
      ..id = id
      ..uuid = uuid.isEmpty ? _generateUuid() : uuid
      ..name = name.trim()
      ..type = type
      ..description = description
      ..iconKey = iconKey ?? type.iconKey
      ..colorValue = colorValue
      ..linkedAccountId = linkedAccountId
      ..isBuiltIn = isBuiltIn
      ..isEnabled = isEnabled
      ..isFavorite = isFavorite
      ..sortOrder = sortOrder
      ..version = version
      ..createdAt = createdAt
      ..updatedAt = updatedAt
      ..deletedAt = deletedAt
      ..syncStatus = syncStatus;
    return record;
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
