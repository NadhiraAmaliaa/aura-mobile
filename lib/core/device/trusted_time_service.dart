import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import 'platform_clock.dart';
import 'trusted_time_anchor.dart';

/// Thrown when trusted time is unavailable (no anchor, reboot detected, etc.)
/// and the attendance capture must be blocked until the device goes online.
class TrustedTimeUnavailableException implements Exception {
  const TrustedTimeUnavailableException([
    this.message = _defaultMessage,
  ]);

  static const _defaultMessage =
      'Waktu terpercaya tidak tersedia. '
      'Hubungkan ke internet terlebih dahulu untuk melanjutkan absensi.';

  static const rebootMessage =
      'Perangkat telah dimulai ulang. '
      'Hubungkan ke internet terlebih dahulu untuk melanjutkan absensi.';

  final String message;

  @override
  String toString() => 'TrustedTimeUnavailableException: $message';
}

/// Manages a monotonic-clock-anchored trusted time that is immune to device
/// wall-clock manipulation.
///
/// The trusted current time is: `anchor.serverTimeUtc + (currentMono - anchor.monotonicMs)`.
///
/// The anchor is refreshed from HTTP Date headers on every successful API
/// response (via [TrustedTimeInterceptor]). It is persisted in SQLite and
/// survives app restarts, but is invalidated on device reboot.
class TrustedTimeService {
  TrustedTimeService(this._clock, this._db, {this.wallClock = DateTime.now});

  final PlatformClock _clock;
  final Database _db;

  /// Injectable wall clock — only used in the iOS sanity check (as a
  /// validation gate to invalidate the anchor, never as a time source).
  /// Tests override this to return deterministic values.
  final DateTime Function() wallClock;

  /// In-memory cache of the current anchor, loaded from SQLite on first use.
  TrustedTimeAnchor? _anchor;
  bool _loaded = false;

  /// The sanity-check threshold for iOS reboot detection (secondary check).
  /// After a reboot, `estimatedNow` will be wildly off from `DateTime.now()`.
  /// 60 seconds is well above the worst-case legitimate drift (~22s at 50 ppm
  /// over 5 days offline) while keeping the maximum exploitable captured_at
  /// error to ≤1 minute — operationally irrelevant for attendance.
  static const _rebootSanityThreshold = Duration(seconds: 60);

  /// Returns the current trusted UTC time, or throws
  /// [TrustedTimeUnavailableException] if no valid anchor exists.
  Future<DateTime> now() async {
    await _ensureLoaded();

    final anchor = _anchor;
    if (anchor == null) {
      throw const TrustedTimeUnavailableException();
    }

    final currentMono = await _clock.monotonicMs();
    if (currentMono == null) {
      throw const TrustedTimeUnavailableException();
    }

    // Reboot detection: the anchor must belong to the current boot session.
    if (await _isRebootDetected(anchor, currentMono)) {
      _anchor = null;
      await _deleteAnchor();
      throw const TrustedTimeUnavailableException(
        TrustedTimeUnavailableException.rebootMessage,
      );
    }

    return anchor.estimateUtcNow(currentMono);
  }

  /// Whether a valid anchor exists and belongs to the current boot session.
  Future<bool> get isAvailable async {
    try {
      await now();
      return true;
    } on TrustedTimeUnavailableException {
      return false;
    }
  }

  /// Establishes or refreshes the trust anchor from a verified server time.
  ///
  /// Called by [TrustedTimeInterceptor] on every successful HTTP response that
  /// carries a Date header, and can also be called directly after an explicit
  /// time-sync endpoint.
  Future<void> setAnchor(DateTime serverTimeUtc) async {
    final currentMono = await _clock.monotonicMs();
    if (currentMono == null) return;

    final currentBootCount = await _clock.bootCount();

    _anchor = TrustedTimeAnchor(
      serverTimeUtc: serverTimeUtc,
      monotonicMs: currentMono,
      bootCount: currentBootCount,
    );

    await _persistAnchor(_anchor!);
  }

  /// Detects whether the device has rebooted since the anchor was created.
  Future<bool> _isRebootDetected(
    TrustedTimeAnchor anchor,
    int currentMono,
  ) async {
    // Primary check (both platforms): monotonic regression is a definitive
    // reboot signal — the clock reset to zero and hasn't caught up yet.
    if (currentMono < anchor.monotonicMs) return true;

    // Android: compare BOOT_COUNT for reliable detection even when
    // post-reboot uptime exceeds the saved value.
    final currentBootCount = await _clock.bootCount();
    if (anchor.bootCount != null && currentBootCount != null) {
      return currentBootCount != anchor.bootCount;
    }

    // iOS (no BOOT_COUNT): secondary sanity check. After a reboot the
    // monotonic clock resets, so estimatedNow will be wildly wrong. We compare
    // it against DateTime.now() — if the gap exceeds the threshold, the anchor
    // is from a previous boot session. DateTime.now() is used ONLY as a
    // validation gate here (to invalidate the anchor), never as the source of
    // captured_at.
    if (anchor.bootCount == null && currentBootCount == null) {
      final estimatedNow = anchor.estimateUtcNow(currentMono);
      final wallNow = wallClock().toUtc();
      final drift = estimatedNow.difference(wallNow).abs();
      if (drift > _rebootSanityThreshold) return true;
    }

    return false;
  }

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    _anchor = await _loadAnchor();
    _loaded = true;
  }

  Future<TrustedTimeAnchor?> _loadAnchor() async {
    final rows = await _db.query(trustedTimeAnchorTable, limit: 1);
    if (rows.isEmpty) return null;
    return TrustedTimeAnchor.fromMap(rows.first);
  }

  Future<void> _persistAnchor(TrustedTimeAnchor anchor) async {
    await _db.transaction((txn) async {
      await txn.delete(trustedTimeAnchorTable);
      await txn.insert(trustedTimeAnchorTable, anchor.toMap());
    });
  }

  Future<void> _deleteAnchor() async {
    await _db.delete(trustedTimeAnchorTable);
  }
}
