enum ReceiptStatus { issued, voided }

/// A single line on a receipt (future: multi-line receipts).
final class ReceiptLine {
  const ReceiptLine({
    required this.description,
    required this.amountMinor,
    this.quantity = 1,
  });
  final String description;
  final int amountMinor;
  final int quantity;
  int get totalMinor => amountMinor * quantity;
}

/// A receipt represents proof of a completed financial transaction.
///
/// Immutable after issue. Receipt numbers are unique.
final class Receipt {
  const Receipt({
    this.id = 0,
    this.uuid = '',
    this.receiptNumber = '',
    this.transactionId,
    this.paymentRequestId,
    this.paymentLinkId,
    this.provider = '',
    required this.issuedAt,
    this.currencyCode = 'USD',
    required this.amountMinor,
    this.status = ReceiptStatus.issued,
    this.notes,
    this.lines = const [],
    this.metadata = const {},
    this.version = 1,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String uuid;
  final String receiptNumber;
  final String? transactionId;
  final int? paymentRequestId;
  final int? paymentLinkId;
  final String provider;
  final DateTime issuedAt;
  final String currencyCode;
  final int amountMinor;
  final ReceiptStatus status;
  final String? notes;
  final List<ReceiptLine> lines;
  final Map<String, String> metadata;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isIssued => status == ReceiptStatus.issued;
  bool get isVoided => status == ReceiptStatus.voided;

  Receipt copyWith({
    int? id, String? uuid, String? receiptNumber,
    String? transactionId, int? paymentRequestId, int? paymentLinkId,
    String? provider, DateTime? issuedAt, String? currencyCode,
    int? amountMinor, ReceiptStatus? status, String? notes,
    List<ReceiptLine>? lines, Map<String, String>? metadata,
    int? version, DateTime? createdAt, DateTime? updatedAt,
  }) => Receipt(
    id: id ?? this.id, uuid: uuid ?? this.uuid,
    receiptNumber: receiptNumber ?? this.receiptNumber,
    transactionId: transactionId ?? this.transactionId,
    paymentRequestId: paymentRequestId ?? this.paymentRequestId,
    paymentLinkId: paymentLinkId ?? this.paymentLinkId,
    provider: provider ?? this.provider,
    issuedAt: issuedAt ?? this.issuedAt,
    currencyCode: currencyCode ?? this.currencyCode,
    amountMinor: amountMinor ?? this.amountMinor,
    status: status ?? this.status, notes: notes ?? this.notes,
    lines: lines ?? this.lines, metadata: metadata ?? this.metadata,
    version: version ?? this.version,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
