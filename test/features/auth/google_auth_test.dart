import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/features/auth/data/datasources/auth_local_datasource_impl.dart';
import 'package:paysa/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:paysa/features/auth/data/providers/google_auth_provider.dart';
import 'package:paysa/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:paysa/features/auth/domain/entities/auth_entities.dart';
import 'package:paysa/features/auth/domain/repositories/auth_repository.dart';

void main() {
  late GoogleAuthProvider googleProvider;
  late AuthLocalDataSource local;

  setUp(() {
    googleProvider = GoogleAuthProvider();
    local = AuthLocalDataSourceImpl();
  });

  group('GoogleAuthProvider', () {
    test('signIn with valid token returns success', () async {
      final result = await googleProvider.signIn(AuthMethod.google, token: 'google_token_123');
      expect(result.success, true);
      expect(result.identity?.displayName, 'Google User');
      expect(result.session?.token, 'google_token_123');
    });

    test('signIn with empty token returns failure', () async {
      final result = await googleProvider.signIn(AuthMethod.google, token: '');
      expect(result.success, false);
    });

    test('signIn with wrong method returns failure', () async {
      final result = await googleProvider.signIn(AuthMethod.email, email: 'a@b.com', password: 'pass');
      expect(result.success, false);
    });

    test('signUp is not supported', () async {
      final result = await googleProvider.signUp('a@b.com', 'pass');
      expect(result.success, false);
    });

    test('signInAnonymously is not supported', () async {
      final result = await googleProvider.signInAnonymously();
      expect(result.success, false);
    });

    test('isAuthenticated returns false after sign out', () async {
      await googleProvider.signIn(AuthMethod.google, token: 'tok');
      await googleProvider.signOut();
      expect(await googleProvider.isAuthenticated(), false);
    });

    test('refreshSession returns new token', () async {
      await googleProvider.signIn(AuthMethod.google, token: 'tok');
      final refreshed = await googleProvider.refreshSession(
        Session(userId: 'u1', token: 'old'),
      );
      expect(refreshed?.token, contains('google_refreshed_'));
    });

    test('refreshSession returns null when not signed in', () async {
      final refreshed = await googleProvider.refreshSession(
        Session(userId: 'u1', token: 'old'),
      );
      expect(refreshed, isNull);
    });
  });

  group('Google Auth through repository', () {
    late AuthRepository repo;

    setUp(() {
      repo = AuthRepositoryImpl(local: local, remote: googleProvider);
    });

    test('sign in with google creates session', () async {
      final result = await repo.signInWithProvider(AuthMethod.google, token: 'google_oauth_token');
      expect(result.success, true);
      expect(result.session, isNotNull);
      expect(await repo.isAuthenticated(), true);
    });

    test('sign out clears session', () async {
      await repo.signInWithProvider(AuthMethod.google, token: 'tok');
      await repo.signOut();
      expect(await repo.isAuthenticated(), false);
    });
  });

  group('Google identity mapping', () {
    test('identity has correct fields', () async {
      final result = await googleProvider.signIn(AuthMethod.google, token: 'tok');
      expect(result.identity?.id, startsWith('google_'));
      expect(result.identity?.email, 'user@gmail.com');
      expect(result.identity?.displayName, 'Google User');
      expect(result.identity?.photoUrl, contains('googleusercontent'));
    });
  });
}
