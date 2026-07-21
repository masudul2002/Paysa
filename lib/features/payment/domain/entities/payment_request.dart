/// Types of payment requests supported by the platform.
enum PaymentRequestType {
  loanRepayment,
  generalPayment,
  donation,
  clubFee,
  support,
  invoice,
  productPurchase;

  String get label => switch (this) {
        PaymentRequestType.loanRepayment => 'Loan Repayment',
        PaymentRequestType.generalPayment => 'General Payment',
        PaymentRequestType.donation => 'Donation',
        PaymentRequestType.clubFee => 'Club Fee',
        PaymentRequestType.support => 'Support',
        PaymentRequestType.invoice => 'Invoice',
        PaymentRequestType.productPurchase => 'Product Purchase',
      };
}

/// Lifecycle status of a payment request.
enum PaymentStatus {
  draft,
  pending,
  partiallyPaid,
  paid,
  expired,
  cancelled,
  failed;

  String get label => switch (this) {
        PaymentStatus.draft => 'Draft',
        PaymentStatus.pending => 'Pending',
        PaymentStatus.partiallyPaid => 'Partially Paid',
        PaymentStatus.paid => 'Paid',
        PaymentStatus.expired => 'Expired',
        PaymentStatus.cancelled => 'Cancelled',
        PaymentStatus.failed => 'Failed',
      };

  bool get isTerminal => switch (this) {
        PaymentStatus.paid || PaymentStatus.expired ||
        PaymentStatus.cancelled || PaymentStatus.failed =>
            true,
        _ => false,
      };
}

/// A request asking someone to make a payment.
///
/// May be linked to a LedgerEntry (for loan repayments) or
/// stand-alone (for donations, club fees, product purchases).
final class PaymentRequest {
  const PaymentRequest({
    this.uuid = '',
    this.requestNumber = '',
    this.title = '',
    this.description,
    required this.requestType,
    this.personId,
    this.ledgerId,
    this.transactionId,
    required this.amountMinor,
    this.currencyCode = 'USD',
    this.status = PaymentStatus.draft,
    this.expiresAt,
    this.allowPartialPayment = false,
    this.allowOverPayment = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final String uuid;
  final String requestNumber;
  final String title;
  final String? description;
  final PaymentRequestType requestType;
  final int? personId;
  final int? ledgerId;
  final int? transactionId;
  final int amountMinor;
  final String currencyCode;
  final PaymentStatus status;
  final DateTime? expiresAt;
  final bool allowPartialPayment;
  final bool allowOverPayment;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  bool get isPayable =>
      status == PaymentStatus.draft ||
      status == PaymentStatus.pending ||
      status == PaymentStatus.partiallyPaid;

  String? validate() {
    if (uuid.trim().isEmpty) return 'UUID is required.';
    if (title.trim().isEmpty) return 'Title is required.';
    if (amountMinor <= 0) return 'Amount must be greater than zero.';
    if (currencyCode.trim().length != 3) {
      return 'Currency must be a 3-letter ISO code.';
    }
    if (requestNumber.trim().isEmpty) return 'Request number is required.';
    return null;
  }

  PaymentRequest copyWith({
    String? uuid,
    String? requestNumber,
    String? title,
    String? description,
    PaymentRequestType? requestType,
    int? personId,
    int? ledgerId,
    int? transactionId,
    int? amountMinor,
    String? currencyCode,
    PaymentStatus? status,
    DateTime? expiresAt,
    bool? allowPartialPayment,
    bool? allowOverPayment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentRequest(
      uuid: uuid ?? this.uuid,
      requestNumber: requestNumber ?? this.requestNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      requestType: requestType ?? this.requestType,
      personId: personId ?? this.personId,
      ledgerId: ledgerId ?? this.ledgerId,
      transactionId: transactionId ?? this.transactionId,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
      allowPartialPayment: allowPartialPayment ?? this.allowPartialPayment,
      allowOverPayment: allowOverPayment ?? this.allowOverPayment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
