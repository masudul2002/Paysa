/// Payment provider used to process a payment session.
enum PaymentProviderType {
  cash,
  bank,
  bkash,
  nagad,
  rocket,
  upay,
  card,
  qr,
  custom;

  String get label => switch (this) {
        PaymentProviderType.cash => 'Cash',
        PaymentProviderType.bank => 'Bank',
        PaymentProviderType.bkash => 'bKash',
        PaymentProviderType.nagad => 'Nagad',
        PaymentProviderType.rocket => 'Rocket',
        PaymentProviderType.upay => 'Upay',
        PaymentProviderType.card => 'Card',
        PaymentProviderType.qr => 'QR',
        PaymentProviderType.custom => 'Custom',
      };
}

/// Status of a single payment attempt (session).
enum PaymentSessionStatus {
  initiated,
  processing,
  succeeded,
  failed,
  cancelled;

  String get label => switch (this) {
        PaymentSessionStatus.initiated => 'Initiated',
        PaymentSessionStatus.processing => 'Processing',
        PaymentSessionStatus.succeeded => 'Succeeded',
        PaymentSessionStatus.failed => 'Failed',
        PaymentSessionStatus.cancelled => 'Cancelled',
      };

  bool get isTerminal => switch (this) {
        PaymentSessionStatus.succeeded ||
        PaymentSessionStatus.failed ||
        PaymentSessionStatus.cancelled =>
            true,
        _ => false,
      };
}

/// Tracks one payment attempt for a PaymentRequest.
///
/// A PaymentRequest may have multiple sessions (e.g., retry after failure).
final class PaymentSession {
  const PaymentSession({
    this.uuid = '',
    this.paymentRequestId = 0,
    this.provider = PaymentProviderType.cash,
    this.status = PaymentSessionStatus.initiated,
    this.startedAt,
    this.completedAt,
    this.failureReason,
    this.amountMinor = 0,
    this.currencyCode = 'USD',
  });

  final String uuid;
  final int paymentRequestId;
  final PaymentProviderType provider;
  final PaymentSessionStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? failureReason;
  final int amountMinor;
  final String currencyCode;

  bool get isSuccess => status == PaymentSessionStatus.succeeded;

  String? validate() {
    if (uuid.trim().isEmpty) return 'UUID is required.';
    if (paymentRequestId <= 0) return 'Payment request ID is required.';
    if (amountMinor <= 0) return 'Amount must be greater than zero.';
    return null;
  }

  PaymentSession copyWith({
    String? uuid,
    int? paymentRequestId,
    PaymentProviderType? provider,
    PaymentSessionStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    String? failureReason,
    int? amountMinor,
    String? currencyCode,
  }) {
    return PaymentSession(
      uuid: uuid ?? this.uuid,
      paymentRequestId: paymentRequestId ?? this.paymentRequestId,
      provider: provider ?? this.provider,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      failureReason: failureReason ?? this.failureReason,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }
}
