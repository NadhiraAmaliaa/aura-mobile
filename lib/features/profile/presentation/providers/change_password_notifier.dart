import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/network/offline_submission.dart';
import '../../../auth/data/auth_providers.dart';
import '../../../auth/data/models/auth_models.dart';

part 'change_password_notifier.g.dart';

/// Drives the "Ganti Password" form.
///
/// The `AsyncValue<void>` state reflects the in-flight request so the save
/// button can show a spinner; [submit] returns the full [ApiResult] so the
/// screen can pop on success or surface field-level validation errors (e.g. a
/// wrong current password).
///
/// Kept alive for the same reason as the other submission notifiers: the screen
/// calls [submit] via `ref.read(...notifier)` and never watches this provider.
@Riverpod(keepAlive: true)
class ChangePasswordNotifier extends _$ChangePasswordNotifier {
  @override
  Future<void> build() async {}

  Future<ApiResult<void>> submit(PasswordUpdateRequest request) async {
    state = const AsyncLoading();

    // Online-only: password changes must reach the backend.
    final offline = await offlineSubmissionGuard<void>(ref);
    if (offline != null) {
      state = AsyncError(offline.exception, StackTrace.current);
      return offline;
    }

    final result = await ref
        .read(authRepositoryProvider)
        .updatePassword(request);

    state = result.fold(
      onSuccess: (_) => const AsyncData(null),
      onFailure: (error) => AsyncError(error, StackTrace.current),
    );

    return result;
  }
}
