// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_edit_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the "Ubah Kontak" form.
///
/// The `AsyncValue<void>` state reflects the in-flight request so the save
/// button can show a spinner; [updateContact] returns the full [ApiResult] so
/// the screen can pop on success or surface field-level validation errors. On
/// success the authenticated session user is refreshed in place so the profile
/// screen reflects the new contact details immediately.
///
/// Kept alive for the same reason as `LeaveSubmitNotifier`: the screen only
/// calls [updateContact] via `ref.read(...notifier)` and never watches this
/// provider, so an auto-dispose provider would be torn down mid-request.

@ProviderFor(ProfileEditNotifier)
final profileEditProvider = ProfileEditNotifierProvider._();

/// Drives the "Ubah Kontak" form.
///
/// The `AsyncValue<void>` state reflects the in-flight request so the save
/// button can show a spinner; [updateContact] returns the full [ApiResult] so
/// the screen can pop on success or surface field-level validation errors. On
/// success the authenticated session user is refreshed in place so the profile
/// screen reflects the new contact details immediately.
///
/// Kept alive for the same reason as `LeaveSubmitNotifier`: the screen only
/// calls [updateContact] via `ref.read(...notifier)` and never watches this
/// provider, so an auto-dispose provider would be torn down mid-request.
final class ProfileEditNotifierProvider
    extends $AsyncNotifierProvider<ProfileEditNotifier, void> {
  /// Drives the "Ubah Kontak" form.
  ///
  /// The `AsyncValue<void>` state reflects the in-flight request so the save
  /// button can show a spinner; [updateContact] returns the full [ApiResult] so
  /// the screen can pop on success or surface field-level validation errors. On
  /// success the authenticated session user is refreshed in place so the profile
  /// screen reflects the new contact details immediately.
  ///
  /// Kept alive for the same reason as `LeaveSubmitNotifier`: the screen only
  /// calls [updateContact] via `ref.read(...notifier)` and never watches this
  /// provider, so an auto-dispose provider would be torn down mid-request.
  ProfileEditNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileEditProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileEditNotifierHash();

  @$internal
  @override
  ProfileEditNotifier create() => ProfileEditNotifier();
}

String _$profileEditNotifierHash() =>
    r'2c75aca2eba065ae8f0e38fa8756bbe6d961082d';

/// Drives the "Ubah Kontak" form.
///
/// The `AsyncValue<void>` state reflects the in-flight request so the save
/// button can show a spinner; [updateContact] returns the full [ApiResult] so
/// the screen can pop on success or surface field-level validation errors. On
/// success the authenticated session user is refreshed in place so the profile
/// screen reflects the new contact details immediately.
///
/// Kept alive for the same reason as `LeaveSubmitNotifier`: the screen only
/// calls [updateContact] via `ref.read(...notifier)` and never watches this
/// provider, so an auto-dispose provider would be torn down mid-request.

abstract class _$ProfileEditNotifier extends $AsyncNotifier<void> {
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
