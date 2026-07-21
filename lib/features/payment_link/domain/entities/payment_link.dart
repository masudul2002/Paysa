import 'dart:math';
import 'dart:convert';

/// Status of a payment link in its lifecycle.
enum PaymentLinkStatus {
  draft,
  active,
  expired,
  disabled,
  resolved;

  String get label => switch (this) {
        PaymentLinkStatus.draft => 'Draft',
        PaymentLinkStatus.active => 'Active',
        PaymentLinkStatus.expired => 'Expired',
        PaymentLinkStatus.disabled => 'Disabled',
        PaymentLinkStatus.resolved => 'Resolved',
      };

  bool get isOpenable => switch (this) {
        PaymentLinkStatus.active => true,
        _ => false,
      };

  bool get isTerminal => switch (this) {
        PaymentLinkStatus.expired ||
        PaymentLinkStatus.resolved =>
            true,
        _ => false,
      };
}

/// A payment link represents a URL that can be shared with a payer
/// to complete a payment for a specific PaymentRequest.
///
/// Designed to work with any future provider (Paysa, bKash, Nagad, etc.)
/// through the Strategy pattern.
final class PaymentLink {
  const PaymentLink({
    this.id = 0,
    this.uuid = '',
    this.paymentRequestId = 0,
    this.provider = '',
    this.token = '',
    this.shortCode,
    this.url,
    this.status = PaymentLinkStatus.draft,
    this.expiresAt,
    this.resolvedAt,
    this.version = 1,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final int id;
  final String uuid;
  final int paymentRequestId;
  final String provider;
  final String token;
  final String? shortCode;
  final String? url;
  final PaymentLinkStatus status;
  final DateTime? expiresAt;
  final DateTime? resolvedAt;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());
  bool get isActive => status == PaymentLinkStatus.active && !isExpired;

  PaymentLink copyWith({
    int? id, String? uuid, int? paymentRequestId, String? provider,
    String? token, String? shortCode, String? url,
    PaymentLinkStatus? status, DateTime? expiresAt, DateTime? resolvedAt,
    int? version, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt,
  }) {
    return PaymentLink(
      id: id ?? this.id, uuid: uuid ?? this.uuid,
      paymentRequestId: paymentRequestId ?? this.paymentRequestId,
      provider: provider ?? this.provider,
      token: token ?? this.token, shortCode: shortCode ?? this.shortCode,
      url: url ?? this.url, status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

// ---------------------------------------------------------------------------
// Token generation (cryptographically secure)
// ---------------------------------------------------------------------------

/// Generates a cryptographically secure random token.
String generateSecureToken({int length = 32}) {
  final random = Random.secure();
  final bytes = List<int>.generate(length, (_) => random.nextInt(256));
  return base64Url.encode(bytes).replaceAll(RegExp(r'[^A-Za-z0-9]'), '').substring(0, length);
}

/// Generates a short code from a token (does not expose DB IDs).
String generateShortCode({int length = 8}) {
  final random = Random.secure();
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
}
