// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_offline_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The cached leave-list store, backed by the shared app database.
///
/// Isolated to the leave feature; it shares only the single on-device database,
/// not the attendance offline queue's behavior.

@ProviderFor(leaveListCacheStore)
final leaveListCacheStoreProvider = LeaveListCacheStoreProvider._();

/// The cached leave-list store, backed by the shared app database.
///
/// Isolated to the leave feature; it shares only the single on-device database,
/// not the attendance offline queue's behavior.

final class LeaveListCacheStoreProvider
    extends
        $FunctionalProvider<
          AsyncValue<LeaveListCacheStore>,
          LeaveListCacheStore,
          FutureOr<LeaveListCacheStore>
        >
    with
        $FutureModifier<LeaveListCacheStore>,
        $FutureProvider<LeaveListCacheStore> {
  /// The cached leave-list store, backed by the shared app database.
  ///
  /// Isolated to the leave feature; it shares only the single on-device database,
  /// not the attendance offline queue's behavior.
  LeaveListCacheStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'leaveListCacheStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$leaveListCacheStoreHash();

  @$internal
  @override
  $FutureProviderElement<LeaveListCacheStore> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LeaveListCacheStore> create(Ref ref) {
    return leaveListCacheStore(ref);
  }
}

String _$leaveListCacheStoreHash() =>
    r'221b44532f907130382da02c1db95b54c01d3fad';
