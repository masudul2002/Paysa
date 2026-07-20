enum PersonType {
  customer,
  supplier,
  friend,
  family,
  employee,
  businessPartner,
  other;

  String get label => switch (this) {
        PersonType.customer => 'Customer',
        PersonType.supplier => 'Supplier',
        PersonType.friend => 'Friend',
        PersonType.family => 'Family',
        PersonType.employee => 'Employee',
        PersonType.businessPartner => 'Business Partner',
        PersonType.other => 'Other',
      };

  bool get isBusiness => switch (this) {
        PersonType.customer => true,
        PersonType.supplier => true,
        PersonType.businessPartner => true,
        PersonType.friend => false,
        PersonType.family => false,
        PersonType.employee => false,
        PersonType.other => false,
      };
}

enum PersonStatus {
  active,
  archived;

  String get label => switch (this) {
        PersonStatus.active => 'Active',
        PersonStatus.archived => 'Archived',
      };
}

final class Person {
  const Person({
    this.id = 0,
    this.uuid = '',
    required this.name,
    this.type = PersonType.other,
    this.phone,
    this.email,
    this.address,
    this.photoPath,
    this.notes,
    this.tags = const [],
    this.openingBalance = 0,
    this.openingBalanceDirection = OpeningBalanceDirection.none,
    this.currency = 'USD',
    this.status = PersonStatus.active,
    this.isFavorite = false,
    this.version = 1,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final int id;
  final String uuid;
  final String name;
  final PersonType type;
  final String? phone;
  final String? email;
  final String? address;
  final String? photoPath;
  final String? notes;
  final List<String> tags;
  final int openingBalance;
  final OpeningBalanceDirection openingBalanceDirection;
  final String currency;
  final PersonStatus status;
  final bool isFavorite;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isArchived => status == PersonStatus.archived;
  bool get isActive => status == PersonStatus.active;
  bool get isDeleted => deletedAt != null;

  int get currentBalance => openingBalance; // placeholder — ledger entries added later

  Person copyWith({
    int? id,
    String? uuid,
    String? name,
    PersonType? type,
    String? phone,
    String? email,
    String? address,
    String? photoPath,
    String? notes,
    List<String>? tags,
    int? openingBalance,
    OpeningBalanceDirection? openingBalanceDirection,
    String? currency,
    PersonStatus? status,
    bool? isFavorite,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Person(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      type: type ?? this.type,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      photoPath: photoPath ?? this.photoPath,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      openingBalance: openingBalance ?? this.openingBalance,
      openingBalanceDirection:
          openingBalanceDirection ?? this.openingBalanceDirection,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      isFavorite: isFavorite ?? this.isFavorite,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

enum OpeningBalanceDirection {
  none,
  give,
  receive;

  String get label => switch (this) {
        OpeningBalanceDirection.none => 'None',
        OpeningBalanceDirection.give => 'They owe me',
        OpeningBalanceDirection.receive => 'I owe them',
      };
}
