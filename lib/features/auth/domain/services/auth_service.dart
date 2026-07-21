import '../entities/auth_entities.dart';

abstract interface class AuthService {
  Future<AuthResult> signInAnonymously();
  Future<AuthResult> signInWithEmail(String email, String password);
  Future<AuthResult> signUp(String email, String password, {String? displayName});
  Future<AuthResult> signInWithProvider(AuthMethod method, {String? token});
  Future<void> signOut();
  Future<AuthState> getState();
  Stream<AuthState> watchState();
  Future<Session?> refreshSession();
  Future<bool> isAuthenticated();
  Future<UserIdentity> getProfile();
  Future<void> updateProfile(UserIdentity profile);
}
