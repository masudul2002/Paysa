import 'package:isar/isar.dart';
import '../../domain/entities/reminder.dart';

part 'reminder_record.g.dart';

/// Sync status for future cloud sync.
enum ReminderSyncStatus {
  pending(0), synced(1), modified(2), deleted(3), failed(4);

  const ReminderSyncStatus(this.value);
  final int value;

  static ReminderSyncStatus fromValue(int value) =>
      ReminderSyncStatus.values.firstWhere(
        (s) => s.value == value,
        orElse: () => ReminderSyncStatus.pending,
      );
}

// ---------------------------------------------------------------------------
// ReminderRecord
// ---------------------------------------------------------------------------

@Collection(inheritance: false)
class ReminderRecord {
  ReminderRecord();

  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String uuid;

  @Index(type: IndexType.value)
  late int ledgerEntryId;

  @Index(type: IndexType.value)
  late int personId;

  /// Due date of the underlying ledger entry (when repayment is expected).
  @Index(type: IndexType.value)
  late DateTime dueDate;

  /// When the reminder should fire. Defaults to dueDate if not set.
  DateTime? reminderDate;

  /// Repeat interval: 0=none, 1=daily, 2=weekly, 3=monthly, 4=yearly.
  late int repeat;

  /// Status: 0=active, 1=completed, 2=cancelled.
  late int status;

  String? note;
  DateTime? lastFiredAt;
  DateTime? nextFireAt;

  late int version;
  late DateTime createdAt;
  late DateTime updatedAt;
  DateTime? deletedAt;
  late int syncStatus;

  String? validate() {
    if (uuid.trim().isEmpty) return 'UUID is required.';
    if (ledgerEntryId <= 0) return 'Ledger entry ID must be positive.';
    if (personId <= 0) return 'Person ID must be positive.';
    return null;
  }

  bool get isActive => status == 0;
  bool get isOverdue => dueDate.isBefore(DateTime.now()) && isActive;
  bool get isDueToday {
    final now = DateTime.now();
    return dueDate.year == now.year && dueDate.month == now.month &&
           dueDate.day == now.day && isActive;
  }
}

// ---------------------------------------------------------------------------
// Mappers
// ---------------------------------------------------------------------------

extension ReminderRecordMapper on ReminderRecord {
  Reminder toEntity() {
    return Reminder(
      id: id,
      uuid: uuid,
      ledgerEntryId: ledgerEntryId,
      personId: personId,
      personName: '',
      dueDate: dueDate,
      reminderDate: reminderDate,
      repeat: ReminderRepeat.values[repeat],
      status: ReminderStatus.values[status],
      note: note,
      lastFiredAt: lastFiredAt,
      nextFireAt: nextFireAt,
      version: version,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }
}

extension ReminderEntityMapper on Reminder {
  ReminderRecord toRecord() {
    final record = ReminderRecord()
      ..id = id
      ..uuid = uuid.isEmpty ? _generateUuid() : uuid
      ..ledgerEntryId = ledgerEntryId
      ..personId = personId
      ..dueDate = dueDate
      ..reminderDate = reminderDate ?? dueDate
      ..repeat = repeat.index
      ..status = status.index
      ..note = note
      ..lastFiredAt = lastFiredAt
      ..nextFireAt = nextFireAt
      ..version = version
      ..syncStatus = ReminderSyncStatus.pending.value
      ..createdAt = createdAt
      ..updatedAt = updatedAt
      ..deletedAt = deletedAt;
    return record;
  }
}

String _generateUuid() {
  final now = DateTime.now().microsecondsSinceEpoch;
  final r1 = (now & 0xFFFFFFFF).toRadixString(16).padLeft(8, '0');
  final r2 = ((now >> 32) & 0xFFFF).toRadixString(16).padLeft(4, '0');
  final r3 = ((now >> 48) & 0x0FFF | 0x4000).toRadixString(16).padLeft(4, '0');
  final r4 = (0x8000 | ((now >> 60) & 0x3FFF)).toRadixString(16).padLeft(4, '0');
  final r5 = (now.abs() & 0xFFFFFFFFFFFF).toRadixString(16).padLeft(12, '0');
  return '$r1-$r2-4$r3-${r4[0]}${r4.substring(1)}-$r5';
}
