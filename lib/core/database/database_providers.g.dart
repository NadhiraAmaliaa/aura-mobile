// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The shared, lazily-opened application [Database].
///
/// Kept alive for the app's lifetime and closed on dispose. Downstream stores
/// depend on this via `ref.watch(appDatabaseProvider.future)`.

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

/// The shared, lazily-opened application [Database].
///
/// Kept alive for the app's lifetime and closed on dispose. Downstream stores
/// depend on this via `ref.watch(appDatabaseProvider.future)`.

final class AppDatabaseProvider
    extends
        $FunctionalProvider<AsyncValue<Database>, Database, FutureOr<Database>>
    with $FutureModifier<Database>, $FutureProvider<Database> {
  /// The shared, lazily-opened application [Database].
  ///
  /// Kept alive for the app's lifetime and closed on dispose. Downstream stores
  /// depend on this via `ref.watch(appDatabaseProvider.future)`.
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $FutureProviderElement<Database> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Database> create(Ref ref) {
    return appDatabase(ref);
  }
}

String _$appDatabaseHash() => r'1da3558ceedc1f2b4b556a2e2544d78606ad65a8';
