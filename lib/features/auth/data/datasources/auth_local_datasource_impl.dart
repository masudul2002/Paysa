import 'dart:convert';

import '../../domain/entities/auth_entities.dart';
import 'auth_local_datasource.dart';

/// In-memory implementation of [AuthLocalDataSource].
///
/// Stores auth data in memory only — data is lost on app restart.
/// Replace with Isar/SecureStorage-backed implementation for production.
final class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  Session? _session;
  UserIdentity? _profile;
  AuthMethod? _method;

  @override Future<void> saveSession(Session session) async { _session = session; }
  @override Future<Session?> getSession() async => _session;
  @override Future<void> saveProfile(UserIdentity profile) async { _profile = profile; }
  @override Future<UserIdentity?> getProfile() async => _profile;
  @override Future<void> saveAuthMethod(AuthMethod method) async { _method = method; }
  @override Future<AuthMethod?> getAuthMethod() async => _method;
  @override Future<void> clear() async { _session = null; _profile = null; _method = null; }
}
