// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives a single check-in submission.
///
/// On success it invalidates [attendanceDashboardProvider] so the dashboard
/// reflects the new record when the user returns to it.

@ProviderFor(CheckInController)
final checkInControllerProvider = CheckInControllerProvider._();

/// Drives a single check-in submission.
///
/// On success it invalidates [attendanceDashboardProvider] so the dashboard
/// reflects the new record when the user returns to it.
final class CheckInControllerProvider
    extends $NotifierProvider<CheckInController, CheckInState> {
  /// Drives a single check-in submission.
  ///
  /// On success it invalidates [attendanceDashboardProvider] so the dashboard
  /// reflects the new record when the user returns to it.
  CheckInControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkInControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkInControllerHash();

  @$internal
  @override
  CheckInController create() => CheckInController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CheckInState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CheckInState>(value),
    );
  }
}

String _$checkInControllerHash() => r'cdedee5ce3186da613269946cb3363d0bd7f10d3';

/// Drives a single check-in submission.
///
/// On success it invalidates [attendanceDashboardProvider] so the dashboard
/// reflects the new record when the user returns to it.

abstract class _$CheckInController extends $Notifier<CheckInState> {
  CheckInState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CheckInState, CheckInState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CheckInState, CheckInState>,
              CheckInState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
