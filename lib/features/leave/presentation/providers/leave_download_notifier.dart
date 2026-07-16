import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_result.dart';
import '../../data/leave_providers.dart';
import '../../data/models/leave_models.dart';
import '../../data/repositories/leave_repository.dart';

part 'leave_download_notifier.g.dart';

/// Drives the detail-screen file actions (open attachment / download PDF).
///
/// A single `AsyncValue<void>` state gates both actions so the buttons can
/// disable while a fetch is in flight; each method returns the [ApiResult] so
/// the screen can surface a failure message. Success opens the file in the
/// device viewer, so no success feedback is needed.
@riverpod
class LeaveDownloadNotifier extends _$LeaveDownloadNotifier {
  @override
  Future<void> build() async {}

  Future<ApiResult<void>> downloadPdf(LeaveRequestModel request) =>
      _run((repository) => repository.downloadApprovedPdf(request));

  Future<ApiResult<void>> openEvidence(LeaveRequestModel request) =>
      _run((repository) => repository.openEvidence(request));

  Future<ApiResult<void>> _run(
    Future<ApiResult<void>> Function(LeaveRepository repository) action,
  ) async {
    state = const AsyncLoading();
    final result = await action(ref.read(leaveRepositoryProvider));
    state = result.fold(
      onSuccess: (_) => const AsyncData(null),
      onFailure: (error) => AsyncError(error, StackTrace.current),
    );
    return result;
  }
}
