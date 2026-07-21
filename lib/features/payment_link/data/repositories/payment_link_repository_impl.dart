import 'package:paysa/core/app_exception.dart';
import '../../domain/entities/payment_link.dart';
import '../datasources/payment_link_local_datasource.dart';
import '../models/payment_link_record.dart';
import 'payment_link_repository.dart';

final class PaymentLinkRepositoryImpl implements PaymentLinkRepository {
  PaymentLinkRepositoryImpl(this._ds);

  final PaymentLinkLocalDataSource _ds;

  @override
  Future<PaymentLink> create(int paymentRequestId, String provider, {Duration? expiry}) async {
    final now = DateTime.now();
    final token = generateSecureToken();
    final shortCode = generateShortCode();

    // Deactivate any existing active link for this provider + request
    final existing = await _ds.getByPaymentRequest(paymentRequestId);
    for (final e in existing) {
      if (e.provider == provider && e.status == PaymentLinkStatus.active) {
        e.status = PaymentLinkStatus.disabled;
        await _ds.put(e);
      }
    }

    final link = PaymentLink(
      paymentRequestId: paymentRequestId,
      provider: provider,
      token: token,
      shortCode: shortCode,
      status: PaymentLinkStatus.active,
      expiresAt: expiry != null ? now.add(expiry) : now.add(const Duration(days: 30)),
      createdAt: now,
      updatedAt: now,
    );

    final saved = await _ds.put(link.toRecord());
    return saved.toEntity();
  }

  @override
  Future<PaymentLink> activate(int id) async {
    final r = await _ds.getById(id);
    if (r == null) throw AppException('Link not found.');
    r.status = PaymentLinkStatus.active;
    r.updatedAt = DateTime.now();
    return (await _ds.put(r)).toEntity();
  }

  @override
  Future<void> deactivate(int id) async {
    final r = await _ds.getById(id);
    if (r == null) throw AppException('Link not found.');
    r.status = PaymentLinkStatus.disabled;
    r.updatedAt = DateTime.now();
    await _ds.put(r);
  }

  @override
  Future<void> expire(int id) async {
    final r = await _ds.getById(id);
    if (r == null) throw AppException('Link not found.');
    if (r.status == PaymentLinkStatus.resolved) {
      throw AppException('Cannot expire a resolved link.');
    }
    r.status = PaymentLinkStatus.expired;
    r.updatedAt = DateTime.now();
    await _ds.put(r);
  }

  @override
  Future<void> resolve(int id) async {
    final r = await _ds.getById(id);
    if (r == null) throw AppException('Link not found.');
    r.status = PaymentLinkStatus.resolved;
    r.resolvedAt = DateTime.now();
    r.updatedAt = DateTime.now();
    await _ds.put(r);
  }

  @override
  Future<PaymentLink> regenerate(int id, {Duration? expiry}) async {
    final r = await _ds.getById(id);
    if (r == null) throw AppException('Link not found.');
    final now = DateTime.now();
    r.token = generateSecureToken();
    r.shortCode = generateShortCode();
    r.status = PaymentLinkStatus.active;
    r.expiresAt = expiry != null ? now.add(expiry) : now.add(const Duration(days: 30));
    r.updatedAt = now;
    return (await _ds.put(r)).toEntity();
  }

  @override
  Future<PaymentLink?> getByToken(String token) async {
    final r = await _ds.getByToken(token);
    return r?.toEntity();
  }

  @override
  Future<PaymentLink?> getByShortCode(String code) async {
    final r = await _ds.getByShortCode(code);
    return r?.toEntity();
  }

  @override
  Future<List<PaymentLink>> getByPaymentRequest(int paymentRequestId) async {
    final records = await _ds.getByPaymentRequest(paymentRequestId);
    return records.map((r) => r.toEntity()).toList();
  }

  @override
  Future<List<PaymentLink>> getActiveLinks(int paymentRequestId) async {
    final records = await _ds.getByPaymentRequest(paymentRequestId);
    return records
        .where((r) => r.status == PaymentLinkStatus.active && (r.expiresAt == null || r.expiresAt!.isAfter(DateTime.now())))
        .map((r) => r.toEntity())
        .toList();
  }

  @override
  Future<List<PaymentLink>> getAll() async {
    final records = await _ds.getAll();
    return records.where((r) => r.deletedAt == null).map((r) => r.toEntity()).toList();
  }

  @override
  Stream<List<PaymentLink>> watchAll() {
    return _ds.watchAll().map((records) {
      return records.where((r) => r.deletedAt == null).map((r) => r.toEntity()).toList();
    });
  }
}
