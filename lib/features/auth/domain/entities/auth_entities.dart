enum AuthMethod { anonymous, email, google, apple, passkey, custom }
enum AuthStatus { unauthenticated, authenticating, authenticated, error }

final class UserIdentity {
  const UserIdentity({
    this.id = '',
    this.email,
    this.displayName,
    this.photoUrl,
    this.phone,
    this.timezone,
    this.preferredCurrency = 'USD',
    this.language = 'en',
  });
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? phone;
  final String? timezone;
  final String preferredCurrency;
  final String language;
}

final class Session {
  const Session({
    required this.userId,
    this.token = '',
    this.refreshToken,
    this.expiresAt,
    this.lastLoginAt,
    this.deviceId,
  });
  final String userId;
  final String token;
  final String? refreshToken;
  final DateTime? expiresAt;
  final DateTime? lastLoginAt;
  final String? deviceId;

  bool get isValid => token.isNotEmpty && (expiresAt == null || expiresAt!.isAfter(DateTime.now()));
  bool get needsRefresh => expiresAt != null && expiresAt!.difference(DateTime.now()).inMinutes < 5;
}

final class AuthResult {
  const AuthResult({
    required this.success,
    this.identity,
    this.session,
    this.errorMessage,
  });
  final bool success;
  final UserIdentity? identity;
  final Session? session;
  final String? errorMessage;
}

final class AuthState {
  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.identity,
    this.session,
    this.method,
    this.errorMessage,
  });
  final AuthStatus status;
  final UserIdentity? identity;
  final Session? session;
  final AuthMethod? method;
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated && identity != null;
}

/// Provider interface for authentication backends.
abstract interface class AuthProvider {
  String get name;
  Future<AuthResult> signIn(AuthMethod method, {String? email, String? password, String? token});
  Future<AuthResult> signUp(String email, String password, {String? displayName});
  Future<void> signOut();
  Future<Session?> refreshSession(Session session);
  Future<bool> isValid();
}
