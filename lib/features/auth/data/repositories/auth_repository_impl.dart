import 'dart:async';

import '../../domain/entities/auth_entities.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/validators/auth_validators.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.local,
    required this.remote,
  });

  final AuthLocalDataSource local;
  final AuthRemoteDataSource remote;

  final _stateController = StreamController<AuthState>.broadcast();
  AuthState _state = const AuthState(status: AuthStatus.unauthenticated);

  void _emit(AuthState s) { _state = s; _stateController.add(s); }

  @override Future<AuthResult> signInAnonymously() async {
    final result = await remote.signInAnonymously();
    if (result.success && result.session != null) {
      await local.saveSession(result.session!);
      if (result.identity != null) await local.saveProfile(result.identity!);
      _emit(AuthState(status: AuthStatus.authenticated, identity: result.identity, session: result.session, method: AuthMethod.anonymous));
    }
    return result;
  }

  @override Future<AuthResult> signInWithProvider(AuthMethod method, {String? email, String? password, String? token}) async {
    final result = await remote.signIn(method, email: email, password: password, token: token);
    if (result.success && result.session != null) {
      await local.saveSession(result.session!);
      if (result.identity != null) await local.saveProfile(result.identity!);
      _emit(AuthState(status: AuthStatus.authenticated, identity: result.identity, session: result.session, method: method));
    }
    return result;
  }

  @override Future<AuthResult> signInWithEmail(String email, String password) async {
    // Validate email
    final emailError = AuthValidators.validateEmail(email);
    if (emailError != null) {
      return AuthResult(success: false, errorMessage: AuthValidators.message(emailError));
    }

    // Validate password
    final passError = AuthValidators.validatePassword(password);
    if (passError != null) {
      return AuthResult(success: false, errorMessage: AuthValidators.message(passError));
    }

    final normalized = AuthValidators.normalizeEmail(email);
    final result = await remote.signIn(AuthMethod.email, email: normalized, password: password);
    if (result.success && result.session != null) {
      await local.saveSession(result.session!);
      if (result.identity != null) await local.saveProfile(result.identity!);
      _emit(AuthState(status: AuthStatus.authenticated, identity: result.identity, session: result.session, method: AuthMethod.email));
    }
    return result;
  }

  @override Future<AuthResult> signUp(String email, String password, {String? displayName}) async {
    // Validate display name
    final nameError = AuthValidators.validateDisplayName(displayName);
    if (nameError != null) {
      return AuthResult(success: false, errorMessage: AuthValidators.message(nameError));
    }

    // Validate email
    final emailError = AuthValidators.validateEmail(email);
    if (emailError != null) {
      return AuthResult(success: false, errorMessage: AuthValidators.message(emailError));
    }

    // Validate password
    final passError = AuthValidators.validatePassword(password);
    if (passError != null) {
      return AuthResult(success: false, errorMessage: AuthValidators.message(passError));
    }

    final normalized = AuthValidators.normalizeEmail(email);
    final result = await remote.signUp(normalized, password, displayName: displayName);
    if (result.success && result.session != null) {
      await local.saveSession(result.session!);
      if (result.identity != null) await local.saveProfile(result.identity!);
      _emit(AuthState(status: AuthStatus.authenticated, identity: result.identity, session: result.session, method: AuthMethod.email));
    }
    return result;
  }

  @override Future<void> signOut() async {
    await remote.signOut();
    await local.clear();
    _emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  @override Future<AuthState> getState() async => _state;

  @override Stream<AuthState> watchState() => _stateController.stream;

  @override Future<bool> isAuthenticated() async => _state.isAuthenticated;

  @override Future<void> restoreSession() async {
    final session = await local.getSession();
    if (session != null && session.isValid) {
      final profile = await local.getProfile();
      final method = await local.getAuthMethod();
      _emit(AuthState(status: AuthStatus.authenticated, identity: profile, session: session, method: method));
    } else {
      _emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }
}
