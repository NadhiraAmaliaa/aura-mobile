import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_result.dart';
import '../../data/leave_providers.dart';
import '../../data/models/leave_models.dart';
import '../../data/models/leave_submission.dart';
import 'leave_list_notifier.dart';
import 'leave_list_state.dart';

part 'leave_submit_notifier.g.dart';

/// Drives the leave submission form.
///
/// The `AsyncValue<void>` state reflects the in-flight request so the button
/// can show a spinner; [submit] returns the full [ApiResult] so the screen can
/// react to the created record or surface field-level validation errors. On
/// success the pending list is invalidated so the new request appears.
///
/// Kept alive because the screen only calls [submit] via `ref.read(...notifier)`
/// and never watches this provider. As an auto-dispose provider it would be
/// torn down during the awaited request, so writing `state` (or invalidating
/// the pending list) after the response would throw "used after dispose" and
/// strand the submit button in its loading state.
@Riverpod(keepAlive: true)
class LeaveSubmitNotifier extends _$LeaveSubmitNotifier {
  @override
  Future<void> build() async {}

  Future<ApiResult<LeaveRequestModel>> submit(LeaveSubmission submission) async {
    state = const AsyncLoading();
    final result = await ref.read(leaveRepositoryProvider).submit(submission);

    state = result.fold(
      onSuccess: (_) => const AsyncData(null),
      onFailure: (error) => AsyncError(error, StackTrace.current),
    );

    if (result is Success<LeaveRequestModel>) {
      ref.invalidate(leaveListProvider(LeaveListFilter.pending));
    }

    return result;
  }
}
