import '../../domain/entities/auth_entities.dart';

/// Local persistence for authentication data.
///
/// Stores session, cached profile, and last auth method.
/// In production, backed by Isar, SecureStorage, or SharedPreferences.
abstract interface class AuthLocalDataSource {
  Future<void> saveSession(Session session);
  Future<Session?> getSession();
  Future<void> saveProfile(UserIdentity profile);
  Future<UserIdentity?> getProfile();
  Future<void> saveAuthMethod(AuthMethod method);
  Future<AuthMethod?> getAuthMethod();
  Future<void> clear();
}
