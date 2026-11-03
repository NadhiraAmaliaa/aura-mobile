// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trusted_attendance_date_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The current attendance date (`yyyy-MM-dd`) from the trusted clock, for
/// display only.
///
/// Lets the attendance sections tell a dashboard snapshot cached on an earlier
/// day apart from today's. Emits `null` while trusted time is unavailable (no
/// anchor yet, or one invalidated by a reboot); the device clock is never used
/// as a fallback. Capture does not read this provider: it takes its own trusted
/// moment at the time of capture.
///
/// Re-evaluated whenever the anchor changes and on a short interval. It only
/// reads the local trusted clock — it never fetches, caches or refreshes
/// attendance data.

@ProviderFor(trustedAttendanceDate)
final trustedAttendanceDateProvider = TrustedAttendanceDateProvider._();

/// The current attendance date (`yyyy-MM-dd`) from the trusted clock, for
/// display only.
///
/// Lets the attendance sections tell a dashboard snapshot cached on an earlier
/// day apart from today's. Emits `null` while trusted time is unavailable (no
/// anchor yet, or one invalidated by a reboot); the device clock is never used
/// as a fallback. Capture does not read this provider: it takes its own trusted
/// moment at the time of capture.
///
/// Re-evaluated whenever the anchor changes and on a short interval. It only
/// reads the local trusted clock — it never fetches, caches or refreshes
/// attendance data.

final class TrustedAttendanceDateProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, Stream<String?>>
    with $FutureModifier<String?>, $StreamProvider<String?> {
  /// The current attendance date (`yyyy-MM-dd`) from the trusted clock, for
  /// display only.
  ///
  /// Lets the attendance sections tell a dashboard snapshot cached on an earlier
  /// day apart from today's. Emits `null` while trusted time is unavailable (no
  /// anchor yet, or one invalidated by a reboot); the device clock is never used
  /// as a fallback. Capture does not read this provider: it takes its own trusted
  /// moment at the time of capture.
  ///
  /// Re-evaluated whenever the anchor changes and on a short interval. It only
  /// reads the local trusted clock — it never fetches, caches or refreshes
  /// attendance data.
  TrustedAttendanceDateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trustedAttendanceDateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trustedAttendanceDateHash();

  @$internal
  @override
  $StreamProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<String?> create(Ref ref) {
    return trustedAttendanceDate(ref);
  }
}

String _$trustedAttendanceDateHash() =>
    r'd0cf0d4d16960d250a4443860119be45403413f0';
