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
/// loading / error / data exhaustively. On failure the typed `AppException` is
/// surfaced through `AsyncError` for the UI to present and retry.

@ProviderFor(AttendanceDashboardNotifier)
final attendanceDashboardProvider = AttendanceDashboardNotifierProvider._();

/// Loads the attendance dashboard (today's snapshot + monthly recap).
///
/// Exposed as `AsyncValue<AttendanceDashboardModel>` so the screen can render
/// loading / error / data exhaustively. On failure the typed `AppException` is
/// surfaced through `AsyncError` for the UI to present and retry.
final class AttendanceDashboardNotifierProvider
    extends
        $AsyncNotifierProvider<
          AttendanceDashboardNotifier,
          AttendanceDashboardModel
        > {
  /// Loads the attendance dashboard (today's snapshot + monthly recap).
  ///
  /// Exposed as `AsyncValue<AttendanceDashboardModel>` so the screen can render
  /// loading / error / data exhaustively. On failure the typed `AppException` is
  /// surfaced through `AsyncError` for the UI to present and retry.
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
    r'10448cf299c26610d5b47d29732efbec1db00f85';

/// Loads the attendance dashboard (today's snapshot + monthly recap).
///
/// Exposed as `AsyncValue<AttendanceDashboardModel>` so the screen can render
/// loading / error / data exhaustively. On failure the typed `AppException` is
/// surfaced through `AsyncError` for the UI to present and retry.

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
