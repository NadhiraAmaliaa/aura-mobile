// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_download_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the detail-screen file actions (open attachment / download PDF).
///
/// A single `AsyncValue<void>` state gates both actions so the buttons can
/// disable while a fetch is in flight; each method returns the [ApiResult] so
/// the screen can surface a failure message. Success opens the file in the
/// device viewer, so no success feedback is needed.

@ProviderFor(LeaveDownloadNotifier)
final leaveDownloadProvider = LeaveDownloadNotifierProvider._();

/// Drives the detail-screen file actions (open attachment / download PDF).
///
/// A single `AsyncValue<void>` state gates both actions so the buttons can
/// disable while a fetch is in flight; each method returns the [ApiResult] so
/// the screen can surface a failure message. Success opens the file in the
/// device viewer, so no success feedback is needed.
final class LeaveDownloadNotifierProvider
    extends $AsyncNotifierProvider<LeaveDownloadNotifier, void> {
  /// Drives the detail-screen file actions (open attachment / download PDF).
  ///
  /// A single `AsyncValue<void>` state gates both actions so the buttons can
  /// disable while a fetch is in flight; each method returns the [ApiResult] so
  /// the screen can surface a failure message. Success opens the file in the
  /// device viewer, so no success feedback is needed.
  LeaveDownloadNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'leaveDownloadProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$leaveDownloadNotifierHash();

  @$internal
  @override
  LeaveDownloadNotifier create() => LeaveDownloadNotifier();
}

String _$leaveDownloadNotifierHash() =>
    r'6fc92998ee587768c4b9a47a6d1129c495aa8c19';

/// Drives the detail-screen file actions (open attachment / download PDF).
///
/// A single `AsyncValue<void>` state gates both actions so the buttons can
/// disable while a fetch is in flight; each method returns the [ApiResult] so
/// the screen can surface a failure message. Success opens the file in the
/// device viewer, so no success feedback is needed.

abstract class _$LeaveDownloadNotifier extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
