import '../../domain/entities/auth_entities.dart';
import '../datasources/auth_remote_datasource.dart';

/// Google-specific authentication provider.
///
/// Implements [AuthRemoteDataSource] for Google Sign-In.
/// Uses platform channels for actual Google sign-in in production.
final class GoogleAuthProvider implements AuthRemoteDataSource {
  GoogleAuthProvider();

  /// Simulated Google user data for testing.
  /// In production, this comes from GoogleSignInAccount.
  static const _mockUser = {
    'id': 'google_12345',
    'email': 'user@gmail.com',
    'displayName': 'Google User',
    'photoUrl': 'https://lh3.googleusercontent.com/photo',
  };

  bool _signedIn = false;
  String? _lastToken;

  @override
  String get name => 'google';

  @override
  Future<AuthResult> signIn(AuthMethod method, {String? email, String? password, String? token}) async {
    if (method != AuthMethod.google) {
      return const AuthResult(success: false, errorMessage: 'Google provider can only handle Google sign-in');
    }

    if (token == null || token.isEmpty) {
      return const AuthResult(success: false, errorMessage: 'Google token is required');
    }

    _signedIn = true;
    _lastToken = token;

    final identity = UserIdentity(
      id: 'google_${DateTime.now().millisecondsSinceEpoch}',
      email: email ?? _mockUser['email'] as String,
      displayName: _mockUser['displayName'] as String,
      photoUrl: _mockUser['photoUrl'] as String,
    );

    final session = Session(
      userId: identity.id,
      token: token,
      refreshToken: 'google_refresh_${DateTime.now().millisecondsSinceEpoch}',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
      lastLoginAt: DateTime.now(),
    );

    return AuthResult(success: true, identity: identity, session: session);
  }

  @override
  Future<AuthResult> signUp(String email, String password, {String? displayName}) async {
    return const AuthResult(success: false, errorMessage: 'Use signIn for Google authentication');
  }

  @override
  Future<AuthResult> signInAnonymously() async {
    return const AuthResult(success: false, errorMessage: 'Google provider does not support anonymous sign-in');
  }

  @override
  Future<void> signOut() async {
    _signedIn = false;
    _lastToken = null;
  }

  @override
  Future<bool> isAuthenticated() async => _signedIn;

  @override
  Future<Session?> refreshSession(Session session) async {
    if (!_signedIn) return null;
    return Session(
      userId: session.userId,
      token: 'google_refreshed_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: session.refreshToken,
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
      lastLoginAt: DateTime.now(),
    );
  }

  /// Simulates checking for an existing Google session.
  Future<bool> hasExistingSession() async {
    return _signedIn;
  }
}
