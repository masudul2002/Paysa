/// Repeat interval for reminders.
enum ReminderRepeat {
  none,
  daily,
  weekly,
  monthly,
  yearly;
}

/// Status of a reminder.
enum ReminderStatus {
  active,
  completed,
  cancelled,
}

/// A reminder for a due payment or receivable.
///
/// Tied to a LedgerEntry (e.g., a Give entry with a due date).
final class Reminder {
  const Reminder({
    this.id = 0,
    this.uuid = '',
    required this.ledgerEntryId,
    required this.personId,
    this.personName = '',
    required this.dueDate,
    this.reminderDate,
    this.repeat = ReminderRepeat.none,
    this.status = ReminderStatus.active,
    this.note,
    this.lastFiredAt,
    this.nextFireAt,
    this.version = 1,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final int id;
  final String uuid;
  final int ledgerEntryId;
  final int personId;
  final String personName;
  final DateTime dueDate;
  final DateTime? reminderDate;
  final ReminderRepeat repeat;
  final ReminderStatus status;
  final String? note;
  final DateTime? lastFiredAt;
  final DateTime? nextFireAt;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isOverdue => dueDate.isBefore(DateTime.now()) && status == ReminderStatus.active;
  bool get isUpcoming => dueDate.isAfter(DateTime.now()) && status == ReminderStatus.active;
  bool get isDueToday =>
      dueDate.year == DateTime.now().year &&
      dueDate.month == DateTime.now().month &&
      dueDate.day == DateTime.now().day &&
      status == ReminderStatus.active;

  Reminder copyWith({
    int? id, String? uuid, int? ledgerEntryId, int? personId, String? personName,
    DateTime? dueDate, DateTime? reminderDate, ReminderRepeat? repeat,
    ReminderStatus? status, String? note, DateTime? lastFiredAt, DateTime? nextFireAt,
    int? version, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt,
  }) {
    return Reminder(
      id: id ?? this.id, uuid: uuid ?? this.uuid,
      ledgerEntryId: ledgerEntryId ?? this.ledgerEntryId,
      personId: personId ?? this.personId, personName: personName ?? this.personName,
      dueDate: dueDate ?? this.dueDate, reminderDate: reminderDate ?? this.reminderDate,
      repeat: repeat ?? this.repeat, status: status ?? this.status, note: note ?? this.note,
      lastFiredAt: lastFiredAt ?? this.lastFiredAt, nextFireAt: nextFireAt ?? this.nextFireAt,
      version: version ?? this.version, createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt, deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
