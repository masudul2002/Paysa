import 'dart:math';
import '../entities/payment_provider.dart';
import 'payment_provider_factory.dart';

/// Base class for placeholder providers.
/// Network operations throw [UnimplementedError].
abstract class _BasePlaceholderProvider implements PaymentProvider {
  @override
  late final String name;

  @override
  late final String displayName;

  @override
  late final PaymentProviderCapability capabilities;

  @override
  bool supportsCapability(bool Function(PaymentProviderCapability) fn) => fn(capabilities);

  @override
  Future<void> initialize(PaymentProviderConfiguration config) async {}

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<PaymentResult> createPayment({
    required int amountMinor, required String currency,
    required String reference, String? description,
    Map<String, String>? metadata,
  }) async {
    return PaymentResult(
      success: true,
      transactionId: 'txn_${Random().nextInt(1000000)}',
      referenceNumber: reference,
    );
  }

  @override
  Future<PaymentResult> verifyPayment(String transactionId) async {
    throw UnimplementedError('${displayName} verifyPayment — provider integration pending');
  }

  @override
  Future<PaymentResult> cancelPayment(String transactionId) async {
    throw UnimplementedError('${displayName} cancelPayment — provider integration pending');
  }

  @override
  Future<PaymentResult> refundPayment(String transactionId, {int? amountMinor}) async {
    throw UnimplementedError('${displayName} refundPayment — provider integration pending');
  }

  @override
  Future<PaymentProviderStatus> getPaymentStatus(String transactionId) async {
    throw UnimplementedError('${displayName} getPaymentStatus — provider integration pending');
  }

  @override
  Future<String?> generateCheckoutUrl({
    required int amountMinor, required String currency,
    required String reference, String? cancelUrl, String? successUrl,
  }) async {
    throw UnimplementedError('${displayName} generateCheckoutUrl — provider integration pending');
  }
}

final class CashPlaceholderProvider extends _BasePlaceholderProvider {
  CashPlaceholderProvider() {
    name = 'cash'; displayName = 'Cash';
    capabilities = const PaymentProviderCapability(refund: true, production: true);
  }
}

final class BankTransferPlaceholderProvider extends _BasePlaceholderProvider {
  BankTransferPlaceholderProvider() {
    name = 'bank_transfer'; displayName = 'Bank Transfer';
    capabilities = const PaymentProviderCapability(
      paymentLink: true, refund: true, sandbox: true, production: true,
    );
  }
}

final class BkashPlaceholderProvider extends _BasePlaceholderProvider {
  BkashPlaceholderProvider() {
    name = 'bkash'; displayName = 'bKash';
    capabilities = const PaymentProviderCapability(
      paymentLink: true, qrPayment: true, refund: true,
      partialPayment: true, webhook: true, sandbox: true, production: true,
    );
  }
}

final class NagadPlaceholderProvider extends _BasePlaceholderProvider {
  NagadPlaceholderProvider() {
    name = 'nagad'; displayName = 'Nagad';
    capabilities = const PaymentProviderCapability(
      paymentLink: true, qrPayment: true, refund: true,
      partialPayment: true, webhook: true, sandbox: true, production: true,
    );
  }
}

final class RocketPlaceholderProvider extends _BasePlaceholderProvider {
  RocketPlaceholderProvider() {
    name = 'rocket'; displayName = 'Rocket';
    capabilities = const PaymentProviderCapability(
      paymentLink: true, qrPayment: true, refund: true,
      partialPayment: true, webhook: true, sandbox: true, production: true,
    );
  }
}

final class UpayPlaceholderProvider extends _BasePlaceholderProvider {
  UpayPlaceholderProvider() {
    name = 'upay'; displayName = 'Upay';
    capabilities = const PaymentProviderCapability(
      paymentLink: true, refund: true,
      partialPayment: true, webhook: true, sandbox: true, production: true,
    );
  }
}

// ---------------------------------------------------------------------------
// Factories
// ---------------------------------------------------------------------------

final class CashProviderFactory implements PaymentProviderFactory {
  @override String get providerName => 'cash';
  @override PaymentProvider create(PaymentProviderConfiguration config) => CashPlaceholderProvider();
}

final class BankTransferProviderFactory implements PaymentProviderFactory {
  @override String get providerName => 'bank_transfer';
  @override PaymentProvider create(PaymentProviderConfiguration config) => BankTransferPlaceholderProvider();
}

final class BkashProviderFactory implements PaymentProviderFactory {
  @override String get providerName => 'bkash';
  @override PaymentProvider create(PaymentProviderConfiguration config) => BkashPlaceholderProvider();
}

final class NagadProviderFactory implements PaymentProviderFactory {
  @override String get providerName => 'nagad';
  @override PaymentProvider create(PaymentProviderConfiguration config) => NagadPlaceholderProvider();
}

final class RocketProviderFactory implements PaymentProviderFactory {
  @override String get providerName => 'rocket';
  @override PaymentProvider create(PaymentProviderConfiguration config) => RocketPlaceholderProvider();
}

final class UpayProviderFactory implements PaymentProviderFactory {
  @override String get providerName => 'upay';
  @override PaymentProvider create(PaymentProviderConfiguration config) => UpayPlaceholderProvider();
}
