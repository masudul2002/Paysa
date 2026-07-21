import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/core/app_exception.dart';
import 'package:paysa/features/payment_link/data/datasources/payment_link_local_datasource.dart';
import 'package:paysa/features/payment_link/data/models/payment_link_record.dart';
import 'package:paysa/features/payment_link/data/repositories/payment_link_repository_impl.dart';
import 'package:paysa/features/payment_link/data/services/default_payment_link_generator.dart';
import 'package:paysa/features/payment_link/domain/entities/payment_link.dart';
import 'package:paysa/features/payment_link/domain/services/payment_link_service.dart';

final class InMemoryPaymentLinkDS implements PaymentLinkLocalDataSource {
  final _records = <int, PaymentLinkRecord>{};
  int _nextId = 1;

  @override Future<PaymentLinkRecord> put(PaymentLinkRecord r) async {
    if (r.id == 0) r.id = _nextId++;
    if (r.uuid.isEmpty) r.uuid = 'pl-${r.id}';
    _records[r.id] = r;
    return r;
  }

  @override Future<PaymentLinkRecord?> getById(int id) async => _records[id];
  @override Future<PaymentLinkRecord?> getByToken(String t) async {
    for (final r in _records.values) { if (r.token == t && r.deletedAt == null) return r; }
    return null;
  }
  @override Future<PaymentLinkRecord?> getByShortCode(String c) async {
    for (final r in _records.values) { if (r.shortCode == c && r.deletedAt == null) return r; }
    return null;
  }
  @override Future<List<PaymentLinkRecord>> getByPaymentRequest(int pid) async {
    return _records.values.where((r) => r.paymentRequestId == pid && r.deletedAt == null).toList();
  }
  @override Future<List<PaymentLinkRecord>> getAll() async => _records.values.toList();
  @override Stream<List<PaymentLinkRecord>> watchAll() async* { yield _records.values.toList(); }
  @override Future<void> delete(int id) async { _records.remove(id); }
}

void main() {
  late PaymentLinkRepositoryImpl repo;

  setUp(() { repo = PaymentLinkRepositoryImpl(InMemoryPaymentLinkDS()); });

  group('create', () {
    test('creates an active link with token and shortCode', () async {
      final link = await repo.create(1, 'paysa');
      expect(link.id, greaterThan(0));
      expect(link.token.length, 32);
      expect(link.shortCode?.length, 8);
      expect(link.status, PaymentLinkStatus.active);
      expect(link.expiresAt, isNotNull);
    });
  });

  group('deactivate / activate / expire / resolve', () {
    test('deactivate sets disabled', () async {
      final l = await repo.create(1, 'paysa');
      await repo.deactivate(l.id);
      expect((await repo.getByToken(l.token))?.status, PaymentLinkStatus.disabled);
    });

    test('expire after deactivate', () async {
      final l = await repo.create(1, 'paysa');
      await repo.deactivate(l.id);
      await repo.expire(l.id);
      expect((await repo.getByToken(l.token))?.status, PaymentLinkStatus.expired);
    });

    test('resolve sets resolved and resolvedAt', () async {
      final l = await repo.create(1, 'paysa');
      await repo.resolve(l.id);
      final updated = await repo.getByToken(l.token);
      expect(updated?.status, PaymentLinkStatus.resolved);
      expect(updated?.resolvedAt, isNotNull);
    });

    test('cannot expire resolved link', () async {
      final l = await repo.create(1, 'paysa');
      await repo.resolve(l.id);
      expect(() => repo.expire(l.id), throwsA(isA<AppException>()));
    });
  });

  group('regenerate', () {
    test('creates new token and keeps active', () async {
      final l = await repo.create(1, 'paysa');
      final oldToken = l.token;
      final regenerated = await repo.regenerate(l.id);
      expect(regenerated.token, isNot(oldToken));
      expect(regenerated.status, PaymentLinkStatus.active);
    });
  });

  group('only one active per provider per request', () {
    test('second create deactivates first', () async {
      final l1 = await repo.create(1, 'paysa');
      final l2 = await repo.create(1, 'paysa');
      expect((await repo.getByToken(l1.token))?.status, PaymentLinkStatus.disabled);
      expect((await repo.getByToken(l2.token))?.status, PaymentLinkStatus.active);
    });
  });

  group('getByToken', () {
    test('find by token', () async {
      final l = await repo.create(1, 'paysa');
      final found = await repo.getByToken(l.token);
      expect(found?.id, l.id);
    });
  });

  group('getActiveLinks', () {
    test('returns only active non-expired', () async {
      await repo.create(1, 'paysa');
      final l2 = await repo.create(1, 'paysa');
      await repo.deactivate(l2.id);
      final active = await repo.getActiveLinks(1);
      for (final a in active) {
        expect(a.status, PaymentLinkStatus.active);
      }
    });
  });

  group('PaymentLink entity', () {
    test('isActive checks status and expiry', () {
      final now = DateTime.now();
      final link = PaymentLink(
        paymentRequestId: 1, provider: 'paysa', token: 'abc',
        status: PaymentLinkStatus.active,
        expiresAt: now.add(const Duration(hours: 1)),
        createdAt: now, updatedAt: now,
      );
      expect(link.isActive, true);
    });

    test('isActive returns false when expired', () {
      final now = DateTime.now();
      final link = PaymentLink(
        paymentRequestId: 1, provider: 'paysa', token: 'abc',
        status: PaymentLinkStatus.active,
        expiresAt: now.subtract(const Duration(hours: 1)),
        createdAt: now, updatedAt: now,
      );
      expect(link.isActive, false);
    });

    test('isOpenable only for active', () {
      for (final s in PaymentLinkStatus.values) {
        if (s == PaymentLinkStatus.active) {
          expect(PaymentLinkStatus.active.isOpenable, true);
        } else {
          expect(s.isOpenable, false, reason: 'status=$s');
        }
      }
    });

    test('terminal statuses', () {
      expect(PaymentLinkStatus.expired.isTerminal, true);
      expect(PaymentLinkStatus.resolved.isTerminal, true);
      expect(PaymentLinkStatus.active.isTerminal, false);
    });
  });

  group('token generation', () {
    test('generates secure token of specified length', () {
      final t = generateSecureToken(length: 32);
      expect(t.length, 32);
      expect(RegExp(r'^[A-Za-z0-9]+$').hasMatch(t), true);
    });

    test('generates short code of specified length', () {
      final c = generateShortCode(length: 8);
      expect(c.length, 8);
    });

    test('tokens are unique across calls', () {
      final t1 = generateSecureToken();
      final t2 = generateSecureToken();
      expect(t1, isNot(t2));
    });
  });

  group('DefaultPaymentLinkValidator', () {
    test('validates token length and characters', () {
      final v = DefaultPaymentLinkValidator();
      expect(v.validateToken('A' * 32), true);
      expect(v.validateToken('short'), false);
      expect(v.validateToken('invalid token!'), false);
    });

    test('validates short code', () {
      final v = DefaultPaymentLinkValidator();
      expect(v.validateShortCode('ABC12345'), true);
      expect(v.validateShortCode('ab'), false);
    });
  });

  group('PaymentLinkService', () {
    test('buildShareUrl uses shortCode when available', () {
      final now = DateTime.now();
      final link = PaymentLink(
        paymentRequestId: 1, provider: 'paysa', token: 'tok',
        shortCode: 'abc123', status: PaymentLinkStatus.active,
        createdAt: now, updatedAt: now,
      );
      final service = PaymentLinkService(
        generators: {}, resolver: DefaultPaymentLinkResolver(repo),
        validator: const DefaultPaymentLinkValidator(),
      );
      final url = service.buildShareUrl(link);
      expect(url, contains('/r/abc123'));
    });

    test('buildShareUrl falls back to token', () {
      final now = DateTime.now();
      final link = PaymentLink(
        paymentRequestId: 1, provider: 'paysa', token: 'mytoken',
        status: PaymentLinkStatus.active,
        createdAt: now, updatedAt: now,
      );
      final service = PaymentLinkService(
        generators: {}, resolver: DefaultPaymentLinkResolver(repo),
        validator: const DefaultPaymentLinkValidator(),
      );
      final url = service.buildShareUrl(link);
      expect(url, contains('/pay/mytoken'));
    });
  });

  group('all statuses', () {
    test('all 5 statuses have labels', () {
      expect(PaymentLinkStatus.values.length, 5);
      for (final s in PaymentLinkStatus.values) {
        expect(s.label.isNotEmpty, true);
      }
    });
  });
}
