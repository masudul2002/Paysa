enum BudgetPeriod { weekly, monthly, quarterly, yearly, custom }

enum BudgetStatus { safe, warning, exceeded, completed, archived;

  String get label => switch (this) {
    BudgetStatus.safe => 'Safe',
    BudgetStatus.warning => 'Warning',
    BudgetStatus.exceeded => 'Exceeded',
    BudgetStatus.completed => 'Completed',
    BudgetStatus.archived => 'Archived',
  };
}

final class Budget {
  const Budget({
    this.id = 0,
    this.name = '',
    this.categoryId,
    this.period = BudgetPeriod.monthly,
    required this.startDate,
    required this.endDate,
    required this.budgetAmountMinor,
    this.spentAmountMinor = 0,
    this.carryForwardEnabled = false,
    this.notes,
    this.status = BudgetStatus.safe,
    this.version = 1,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });

  final int id;
  final String name;
  final int? categoryId;
  final BudgetPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final int budgetAmountMinor;
  final int spentAmountMinor;
  final bool carryForwardEnabled;
  final String? notes;
  final BudgetStatus status;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;

  int get remainingAmountMinor => (budgetAmountMinor - spentAmountMinor).clamp(0, budgetAmountMinor);
  double get progressPercent => budgetAmountMinor > 0 ? (spentAmountMinor / budgetAmountMinor) * 100 : 0;
  bool get isExceeded => spentAmountMinor > budgetAmountMinor;
  bool get isArchived => archivedAt != null;

  int get remainingDays => endDate.difference(DateTime.now()).inDays.clamp(0, 365);
  int get dailyBudget => remainingDays > 0 ? remainingAmountMinor ~/ remainingDays : 0;

  /// Budget health: positive is good, negative means overspending projected.
  int get projectedEndAmount {
    final elapsed = DateTime.now().difference(startDate).inDays.clamp(1, 365);
    final totalPeriod = endDate.difference(startDate).inDays.clamp(1, 365);
    if (elapsed == 0) return budgetAmountMinor;
    return (spentAmountMinor / elapsed * totalPeriod).round();
  }

  bool get isOnTrack => projectedEndAmount <= budgetAmountMinor;

  Budget copyWith({
    int? id, String? name, int? categoryId, BudgetPeriod? period,
    DateTime? startDate, DateTime? endDate, int? budgetAmountMinor,
    int? spentAmountMinor, bool? carryForwardEnabled, String? notes,
    BudgetStatus? status, int? version, DateTime? createdAt,
    DateTime? updatedAt, DateTime? archivedAt,
  }) => Budget(
    id: id ?? this.id, name: name ?? this.name,
    categoryId: categoryId ?? this.categoryId,
    period: period ?? this.period,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    budgetAmountMinor: budgetAmountMinor ?? this.budgetAmountMinor,
    spentAmountMinor: spentAmountMinor ?? this.spentAmountMinor,
    carryForwardEnabled: carryForwardEnabled ?? this.carryForwardEnabled,
    notes: notes ?? this.notes, status: status ?? this.status,
    version: version ?? this.version,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    archivedAt: archivedAt ?? this.archivedAt,
  );
}

final class BudgetProgress {
  const BudgetProgress({
    required this.totalBudgets,
    required this.totalBudgeted,
    required this.totalSpent,
    required this.remaining,
    required this.onTrack,
    required this.warning,
    required this.exceeded,
  });
  final int totalBudgets;
  final int totalBudgeted;
  final int totalSpent;
  final int remaining;
  final int onTrack;
  final int warning;
  final int exceeded;
}
