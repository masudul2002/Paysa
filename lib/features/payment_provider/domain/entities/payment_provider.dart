// ---------------------------------------------------------------------------
// Capabilities
// ---------------------------------------------------------------------------

/// Capabilities a payment provider may support.
final class PaymentProviderCapability {
  const PaymentProviderCapability({
    this.paymentLink = false,
    this.qrPayment = false,
    this.refund = false,
    this.partialPayment = false,
    this.recurringPayment = false,
    this.webhook = false,
    this.sandbox = false,
    this.production = false,
  });

  final bool paymentLink;
  final bool qrPayment;
  final bool refund;
  final bool partialPayment;
  final bool recurringPayment;
  final bool webhook;
  final bool sandbox;
  final bool production;
}

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

/// Key-value configuration for a payment provider.
///
/// Each provider defines its own required keys.
/// Examples: merchantId, storeId, apiKey, apiSecret, webhookSecret, baseUrl.
final class PaymentProviderConfiguration {
  const PaymentProviderConfiguration({
    this.name = '',
    this.displayName = '',
    this.isEnabled = true,
    this.isSandbox = true,
    this.timeoutSeconds = 30,
    this.currency = 'USD',
    this.sandboxUrl = '',
    this.productionUrl = '',
    this.credentials = const {},
  });

  final String name;
  final String displayName;
  final bool isEnabled;
  final bool isSandbox;
  final int timeoutSeconds;
  final String currency;
  final String sandboxUrl;
  final String productionUrl;
  final Map<String, String> credentials;

  String get baseUrl => isSandbox ? sandboxUrl : productionUrl;

  PaymentProviderConfiguration copyWith({
    String? name, String? displayName,
    bool? isEnabled, bool? isSandbox, int? timeoutSeconds,
    String? currency, String? sandboxUrl, String? productionUrl,
    Map<String, String>? credentials,
  }) => PaymentProviderConfiguration(
    name: name ?? this.name, displayName: displayName ?? this.displayName,
    isEnabled: isEnabled ?? this.isEnabled, isSandbox: isSandbox ?? this.isSandbox,
    timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
    currency: currency ?? this.currency,
    sandboxUrl: sandboxUrl ?? this.sandboxUrl,
    productionUrl: productionUrl ?? this.productionUrl,
    credentials: credentials ?? this.credentials,
  );
}

// ---------------------------------------------------------------------------
// Payment result
// ---------------------------------------------------------------------------

/// Result of a payment operation.
final class PaymentResult {
  const PaymentResult({
    required this.success,
    this.transactionId,
    this.referenceNumber,
    this.statusUrl,
    this.errorMessage,
  });

  final bool success;
  final String? transactionId;
  final String? referenceNumber;
  final String? statusUrl;
  final String? errorMessage;
}

// ---------------------------------------------------------------------------
// Payment status
// ---------------------------------------------------------------------------

/// Status returned by a provider for a payment.
enum PaymentProviderStatus {
  initiated, processing, succeeded, failed, cancelled, refunded;

  String get label => switch (this) {
    PaymentProviderStatus.initiated => 'Initiated',
    PaymentProviderStatus.processing => 'Processing',
    PaymentProviderStatus.succeeded => 'Succeeded',
    PaymentProviderStatus.failed => 'Failed',
    PaymentProviderStatus.cancelled => 'Cancelled',
    PaymentProviderStatus.refunded => 'Refunded',
  };
}

// ---------------------------------------------------------------------------
// Provider contract
// ---------------------------------------------------------------------------

/// Every payment provider must implement this interface.
abstract interface class PaymentProvider {
  /// Unique provider name (e.g. 'bkash', 'stripe', 'cash').
  String get name;

  /// Human-readable display name.
  String get displayName;

  /// Provider's capabilities.
  PaymentProviderCapability get capabilities;

  /// Initialize the provider with configuration.
  Future<void> initialize(PaymentProviderConfiguration config);

  /// Whether the provider is available (configured and ready).
  Future<bool> isAvailable();

  /// Create a payment for the given amount (in minor units).
  Future<PaymentResult> createPayment({
    required int amountMinor,
    required String currency,
    required String reference,
    String? description,
    Map<String, String>? metadata,
  });

  /// Verify a payment by transaction ID.
  Future<PaymentResult> verifyPayment(String transactionId);

  /// Cancel a pending payment.
  Future<PaymentResult> cancelPayment(String transactionId);

  /// Refund a completed payment.
  Future<PaymentResult> refundPayment(String transactionId, {int? amountMinor});

  /// Get the current status of a payment.
  Future<PaymentProviderStatus> getPaymentStatus(String transactionId);

  /// Generate a checkout URL for redirect-based payments.
  Future<String?> generateCheckoutUrl({
    required int amountMinor,
    required String currency,
    required String reference,
    String? cancelUrl,
    String? successUrl,
  });

  /// Check if the provider supports a specific capability.
  bool supportsCapability(bool Function(PaymentProviderCapability) capability);
}
