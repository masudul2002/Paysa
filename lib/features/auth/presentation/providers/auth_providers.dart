import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_local_datasource_impl.dart';
import '../../domain/entities/auth_entities.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/services/auth_service_impl.dart';

final authLocalDataSourceProvider = Provider<AuthLocalDataSourceImpl>((ref) => AuthLocalDataSourceImpl());

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  // Uses AuthServiceImpl as the remote data source for MVP
  return _AuthServiceRemoteAdapter(AuthServiceImpl());
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final local = ref.watch(authLocalDataSourceProvider);
  final remote = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(local: local, remote: remote);
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  repo.restoreSession();
  return repo.watchState();
});

final currentUserProvider = Provider<UserIdentity?>((ref) {
  final state = ref.watch(authStateProvider).asData?.value;
  return state?.identity;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final state = ref.watch(authStateProvider).asData?.value;
  return state?.isAuthenticated ?? false;
});

/// Adapter to make [AuthServiceImpl] conform to [AuthRemoteDataSource].
final class _AuthServiceRemoteAdapter implements AuthRemoteDataSource {
  _AuthServiceRemoteAdapter(this._service);
  final AuthServiceImpl _service;

  @override Future<AuthResult> signIn(AuthMethod method, {String? email, String? password, String? token}) async {
    if (method == AuthMethod.email && email != null && password != null) {
      return _service.signInWithEmail(email, password);
    }
    return _service.signInWithProvider(method, token: token);
  }

  @override Future<AuthResult> signUp(String email, String password, {String? displayName}) async {
    return _service.signUp(email, password, displayName: displayName);
  }

  @override Future<AuthResult> signInAnonymously() async => _service.signInAnonymously();

  @override Future<void> signOut() async => _service.signOut();

  @override Future<bool> isAuthenticated() async => _service.isAuthenticated();

  @override Future<Session?> refreshSession(Session session) async => _service.refreshSession();
}
