import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/payment_provider.dart';
import '../../domain/services/payment_provider_factory.dart';
import '../../domain/services/payment_provider_registry.dart';
import '../../domain/services/default_provider_factories.dart';

final paymentProviderRegistryProvider = Provider<PaymentProviderRegistry>((ref) {
  final registry = PaymentProviderRegistry();
  // Register default providers
  for (final factory in _defaultFactories) {
    registry.register(factory.create(PaymentProviderConfiguration(
      name: factory.providerName,
      displayName: factory.providerName,
      isSandbox: true,
    )));
  }
  return registry;
});

final paymentProviderFactoryRegistryProvider = Provider<PaymentProviderFactoryRegistry>((ref) {
  final registry = PaymentProviderFactoryRegistry();
  for (final factory in _defaultFactories) {
    registry.register(factory);
  }
  return registry;
});

final enabledPaymentProvidersProvider = Provider<List<PaymentProvider>>((ref) {
  return ref.watch(paymentProviderRegistryProvider).enabledProviders;
});

final paymentProviderByNameProvider = Provider.family<PaymentProvider?, String>((ref, name) {
  return ref.watch(paymentProviderRegistryProvider).getProvider(name);
});

final _defaultFactories = <PaymentProviderFactory>[
  CashProviderFactory(),
  BankTransferProviderFactory(),
  BkashProviderFactory(),
  NagadProviderFactory(),
  RocketProviderFactory(),
  UpayProviderFactory(),
];
