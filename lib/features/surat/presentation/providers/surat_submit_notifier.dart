import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/network/offline_submission.dart';
import '../../data/models/surat_submission.dart';
import '../../data/surat_providers.dart';

part 'surat_submit_notifier.g.dart';

/// Drives the Surat Pulang Cepat form.
///
/// The `AsyncValue<void>` state reflects the in-flight request so the button
/// can show a spinner; [generate] returns the full [ApiResult] so the screen
/// can react to success (the native print sheet is shown by the download
/// service) or surface field-level validation errors.
///
/// Generation is online-only (there is no offline queue): when the device has
/// no connectivity, [generate] fails fast via the shared
/// [offlineSubmissionGuard], returning the same Indonesian message as Leave
/// Request so the offline experience is identical.
///
/// Kept alive because the screen only calls [generate] via
/// `ref.read(...notifier)` and never watches this provider. As an auto-dispose
/// provider it would be torn down during the awaited request, so writing
/// `state` after the response would throw "used after dispose".
@Riverpod(keepAlive: true)
class SuratSubmitNotifier extends _$SuratSubmitNotifier {
  @override
  Future<void> build() async {}

  Future<ApiResult<void>> generate(SuratSubmission submission) async {
    state = const AsyncLoading();

    // Online-only: mirror Leave Request's offline behavior exactly (same check
    // and message) so the experience is identical when the device is offline.
    final offline = await offlineSubmissionGuard<void>(ref);
    if (offline != null) {
      state = AsyncError(offline.exception, StackTrace.current);
      return offline;
    }

    final result = await ref
        .read(suratRepositoryProvider)
        .generateLetter(submission);

    state = result.fold(
      onSuccess: (_) => const AsyncData(null),
      onFailure: (error) => AsyncError(error, StackTrace.current),
    );

    return result;
  }
}
