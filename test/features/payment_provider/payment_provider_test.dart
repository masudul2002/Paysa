import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/features/payment_provider/domain/entities/payment_provider.dart';
import 'package:paysa/features/payment_provider/domain/services/payment_provider_registry.dart';
import 'package:paysa/features/payment_provider/domain/services/payment_provider_factory.dart';
import 'package:paysa/features/payment_provider/domain/services/default_provider_factories.dart';

void main() {
  // ====================================================================
  // Registry
  // ====================================================================

  group('PaymentProviderRegistry', () {
    test('register and get provider', () {
      final reg = PaymentProviderRegistry();
      reg.register(CashPlaceholderProvider());
      expect(reg.getProvider('cash'), isNotNull);
      expect(reg.count, 1);
    });

    test('rejects duplicate registration', () {
      final reg = PaymentProviderRegistry();
      reg.register(CashPlaceholderProvider());
      expect(() => reg.register(CashPlaceholderProvider()), throwsArgumentError);
    });

    test('unregister removes provider', () {
      final reg = PaymentProviderRegistry();
      reg.register(CashPlaceholderProvider());
      reg.unregister('cash');
      expect(reg.getProvider('cash'), isNull);
    });

    test('enable and disable', () {
      final reg = PaymentProviderRegistry();
      reg.register(CashPlaceholderProvider());
      reg.disable('cash');
      expect(reg.isEnabled('cash'), false);
      expect(reg.getProvider('cash'), isNull);
      reg.enable('cash');
      expect(reg.isEnabled('cash'), true);
      expect(reg.getProvider('cash'), isNotNull);
    });

    test('enabledProviders only returns enabled', () {
      final reg = PaymentProviderRegistry();
      reg.register(CashPlaceholderProvider());
      reg.register(BkashPlaceholderProvider());
      reg.disable('cash');
      expect(reg.enabledProviders.length, 1);
      expect(reg.enabledProviders.first.name, 'bkash');
    });

    test('registeredProviders returns all names', () {
      final reg = PaymentProviderRegistry();
      reg.register(CashPlaceholderProvider());
      reg.register(BkashPlaceholderProvider());
      expect(reg.registeredProviders.length, 2);
    });

    test('configure updates config', () {
      final reg = PaymentProviderRegistry();
      reg.register(CashPlaceholderProvider());
      reg.configure('cash', const PaymentProviderConfiguration(
        name: 'cash', displayName: 'Cash', isSandbox: false,
      ));
      final config = reg.getConfiguration('cash');
      expect(config?.isSandbox, false);
    });

    test('configure throws for unregistered', () {
      final reg = PaymentProviderRegistry();
      expect(() => reg.configure('unknown', const PaymentProviderConfiguration()), throwsArgumentError);
    });

    test('isRegistered returns correct', () {
      final reg = PaymentProviderRegistry();
      reg.register(CashPlaceholderProvider());
      expect(reg.isRegistered('cash'), true);
      expect(reg.isRegistered('unknown'), false);
    });
  });

  // ====================================================================
  // Factory
  // ====================================================================

  group('PaymentProviderFactoryRegistry', () {
    test('register and create provider', () {
      final reg = PaymentProviderFactoryRegistry();
      reg.register(CashProviderFactory());
      expect(reg.hasFactory('cash'), true);
      final provider = reg.create('cash', const PaymentProviderConfiguration());
      expect(provider.name, 'cash');
    });

    test('rejects duplicate factory', () {
      final reg = PaymentProviderFactoryRegistry();
      reg.register(CashProviderFactory());
      expect(() => reg.register(CashProviderFactory()), throwsArgumentError);
    });

    test('create throws for unknown provider', () {
      final reg = PaymentProviderFactoryRegistry();
      expect(() => reg.create('unknown', const PaymentProviderConfiguration()), throwsArgumentError);
    });

    test('supportedProviders lists all', () {
      final reg = PaymentProviderFactoryRegistry();
      reg.register(CashProviderFactory());
      reg.register(BkashProviderFactory());
      expect(reg.supportedProviders.length, 2);
    });
  });

  // ====================================================================
  // Default placeholders
  // ====================================================================

  group('Default placeholders', () {
    test('Cash placeholder has correct name and capabilities', () {
      final p = CashPlaceholderProvider();
      expect(p.name, 'cash');
      expect(p.displayName, 'Cash');
      expect(p.capabilities.refund, true);
      expect(p.capabilities.paymentLink, false);
    });

    test('bKash placeholder has payment link and QR capabilities', () {
      final p = BkashPlaceholderProvider();
      expect(p.name, 'bkash');
      expect(p.capabilities.paymentLink, true);
      expect(p.capabilities.qrPayment, true);
      expect(p.capabilities.refund, true);
      expect(p.capabilities.partialPayment, true);
      expect(p.capabilities.webhook, true);
    });

    test('all 6 default providers have unique names', () {
      final factories = [
        CashProviderFactory(), BankTransferProviderFactory(),
        BkashProviderFactory(), NagadProviderFactory(),
        RocketProviderFactory(), UpayProviderFactory(),
      ];
      final names = factories.map((f) => f.providerName).toSet();
      expect(names.length, 6);
    });

    test('createPayment succeeds with placeholder', () async {
      final p = CashPlaceholderProvider();
      final result = await p.createPayment(amountMinor: 50000, currency: 'USD', reference: 'ref1');
      expect(result.success, true);
      expect(result.transactionId, isNotNull);
    });

    test('network operations throw unimplemented', () async {
      final p = CashPlaceholderProvider();
      expect(() => p.verifyPayment('txn'), throwsA(isA<UnimplementedError>()));
      expect(() => p.cancelPayment('txn'), throwsA(isA<UnimplementedError>()));
      expect(() => p.refundPayment('txn'), throwsA(isA<UnimplementedError>()));
      expect(() => p.getPaymentStatus('txn'), throwsA(isA<UnimplementedError>()));
      expect(() => p.generateCheckoutUrl(amountMinor: 100, currency: 'USD', reference: 'r'), throwsA(isA<UnimplementedError>()));
    });
  });

  // ====================================================================
  // Capabilities
  // ====================================================================

  group('PaymentProviderCapability', () {
    test('default all false', () {
      final c = PaymentProviderCapability();
      expect(c.paymentLink, false);
      expect(c.qrPayment, false);
      expect(c.refund, false);
    });

    test('supportsCapability delegates correctly', () {
      final p = BkashPlaceholderProvider();
      expect(p.supportsCapability((c) => c.paymentLink), true);
      expect(p.supportsCapability((c) => c.recurringPayment), false);
    });
  });

  // ====================================================================
  // Configuration
  // ====================================================================

  group('PaymentProviderConfiguration', () {
    test('baseUrl returns sandbox when isSandbox', () {
      final config = const PaymentProviderConfiguration(
        sandboxUrl: 'https://sandbox.api.com',
        productionUrl: 'https://api.com',
        isSandbox: true,
      );
      expect(config.baseUrl, 'https://sandbox.api.com');
    });

    test('baseUrl returns production when not sandbox', () {
      final config = const PaymentProviderConfiguration(
        sandboxUrl: 'https://sandbox.api.com',
        productionUrl: 'https://api.com',
        isSandbox: false,
      );
      expect(config.baseUrl, 'https://api.com');
    });

    test('copyWith preserves fields', () {
      final c = const PaymentProviderConfiguration(name: 'test');
      final copy = c.copyWith(name: 'updated', isSandbox: false);
      expect(copy.name, 'updated');
      expect(copy.isSandbox, false);
    });
  });

  // ====================================================================
  // PaymentResult
  // ====================================================================

  group('PaymentResult', () {
    test('success result', () {
      final r = PaymentResult(success: true, transactionId: 'txn_123');
      expect(r.success, true);
      expect(r.transactionId, 'txn_123');
    });
  });
}
