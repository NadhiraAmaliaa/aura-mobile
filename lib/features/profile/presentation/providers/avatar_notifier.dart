import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/network/offline_submission.dart';
import '../../../auth/data/auth_providers.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';

part 'avatar_notifier.g.dart';

/// Drives the profile-photo upload / removal.
///
/// The `AsyncValue<void>` state reflects the in-flight request so the avatar
/// can show a spinner; [upload] and [remove] return the full [ApiResult] so the
/// screen can surface a snackbar on success or map an error message. On success
/// the authenticated session user is refreshed in place so the new photo shows
/// immediately.
///
/// Kept alive for the same reason as `ProfileEditNotifier`: the screen only
/// calls these methods via `ref.read(...notifier)` and never watches this
/// provider, so an auto-dispose provider would be torn down mid-request.
@Riverpod(keepAlive: true)
class AvatarNotifier extends _$AvatarNotifier {
  @override
  Future<void> build() async {}

  Future<ApiResult<UserModel>> upload(File photo) async {
    state = const AsyncLoading();

    // Online-only: the photo must reach the backend to be stored.
    final offline = await offlineSubmissionGuard<UserModel>(ref);
    if (offline != null) {
      state = AsyncError(offline.exception, StackTrace.current);
      return offline;
    }

    final result = await ref.read(authRepositoryProvider).updateAvatar(photo);

    state = result.fold(
      onSuccess: (_) => const AsyncData(null),
      onFailure: (error) => AsyncError(error, StackTrace.current),
    );

    if (result is Success<UserModel>) {
      ref.read(authProvider.notifier).updateUser(result.data);
    }

    return result;
  }

  Future<ApiResult<UserModel>> remove() async {
    state = const AsyncLoading();

    final offline = await offlineSubmissionGuard<UserModel>(ref);
    if (offline != null) {
      state = AsyncError(offline.exception, StackTrace.current);
      return offline;
    }

    final result = await ref.read(authRepositoryProvider).deleteAvatar();

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
