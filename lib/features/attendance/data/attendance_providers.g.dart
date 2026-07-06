// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Retrofit attendance client bound to the shared Dio instance.

@ProviderFor(attendanceApi)
final attendanceApiProvider = AttendanceApiProvider._();

/// Retrofit attendance client bound to the shared Dio instance.

final class AttendanceApiProvider
    extends $FunctionalProvider<AttendanceApi, AttendanceApi, AttendanceApi>
    with $Provider<AttendanceApi> {
  /// Retrofit attendance client bound to the shared Dio instance.
  AttendanceApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attendanceApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attendanceApiHash();

  @$internal
  @override
  $ProviderElement<AttendanceApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AttendanceApi create(Ref ref) {
    return attendanceApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AttendanceApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AttendanceApi>(value),
    );
  }
}

String _$attendanceApiHash() => r'608c0bf50b62406c0a094610260a7ba38da4d614';

/// The attendance repository seam consumed by the presentation layer.

@ProviderFor(attendanceRepository)
final attendanceRepositoryProvider = AttendanceRepositoryProvider._();

/// The attendance repository seam consumed by the presentation layer.

final class AttendanceRepositoryProvider
    extends
        $FunctionalProvider<
          AttendanceRepository,
          AttendanceRepository,
          AttendanceRepository
        >
    with $Provider<AttendanceRepository> {
  /// The attendance repository seam consumed by the presentation layer.
  AttendanceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attendanceRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attendanceRepositoryHash();

  @$internal
  @override
  $ProviderElement<AttendanceRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AttendanceRepository create(Ref ref) {
    return attendanceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AttendanceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AttendanceRepository>(value),
    );
  }
}

String _$attendanceRepositoryHash() =>
    r'8421c9c4cd5a49b681943d8aa3f409885f68fe61';
