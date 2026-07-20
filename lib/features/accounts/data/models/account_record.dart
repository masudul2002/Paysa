import 'package:isar/isar.dart';

import '../../domain/entities/account.dart';

part 'account_record.g.dart';

@Collection(inheritance: false)
class AccountRecord {
  AccountRecord();

  Id id = Isar.autoIncrement;

  @Index(unique: true, caseSensitive: false)
  late String name;

  @Enumerated(EnumType.name)
  late AccountType type;

  late String currency;
  late double balance;
  late String icon;
  late int color;
  String? description;
  late bool isArchived;
  late DateTime createdAt;
  late DateTime updatedAt;
}

extension AccountRecordMapper on AccountRecord {
  Account toEntity() {
    return Account(
      id: id,
      name: name,
      type: type,
      currency: currency,
      balance: balance,
      icon: icon,
      color: color,
      description: description ?? '',
      isArchived: isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension AccountEntityMapper on Account {
  AccountRecord toRecord() {
    final record = AccountRecord()
      ..id = id
      ..name = name.trim()
      ..type = type
      ..currency = currency.trim().toUpperCase()
      ..balance = balance
      ..icon = icon
      ..color = color
      ..description = description.trim().isEmpty ? null : description.trim()
      ..isArchived = isArchived
      ..createdAt = createdAt
      ..updatedAt = updatedAt;
    return record;
  }
}
