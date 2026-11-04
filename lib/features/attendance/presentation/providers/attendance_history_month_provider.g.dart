// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_history_month_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The latest month the history offers (`yyyy-MM`), resolved once per visit.
///
/// Only reads providers that are already alive (the dashboard below this
/// screen and its trusted date), so opening the history never starts a
/// dashboard fetch or a trusted-time lookup of its own.

@ProviderFor(attendanceHistoryLatestMonth)
final attendanceHistoryLatestMonthProvider =
    AttendanceHistoryLatestMonthProvider._();

/// The latest month the history offers (`yyyy-MM`), resolved once per visit.
///
/// Only reads providers that are already alive (the dashboard below this
/// screen and its trusted date), so opening the history never starts a
/// dashboard fetch or a trusted-time lookup of its own.

final class AttendanceHistoryLatestMonthProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// The latest month the history offers (`yyyy-MM`), resolved once per visit.
  ///
  /// Only reads providers that are already alive (the dashboard below this
  /// screen and its trusted date), so opening the history never starts a
  /// dashboard fetch or a trusted-time lookup of its own.
  AttendanceHistoryLatestMonthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attendanceHistoryLatestMonthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attendanceHistoryLatestMonthHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return attendanceHistoryLatestMonth(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$attendanceHistoryLatestMonthHash() =>
    r'3d8ba854de4834ca9f4a984ad1ba93e97c7c91e6';

/// The month selected on the history screen (`yyyy-MM`). Starts at the latest
/// month and resets on every visit (auto-disposed with the screen).

@ProviderFor(AttendanceHistoryMonth)
final attendanceHistoryMonthProvider = AttendanceHistoryMonthProvider._();

/// The month selected on the history screen (`yyyy-MM`). Starts at the latest
/// month and resets on every visit (auto-disposed with the screen).
final class AttendanceHistoryMonthProvider
    extends $NotifierProvider<AttendanceHistoryMonth, String> {
  /// The month selected on the history screen (`yyyy-MM`). Starts at the latest
  /// month and resets on every visit (auto-disposed with the screen).
  AttendanceHistoryMonthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attendanceHistoryMonthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attendanceHistoryMonthHash();

  @$internal
  @override
  AttendanceHistoryMonth create() => AttendanceHistoryMonth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$attendanceHistoryMonthHash() =>
    r'5531ad3a945e73ed68c473f46c97113d51939df5';

/// The month selected on the history screen (`yyyy-MM`). Starts at the latest
/// month and resets on every visit (auto-disposed with the screen).

abstract class _$AttendanceHistoryMonth extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The monthly recap for a `yyyy-MM` [month], read from the existing dashboard
/// endpoint so the six categories keep the backend's rules exactly.
///
/// A recap echoing a different month (e.g. an older backend resolving the
/// month differently) is rejected rather than shown under the wrong month.

@ProviderFor(attendanceMonthSummary)
final attendanceMonthSummaryProvider = AttendanceMonthSummaryFamily._();

/// The monthly recap for a `yyyy-MM` [month], read from the existing dashboard
/// endpoint so the six categories keep the backend's rules exactly.
///
/// A recap echoing a different month (e.g. an older backend resolving the
/// month differently) is rejected rather than shown under the wrong month.

final class AttendanceMonthSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<MonthlySummaryModel>,
          MonthlySummaryModel,
          FutureOr<MonthlySummaryModel>
        >
    with
        $FutureModifier<MonthlySummaryModel>,
        $FutureProvider<MonthlySummaryModel> {
  /// The monthly recap for a `yyyy-MM` [month], read from the existing dashboard
  /// endpoint so the six categories keep the backend's rules exactly.
  ///
  /// A recap echoing a different month (e.g. an older backend resolving the
  /// month differently) is rejected rather than shown under the wrong month.
  AttendanceMonthSummaryProvider._({
    required AttendanceMonthSummaryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'attendanceMonthSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$attendanceMonthSummaryHash();

  @override
  String toString() {
    return r'attendanceMonthSummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<MonthlySummaryModel> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MonthlySummaryModel> create(Ref ref) {
    final argument = this.argument as String;
    return attendanceMonthSummary(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AttendanceMonthSummaryProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$attendanceMonthSummaryHash() =>
    r'0162864fbadaaa05dd77ab69de83595625794f95';

/// The monthly recap for a `yyyy-MM` [month], read from the existing dashboard
/// endpoint so the six categories keep the backend's rules exactly.
///
/// A recap echoing a different month (e.g. an older backend resolving the
/// month differently) is rejected rather than shown under the wrong month.

final class AttendanceMonthSummaryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<MonthlySummaryModel>, String> {
  AttendanceMonthSummaryFamily._()
    : super(
        retry: null,
        name: r'attendanceMonthSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The monthly recap for a `yyyy-MM` [month], read from the existing dashboard
  /// endpoint so the six categories keep the backend's rules exactly.
  ///
  /// A recap echoing a different month (e.g. an older backend resolving the
  /// month differently) is rejected rather than shown under the wrong month.

  AttendanceMonthSummaryProvider call(String month) =>
      AttendanceMonthSummaryProvider._(argument: month, from: this);

  @override
  String toString() => r'attendanceMonthSummaryProvider';
}
