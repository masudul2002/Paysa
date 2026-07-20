/// Status of a ledger record.
enum LedgerStatus {
  active,
  archived,
  closed,
}

/// Entry types for ledger transactions.
enum LedgerEntryType {
  opening,
  give,
  receive,
  borrow,
  repayment,
  adjustment,
  discount,
  sale,
  purchase,
  manual;

  String get label => switch (this) {
        LedgerEntryType.opening => 'Opening Balance',
        LedgerEntryType.give => 'Give',
        LedgerEntryType.receive => 'Receive',
        LedgerEntryType.borrow => 'Borrow',
        LedgerEntryType.repayment => 'Repayment',
        LedgerEntryType.adjustment => 'Adjustment',
        LedgerEntryType.discount => 'Discount',
        LedgerEntryType.sale => 'Sale',
        LedgerEntryType.purchase => 'Purchase',
        LedgerEntryType.manual => 'Manual Entry',
      };

  bool get isIncoming => switch (this) {
        LedgerEntryType.receive || LedgerEntryType.repayment => true,
        _ => false,
      };

  bool get isOutgoing => switch (this) {
        LedgerEntryType.give || LedgerEntryType.borrow ||
        LedgerEntryType.sale || LedgerEntryType.purchase =>
            true,
        _ => false,
      };
}

/// A ledger is a financial relationship with one person.
final class Ledger {
  const Ledger({
    this.id = 0,
    this.uuid = '',
    required this.personId,
    this.currentBalance = 0,
    this.openingBalance = 0,
    this.receivableAmount = 0,
    this.payableAmount = 0,
    this.lastTransactionAt,
    this.status = LedgerStatus.active,
    this.version = 1,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncStatus = 0,
  });

  final int id;
  final String uuid;
  final int personId;
  final int currentBalance;
  final int openingBalance;
  final int receivableAmount;
  final int payableAmount;
  final DateTime? lastTransactionAt;
  final LedgerStatus status;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int syncStatus;

  bool get isActive => status == LedgerStatus.active;
  bool get isDeleted => deletedAt != null;

  Ledger copyWith({
    int? id,
    String? uuid,
    int? personId,
    int? currentBalance,
    int? openingBalance,
    int? receivableAmount,
    int? payableAmount,
    DateTime? lastTransactionAt,
    LedgerStatus? status,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    int? syncStatus,
  }) {
    return Ledger(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      personId: personId ?? this.personId,
      currentBalance: currentBalance ?? this.currentBalance,
      openingBalance: openingBalance ?? this.openingBalance,
      receivableAmount: receivableAmount ?? this.receivableAmount,
      payableAmount: payableAmount ?? this.payableAmount,
      lastTransactionAt: lastTransactionAt ?? this.lastTransactionAt,
      status: status ?? this.status,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}

/// A single movement in a ledger.
final class LedgerEntry {
  const LedgerEntry({
    this.id = 0,
    this.uuid = '',
    required this.ledgerId,
    required this.personId,
    required this.entryType,
    required this.amount,
    this.currencyCode = 'USD',
    this.paymentMethodId,
    required this.transactionDate,
    this.transactionTime,
    this.description,
    this.notes,
    this.attachmentCount = 0,
    this.location,
    this.version = 1,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncStatus = 0,
  });

  final int id;
  final String uuid;
  final int ledgerId;
  final int personId;
  final LedgerEntryType entryType;
  final int amount;
  final String currencyCode;
  final int? paymentMethodId;
  final DateTime transactionDate;
  final String? transactionTime;
  final String? description;
  final String? notes;
  final int attachmentCount;
  final String? location;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int syncStatus;

  bool get isDeleted => deletedAt != null;

  LedgerEntry copyWith({
    int? id,
    String? uuid,
    int? ledgerId,
    int? personId,
    LedgerEntryType? entryType,
    int? amount,
    String? currencyCode,
    int? paymentMethodId,
    DateTime? transactionDate,
    String? transactionTime,
    String? description,
    String? notes,
    int? attachmentCount,
    String? location,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    int? syncStatus,
  }) {
    return LedgerEntry(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      ledgerId: ledgerId ?? this.ledgerId,
      personId: personId ?? this.personId,
      entryType: entryType ?? this.entryType,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      transactionDate: transactionDate ?? this.transactionDate,
      transactionTime: transactionTime ?? this.transactionTime,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      attachmentCount: attachmentCount ?? this.attachmentCount,
      location: location ?? this.location,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}

/// Computed balance for a ledger.
final class LedgerBalance {
  const LedgerBalance({
    required this.currentBalance,
    required this.receivableAmount,
    required this.payableAmount,
    required this.openingBalance,
    required this.entryCount,
    required this.lastEntryDate,
  });

  final int currentBalance;
  final int receivableAmount;
  final int payableAmount;
  final int openingBalance;
  final int entryCount;
  final DateTime? lastEntryDate;
}
