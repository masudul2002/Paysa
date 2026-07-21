final class PaymentSession {
  const PaymentSession({
    this.id = 0,
    this.uuid = '',
    this.paymentRequestId = 0,
    this.provider = '',
    this.status = PaymentSessionStatus.initiated,
    this.amountMinor = 0,
    this.currencyCode = 'USD',
    this.startedAt,
    this.completedAt,
    this.failureReason,
    this.referenceNumber,
    this.version = 1,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String uuid;
  final int paymentRequestId;
  final String provider;
  final PaymentSessionStatus status;
  final int amountMinor;
  final String currencyCode;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? failureReason;
  final String? referenceNumber;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isSuccess => status == PaymentSessionStatus.succeeded;
}

enum PaymentSessionStatus {
  initiated, processing, succeeded, failed, cancelled;

  String get label => switch (this) {
    PaymentSessionStatus.initiated => 'Initiated',
    PaymentSessionStatus.processing => 'Processing',
    PaymentSessionStatus.succeeded => 'Succeeded',
    PaymentSessionStatus.failed => 'Failed',
    PaymentSessionStatus.cancelled => 'Cancelled',
  };

  bool get isTerminal => switch (this) {
    PaymentSessionStatus.succeeded || PaymentSessionStatus.failed ||
    PaymentSessionStatus.cancelled => true,
    _ => false,
  };
}
