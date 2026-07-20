import 'package:isar/isar.dart';

import '../../domain/entities/transaction.dart';

part 'transaction_record.g.dart';

@Collection(inheritance: false)
class TransactionRecord {
  TransactionRecord();

  Id id = Isar.autoIncrement;

  late int accountId;
  int? categoryId;

  @Enumerated(EnumType.name)
  late TransactionType type;

  late double amount;
  late String currency;
  String? description;
  late DateTime date;
  late bool isPending;

  @Index(type: IndexType.value)
  late DateTime createdAt;

  late DateTime updatedAt;
  List<String>? tags;
}

extension TransactionRecordMapper on TransactionRecord {
  Transaction toEntity() {
    return Transaction(
      id: id,
      accountId: accountId,
      categoryId: categoryId,
      type: type,
      amount: amount,
      currency: currency,
      description: description ?? '',
      date: date,
      isPending: isPending,
      tags: tags ?? const [],
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension TransactionEntityMapper on Transaction {
  TransactionRecord toRecord() {
    final record = TransactionRecord()
      ..id = id
      ..accountId = accountId
      ..categoryId = categoryId
      ..type = type
      ..amount = amount
      ..currency = currency.trim().toUpperCase()
      ..description = description.trim().isEmpty ? null : description.trim()
      ..date = date
      ..isPending = isPending
      ..tags = tags.isEmpty ? null : tags
      ..createdAt = createdAt
      ..updatedAt = updatedAt;
    return record;
  }
}
