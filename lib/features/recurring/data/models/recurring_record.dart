import 'package:isar/isar.dart';
import '../../domain/entities/recurring_transaction.dart';

part 'recurring_record.g.dart';

@Collection(inheritance: false)
class RecurringRecord {
  RecurringRecord();
  Id id = Isar.autoIncrement;
  @Index(type: IndexType.value) late String uuid;
  late String title; late int amountMinor; late int transactionType;
  late int accountId; int? categoryId; int? personId; int? paymentMethodId;
  String? notes;
  late int frequency; // RecurringFrequency.index
  late int interval; late int status; // RecurringStatus.index
  DateTime? nextExecutionDate; DateTime? lastExecutionDate;
  late int executionCount; DateTime? startDate; DateTime? endDate; int? totalExecutions;
  late int version; late DateTime createdAt; late DateTime updatedAt;
  DateTime? deletedAt; late int syncStatus;
}

extension RecurringRecordMapper on RecurringRecord {
  RecurringTransaction toEntity() => RecurringTransaction(
    id: id, title: title, amountMinor: amountMinor,
    transactionType: transactionType, accountId: accountId,
    categoryId: categoryId, personId: personId,
    paymentMethodId: paymentMethodId, notes: notes,
    frequency: RecurringFrequency.values[frequency],
    interval: interval, status: RecurringStatus.values[status],
    nextExecutionDate: nextExecutionDate, lastExecutionDate: lastExecutionDate,
    executionCount: executionCount, startDate: startDate, endDate: endDate,
    totalExecutions: totalExecutions, version: version,
    createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt,
    syncStatus: syncStatus,
  );
}

extension RecurringEntityMapper on RecurringTransaction {
  RecurringRecord toRecord() {
    final r = RecurringRecord()
      ..id = id ..uuid = id == 0 ? _uuid() : 'rt-$id'
      ..title = title ..amountMinor = amountMinor ..transactionType = transactionType
      ..accountId = accountId ..categoryId = categoryId ..personId = personId
      ..paymentMethodId = paymentMethodId ..notes = notes ..frequency = frequency.index
      ..interval = interval ..status = status.index
      ..nextExecutionDate = nextExecutionDate ..lastExecutionDate = lastExecutionDate
      ..executionCount = executionCount ..startDate = startDate ..endDate = endDate
      ..totalExecutions = totalExecutions ..version = version
      ..createdAt = createdAt ..updatedAt = updatedAt ..deletedAt = deletedAt
      ..syncStatus = syncStatus;
    return r;
  }
}

String _uuid() {
  final n = DateTime.now().microsecondsSinceEpoch;
  return '${n & 0xFFFFFFFF}-${(n >> 32) & 0xFFFF}';
}
