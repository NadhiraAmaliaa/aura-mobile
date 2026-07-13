import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../data/auth_providers.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

part 'auth_notifier.g.dart';

/// Global session ViewModel.
///
/// `build()` resolves the session on cold start (reads the stored token and
/// validates it via `/auth/me`). The surrounding [AsyncValue] models the
/// resolving phase, so the router can show a splash while `loading`. Login and
/// logout flip the resolved [AuthState].
///
/// Offline resilience: a transient validation failure (no network, timeout,
/// unreachable server, 5xx) must NOT drop a previously authenticated user. The
/// session is restored from the on-device user cache in that case; only an
/// explicit `401` (invalid/expired token) clears the session and requires a new
/// login.
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<AuthState> build() async {
    final repository = ref.watch(authRepositoryProvider);
    final token = await repository.currentToken();
    if (token == null || token.isEmpty) {
      return const AuthState.unauthenticated();
    }

    final result = await repository.me();
    return switch (result) {
      Success(:final data) => AuthState.authenticated(data),
      // Token explicitly rejected by the server → require a fresh login.
      Failure(:final exception) when exception is UnauthorizedException =>
        await _clearSession(repository),
      // Backend unreachable (offline / timeout / 5xx) → keep the local session
      // alive using the cached profile so the app is usable offline.
      Failure() => await _restoreFromCache(repository),
    };
  }

  Future<AuthState> _restoreFromCache(AuthRepository repository) async {
    final cached = await repository.cachedUser();
    return cached != null
        ? AuthState.authenticated(cached)
        : const AuthState.unauthenticated();
  }

  Future<AuthState> _clearSession(AuthRepository repository) async {
    await repository.logout();
    return const AuthState.unauthenticated();
  }

  /// Promote the session to authenticated after a successful login.
  void onAuthenticated(UserModel user) {
    state = AsyncData(AuthState.authenticated(user));
  }

  /// Revoke the token server-side (best effort) and drop to unauthenticated.
  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(AuthState.unauthenticated());
  }
}
