import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/features/auth/domain/entities/auth_entities.dart';
import 'package:paysa/features/auth/data/services/auth_service_impl.dart';

void main() {
  late AuthServiceImpl auth;

  setUp(() { auth = AuthServiceImpl(); });

  group('signInAnonymously', () {
    test('creates guest session', () async {
      final r = await auth.signInAnonymously();
      expect(r.success, true);
      expect(r.identity?.displayName, 'Guest');
    });
  });

  group('signInWithEmail', () {
    test('rejects empty credentials', () async {
      final r = await auth.signInWithEmail('', '');
      expect(r.success, false);
    });

    test('creates session with valid email', () async {
      final r = await auth.signInWithEmail('user@test.com', 'pass123');
      expect(r.success, true);
      expect(r.identity?.email, 'user@test.com');
    });
  });

  group('signUp', () {
    test('creates new user', () async {
      final r = await auth.signUp('new@test.com', 'pass', displayName: 'Alice');
      expect(r.success, true);
      expect(r.identity?.displayName, 'Alice');
    });
  });

  group('signOut', () {
    test('clears authentication', () async {
      await auth.signInAnonymously();
      await auth.signOut();
      expect((await auth.getState()).isAuthenticated, false);
    });
  });

  group('getState / watchState', () {
    test('initial state is unauthenticated', () async {
      final s = await auth.getState();
      expect(s.status, AuthStatus.unauthenticated);
    });
  });

  group('refreshSession', () {
    test('returns new token', () async {
      await auth.signInAnonymously();
      final renewed = await auth.refreshSession();
      expect(renewed?.token, contains('ref_'));
    });
  });

  group('isAuthenticated', () {
    test('false before sign in', () async {
      expect(await auth.isAuthenticated(), false);
    });

    test('true after sign in', () async {
      await auth.signInAnonymously();
      expect(await auth.isAuthenticated(), true);
    });
  });

  group('getProfile / updateProfile', () {
    test('getProfile returns identity', () async {
      await auth.signInAnonymously();
      final p = await auth.getProfile();
      expect(p.id, isNotEmpty);
    });

    test('updateProfile changes identity', () async {
      await auth.signInAnonymously();
      const profile = UserIdentity(id: 'new_id', displayName: 'Updated');
      await auth.updateProfile(profile);
      final p = await auth.getProfile();
      expect(p.displayName, 'Updated');
    });
  });

  group('signInWithProvider', () {
    test('authenticates with provider', () async {
      final r = await auth.signInWithProvider(AuthMethod.google, token: 'google_tok');
      expect(r.success, true);
      expect(r.identity?.id, contains('google'));
    });
  });

  group('Session', () {
    test('isValid when token present and not expired', () {
      final s = Session(userId: '1', token: 'tok', expiresAt: DateTime.now().add(const Duration(hours: 1)));
      expect(s.isValid, true);
    });

    test('needsRefresh when within 5 min of expiry', () {
      final s = Session(userId: '1', token: 'tok', expiresAt: DateTime.now().add(const Duration(minutes: 2)));
      expect(s.needsRefresh, true);
    });
  });

  group('AuthState', () {
    test('isAuthenticated when authenticated', () {
      final s = AuthState(status: AuthStatus.authenticated, identity: UserIdentity(id: '1'));
      expect(s.isAuthenticated, true);
    });
  });
}
