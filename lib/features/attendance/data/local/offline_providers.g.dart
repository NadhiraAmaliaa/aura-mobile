// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The offline attendance queue store, backed by the shared app database.

@ProviderFor(attendanceQueueStore)
final attendanceQueueStoreProvider = AttendanceQueueStoreProvider._();

/// The offline attendance queue store, backed by the shared app database.

final class AttendanceQueueStoreProvider
    extends
        $FunctionalProvider<
          AsyncValue<AttendanceQueueStore>,
          AttendanceQueueStore,
          FutureOr<AttendanceQueueStore>
        >
    with
        $FutureModifier<AttendanceQueueStore>,
        $FutureProvider<AttendanceQueueStore> {
  /// The offline attendance queue store, backed by the shared app database.
  AttendanceQueueStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attendanceQueueStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attendanceQueueStoreHash();

  @$internal
  @override
  $FutureProviderElement<AttendanceQueueStore> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AttendanceQueueStore> create(Ref ref) {
    return attendanceQueueStore(ref);
  }
}

String _$attendanceQueueStoreHash() =>
    r'a63f4397680182875f9923a308ad9fac35811d8b';

/// The cached office-configuration store, backed by the shared app database.

@ProviderFor(officeConfigCacheStore)
final officeConfigCacheStoreProvider = OfficeConfigCacheStoreProvider._();

/// The cached office-configuration store, backed by the shared app database.

final class OfficeConfigCacheStoreProvider
    extends
        $FunctionalProvider<
          AsyncValue<OfficeConfigCacheStore>,
          OfficeConfigCacheStore,
          FutureOr<OfficeConfigCacheStore>
        >
    with
        $FutureModifier<OfficeConfigCacheStore>,
        $FutureProvider<OfficeConfigCacheStore> {
  /// The cached office-configuration store, backed by the shared app database.
  OfficeConfigCacheStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'officeConfigCacheStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$officeConfigCacheStoreHash();

  @$internal
  @override
  $FutureProviderElement<OfficeConfigCacheStore> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<OfficeConfigCacheStore> create(Ref ref) {
    return officeConfigCacheStore(ref);
  }
}

String _$officeConfigCacheStoreHash() =>
    r'96ef89fa4e92680c286026271a0556ef290b2786';

/// The cached attendance-dashboard store, backed by the shared app database.

@ProviderFor(dashboardCacheStore)
final dashboardCacheStoreProvider = DashboardCacheStoreProvider._();

/// The cached attendance-dashboard store, backed by the shared app database.

final class DashboardCacheStoreProvider
    extends
        $FunctionalProvider<
          AsyncValue<DashboardCacheStore>,
          DashboardCacheStore,
          FutureOr<DashboardCacheStore>
        >
    with
        $FutureModifier<DashboardCacheStore>,
        $FutureProvider<DashboardCacheStore> {
  /// The cached attendance-dashboard store, backed by the shared app database.
  DashboardCacheStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardCacheStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardCacheStoreHash();

  @$internal
  @override
  $FutureProviderElement<DashboardCacheStore> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DashboardCacheStore> create(Ref ref) {
    return dashboardCacheStore(ref);
  }
}

String _$dashboardCacheStoreHash() =>
    r'5add003c427c972963d4704d9ae0827e4f69ec0f';
