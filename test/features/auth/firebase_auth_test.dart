import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/features/auth/data/datasources/auth_local_datasource_impl.dart';
import 'package:paysa/features/auth/data/providers/firebase_auth_provider.dart';
import 'package:paysa/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:paysa/features/auth/domain/entities/auth_entities.dart';

void main() {
  late FirebaseAuthProvider firebaseAuth;
  late AuthLocalDataSourceImpl local;

  setUp(() {
    firebaseAuth = FirebaseAuthProvider();
    local = AuthLocalDataSourceImpl();
  });

  group('signUp', () {
    test('creates user with valid data', () async {
      final result = await firebaseAuth.signUp('test@test.com', 'password123', displayName: 'Alice');
      expect(result.success, true);
      expect(result.identity?.email, 'test@test.com');
      expect(result.identity?.displayName, 'Alice');
    });

    test('rejects short password', () async {
      final result = await firebaseAuth.signUp('test@test.com', 'short', displayName: 'Bob');
      expect(result.success, false);
      expect(result.errorMessage, contains('weak-password'));
    });

    test('rejects duplicate email', () async {
      await firebaseAuth.signUp('dup@test.com', 'password123');
      final result = await firebaseAuth.signUp('dup@test.com', 'password123');
      expect(result.success, false);
      expect(result.errorMessage, contains('email-already-in-use'));
    });

    test('rejects empty email', () async {
      final result = await firebaseAuth.signUp('', 'password123');
      expect(result.success, false);
    });
  });

  group('signIn with email', () {
    test('signs in with correct credentials', () async {
      await firebaseAuth.signUp('user@test.com', 'password123', displayName: 'Alice');
      final result = await firebaseAuth.signIn(AuthMethod.email, email: 'user@test.com', password: 'password123');
      expect(result.success, true);
      expect(result.identity?.displayName, 'Alice');
    });

    test('rejects wrong password', () async {
      await firebaseAuth.signUp('secure@test.com', 'correctpass123');
      final result = await firebaseAuth.signIn(AuthMethod.email, email: 'secure@test.com', password: 'wrongpass');
      expect(result.success, false);
      expect(result.errorMessage, contains('wrong-password'));
    });

    test('rejects non-existent user', () async {
      final result = await firebaseAuth.signIn(AuthMethod.email, email: 'nobody@test.com', password: 'pass1234');
      expect(result.success, false);
      expect(result.errorMessage, contains('user-not-found'));
    });
  });

  group('signInAnonymously', () {
    test('creates anonymous session', () async {
      final result = await firebaseAuth.signInAnonymously();
      expect(result.success, true);
      expect(result.identity?.displayName, 'Guest');
    });
  });

  group('signOut', () {
    test('clears current user', () async {
      await firebaseAuth.signInAnonymously();
      expect(await firebaseAuth.isAuthenticated(), true);
      await firebaseAuth.signOut();
      expect(await firebaseAuth.isAuthenticated(), false);
    });
  });

  group('sendPasswordResetEmail', () {
    test('rejects empty email', () async {
      final result = await firebaseAuth.sendPasswordResetEmail('');
      expect(result.success, false);
    });

    test('accepts valid email', () async {
      final result = await firebaseAuth.sendPasswordResetEmail('user@test.com');
      expect(result.success, true);
    });
  });

  group('refreshSession', () {
    test('returns new token when authenticated', () async {
      await firebaseAuth.signInAnonymously();
      final refreshed = await firebaseAuth.refreshSession(Session(userId: 'u1', token: 'old'));
      expect(refreshed?.token, contains('firebase_refreshed_'));
    });

    test('returns null when not authenticated', () async {
      final refreshed = await firebaseAuth.refreshSession(Session(userId: 'u1', token: 'old'));
      expect(refreshed, isNull);
    });
  });

  group('through repository', () {
    test('sign up and sign in flow', () async {
      final repo = AuthRepositoryImpl(local: local, remote: firebaseAuth);
      final signUpResult = await repo.signUp('flow@test.com', 'password123', displayName: 'Flow');
      expect(signUpResult.success, true);

      await repo.signOut();
      expect(await repo.isAuthenticated(), false);

      final signInResult = await repo.signInWithEmail('flow@test.com', 'password123');
      expect(signInResult.success, true);
      expect(await repo.isAuthenticated(), true);
    });
  });
}
