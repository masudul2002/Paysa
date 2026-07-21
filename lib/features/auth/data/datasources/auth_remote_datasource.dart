import '../../domain/entities/auth_entities.dart';

/// Remote authentication interface.
///
/// Implementations: FirebaseAuthRemote, SupabaseAuthRemote, CustomAuthRemote.
/// No implementation in MVP — only interface.
abstract interface class AuthRemoteDataSource {
  Future<AuthResult> signIn(AuthMethod method, {String? email, String? password, String? token});
  Future<AuthResult> signUp(String email, String password, {String? displayName});
  Future<AuthResult> signInAnonymously();
  Future<void> signOut();
  Future<bool> isAuthenticated();
  Future<Session?> refreshSession(Session session);
}
