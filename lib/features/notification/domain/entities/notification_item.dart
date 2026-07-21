enum NotificationType {
  recurringDue,
  budgetWarning,
  budgetExceeded,
  goalDeadline,
  goalBehind,
  paymentPending,
  custom;

  String get label => switch (this) {
    NotificationType.recurringDue => 'Recurring Due',
    NotificationType.budgetWarning => 'Budget Warning',
    NotificationType.budgetExceeded => 'Budget Exceeded',
    NotificationType.goalDeadline => 'Goal Deadline',
    NotificationType.goalBehind => 'Goal Behind',
    NotificationType.paymentPending => 'Payment Pending',
    NotificationType.custom => 'Reminder',
  };
}

enum NotificationStatus { unread, read, dismissed, snoozed }

final class NotificationItem {
  const NotificationItem({
    this.id = 0,
    this.type = NotificationType.custom,
    this.title = '',
    this.body = '',
    this.entityType,
    this.entityId,
    this.status = NotificationStatus.unread,
    this.priority = 0,
    this.snoozedUntil,
    required this.createdAt,
  });

  final int id;
  final NotificationType type;
  final String title;
  final String body;
  final String? entityType;
  final int? entityId;
  final NotificationStatus status;
  final int priority;
  final DateTime? snoozedUntil;
  final DateTime createdAt;

  NotificationItem copyWith({
    int? id, NotificationType? type, String? title, String? body,
    String? entityType, int? entityId, NotificationStatus? status,
    int? priority, DateTime? snoozedUntil, DateTime? createdAt,
  }) => NotificationItem(
    id: id ?? this.id, type: type ?? this.type,
    title: title ?? this.title, body: body ?? this.body,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    status: status ?? this.status,
    priority: priority ?? this.priority,
    snoozedUntil: snoozedUntil ?? this.snoozedUntil,
    createdAt: createdAt ?? this.createdAt,
  );
}

/// A rule that generates reminders based on conditions.
final class ReminderRule {
  const ReminderRule({
    this.id = 0,
    this.type = NotificationType.custom,
    this.entityType = '',
    this.entityId = 0,
    this.thresholdValue,
    this.thresholdUnit,
    this.leadDays = 0,
    this.repeatInterval,
    this.isEnabled = true,
    this.createdAt,
  });

  final int id;
  final NotificationType type;
  final String entityType;
  final int entityId;
  final double? thresholdValue;
  final String? thresholdUnit;
  final int leadDays;
  final int? repeatInterval;
  final bool isEnabled;
  final DateTime? createdAt;
}
