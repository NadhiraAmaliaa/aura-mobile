// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avatar_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the profile-photo upload / removal.
///
/// The `AsyncValue<void>` state reflects the in-flight request so the avatar
/// can show a spinner; [upload] and [remove] return the full [ApiResult] so the
/// screen can surface a snackbar on success or map an error message. On success
/// the authenticated session user is refreshed in place so the new photo shows
/// immediately.
///
/// Kept alive for the same reason as `ProfileEditNotifier`: the screen only
/// calls these methods via `ref.read(...notifier)` and never watches this
/// provider, so an auto-dispose provider would be torn down mid-request.

@ProviderFor(AvatarNotifier)
final avatarProvider = AvatarNotifierProvider._();

/// Drives the profile-photo upload / removal.
///
/// The `AsyncValue<void>` state reflects the in-flight request so the avatar
/// can show a spinner; [upload] and [remove] return the full [ApiResult] so the
/// screen can surface a snackbar on success or map an error message. On success
/// the authenticated session user is refreshed in place so the new photo shows
/// immediately.
///
/// Kept alive for the same reason as `ProfileEditNotifier`: the screen only
/// calls these methods via `ref.read(...notifier)` and never watches this
/// provider, so an auto-dispose provider would be torn down mid-request.
final class AvatarNotifierProvider
    extends $AsyncNotifierProvider<AvatarNotifier, void> {
  /// Drives the profile-photo upload / removal.
  ///
  /// The `AsyncValue<void>` state reflects the in-flight request so the avatar
  /// can show a spinner; [upload] and [remove] return the full [ApiResult] so the
  /// screen can surface a snackbar on success or map an error message. On success
  /// the authenticated session user is refreshed in place so the new photo shows
  /// immediately.
  ///
  /// Kept alive for the same reason as `ProfileEditNotifier`: the screen only
  /// calls these methods via `ref.read(...notifier)` and never watches this
  /// provider, so an auto-dispose provider would be torn down mid-request.
  AvatarNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'avatarProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$avatarNotifierHash();

  @$internal
  @override
  AvatarNotifier create() => AvatarNotifier();
}

String _$avatarNotifierHash() => r'2aa4e6252e8b26b487d0353c6c42c39b1557bc16';

/// Drives the profile-photo upload / removal.
///
/// The `AsyncValue<void>` state reflects the in-flight request so the avatar
/// can show a spinner; [upload] and [remove] return the full [ApiResult] so the
/// screen can surface a snackbar on success or map an error message. On success
/// the authenticated session user is refreshed in place so the new photo shows
/// immediately.
///
/// Kept alive for the same reason as `ProfileEditNotifier`: the screen only
/// calls these methods via `ref.read(...notifier)` and never watches this
/// provider, so an auto-dispose provider would be torn down mid-request.

abstract class _$AvatarNotifier extends $AsyncNotifier<void> {
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
