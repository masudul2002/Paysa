import 'dart:async';
import '../../domain/entities/auth_entities.dart';
import '../../domain/services/auth_service.dart';

final class AuthServiceImpl implements AuthService {
  final _stateController = StreamController<AuthState>.broadcast();
  AuthState _state = const AuthState(status: AuthStatus.unauthenticated);

  @override Future<AuthResult> signInAnonymously() async {
    _state = AuthState(status: AuthStatus.authenticated,
      identity: UserIdentity(id: 'anon_${DateTime.now().millisecondsSinceEpoch}', displayName: 'Guest'),
      session: Session(userId: 'anon', token: 'anon_token', lastLoginAt: DateTime.now()),
      method: AuthMethod.anonymous);
    _stateController.add(_state);
    return AuthResult(success: true, identity: _state.identity, session: _state.session);
  }

  @override Future<AuthResult> signInWithEmail(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return const AuthResult(success: false, errorMessage: 'Email and password required');
    }
    _state = AuthState(status: AuthStatus.authenticated,
      identity: UserIdentity(id: email, email: email, displayName: email.split('@').first),
      session: Session(userId: email, token: 'tok_${DateTime.now().millisecondsSinceEpoch}', lastLoginAt: DateTime.now()),
      method: AuthMethod.email);
    _stateController.add(_state);
    return AuthResult(success: true, identity: _state.identity, session: _state.session);
  }

  @override Future<AuthResult> signUp(String email, String password, {String? displayName}) async {
    _state = AuthState(status: AuthStatus.authenticated,
      identity: UserIdentity(id: email, email: email, displayName: displayName ?? email.split('@').first),
      session: Session(userId: email, token: 'tok_${DateTime.now().millisecondsSinceEpoch}', lastLoginAt: DateTime.now()),
      method: AuthMethod.email);
    _stateController.add(_state);
    return AuthResult(success: true, identity: _state.identity, session: _state.session);
  }

  @override Future<AuthResult> signInWithProvider(AuthMethod method, {String? token}) async {
    _state = AuthState(status: AuthStatus.authenticated,
      identity: UserIdentity(id: '${method.name}_${DateTime.now().millisecondsSinceEpoch}'),
      session: Session(userId: method.name, token: token ?? 'provider_token', lastLoginAt: DateTime.now()),
      method: method);
    _stateController.add(_state);
    return AuthResult(success: true, identity: _state.identity, session: _state.session);
  }

  @override Future<void> signOut() async {
    _state = const AuthState(status: AuthStatus.unauthenticated);
    _stateController.add(_state);
  }

  @override Future<AuthState> getState() async => _state;

  @override Stream<AuthState> watchState() => _stateController.stream;

  @override Future<Session?> refreshSession() async {
    if (_state.session == null) return null;
    final renewed = Session(userId: _state.session!.userId, token: 'ref_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: _state.session!.refreshToken, lastLoginAt: DateTime.now());
    _state = _state.copyWith(session: renewed);
    return renewed;
  }

  @override Future<bool> isAuthenticated() async => _state.isAuthenticated;

  @override Future<UserIdentity> getProfile() async => _state.identity ?? const UserIdentity(id: '');

  @override Future<void> updateProfile(UserIdentity profile) async {
    _state = AuthState(status: AuthStatus.authenticated, identity: profile, session: _state.session, method: _state.method);
    _stateController.add(_state);
  }
}

extension on AuthState {
  AuthState copyWith({AuthStatus? status, UserIdentity? identity, Session? session, AuthMethod? method, String? errorMessage}) =>
    AuthState(status: status ?? this.status, identity: identity ?? this.identity, session: session ?? this.session, method: method ?? this.method, errorMessage: errorMessage ?? this.errorMessage);
}
