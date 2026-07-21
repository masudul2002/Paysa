import 'dart:convert';
import '../../domain/entities/auth_entities.dart';
import 'auth_local_datasource.dart';

/// Secure implementation of [AuthLocalDataSource].
///
/// In production, this would use [FlutterSecureStorage] to persist
/// tokens and session data in the platform's encrypted storage
/// (Keychain on iOS, EncryptedSharedPreferences on Android).
///
/// For now, uses an in-memory store with the same interface,
/// ready to swap to FlutterSecureStorage when the package is added.
final class SecureAuthLocalDataSource implements AuthLocalDataSource {
  SecureAuthLocalDataSource();

  // In production, these would use FlutterSecureStorage:
  // final _storage = const FlutterSecureStorage();
  // static const _keySession = 'auth_session';
  // static const _keyProfile = 'auth_profile';
  // static const _keyMethod = 'auth_method';

  Session? _session;
  UserIdentity? _profile;
  AuthMethod? _method;

  @override
  Future<void> saveSession(Session session) async {
    // In production: await _storage.write(key: _keySession, value: _encodeSession(session));
    _session = session;
  }

  @override
  Future<Session?> getSession() async {
    // In production: final data = await _storage.read(key: _keySession);
    // return data != null ? _decodeSession(data) : null;
    if (_session == null) return null;
    // Reject expired sessions
    if (_session!.expiresAt != null && _session!.expiresAt!.isBefore(DateTime.now())) {
      _session = null;
      return null;
    }
    return _session;
  }

  @override
  Future<void> saveProfile(UserIdentity profile) async {
    // In production: await _storage.write(key: _keyProfile, value: jsonEncode(_profileToMap(profile)));
    _profile = profile;
  }

  @override
  Future<UserIdentity?> getProfile() async {
    // In production: final data = await _storage.read(key: _keyProfile);
    // return data != null ? _profileFromMap(jsonDecode(data)) : null;
    return _profile;
  }

  @override
  Future<void> saveAuthMethod(AuthMethod method) async {
    // In production: await _storage.write(key: _keyMethod, value: method.name);
    _method = method;
  }

  @override
  Future<AuthMethod?> getAuthMethod() async {
    // In production: final data = await _storage.read(key: _keyMethod);
    // return data != null ? AuthMethod.values.byName(data) : null;
    return _method;
  }

  @override
  Future<void> clear() async {
    // In production:
    // await _storage.delete(key: _keySession);
    // await _storage.delete(key: _keyProfile);
    // await _storage.delete(key: _keyMethod);
    _session = null;
    _profile = null;
    _method = null;
  }

  // ---------------------------------------------------------------------------
  // Serialization helpers (for production FlutterSecureStorage implementation)
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _sessionToMap(Session s) => {
    'userId': s.userId, 'token': s.token, 'refreshToken': s.refreshToken,
    'expiresAt': s.expiresAt?.toIso8601String(),
    'lastLoginAt': s.lastLoginAt?.toIso8601String(),
    'deviceId': s.deviceId,
  };

  Session _sessionFromMap(Map<String, dynamic> m) => Session(
    userId: m['userId'] as String? ?? '',
    token: m['token'] as String? ?? '',
    refreshToken: m['refreshToken'] as String?,
    expiresAt: m['expiresAt'] != null ? DateTime.parse(m['expiresAt'] as String) : null,
    lastLoginAt: m['lastLoginAt'] != null ? DateTime.parse(m['lastLoginAt'] as String) : null,
    deviceId: m['deviceId'] as String?,
  );

  Map<String, dynamic> _profileToMap(UserIdentity p) => {
    'id': p.id, 'email': p.email, 'displayName': p.displayName,
    'photoUrl': p.photoUrl, 'phone': p.phone, 'timezone': p.timezone,
    'preferredCurrency': p.preferredCurrency, 'language': p.language,
  };

  UserIdentity _profileFromMap(Map<String, dynamic> m) => UserIdentity(
    id: m['id'] as String? ?? '', email: m['email'] as String?,
    displayName: m['displayName'] as String?, photoUrl: m['photoUrl'] as String?,
    phone: m['phone'] as String?, timezone: m['timezone'] as String?,
    preferredCurrency: m['preferredCurrency'] as String? ?? 'USD',
    language: m['language'] as String? ?? 'en',
  );
}
