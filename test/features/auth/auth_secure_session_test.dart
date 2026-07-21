import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/features/auth/data/datasources/auth_secure_datasource.dart';
import 'package:paysa/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:paysa/features/auth/domain/entities/auth_entities.dart';

void main() {
  late SecureAuthLocalDataSource storage;

  setUp(() { storage = SecureAuthLocalDataSource(); });

  group('saveSession / getSession', () {
    test('saves and retrieves session', () async {
      final session = Session(userId: 'user1', token: 'tok_abc', lastLoginAt: DateTime.now());
      await storage.saveSession(session);
      final retrieved = await storage.getSession();
      expect(retrieved?.userId, 'user1');
      expect(retrieved?.token, 'tok_abc');
    });

    test('returns null when no session saved', () async {
      expect(await storage.getSession(), isNull);
    });

    test('returns null for expired session', () async {
      final expired = Session(
        userId: 'user1',
        token: 'tok_expired',
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
      await storage.saveSession(expired);
      expect(await storage.getSession(), isNull);
    });

    test('returns session for non-expired session', () async {
      final valid = Session(
        userId: 'user1',
        token: 'tok_valid',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
      await storage.saveSession(valid);
      expect(await storage.getSession(), isNotNull);
    });
  });

  group('saveProfile / getProfile', () {
    test('saves and retrieves profile', () async {
      const profile = UserIdentity(id: 'u1', displayName: 'Alice', email: 'alice@test.com');
      await storage.saveProfile(profile);
      final retrieved = await storage.getProfile();
      expect(retrieved?.displayName, 'Alice');
      expect(retrieved?.email, 'alice@test.com');
    });

    test('returns null when no profile saved', () async {
      expect(await storage.getProfile(), isNull);
    });
  });

  group('saveAuthMethod / getAuthMethod', () {
    test('saves and retrieves auth method', () async {
      await storage.saveAuthMethod(AuthMethod.email);
      expect(await storage.getAuthMethod(), AuthMethod.email);
    });

    test('returns null when no method saved', () async {
      expect(await storage.getAuthMethod(), isNull);
    });
  });

  group('clear', () {
    test('removes all stored data', () async {
      await storage.saveSession(Session(userId: 'u1', token: 'tok'));
      await storage.saveProfile(const UserIdentity(id: 'u1'));
      await storage.saveAuthMethod(AuthMethod.anonymous);

      await storage.clear();

      expect(await storage.getSession(), isNull);
      expect(await storage.getProfile(), isNull);
      expect(await storage.getAuthMethod(), isNull);
    });
  });

  group('session lifecycle', () {
    test('session survives save -> clear -> restore sequence', () async {
      final session = Session(userId: 'persist', token: 'tok_persist', lastLoginAt: DateTime.now());
      await storage.saveSession(session);
      expect(await storage.getSession(), isNotNull);

      await storage.clear();
      expect(await storage.getSession(), isNull);

      // Re-save (simulating new login)
      await storage.saveSession(session);
      expect(await storage.getSession(), isNotNull);
    });
  });

  group('SecureAuthLocalDataSource implements AuthLocalDataSource', () {
    test('can be used as AuthLocalDataSource', () {
      expect(storage, isA<AuthLocalDataSource>());
    });
  });
}
