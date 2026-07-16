// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_submit_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(LeaveSubmitNotifier)
final leaveSubmitProvider = LeaveSubmitNotifierProvider._();

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
final class LeaveSubmitNotifierProvider
    extends $AsyncNotifierProvider<LeaveSubmitNotifier, void> {
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
  LeaveSubmitNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'leaveSubmitProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$leaveSubmitNotifierHash();

  @$internal
  @override
  LeaveSubmitNotifier create() => LeaveSubmitNotifier();
}

String _$leaveSubmitNotifierHash() =>
    r'df5053167b47e4c466a8153dd07820872c51a44d';

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

abstract class _$LeaveSubmitNotifier extends $AsyncNotifier<void> {
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
