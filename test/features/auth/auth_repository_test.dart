import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/features/auth/data/datasources/auth_local_datasource_impl.dart';
import 'package:paysa/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:paysa/features/auth/data/services/auth_service_impl.dart';
import 'package:paysa/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:paysa/features/auth/domain/entities/auth_entities.dart';

final class _TestRemoteAdapter implements AuthRemoteDataSource {
  final _inner = AuthServiceImpl();

  @override Future<AuthResult> signIn(AuthMethod method, {String? email, String? password, String? token}) =>
      _inner.signInWithProvider(method, token: token);

  @override Future<AuthResult> signUp(String email, String password, {String? displayName}) =>
      _inner.signUp(email, password, displayName: displayName);

  @override Future<AuthResult> signInAnonymously() => _inner.signInAnonymously();

  @override Future<void> signOut() => _inner.signOut();

  @override Future<bool> isAuthenticated() => _inner.isAuthenticated();

  @override Future<Session?> refreshSession(Session session) => _inner.refreshSession();
}

void main() {
  late AuthRepositoryImpl repo;

  setUp(() {
    repo = AuthRepositoryImpl(
      local: AuthLocalDataSourceImpl(),
      remote: _TestRemoteAdapter(),
    );
  });

  group('signInAnonymously', () {
    test('creates guest session and caches locally', () async {
      final result = await repo.signInAnonymously();
      expect(result.success, true);
      expect(result.session, isNotNull);

      final session = await repo.local.getSession();
      expect(session?.userId, isNotEmpty);
    });
  });

  group('signInWithEmail', () {
    test('signs in with credentials', () async {
      final result = await repo.signInWithEmail('test@test.com', 'pass');
      expect(result.success, true);
      expect(await repo.isAuthenticated(), true);
    });
  });

  group('signOut', () {
    test('clears local data and state', () async {
      await repo.signInAnonymously();
      await repo.signOut();
      expect(await repo.isAuthenticated(), false);
      expect(await repo.local.getSession(), isNull);
    });
  });

  group('restoreSession', () {
    test('restores authenticated state from cache', () async {
      await repo.signInAnonymously();
      await repo.signOut();

      // Simulate session restore without signing in
      await repo.local.saveSession(Session(userId: 'restored', token: 'tok'));
      await repo.local.saveProfile(const UserIdentity(id: 'restored', displayName: 'Restored'));

      await repo.restoreSession();
      final state = await repo.getState();
      expect(state.isAuthenticated, true);
    });
  });
}
