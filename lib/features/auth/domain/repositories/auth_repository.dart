import '../entities/auth_entities.dart';

/// Single source of truth for authentication operations.
///
/// Orchestrates between local cache and remote auth provider.
abstract interface class AuthRepository {
  Future<AuthResult> signInAnonymously();
  Future<AuthResult> signInWithEmail(String email, String password);
  Future<AuthResult> signInWithProvider(AuthMethod method, {String? email, String? password, String? token});
  Future<AuthResult> signUp(String email, String password, {String? displayName});
  Future<void> signOut();
  Future<AuthState> getState();
  Stream<AuthState> watchState();
  Future<bool> isAuthenticated();
  Future<void> restoreSession();
}
