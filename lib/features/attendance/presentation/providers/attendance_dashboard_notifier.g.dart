// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_dashboard_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads the attendance dashboard (today's snapshot + monthly recap).
///
/// Exposed as `AsyncValue<AttendanceDashboardModel>` so the screen can render
/// loading / error / data exhaustively. A successful load is cached on-device;
/// when the backend is unreachable (offline / timeout / 5xx) the cached
/// snapshot is served so the screen stays usable instead of erroring or
/// spinning forever. Only an explicit `401` surfaces as an error — a transient
/// failure must never look like a broken session.

@ProviderFor(AttendanceDashboardNotifier)
final attendanceDashboardProvider = AttendanceDashboardNotifierProvider._();

/// Loads the attendance dashboard (today's snapshot + monthly recap).
///
/// Exposed as `AsyncValue<AttendanceDashboardModel>` so the screen can render
/// loading / error / data exhaustively. A successful load is cached on-device;
/// when the backend is unreachable (offline / timeout / 5xx) the cached
/// snapshot is served so the screen stays usable instead of erroring or
/// spinning forever. Only an explicit `401` surfaces as an error — a transient
/// failure must never look like a broken session.
final class AttendanceDashboardNotifierProvider
    extends
        $AsyncNotifierProvider<
          AttendanceDashboardNotifier,
          AttendanceDashboardModel
        > {
  /// Loads the attendance dashboard (today's snapshot + monthly recap).
  ///
  /// Exposed as `AsyncValue<AttendanceDashboardModel>` so the screen can render
  /// loading / error / data exhaustively. A successful load is cached on-device;
  /// when the backend is unreachable (offline / timeout / 5xx) the cached
  /// snapshot is served so the screen stays usable instead of erroring or
  /// spinning forever. Only an explicit `401` surfaces as an error — a transient
  /// failure must never look like a broken session.
  AttendanceDashboardNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attendanceDashboardProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attendanceDashboardNotifierHash();

  @$internal
  @override
  AttendanceDashboardNotifier create() => AttendanceDashboardNotifier();
}

String _$attendanceDashboardNotifierHash() =>
    r'cca1cf596e3411d2a115b688921966ca9474016a';

/// Loads the attendance dashboard (today's snapshot + monthly recap).
///
/// Exposed as `AsyncValue<AttendanceDashboardModel>` so the screen can render
/// loading / error / data exhaustively. A successful load is cached on-device;
/// when the backend is unreachable (offline / timeout / 5xx) the cached
/// snapshot is served so the screen stays usable instead of erroring or
/// spinning forever. Only an explicit `401` surfaces as an error — a transient
/// failure must never look like a broken session.

abstract class _$AttendanceDashboardNotifier
    extends $AsyncNotifier<AttendanceDashboardModel> {
  FutureOr<AttendanceDashboardModel> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<AttendanceDashboardModel>,
              AttendanceDashboardModel
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<AttendanceDashboardModel>,
                AttendanceDashboardModel
              >,
              AsyncValue<AttendanceDashboardModel>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
