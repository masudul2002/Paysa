import 'package:isar/isar.dart';
import '../../domain/entities/budget.dart';

part 'budget_record.g.dart';

@Collection(inheritance: false)
class BudgetRecord {
  BudgetRecord();
  Id id = Isar.autoIncrement;
  late String name; int? categoryId;
  late int period; // BudgetPeriod.index
  late DateTime startDate; late DateTime endDate;
  late int budgetAmountMinor; late int spentAmountMinor;
  late bool carryForwardEnabled; String? notes;
  late int status; // BudgetStatus.index
  late int version; late DateTime createdAt; late DateTime updatedAt;
  DateTime? archivedAt;
}

extension BudgetRecordMapper on BudgetRecord {
  Budget toEntity() => Budget(
    id: id, name: name, categoryId: categoryId,
    period: BudgetPeriod.values[period],
    startDate: startDate, endDate: endDate,
    budgetAmountMinor: budgetAmountMinor,
    spentAmountMinor: spentAmountMinor,
    carryForwardEnabled: carryForwardEnabled, notes: notes,
    status: BudgetStatus.values[status], version: version,
    createdAt: createdAt, updatedAt: updatedAt, archivedAt: archivedAt,
  );
}

extension BudgetEntityMapper on Budget {
  BudgetRecord toRecord() {
    final r = BudgetRecord()
      ..id = id ..name = name ..categoryId = categoryId
      ..period = period.index ..startDate = startDate ..endDate = endDate
      ..budgetAmountMinor = budgetAmountMinor
      ..spentAmountMinor = spentAmountMinor
      ..carryForwardEnabled = carryForwardEnabled ..notes = notes
      ..status = status.index ..version = version
      ..createdAt = createdAt ..updatedAt = updatedAt ..archivedAt = archivedAt;
    return r;
  }
}
