// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The offline attendance sync engine, wired to the local queue store and the
/// network repository.

@ProviderFor(attendanceSyncService)
final attendanceSyncServiceProvider = AttendanceSyncServiceProvider._();

/// The offline attendance sync engine, wired to the local queue store and the
/// network repository.

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
  /// The offline attendance sync engine, wired to the local queue store and the
  /// network repository.
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
    r'621ab33342b909cb6419982a7feeef89d38b0e24';
