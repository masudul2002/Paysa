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

enum PaymentRequestStatus {
  draft, pending, partiallyPaid, paid, expired, cancelled, failed;

  String get label => switch (this) {
    PaymentRequestStatus.draft => 'Draft',
    PaymentRequestStatus.pending => 'Pending',
    PaymentRequestStatus.partiallyPaid => 'Partially Paid',
    PaymentRequestStatus.paid => 'Paid',
    PaymentRequestStatus.expired => 'Expired',
    PaymentRequestStatus.cancelled => 'Cancelled',
    PaymentRequestStatus.failed => 'Failed',
  };

  bool get isTerminal => switch (this) {
    PaymentRequestStatus.paid || PaymentRequestStatus.expired ||
    PaymentRequestStatus.cancelled || PaymentRequestStatus.failed => true,
    _ => false,
  };

  bool get isEditable => switch (this) {
    PaymentRequestStatus.draft || PaymentRequestStatus.pending => true,
    _ => false,
  };
}

final class PaymentRequest {
  const PaymentRequest({
    this.id = 0,
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
    this.status = PaymentRequestStatus.draft,
    this.expiresAt,
    this.allowPartialPayment = false,
    this.allowOverPayment = false,
    this.createdBy,
    this.lastModifiedBy,
    this.statusChangedAt,
    this.version = 1,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncStatus = 0,
  });

  final int id;
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
  final PaymentRequestStatus status;
  final DateTime? expiresAt;
  final bool allowPartialPayment;
  final bool allowOverPayment;
  final String? createdBy;
  final String? lastModifiedBy;
  final DateTime? statusChangedAt;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int syncStatus;

  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());
  bool get isPayable => status == PaymentRequestStatus.draft || status == PaymentRequestStatus.pending || status == PaymentRequestStatus.partiallyPaid;
  bool get isDeleted => deletedAt != null;

  PaymentRequest copyWith({
    int? id, String? uuid, String? requestNumber, String? title,
    String? description, PaymentRequestType? requestType,
    int? personId, int? ledgerId, int? transactionId,
    int? amountMinor, String? currencyCode, PaymentRequestStatus? status,
    DateTime? expiresAt, bool? allowPartialPayment, bool? allowOverPayment,
    String? createdBy, String? lastModifiedBy, DateTime? statusChangedAt,
    int? version, DateTime? createdAt, DateTime? updatedAt,
    DateTime? deletedAt, int? syncStatus,
  }) {
    return PaymentRequest(
      id: id ?? this.id, uuid: uuid ?? this.uuid,
      requestNumber: requestNumber ?? this.requestNumber,
      title: title ?? this.title, description: description ?? this.description,
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
      createdBy: createdBy ?? this.createdBy,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      statusChangedAt: statusChangedAt ?? this.statusChangedAt,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
