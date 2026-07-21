import '../entities/payment_provider.dart';

/// Registry of all available payment providers.
///
/// Providers are registered by name. No duplicates allowed.
/// The registry supports enable/disable and provides lookup.
final class PaymentProviderRegistry {
  final _providers = <String, _ProviderEntry>{};

  /// Register a provider with optional configuration.
  /// Throws if a provider with the same [name] is already registered.
  void register(
    PaymentProvider provider, {
    PaymentProviderConfiguration? config,
  }) {
    if (_providers.containsKey(provider.name)) {
      throw ArgumentError('Provider "${provider.name}" is already registered.');
    }
    _providers[provider.name] = _ProviderEntry(provider: provider, config: config);
  }

  /// Unregister a provider by name.
  void unregister(String name) {
    _providers.remove(name);
  }

  /// Get a registered provider by name. Returns null if not found.
  PaymentProvider? getProvider(String name) {
    final entry = _providers[name];
    if (entry == null || entry.disabled) return null;
    return entry.provider;
  }

  /// Get configuration for a provider.
  PaymentProviderConfiguration? getConfiguration(String name) {
    return _providers[name]?.config;
  }

  /// Update configuration for a provider.
  void configure(String name, PaymentProviderConfiguration config) {
    if (!_providers.containsKey(name)) {
      throw ArgumentError('Provider "$name" is not registered.');
    }
    _providers[name] = _providers[name]!.copyWith(config: config);
  }

  /// Enable a provider.
  void enable(String name) {
    final entry = _providers[name];
    if (entry == null) throw ArgumentError('Provider "$name" not found.');
    _providers[name] = entry.copyWith(disabled: false);
  }

  /// Disable a provider.
  void disable(String name) {
    final entry = _providers[name];
    if (entry == null) throw ArgumentError('Provider "$name" not found.');
    _providers[name] = entry.copyWith(disabled: true);
  }

  /// List all registered provider names (including disabled).
  List<String> get registeredProviders => _providers.keys.toList();

  /// List only enabled providers.
  List<PaymentProvider> get enabledProviders =>
      _providers.values
          .where((e) => !e.disabled)
          .map((e) => e.provider)
          .toList();

  /// List all providers (including disabled).
  List<PaymentProvider> get allProviders =>
      _providers.values.map((e) => e.provider).toList();

  /// Check if a provider is registered.
  bool isRegistered(String name) => _providers.containsKey(name);

  /// Check if a provider is enabled.
  bool isEnabled(String name) {
    final entry = _providers[name];
    return entry != null && !entry.disabled;
  }

  /// Count of registered providers.
  int get count => _providers.length;
}

/// Internal registry entry.
final class _ProviderEntry {
  const _ProviderEntry({
    required this.provider,
    this.config,
    this.disabled = false,
  });

  final PaymentProvider provider;
  final PaymentProviderConfiguration? config;
  final bool disabled;

  _ProviderEntry copyWith({
    PaymentProvider? provider,
    PaymentProviderConfiguration? config,
    bool? disabled,
  }) => _ProviderEntry(
    provider: provider ?? this.provider,
    config: config ?? this.config,
    disabled: disabled ?? this.disabled,
  );
}
