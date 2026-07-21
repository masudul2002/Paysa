import 'package:paysa/features/payment_method/domain/entities/payment_method.dart';
import 'package:paysa/features/payment_method/domain/entities/payment_method_type.dart';

/// System preset payment methods created on first launch.
final class PaymentMethodDefaults {
  const PaymentMethodDefaults._();

  static List<PaymentMethod> systemPresets(DateTime now) => [
        PaymentMethod(
          name: 'Cash',
          type: PaymentMethodType.cash,
          iconKey: 'cash',
          isBuiltIn: true,
          sortOrder: 0,
          capabilities: const PaymentCapability(supportsRefund: true),
          createdAt: now, updatedAt: now,
        ),
        PaymentMethod(
          name: 'Bank Account',
          type: PaymentMethodType.bankAccount,
          iconKey: 'bank',
          isBuiltIn: true,
          sortOrder: 1,
          capabilities: const PaymentCapability(
            supportsPaymentLink: true,
            supportsRefund: true,
          ),
          createdAt: now, updatedAt: now,
        ),
        PaymentMethod(
          name: 'Debit Card',
          type: PaymentMethodType.debitCard,
          iconKey: 'debit_card',
          isBuiltIn: true,
          sortOrder: 2,
          createdAt: now, updatedAt: now,
        ),
        PaymentMethod(
          name: 'Credit Card',
          type: PaymentMethodType.creditCard,
          iconKey: 'credit_card',
          isBuiltIn: true,
          sortOrder: 3,
          createdAt: now, updatedAt: now,
        ),
        PaymentMethod(
          name: 'bKash',
          type: PaymentMethodType.bkash,
          iconKey: 'bkash',
          isBuiltIn: true,
          sortOrder: 4,
          capabilities: const PaymentCapability(
            supportsPaymentLink: true,
            supportsQRCode: true,
            supportsPartialPayment: true,
            supportsRefund: true,
          ),
          createdAt: now, updatedAt: now,
        ),
        PaymentMethod(
          name: 'Nagad',
          type: PaymentMethodType.nagad,
          iconKey: 'nagad',
          isBuiltIn: true,
          sortOrder: 5,
          capabilities: const PaymentCapability(
            supportsPaymentLink: true,
            supportsQRCode: true,
            supportsPartialPayment: true,
            supportsRefund: true,
          ),
          createdAt: now, updatedAt: now,
        ),
        PaymentMethod(
          name: 'Rocket',
          type: PaymentMethodType.rocket,
          iconKey: 'rocket',
          isBuiltIn: true,
          sortOrder: 6,
          capabilities: const PaymentCapability(
            supportsPaymentLink: true,
            supportsQRCode: true,
            supportsPartialPayment: true,
            supportsRefund: true,
          ),
          createdAt: now, updatedAt: now,
        ),
        PaymentMethod(
          name: 'Upay',
          type: PaymentMethodType.upay,
          iconKey: 'upay',
          isBuiltIn: true,
          sortOrder: 7,
          capabilities: const PaymentCapability(
            supportsPaymentLink: true,
            supportsQRCode: true,
            supportsPartialPayment: true,
            supportsRefund: true,
          ),
          createdAt: now, updatedAt: now,
        ),
        PaymentMethod(
          name: 'Cheque',
          type: PaymentMethodType.cheque,
          iconKey: 'cheque',
          isBuiltIn: true,
          sortOrder: 8,
          createdAt: now, updatedAt: now,
        ),
        PaymentMethod(
          name: 'Digital Wallet',
          type: PaymentMethodType.digitalWallet,
          iconKey: 'wallet',
          isBuiltIn: true,
          sortOrder: 9,
          createdAt: now, updatedAt: now,
        ),
        PaymentMethod(
          name: 'Other',
          type: PaymentMethodType.other,
          iconKey: 'payment',
          isBuiltIn: true,
          sortOrder: 10,
          createdAt: now, updatedAt: now,
        ),
      ];
}
