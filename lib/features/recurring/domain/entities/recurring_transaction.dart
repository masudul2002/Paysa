/// Schedule frequency for recurring transactions.
enum RecurringFrequency {
  daily,
  weekly,
  monthly,
  yearly,
  weekdays,
  custom;

  String get label => switch (this) {
    RecurringFrequency.daily => 'Daily',
    RecurringFrequency.weekly => 'Weekly',
    RecurringFrequency.monthly => 'Monthly',
    RecurringFrequency.yearly => 'Yearly',
    RecurringFrequency.weekdays => 'Weekdays',
    RecurringFrequency.custom => 'Custom',
  };
}

/// Execution status of a recurring transaction template.
enum RecurringStatus {
  draft,
  active,
  paused,
  completed,
  archived;

  String get label => switch (this) {
    RecurringStatus.draft => 'Draft',
    RecurringStatus.active => 'Active',
    RecurringStatus.paused => 'Paused',
    RecurringStatus.completed => 'Completed',
    RecurringStatus.archived => 'Archived',
  };
}

/// A recurring transaction template that generates transaction instances
/// on a schedule. Execution is manual for MVP.
final class RecurringTransaction {
  const RecurringTransaction({
    this.id = 0,
    this.title = '',
    this.amountMinor = 0,
    this.transactionType = 0, // 0=income, 1=expense
    this.accountId = 0,
    this.categoryId,
    this.personId,
    this.paymentMethodId,
    this.notes,
    this.frequency = RecurringFrequency.monthly,
    this.interval = 1,
    this.status = RecurringStatus.draft,
    this.nextExecutionDate,
    this.lastExecutionDate,
    this.executionCount = 0,
    this.startDate,
    this.endDate,
    this.totalExecutions,
    this.version = 1,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncStatus = 0,
  });

  final int id;
  final String title;
  final int amountMinor;
  final int transactionType;
  final int accountId;
  final int? categoryId;
  final int? personId;
  final int? paymentMethodId;
  final String? notes;
  final RecurringFrequency frequency;
  final int interval;
  final RecurringStatus status;
  final DateTime? nextExecutionDate;
  final DateTime? lastExecutionDate;
  final int executionCount;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? totalExecutions;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int syncStatus;

  bool get isActive => status == RecurringStatus.active;
  bool get isDue => nextExecutionDate != null && nextExecutionDate!.isBefore(DateTime.now()) && isActive;
  bool get isDeleted => deletedAt != null;

  /// Calculate the next execution date based on the schedule.
  DateTime? calculateNextDate(DateTime from) {
    if (endDate != null && from.isAfter(endDate!)) return null;
    if (totalExecutions != null && executionCount >= totalExecutions!) return null;

    return switch (frequency) {
      RecurringFrequency.daily => from.add(Duration(days: interval)),
      RecurringFrequency.weekly => from.add(Duration(days: 7 * interval)),
      RecurringFrequency.monthly => DateTime(from.year, from.month + interval, from.day),
      RecurringFrequency.yearly => DateTime(from.year + interval, from.month, from.day),
      RecurringFrequency.weekdays => _nextWeekday(from),
      RecurringFrequency.custom => from.add(Duration(days: interval)),
    };
  }

  DateTime _nextWeekday(DateTime from) {
    var d = from.add(const Duration(days: 1));
    while (d.weekday == DateTime.saturday || d.weekday == DateTime.sunday) {
      d = d.add(const Duration(days: 1));
    }
    return d;
  }

  RecurringTransaction copyWith({
    int? id, String? title, int? amountMinor, int? transactionType,
    int? accountId, int? categoryId, int? personId, int? paymentMethodId,
    String? notes, RecurringFrequency? frequency, int? interval,
    RecurringStatus? status, DateTime? nextExecutionDate, DateTime? lastExecutionDate,
    int? executionCount, DateTime? startDate, DateTime? endDate, int? totalExecutions,
    int? version, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt, int? syncStatus,
  }) => RecurringTransaction(
    id: id ?? this.id, title: title ?? this.title,
    amountMinor: amountMinor ?? this.amountMinor,
    transactionType: transactionType ?? this.transactionType,
    accountId: accountId ?? this.accountId,
    categoryId: categoryId ?? this.categoryId,
    personId: personId ?? this.personId,
    paymentMethodId: paymentMethodId ?? this.paymentMethodId,
    notes: notes ?? this.notes,
    frequency: frequency ?? this.frequency, interval: interval ?? this.interval,
    status: status ?? this.status,
    nextExecutionDate: nextExecutionDate ?? this.nextExecutionDate,
    lastExecutionDate: lastExecutionDate ?? this.lastExecutionDate,
    executionCount: executionCount ?? this.executionCount,
    startDate: startDate ?? this.startDate, endDate: endDate ?? this.endDate,
    totalExecutions: totalExecutions ?? this.totalExecutions,
    version: version ?? this.version,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt ?? this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
}

/// A single execution record for a recurring transaction.
final class RecurringExecution {
  const RecurringExecution({
    this.id = 0,
    this.recurringId = 0,
    this.executedAt,
    this.transactionId,
    this.status = 'pending',
    this.notes,
    this.version = 1,
    required this.createdAt,
  });

  final int id;
  final int recurringId;
  final DateTime? executedAt;
  final int? transactionId;
  final String status;
  final String? notes;
  final int version;
  final DateTime createdAt;
}
