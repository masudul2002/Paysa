/// Types of entities that can be audited.
enum AuditEntityType {
  transaction,
  paymentRequest,
  paymentLink,
  receipt,
  ledgerEntry,
  account,
  person;

  String get label => name;
}

/// Actions recorded in the audit log.
enum AuditAction {
  created,
  updated,
  deleted,
  cancelled,
  expired,
  resolved,
  paymentStarted,
  paymentSucceeded,
  paymentFailed,
  receiptIssued;

  String get label => name;
}

/// Who performed the action.
final class AuditActor {
  const AuditActor({required this.type, this.name, this.id});
  final String type; // 'system', 'user', 'provider'
  final String? name;
  final int? id;
}

/// An immutable audit entry recording a financial event.
///
/// Append-only. Soft delete is NOT allowed.
final class AuditEntry {
  const AuditEntry({
    this.id = 0,
    this.uuid = '',
    required this.entityId,
    required this.entityType,
    required this.action,
    required this.actor,
    this.description,
    this.oldValue,
    this.newValue,
    required this.occurredAt,
    this.version = 1,
    required this.createdAt,
  });

  final int id;
  final String uuid;
  final int entityId;
  final AuditEntityType entityType;
  final AuditAction action;
  final AuditActor actor;
  final String? description;
  final String? oldValue;
  final String? newValue;
  final DateTime occurredAt;
  final int version;
  final DateTime createdAt;

  AuditEntry copyWith({
    int? id, String? uuid, int? entityId, AuditEntityType? entityType,
    AuditAction? action, AuditActor? actor, String? description,
    String? oldValue, String? newValue, DateTime? occurredAt,
    int? version, DateTime? createdAt,
  }) => AuditEntry(
    id: id ?? this.id, uuid: uuid ?? this.uuid,
    entityId: entityId ?? this.entityId,
    entityType: entityType ?? this.entityType,
    action: action ?? this.action, actor: actor ?? this.actor,
    description: description ?? this.description,
    oldValue: oldValue ?? this.oldValue,
    newValue: newValue ?? this.newValue,
    occurredAt: occurredAt ?? this.occurredAt,
    version: version ?? this.version,
    createdAt: createdAt ?? this.createdAt,
  );
}
