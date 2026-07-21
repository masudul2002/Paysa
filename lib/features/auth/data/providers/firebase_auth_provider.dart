import '../../domain/entities/auth_entities.dart';
import '../datasources/auth_remote_datasource.dart';

/// Firebase Authentication implementation of [AuthRemoteDataSource].
///
/// In production, this uses firebase_auth package:
/// ```dart
/// final _auth = FirebaseAuth.instance;
/// ```
///
/// For now, uses a mock implementation that simulates Firebase behavior
/// including error codes, session management, and token refresh.
final class FirebaseAuthProvider implements AuthRemoteDataSource {
  FirebaseAuthProvider();

  // Simulated user database for MVP
  final _users = <String, _FirebaseUser>{};
  _FirebaseUser? _currentUser;
  String? _lastToken;

  @override
  String get name => 'firebase';

  @override
  Future<AuthResult> signIn(AuthMethod method, {String? email, String? password, String? token}) async {
    if (method == AuthMethod.google && token != null) {
      // Simulate Google credential sign-in with Firebase
      _currentUser = _FirebaseUser(
        uid: 'firebase_google_${DateTime.now().millisecondsSinceEpoch}',
        email: email ?? 'user@gmail.com',
        displayName: 'Firebase Google User',
      );
    } else if (method == AuthMethod.email && email != null && password != null) {
      // Simulate email/password sign-in
      if (!_users.containsKey(email)) {
        return _error('user-not-found', 'No account found with this email.');
      }
      final user = _users[email]!;
      if (user.password != password) {
        return _error('wrong-password', 'Incorrect password.');
      }
      _currentUser = user;
    } else {
      return _error('invalid-credential', 'Invalid authentication method.');
    }

    _lastToken = 'firebase_${DateTime.now().millisecondsSinceEpoch}';
    return _success();
  }

  @override
  Future<AuthResult> signUp(String email, String password, {String? displayName}) async {
    if (email.isEmpty || password.isEmpty) {
      return _error('invalid-email', 'Email and password are required.');
    }
    if (password.length < 8) {
      return _error('weak-password', 'Password should be at least 8 characters.');
    }
    if (_users.containsKey(email)) {
      return _error('email-already-in-use', 'An account with this email already exists.');
    }

    _currentUser = _FirebaseUser(
      uid: 'firebase_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: displayName ?? email.split('@').first,
      password: password,
    );
    _users[email] = _currentUser!;
    _lastToken = 'firebase_${DateTime.now().millisecondsSinceEpoch}';

    return _success();
  }

  @override
  Future<AuthResult> signInAnonymously() async {
    _currentUser = _FirebaseUser(
      uid: 'firebase_anon_${DateTime.now().millisecondsSinceEpoch}',
      displayName: 'Guest',
    );
    _lastToken = 'firebase_anon_${DateTime.now().millisecondsSinceEpoch}';
    return _success();
  }

  /// Send password reset email (simulated).
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    if (email.isEmpty) {
      return _error('invalid-email', 'Email is required.');
    }
    return const AuthResult(success: true);
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _lastToken = null;
  }

  @override
  Future<bool> isAuthenticated() async => _currentUser != null;

  @override
  Future<Session?> refreshSession(Session session) async {
    if (_currentUser == null) return null;
    return Session(
      userId: session.userId,
      token: 'firebase_refreshed_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: session.refreshToken,
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
      lastLoginAt: DateTime.now(),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  AuthResult _success() {
    if (_currentUser == null) return const AuthResult(success: false, errorMessage: 'Unknown error');

    final identity = UserIdentity(
      id: _currentUser!.uid,
      email: _currentUser!.email,
      displayName: _currentUser!.displayName,
    );

    final session = Session(
      userId: identity.id,
      token: _lastToken ?? '',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
      lastLoginAt: DateTime.now(),
    );

    return AuthResult(success: true, identity: identity, session: session);
  }

  AuthResult _error(String code, String message) {
    return AuthResult(success: false, errorMessage: '[$code] $message');
  }
}

final class _FirebaseUser {
  const _FirebaseUser({
    required this.uid,
    this.email,
    this.displayName,
    this.password,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? password;
}
