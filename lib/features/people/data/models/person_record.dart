import 'package:isar/isar.dart';

import '../../domain/entities/person.dart';

part 'person_record.g.dart';

/// Sync status for future cloud sync.
/// Stored as int in Isar.
enum SyncStatus {
  /// Record has not been synced yet.
  pending(0),

  /// Record has been synced successfully.
  synced(1),

  /// Record has been modified locally after last sync.
  modified(2),

  /// Record has been deleted locally and needs sync.
  deleted(3),

  /// Sync failed after retries.
  failed(4);

  const SyncStatus(this.value);

  final int value;

  static SyncStatus fromValue(int value) {
    return SyncStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => SyncStatus.pending,
    );
  }
}

@Collection(inheritance: false)
class PersonRecord {
  PersonRecord();

  /// Local auto-increment identifier.
  Id id = Isar.autoIncrement;

  /// Universal unique identifier for future sync.
  @Index(type: IndexType.value)
  late String uuid;

  /// Person's full name. Unique case-insensitive index.
  @Index(unique: true, caseSensitive: false)
  late String name;

  /// Phone number.
  @Index(type: IndexType.value, caseSensitive: false)
  String? phone;

  /// Email address.
  String? email;

  /// Physical address.
  String? address;

  /// Local file path to person's photo.
  String? photoPath;

  /// Person type: Customer, Supplier, Friend, Family, Employee, Other.
  @Enumerated(EnumType.name)
  late PersonType personType;

  /// Opening balance in minor currency units (cents/paisa).
  late int openingBalance;

  /// Opening balance direction.
  @Enumerated(EnumType.name)
  late OpeningBalanceDirection openingBalanceDirection;

  /// Current balance in minor currency units.
  /// This is a placeholder — in future, balance will be computed from ledger entries.
  late int currentBalance;

  /// ISO 4217 currency code (e.g., "USD", "BDT").
  late String currencyCode;

  /// Free-text notes about this person.
  String? notes;

  /// Whether this person is marked as favorite.
  late bool favorite;

  /// Whether this person is active.
  late bool active;

  /// Record creation timestamp.
  late DateTime createdAt;

  /// Record last-updated timestamp.
  late DateTime updatedAt;

  /// Soft-delete timestamp. Null means not deleted.
  DateTime? deletedAt;

  /// Sync status for future cloud sync: 0=pending, 1=synced, 2=modified, 3=deleted, 4=failed.
  late int syncStatus;

  /// Optimistic concurrency version. Incremented on every mutation.
  late int version;

  /// Validate required fields. Returns null if valid, error message if invalid.
  String? validate() {
    if (name.trim().isEmpty) return 'Name is required.';
    if (name.trim().length > 100) return 'Name must be under 100 characters.';
    if (openingBalance < 0) return 'Opening balance cannot be negative.';
    if (openingBalance > 0 &&
        openingBalanceDirection == OpeningBalanceDirection.none) {
      return 'Opening balance direction must be set when balance is non-zero.';
    }
    if (currencyCode.trim().isEmpty) return 'Currency code is required.';
    if (phone != null && phone!.trim().isEmpty) return 'Phone cannot be empty.';
    if (email != null && email!.trim().isNotEmpty) {
      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
      if (!emailRegex.hasMatch(email!.trim())) return 'Invalid email format.';
    }
    return null;
  }
}

// ---------------------------------------------------------------------------
// Mappers
// ---------------------------------------------------------------------------

extension PersonRecordMapper on PersonRecord {
  Person toEntity() {
    return Person(
      id: id,
      uuid: uuid,
      name: name,
      type: personType,
      phone: phone,
      email: email,
      address: address,
      photoPath: photoPath,
      notes: notes,
      openingBalance: openingBalance,
      openingBalanceDirection: openingBalanceDirection,
      currency: currencyCode,
      status: active ? PersonStatus.active : PersonStatus.archived,
      isFavorite: favorite,
      version: version,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }
}

extension PersonEntityMapper on Person {
  PersonRecord toRecord() {
    final record = PersonRecord()
      ..id = id
      ..uuid = uuid.isEmpty ? _generateUuid() : uuid
      ..name = name.trim()
      ..personType = type
      ..phone = phone?.trim().isEmpty == true ? null : phone?.trim()
      ..email = email?.trim().isEmpty == true ? null : email?.trim()
      ..address = address?.trim().isEmpty == true ? null : address?.trim()
      ..photoPath = photoPath
      ..notes = notes?.trim().isEmpty == true ? null : notes?.trim()
      ..openingBalance = openingBalance
      ..openingBalanceDirection = openingBalanceDirection
      ..currentBalance = openingBalance
      ..currencyCode = currency.trim().toUpperCase()
      ..favorite = isFavorite
      ..active = status == PersonStatus.active
      ..version = version
      ..syncStatus = SyncStatus.pending.value
      ..createdAt = createdAt
      ..updatedAt = updatedAt
      ..deletedAt = deletedAt;
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
