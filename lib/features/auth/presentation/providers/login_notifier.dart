import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_result.dart';
import '../../data/auth_providers.dart';
import '../../data/models/auth_models.dart';
import 'auth_notifier.dart';

part 'login_notifier.g.dart';

/// Drives the login form submission.
///
/// Exposed as `AsyncValue<void>`: `loading` while the request is in flight,
/// `error` (carrying an `AppException`) on failure. On success it promotes the
/// global [AuthNotifier] to authenticated, which triggers the router redirect.
/// Kept separate from [AuthNotifier] so a failed login never corrupts the
/// global session state.
@riverpod
class LoginNotifier extends _$LoginNotifier {
  @override
  Future<void> build() async {}

  Future<void> submit({
    required int universityId,
    required String nim,
    required String password,
  }) async {
    state = const AsyncLoading();

    final request = LoginRequest(
      universityId: universityId,
      nim: nim,
      password: password,
      deviceName: 'aura-mobile-${defaultTargetPlatform.name}',
    );

    final result = await ref.read(authRepositoryProvider).login(request);

    switch (result) {
      case Success(:final data):
        ref.read(authProvider.notifier).onAuthenticated(data);
        state = const AsyncData<void>(null);
      case Failure(:final exception):
        state = AsyncError<void>(exception, StackTrace.current);
    }
  }
}
