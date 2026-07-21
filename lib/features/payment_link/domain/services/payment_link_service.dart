import '../entities/payment_link.dart';

/// Strategy interface for generating payment links for a specific provider.
///
/// Each provider (Paysa, bKash, Nagad, Stripe, etc.) implements this
/// to create provider-specific URLs, parameters, or deep links.
abstract interface class PaymentLinkGenerator {
  /// The provider name this generator handles (e.g. 'paysa', 'bkash').
  String get providerName;

  /// Generate a [PaymentLink] for the given [paymentRequestId].
  /// Returns the link entity with provider-specific [url] and [token] populated.
  Future<PaymentLink> generate(int paymentRequestId, {Duration? expiry});

  /// Regenerate an existing link (e.g. after expiry).
  Future<PaymentLink> regenerate(PaymentLink existingLink);
}

/// Strategy interface for validating a payment link's integrity.
abstract interface class PaymentLinkValidator {
  /// Returns true if the [token] is well-formed and passes integrity checks.
  bool validateToken(String token);

  /// Returns true if the [shortCode] is valid.
  bool validateShortCode(String shortCode);

  /// Verify the link's signature or HMAC (future use).
  Future<bool> verifySignature(PaymentLink link, String signature);
}

/// Strategy interface for resolving a token or short code to a [PaymentLink].
abstract interface class PaymentLinkResolver {
  /// Resolve a [token] to its [PaymentLink].
  Future<PaymentLink?> resolveByToken(String token);

  /// Resolve a [shortCode] to its [PaymentLink].
  Future<PaymentLink?> resolveByShortCode(String shortCode);

  /// Check if the link is still payable (active and not expired).
  Future<bool> isPayable(String token);
}

/// Orchestration service that coordinates link generation, validation,
/// and resolution across providers.
final class PaymentLinkService {
  const PaymentLinkService({
    required this.generators,
    required this.resolver,
    required this.validator,
    this.baseUrl = 'https://pay.paysa.app',
  });

  /// Map of provider name → generator.
  final Map<String, PaymentLinkGenerator> generators;

  /// The resolver instance.
  final PaymentLinkResolver resolver;

  /// The validator instance.
  final PaymentLinkValidator validator;

  /// Configurable base URL for Paysa-hosted links.
  final String baseUrl;

  /// Generate a link for the given [provider] and [paymentRequestId].
  Future<PaymentLink> generateLink(
    String provider,
    int paymentRequestId, {
    Duration? expiry,
  }) async {
    final generator = generators[provider];
    if (generator == null) throw ArgumentError('No generator for provider: $provider');
    return generator.generate(paymentRequestId, expiry: expiry);
  }

  /// Validate a token.
  bool isValidToken(String token) => validator.validateToken(token);

  /// Resolve a token to a payment link.
  Future<PaymentLink?> resolveToken(String token) => resolver.resolveByToken(token);

  /// Resolve a short code to a payment link.
  Future<PaymentLink?> resolveShortCode(String code) =>
      resolver.resolveByShortCode(code);

  /// Build a shareable URL for a link.
  String buildShareUrl(PaymentLink link) {
    if (link.shortCode != null) return '$baseUrl/r/${link.shortCode}';
    return '$baseUrl/pay/${link.token}';
  }
}
