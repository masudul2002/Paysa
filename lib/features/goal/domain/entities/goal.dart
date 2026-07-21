enum GoalType {
  emergencyFund, vacation, education, vehicle,
  house, electronics, investment, debtPayoff, custom;
  String get label => name.split(RegExp(r'(?=[A-Z])')).map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
}

enum GoalPriority { low, medium, high }
enum GoalStatus { notStarted, onTrack, behind, completed, archived;

  String get label => switch (this) {
    GoalStatus.notStarted => 'Not Started',
    GoalStatus.onTrack => 'On Track',
    GoalStatus.behind => 'Behind',
    GoalStatus.completed => 'Completed',
    GoalStatus.archived => 'Archived',
  };
}

final class FinancialGoal {
  const FinancialGoal({
    this.id = 0,
    this.title = '',
    this.goalType = GoalType.custom,
    required this.targetAmountMinor,
    this.currentAmountMinor = 0,
    this.targetDate,
    this.priority = GoalPriority.medium,
    this.status = GoalStatus.notStarted,
    this.linkedAccountId,
    this.notes,
    this.version = 1,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });

  final int id;
  final String title;
  final GoalType goalType;
  final int targetAmountMinor;
  final int currentAmountMinor;
  final DateTime? targetDate;
  final GoalPriority priority;
  final GoalStatus status;
  final int? linkedAccountId;
  final String? notes;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;

  int get remainingAmount => (targetAmountMinor - currentAmountMinor).clamp(0, targetAmountMinor);
  double get progressPercent => targetAmountMinor > 0 ? (currentAmountMinor / targetAmountMinor) * 100 : 0;
  bool get isCompleted => status == GoalStatus.completed;
  bool get isArchived => archivedAt != null;

  int get remainingDays {
    if (targetDate == null) return 365;
    return targetDate!.difference(DateTime.now()).inDays.clamp(0, 365 * 10);
  }

  int get requiredMonthlySaving {
    final months = (remainingDays / 30.0).ceil().clamp(1, 120);
    return remainingAmount ~/ months;
  }

  DateTime? get projectedCompletionDate {
    if (currentAmountMinor <= 0 || remainingAmount <= 0) return null;
    final monthly = requiredMonthlySaving;
    if (monthly <= 0) return null;
    final monthsNeeded = (remainingAmount / monthly).ceil();
    return DateTime.now().add(Duration(days: monthsNeeded * 30));
  }

  bool get isBehind => targetDate != null && targetDate!.isBefore(DateTime.now()) && !isCompleted;

  FinancialGoal copyWith({
    int? id, String? title, GoalType? goalType,
    int? targetAmountMinor, int? currentAmountMinor,
    DateTime? targetDate, GoalPriority? priority, GoalStatus? status,
    int? linkedAccountId, String? notes,
    int? version, DateTime? createdAt, DateTime? updatedAt, DateTime? archivedAt,
  }) => FinancialGoal(
    id: id ?? this.id, title: title ?? this.title,
    goalType: goalType ?? this.goalType,
    targetAmountMinor: targetAmountMinor ?? this.targetAmountMinor,
    currentAmountMinor: currentAmountMinor ?? this.currentAmountMinor,
    targetDate: targetDate ?? this.targetDate,
    priority: priority ?? this.priority,
    status: status ?? this.status,
    linkedAccountId: linkedAccountId ?? this.linkedAccountId,
    notes: notes ?? this.notes,
    version: version ?? this.version,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    archivedAt: archivedAt ?? this.archivedAt,
  );
}

final class GoalContribution {
  const GoalContribution({
    this.id = 0,
    this.goalId = 0,
    required this.amountMinor,
    this.accountId,
    this.notes,
    required this.date,
    this.version = 1,
    required this.createdAt,
  });
  final int id;
  final int goalId;
  final int amountMinor;
  final int? accountId;
  final String? notes;
  final DateTime date;
  final int version;
  final DateTime createdAt;
}

final class GoalSummary {
  const GoalSummary({
    required this.totalGoals,
    required this.totalTarget,
    required this.totalCurrent,
    required this.completedCount,
    required this.behindCount,
  });
  final int totalGoals;
  final int totalTarget;
  final int totalCurrent;
  final int completedCount;
  final int behindCount;
}
