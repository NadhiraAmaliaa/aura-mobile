// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's [GoRouter], driven by [AuthNotifier].
///
/// The redirect is pure and cheap: it only reads the current auth snapshot and
/// returns a path. Re-evaluation is triggered by a [ValueNotifier] bumped
/// whenever the auth state changes (see architecture doc §8).

@ProviderFor(router)
final routerProvider = RouterProvider._();

/// The app's [GoRouter], driven by [AuthNotifier].
///
/// The redirect is pure and cheap: it only reads the current auth snapshot and
/// returns a path. Re-evaluation is triggered by a [ValueNotifier] bumped
/// whenever the auth state changes (see architecture doc §8).

final class RouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The app's [GoRouter], driven by [AuthNotifier].
  ///
  /// The redirect is pure and cheap: it only reads the current auth snapshot and
  /// returns a path. Re-evaluation is triggered by a [ValueNotifier] bumped
  /// whenever the auth state changes (see architecture doc §8).
  RouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routerHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return router(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$routerHash() => r'bdfb33e4d0d20e3092c3ec47b8f064ed5aebacb5';
