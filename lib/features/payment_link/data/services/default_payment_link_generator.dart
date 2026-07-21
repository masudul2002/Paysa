import 'package:paysa/core/app_exception.dart';
import '../../domain/entities/payment_link.dart';
import '../../domain/services/payment_link_service.dart';
import '../repositories/payment_link_repository.dart';

/// Default generator for Paysa-hosted payment links.
///
/// This is a placeholder generator that creates generic payment links.
/// Provider-specific generators (bKash Merchant, Nagad, Stripe, etc.)
/// would implement [PaymentLinkGenerator] with their own URL/parameter logic.
final class DefaultPaymentLinkGenerator implements PaymentLinkGenerator {
  const DefaultPaymentLinkGenerator(this._repository, {this.baseUrl = 'https://pay.paysa.app'});

  final PaymentLinkRepository _repository;
  final String baseUrl;

  @override
  String get providerName => 'paysa';

  @override
  Future<PaymentLink> generate(int paymentRequestId, {Duration? expiry}) async {
    return _repository.create(paymentRequestId, providerName, expiry: expiry);
  }

  @override
  Future<PaymentLink> regenerate(PaymentLink existingLink) async {
    return _repository.regenerate(existingLink.id);
  }
}

/// Default validator for Paysa payment link tokens.
final class DefaultPaymentLinkValidator implements PaymentLinkValidator {
  const DefaultPaymentLinkValidator();

  @override
  bool validateToken(String token) {
    if (token.length < 16) return false;
    return RegExp(r'^[A-Za-z0-9]+$').hasMatch(token);
  }

  @override
  bool validateShortCode(String shortCode) {
    if (shortCode.length < 4 || shortCode.length > 16) return false;
    return RegExp(r'^[A-Za-z0-9]+$').hasMatch(shortCode);
  }

  @override
  Future<bool> verifySignature(PaymentLink link, String signature) async {
    // Future: implement HMAC signature verification
    throw UnimplementedError('Signature verification not yet implemented');
  }
}

/// Default resolver that uses the repository directly.
final class DefaultPaymentLinkResolver implements PaymentLinkResolver {
  const DefaultPaymentLinkResolver(this._repository);

  final PaymentLinkRepository _repository;

  @override
  Future<PaymentLink?> resolveByToken(String token) => _repository.getByToken(token);

  @override
  Future<PaymentLink?> resolveByShortCode(String shortCode) =>
      _repository.getByShortCode(shortCode);

  @override
  Future<bool> isPayable(String token) async {
    final link = await _repository.getByToken(token);
    if (link == null) throw AppException('Payment link not found.');
    if (!link.isActive) return false;
    return true;
  }
}
