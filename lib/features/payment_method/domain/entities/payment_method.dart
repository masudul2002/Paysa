import 'payment_method_type.dart';

/// Capabilities a payment method supports.
final class PaymentCapability {
  const PaymentCapability({
    this.supportsPaymentLink = false,
    this.supportsQRCode = false,
    this.supportsPartialPayment = false,
    this.supportsRefund = false,
  });

  final bool supportsPaymentLink;
  final bool supportsQRCode;
  final bool supportsPartialPayment;
  final bool supportsRefund;
}

/// A payment method represents how a user transacts.
///
/// Can be built-in (system preset) or user-defined (custom).
/// Built-in methods cannot be permanently deleted.
final class PaymentMethod {
  const PaymentMethod({
    this.id = 0,
    this.uuid = '',
    this.name = '',
    this.type = PaymentMethodType.other,
    this.description,
    this.iconKey,
    this.colorValue,
    this.linkedAccountId,
    this.isBuiltIn = false,
    this.isEnabled = true,
    this.isFavorite = false,
    this.capabilities = const PaymentCapability(),
    this.sortOrder = 0,
    this.version = 1,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncStatus = 0,
  });

  final int id;
  final String uuid;
  final String name;
  final PaymentMethodType type;
  final String? description;
  final String? iconKey;
  final int? colorValue;
  final int? linkedAccountId;
  final bool isBuiltIn;
  final bool isEnabled;
  final bool isFavorite;
  final PaymentCapability capabilities;
  final int sortOrder;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int syncStatus;

  bool get isActive => isEnabled && deletedAt == null;
  bool get isDeleted => deletedAt != null;

  String? validate() {
    if (name.trim().isEmpty) return 'Name is required.';
    if (name.trim().length > 50) return 'Name must be under 50 characters.';
    return null;
  }

  PaymentMethod copyWith({
    int? id, String? uuid, String? name, PaymentMethodType? type,
    String? description, String? iconKey, int? colorValue,
    int? linkedAccountId, bool? isBuiltIn, bool? isEnabled, bool? isFavorite,
    PaymentCapability? capabilities, int? sortOrder, int? version,
    DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt, int? syncStatus,
  }) {
    return PaymentMethod(
      id: id ?? this.id, uuid: uuid ?? this.uuid,
      name: name ?? this.name, type: type ?? this.type,
      description: description ?? this.description,
      iconKey: iconKey ?? this.iconKey,
      colorValue: colorValue ?? this.colorValue,
      linkedAccountId: linkedAccountId ?? this.linkedAccountId,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      isEnabled: isEnabled ?? this.isEnabled,
      isFavorite: isFavorite ?? this.isFavorite,
      capabilities: capabilities ?? this.capabilities,
      sortOrder: sortOrder ?? this.sortOrder,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
