// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_out_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives a single check-out submission.
///
/// On success it invalidates [attendanceDashboardProvider] so the dashboard
/// reflects the updated record when the user returns to it.

@ProviderFor(CheckOutController)
final checkOutControllerProvider = CheckOutControllerProvider._();

/// Drives a single check-out submission.
///
/// On success it invalidates [attendanceDashboardProvider] so the dashboard
/// reflects the updated record when the user returns to it.
final class CheckOutControllerProvider
    extends $NotifierProvider<CheckOutController, CheckOutState> {
  /// Drives a single check-out submission.
  ///
  /// On success it invalidates [attendanceDashboardProvider] so the dashboard
  /// reflects the updated record when the user returns to it.
  CheckOutControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkOutControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkOutControllerHash();

  @$internal
  @override
  CheckOutController create() => CheckOutController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CheckOutState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CheckOutState>(value),
    );
  }
}

String _$checkOutControllerHash() =>
    r'b4885b449f62f5ea4687eac9bf0558425bbe4c66';

/// Drives a single check-out submission.
///
/// On success it invalidates [attendanceDashboardProvider] so the dashboard
/// reflects the updated record when the user returns to it.

abstract class _$CheckOutController extends $Notifier<CheckOutState> {
  CheckOutState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CheckOutState, CheckOutState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CheckOutState, CheckOutState>,
              CheckOutState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
