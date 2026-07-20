import 'package:isar/isar.dart';
import 'package:paysa/features/people/domain/entities/person.dart';

import '../../domain/entities/ledger.dart';

part 'ledger_record.g.dart';

/// Sync status for future cloud sync.
enum LedgerSyncStatus {
  pending(0),
  synced(1),
  modified(2),
  deleted(3),
  failed(4);

  const LedgerSyncStatus(this.value);
  final int value;

  static LedgerSyncStatus fromValue(int value) =>
      LedgerSyncStatus.values.firstWhere(
        (s) => s.value == value,
        orElse: () => LedgerSyncStatus.pending,
      );
}


// ---------------------------------------------------------------------------
// LedgerRecord
// ---------------------------------------------------------------------------

@Collection(inheritance: false)
class LedgerRecord {
  LedgerRecord();

  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String uuid;

  @Index(type: IndexType.value)
  late int personId;

  late int currentBalance;
  late int openingBalance;
  late int receivableAmount;
  late int payableAmount;
  DateTime? lastTransactionAt;

  @Enumerated(EnumType.name)
  late PersonStatus status;

  late int version;
  late DateTime createdAt;
  late DateTime updatedAt;
  DateTime? deletedAt;
  late int syncStatus;

  String? validate() {
    if (uuid.trim().isEmpty) return 'UUID is required.';
    if (personId <= 0) return 'Person ID must be positive.';
    return null;
  }
}

// ---------------------------------------------------------------------------
// LedgerEntryRecord
// ---------------------------------------------------------------------------

@Collection(inheritance: false)
class LedgerEntryRecord {
  LedgerEntryRecord();

  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String uuid;

  @Index(type: IndexType.value)
  late int ledgerId;

  @Index(type: IndexType.value)
  late int personId;

  @Enumerated(EnumType.name)
  late LedgerEntryType entryType;

  /// Amount in minor currency units (cents/paisa). Always positive.
  late int amount;

  /// ISO 4217 currency code.
  late String currencyCode;

  /// FK to PaymentMethod.id. Nullable.
  int? paymentMethodId;

  /// Date of the transaction.
  @Index(type: IndexType.value)
  late DateTime transactionDate;

  /// Optional time of the transaction.
  String? transactionTime;

  /// Optional description (max 200 chars).
  String? description;

  /// Optional notes (max 1000 chars).
  String? notes;

  /// Count of attached files (for future attachment module).
  late int attachmentCount;

  /// Optional location string.
  String? location;

  late int version;
  late DateTime createdAt;
  late DateTime updatedAt;
  DateTime? deletedAt;
  late int syncStatus;

  String? validate() {
    if (uuid.trim().isEmpty) return 'UUID is required.';
    if (ledgerId <= 0) return 'Ledger ID must be positive.';
    if (personId <= 0) return 'Person ID must be positive.';
    if (amount <= 0) return 'Amount must be greater than zero.';
    if (currencyCode.trim().isEmpty) return 'Currency code is required.';
    if (currencyCode.trim().length != 3) return 'Currency must be a 3-letter ISO code.';

    final futureLimit = DateTime.now().add(const Duration(days: 365));
    if (transactionDate.isAfter(futureLimit)) {
      return 'Transaction date cannot be more than 365 days in the future.';
    }

    if (description != null && description!.trim().length > 200) {
      return 'Description must be under 200 characters.';
    }
    if (notes != null && notes!.trim().length > 1000) {
      return 'Notes must be under 1000 characters.';
    }

    return null;
  }
}

// ---------------------------------------------------------------------------
// UUID generator (v4-style, no external dependency)
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Mappers
// ---------------------------------------------------------------------------

extension LedgerRecordMapper on LedgerRecord {
  Ledger toEntity() {
    return Ledger(
      id: id,
      uuid: uuid,
      personId: personId,
      currentBalance: currentBalance,
      openingBalance: openingBalance,
      receivableAmount: receivableAmount,
      payableAmount: payableAmount,
      lastTransactionAt: lastTransactionAt,
      status: status == PersonStatus.active
          ? LedgerStatus.active
          : (status == PersonStatus.archived ? LedgerStatus.archived : LedgerStatus.closed),
      version: version,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      syncStatus: syncStatus,
    );
  }
}

extension LedgerEntityMapper on Ledger {
  LedgerRecord toRecord() {
    final record = LedgerRecord()
      ..id = id
      ..uuid = uuid.isEmpty ? _generateUuid() : uuid
      ..personId = personId
      ..currentBalance = currentBalance
      ..openingBalance = openingBalance
      ..receivableAmount = receivableAmount
      ..payableAmount = payableAmount
      ..lastTransactionAt = lastTransactionAt
      ..status = switch (status) {
        LedgerStatus.active => PersonStatus.active,
        LedgerStatus.archived => PersonStatus.archived,
        LedgerStatus.closed => PersonStatus.active,
      }
      ..version = version
      ..createdAt = createdAt
      ..updatedAt = updatedAt
      ..deletedAt = deletedAt
      ..syncStatus = syncStatus;
    return record;
  }
}

extension LedgerEntryRecordMapper on LedgerEntryRecord {
  LedgerEntry toEntity() {
    return LedgerEntry(
      id: id,
      uuid: uuid,
      ledgerId: ledgerId,
      personId: personId,
      entryType: entryType,
      amount: amount,
      currencyCode: currencyCode,
      paymentMethodId: paymentMethodId,
      transactionDate: transactionDate,
      transactionTime: transactionTime,
      description: description,
      notes: notes,
      attachmentCount: attachmentCount,
      location: location,
      version: version,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      syncStatus: syncStatus,
    );
  }
}

extension LedgerEntryEntityMapper on LedgerEntry {
  LedgerEntryRecord toRecord() {
    final record = LedgerEntryRecord()
      ..id = id
      ..uuid = uuid.isEmpty ? _generateUuid() : uuid
      ..ledgerId = ledgerId
      ..personId = personId
      ..entryType = entryType
      ..amount = amount
      ..currencyCode = currencyCode
      ..paymentMethodId = paymentMethodId
      ..transactionDate = transactionDate
      ..transactionTime = transactionTime
      ..description = description
      ..notes = notes
      ..attachmentCount = attachmentCount
      ..location = location
      ..version = version
      ..createdAt = createdAt
      ..updatedAt = updatedAt
      ..deletedAt = deletedAt
      ..syncStatus = syncStatus;
    return record;
  }
}

// ---------------------------------------------------------------------------
// UUID generator (v4-style, no external dependency)
// ---------------------------------------------------------------------------

String _generateUuid() {
  final now = DateTime.now().microsecondsSinceEpoch;
  final r1 = (now & 0xFFFFFFFF).toRadixString(16).padLeft(8, '0');
  final r2 = ((now >> 32) & 0xFFFF).toRadixString(16).padLeft(4, '0');
  final r3 = ((now >> 48) & 0x0FFF | 0x4000).toRadixString(16).padLeft(4, '0');
  final r4 = (0x8000 | ((now >> 60) & 0x3FFF)).toRadixString(16).padLeft(4, '0');
  final r5 = (now.abs() & 0xFFFFFFFFFFFF).toRadixString(16).padLeft(12, '0');
  return '$r1-$r2-4$r3-${r4[0]}${r4.substring(1)}-$r5';
}
