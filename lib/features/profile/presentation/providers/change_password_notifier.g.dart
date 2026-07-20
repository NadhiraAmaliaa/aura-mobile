// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_password_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the "Ganti Password" form.
///
/// The `AsyncValue<void>` state reflects the in-flight request so the save
/// button can show a spinner; [submit] returns the full [ApiResult] so the
/// screen can pop on success or surface field-level validation errors (e.g. a
/// wrong current password).
///
/// Kept alive for the same reason as the other submission notifiers: the screen
/// calls [submit] via `ref.read(...notifier)` and never watches this provider.

@ProviderFor(ChangePasswordNotifier)
final changePasswordProvider = ChangePasswordNotifierProvider._();

/// Drives the "Ganti Password" form.
///
/// The `AsyncValue<void>` state reflects the in-flight request so the save
/// button can show a spinner; [submit] returns the full [ApiResult] so the
/// screen can pop on success or surface field-level validation errors (e.g. a
/// wrong current password).
///
/// Kept alive for the same reason as the other submission notifiers: the screen
/// calls [submit] via `ref.read(...notifier)` and never watches this provider.
final class ChangePasswordNotifierProvider
    extends $AsyncNotifierProvider<ChangePasswordNotifier, void> {
  /// Drives the "Ganti Password" form.
  ///
  /// The `AsyncValue<void>` state reflects the in-flight request so the save
  /// button can show a spinner; [submit] returns the full [ApiResult] so the
  /// screen can pop on success or surface field-level validation errors (e.g. a
  /// wrong current password).
  ///
  /// Kept alive for the same reason as the other submission notifiers: the screen
  /// calls [submit] via `ref.read(...notifier)` and never watches this provider.
  ChangePasswordNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'changePasswordProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$changePasswordNotifierHash();

  @$internal
  @override
  ChangePasswordNotifier create() => ChangePasswordNotifier();
}

String _$changePasswordNotifierHash() =>
    r'36cce082fbe75b693c35d9a8aaf3c47af145e555';

/// Drives the "Ganti Password" form.
///
/// The `AsyncValue<void>` state reflects the in-flight request so the save
/// button can show a spinner; [submit] returns the full [ApiResult] so the
/// screen can pop on success or surface field-level validation errors (e.g. a
/// wrong current password).
///
/// Kept alive for the same reason as the other submission notifiers: the screen
/// calls [submit] via `ref.read(...notifier)` and never watches this provider.

abstract class _$ChangePasswordNotifier extends $AsyncNotifier<void> {
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
