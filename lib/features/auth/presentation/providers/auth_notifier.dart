import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_result.dart';
import '../../data/auth_providers.dart';
import '../../data/models/user_model.dart';
import 'auth_state.dart';

part 'auth_notifier.g.dart';

/// Global session ViewModel.
///
/// `build()` resolves the session on cold start (reads the stored token and
/// validates it via `/auth/me`). The surrounding [AsyncValue] models the
/// resolving phase, so the router can show a splash while `loading`. Login and
/// logout flip the resolved [AuthState].
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
    return result.fold(
      onSuccess: AuthState.authenticated,
      onFailure: (_) => const AuthState.unauthenticated(),
    );
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
