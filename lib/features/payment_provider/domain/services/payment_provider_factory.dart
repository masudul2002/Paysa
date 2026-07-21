import '../entities/payment_provider.dart';

/// Factory contract for creating provider instances.
///
/// Each provider type has its own factory class.
/// The factory pattern avoids switch/if-else chains in core code.
abstract interface class PaymentProviderFactory {
  /// The provider name this factory creates.
  String get providerName;

  /// Create a new provider instance with the given configuration.
  PaymentProvider create(PaymentProviderConfiguration config);
}

/// Maps provider names to their factories.
///
/// New providers register their factory here at app startup.
final class PaymentProviderFactoryRegistry {
  final _factories = <String, PaymentProviderFactory>{};

  void register(PaymentProviderFactory factory) {
    if (_factories.containsKey(factory.providerName)) {
      throw ArgumentError('Factory for "${factory.providerName}" already registered.');
    }
    _factories[factory.providerName] = factory;
  }

  PaymentProviderFactory? getFactory(String providerName) => _factories[providerName];

  PaymentProvider create(String providerName, PaymentProviderConfiguration config) {
    final factory = _factories[providerName];
    if (factory == null) throw ArgumentError('No factory registered for "$providerName".');
    return factory.create(config);
  }

  bool hasFactory(String providerName) => _factories.containsKey(providerName);

  List<String> get supportedProviders => _factories.keys.toList();
}
