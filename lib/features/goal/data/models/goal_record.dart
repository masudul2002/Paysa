import 'package:isar/isar.dart';
import '../../domain/entities/goal.dart';

part 'goal_record.g.dart';

@Collection(inheritance: false)
class GoalRecord {
  GoalRecord();
  Id id = Isar.autoIncrement;
  late String title; late int goalType;
  late int targetAmountMinor; late int currentAmountMinor;
  DateTime? targetDate; late int priority; late int status;
  int? linkedAccountId; String? notes;
  late int version; late DateTime createdAt; late DateTime updatedAt;
  DateTime? archivedAt;
}

extension GoalRecordMapper on GoalRecord {
  FinancialGoal toEntity() => FinancialGoal(
    id: id, title: title, goalType: GoalType.values[goalType],
    targetAmountMinor: targetAmountMinor, currentAmountMinor: currentAmountMinor,
    targetDate: targetDate, priority: GoalPriority.values[priority],
    status: GoalStatus.values[status],
    linkedAccountId: linkedAccountId, notes: notes,
    version: version, createdAt: createdAt, updatedAt: updatedAt,
    archivedAt: archivedAt,
  );
}

extension GoalEntityMapper on FinancialGoal {
  GoalRecord toRecord() {
    final r = GoalRecord()
      ..id = id ..title = title ..goalType = goalType.index
      ..targetAmountMinor = targetAmountMinor ..currentAmountMinor = currentAmountMinor
      ..targetDate = targetDate ..priority = priority.index
      ..status = status.index ..linkedAccountId = linkedAccountId ..notes = notes
      ..version = version ..createdAt = createdAt ..updatedAt = updatedAt
      ..archivedAt = archivedAt;
    return r;
  }
}
