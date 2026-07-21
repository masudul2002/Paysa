/// Predefined payment method types.
enum PaymentMethodType {
  cash,
  bankAccount,
  debitCard,
  creditCard,
  bkash,
  nagad,
  rocket,
  upay,
  cheque,
  digitalWallet,
  other;

  String get label => switch (this) {
        PaymentMethodType.cash => 'Cash',
        PaymentMethodType.bankAccount => 'Bank Account',
        PaymentMethodType.debitCard => 'Debit Card',
        PaymentMethodType.creditCard => 'Credit Card',
        PaymentMethodType.bkash => 'bKash',
        PaymentMethodType.nagad => 'Nagad',
        PaymentMethodType.rocket => 'Rocket',
        PaymentMethodType.upay => 'Upay',
        PaymentMethodType.cheque => 'Cheque',
        PaymentMethodType.digitalWallet => 'Digital Wallet',
        PaymentMethodType.other => 'Other',
      };

  String get iconKey => switch (this) {
        PaymentMethodType.cash => 'cash',
        PaymentMethodType.bankAccount => 'bank',
        PaymentMethodType.debitCard => 'debit_card',
        PaymentMethodType.creditCard => 'credit_card',
        PaymentMethodType.bkash => 'bkash',
        PaymentMethodType.nagad => 'nagad',
        PaymentMethodType.rocket => 'rocket',
        PaymentMethodType.upay => 'upay',
        PaymentMethodType.cheque => 'cheque',
        PaymentMethodType.digitalWallet => 'wallet',
        PaymentMethodType.other => 'payment',
      };

  bool get isMobileWallet => switch (this) {
        PaymentMethodType.bkash ||
        PaymentMethodType.nagad ||
        PaymentMethodType.rocket ||
        PaymentMethodType.upay =>
            true,
        _ => false,
      };
}
