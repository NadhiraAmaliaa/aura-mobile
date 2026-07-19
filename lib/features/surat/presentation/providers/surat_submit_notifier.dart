import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_result.dart';
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
