// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's [GoRouter].
///
/// An auth-driven `redirect` + `refreshListenable` will be added with the auth
/// feature (see the architecture doc §8). For now it exposes a single
/// placeholder route so the shell is runnable.

@ProviderFor(router)
final routerProvider = RouterProvider._();

/// The app's [GoRouter].
///
/// An auth-driven `redirect` + `refreshListenable` will be added with the auth
/// feature (see the architecture doc §8). For now it exposes a single
/// placeholder route so the shell is runnable.

final class RouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The app's [GoRouter].
  ///
  /// An auth-driven `redirect` + `refreshListenable` will be added with the auth
  /// feature (see the architecture doc §8). For now it exposes a single
  /// placeholder route so the shell is runnable.
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

String _$routerHash() => r'3ae52b954dbecce9ce1488b6b67901149f78a5ae';
