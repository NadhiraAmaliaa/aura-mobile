import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/network/offline_submission.dart';
import '../../../auth/data/auth_providers.dart';
import '../../../auth/data/models/auth_models.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';

part 'profile_edit_notifier.g.dart';

/// Drives the "Ubah Kontak" form.
///
/// The `AsyncValue<void>` state reflects the in-flight request so the save
/// button can show a spinner; [updateContact] returns the full [ApiResult] so
/// the screen can pop on success or surface field-level validation errors. On
/// success the authenticated session user is refreshed in place so the profile
/// screen reflects the new contact details immediately.
///
/// Kept alive for the same reason as `LeaveSubmitNotifier`: the screen only
/// calls [updateContact] via `ref.read(...notifier)` and never watches this
/// provider, so an auto-dispose provider would be torn down mid-request.
@Riverpod(keepAlive: true)
class ProfileEditNotifier extends _$ProfileEditNotifier {
  @override
  Future<void> build() async {}

  Future<ApiResult<UserModel>> updateContact(
    ContactUpdateRequest request,
  ) async {
    state = const AsyncLoading();

    // Online-only: contact edits must reach the backend to be recorded.
    final offline = await offlineSubmissionGuard<UserModel>(ref);
    if (offline != null) {
      state = AsyncError(offline.exception, StackTrace.current);
      return offline;
    }

    final result = await ref
        .read(authRepositoryProvider)
        .updateContact(request);

    state = result.fold(
      onSuccess: (_) => const AsyncData(null),
      onFailure: (error) => AsyncError(error, StackTrace.current),
    );

    if (result is Success<UserModel>) {
      ref.read(authProvider.notifier).updateUser(result.data);
    }

    return result;
  }
}
