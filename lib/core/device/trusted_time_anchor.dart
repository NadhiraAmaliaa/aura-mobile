/// A trust anchor recording the last verified server time together with the
/// monotonic clock reading and boot identity at that moment.
///
/// To estimate the current time: `serverTimeUtc + (currentMono - monotonicMs)`.
///
/// The anchor is invalidated when a reboot is detected (Android: [bootCount]
/// differs; iOS: monotonic regression or sanity-check failure).
class TrustedTimeAnchor {
  const TrustedTimeAnchor({
    required this.serverTimeUtc,
    required this.monotonicMs,
    this.bootCount,
  });

  /// The server-provided UTC time at the moment the anchor was created.
  final DateTime serverTimeUtc;

  /// The platform monotonic clock reading (ms since boot) when the anchor was
  /// created.
  final int monotonicMs;

  /// Android-only: `Settings.Global.BOOT_COUNT` at the time the anchor was
  /// saved. `null` on iOS or unsupported Android devices.
  final int? bootCount;

  /// Projects the current UTC time using the elapsed monotonic delta.
  DateTime estimateUtcNow(int currentMonotonicMs) {
    final deltaMs = currentMonotonicMs - monotonicMs;
    return serverTimeUtc.add(Duration(milliseconds: deltaMs));
  }

  Map<String, Object?> toMap() => {
    'server_time_utc': serverTimeUtc.toIso8601String(),
    'monotonic_ms': monotonicMs,
    'boot_count': bootCount,
  };

  factory TrustedTimeAnchor.fromMap(Map<String, Object?> map) {
    return TrustedTimeAnchor(
      serverTimeUtc: DateTime.parse(map['server_time_utc']! as String),
      monotonicMs: map['monotonic_ms']! as int,
      bootCount: map['boot_count'] as int?,
    );
  }
}
