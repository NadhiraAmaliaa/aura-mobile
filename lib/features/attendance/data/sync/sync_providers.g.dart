// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The offline attendance sync engine, wired to the local queue store, the
/// network repository and the dashboard cache it updates after each successful
/// sync.

@ProviderFor(attendanceSyncService)
final attendanceSyncServiceProvider = AttendanceSyncServiceProvider._();

/// The offline attendance sync engine, wired to the local queue store, the
/// network repository and the dashboard cache it updates after each successful
/// sync.

final class AttendanceSyncServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<AttendanceSyncService>,
          AttendanceSyncService,
          FutureOr<AttendanceSyncService>
        >
    with
        $FutureModifier<AttendanceSyncService>,
        $FutureProvider<AttendanceSyncService> {
  /// The offline attendance sync engine, wired to the local queue store, the
  /// network repository and the dashboard cache it updates after each successful
  /// sync.
  AttendanceSyncServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attendanceSyncServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attendanceSyncServiceHash();

  @$internal
  @override
  $FutureProviderElement<AttendanceSyncService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AttendanceSyncService> create(Ref ref) {
    return attendanceSyncService(ref);
  }
}

String _$attendanceSyncServiceHash() =>
    r'e9695101dfdae7e3e95d9f257d653e3a172101ca';
