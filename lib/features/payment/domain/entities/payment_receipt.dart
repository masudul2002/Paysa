/// Method used for a payment.
enum PaymentMethodType {
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
        PaymentMethodType.cash => 'Cash',
        PaymentMethodType.bank => 'Bank',
        PaymentMethodType.bkash => 'bKash',
        PaymentMethodType.nagad => 'Nagad',
        PaymentMethodType.rocket => 'Rocket',
        PaymentMethodType.upay => 'Upay',
        PaymentMethodType.card => 'Card',
        PaymentMethodType.qr => 'QR',
        PaymentMethodType.custom => 'Custom',
      };
}

/// A successful payment receipt.
///
/// Created only after a payment is successfully completed.
/// One PaymentRequest produces at most one PaymentReceipt
/// (full payment), or multiple if partial payments are allowed.
final class PaymentReceipt {
  const PaymentReceipt({
    this.uuid = '',
    this.receiptNumber = '',
    this.paymentRequestId = 0,
    this.payerName = '',
    this.payerPhone,
    required this.amountMinor,
    this.currencyCode = 'USD',
    this.paymentMethodType = PaymentMethodType.cash,
    this.referenceNumber,
    required this.paidAt,
    this.notes,
    this.createdAt,
  });

  final String uuid;
  final String receiptNumber;
  final int paymentRequestId;
  final String payerName;
  final String? payerPhone;
  final int amountMinor;
  final String currencyCode;
  final PaymentMethodType paymentMethodType;
  final String? referenceNumber;
  final DateTime paidAt;
  final String? notes;
  final DateTime? createdAt;

  String? validate() {
    if (uuid.trim().isEmpty) return 'UUID is required.';
    if (receiptNumber.trim().isEmpty) return 'Receipt number is required.';
    if (paymentRequestId <= 0) return 'Payment request ID is required.';
    if (payerName.trim().isEmpty) return 'Payer name is required.';
    if (amountMinor <= 0) return 'Amount must be greater than zero.';
    if (currencyCode.trim().length != 3) {
      return 'Currency must be a 3-letter ISO code.';
    }
    return null;
  }

  PaymentReceipt copyWith({
    String? uuid,
    String? receiptNumber,
    int? paymentRequestId,
    String? payerName,
    String? payerPhone,
    int? amountMinor,
    String? currencyCode,
    PaymentMethodType? paymentMethodType,
    String? referenceNumber,
    DateTime? paidAt,
    String? notes,
    DateTime? createdAt,
  }) {
    return PaymentReceipt(
      uuid: uuid ?? this.uuid,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      paymentRequestId: paymentRequestId ?? this.paymentRequestId,
      payerName: payerName ?? this.payerName,
      payerPhone: payerPhone ?? this.payerPhone,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      paymentMethodType: paymentMethodType ?? this.paymentMethodType,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      paidAt: paidAt ?? this.paidAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
