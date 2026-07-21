/// Domain events emitted during payment workflows.
///
/// Each event captures the business meaning, not the technical detail.
sealed class PaymentEvent {
  const PaymentEvent({required this.timestamp});
  final DateTime timestamp;
}

final class PaymentRequestCreatedEvent extends PaymentEvent {
  const PaymentRequestCreatedEvent({required this.requestId, required super.timestamp});
  final int requestId;
}

final class PaymentStartedEvent extends PaymentEvent {
  const PaymentStartedEvent({
    required this.requestId,
    required this.provider,
    required super.timestamp,
  });
  final int requestId;
  final String provider;
}

final class PaymentSucceededEvent extends PaymentEvent {
  const PaymentSucceededEvent({
    required this.requestId,
    required this.provider,
    required this.transactionId,
    required this.amountMinor,
    required super.timestamp,
  });
  final int requestId;
  final String provider;
  final String transactionId;
  final int amountMinor;
}

final class PaymentFailedEvent extends PaymentEvent {
  const PaymentFailedEvent({
    required this.requestId,
    required this.provider,
    required this.reason,
    required super.timestamp,
  });
  final int requestId;
  final String provider;
  final String reason;
}

final class PaymentCancelledEvent extends PaymentEvent {
  const PaymentCancelledEvent({required this.requestId, required super.timestamp});
  final int requestId;
}

final class PaymentExpiredEvent extends PaymentEvent {
  const PaymentExpiredEvent({
    required this.requestId,
    this.linkId,
    required super.timestamp,
  });
  final int requestId;
  final int? linkId;
}

final class LedgerUpdatedEvent extends PaymentEvent {
  const LedgerUpdatedEvent({
    required this.ledgerEntryId,
    required this.personId,
    required this.amountMinor,
    required super.timestamp,
  });
  final int ledgerEntryId;
  final int personId;
  final int amountMinor;
}

final class TransactionCreatedEvent extends PaymentEvent {
  const TransactionCreatedEvent({
    required this.transactionId,
    required this.amountMinor,
    required super.timestamp,
  });
  final int transactionId;
  final int amountMinor;
}

final class ReceiptRequestedEvent extends PaymentEvent {
  const ReceiptRequestedEvent({
    required this.requestId,
    required super.timestamp,
  });
  final int requestId;
}

final class RollbackPerformedEvent extends PaymentEvent {
  const RollbackPerformedEvent({
    required this.workflowName,
    required this.failedStep,
    required this.reason,
    required super.timestamp,
  });
  final String workflowName;
  final String failedStep;
  final String reason;
}
