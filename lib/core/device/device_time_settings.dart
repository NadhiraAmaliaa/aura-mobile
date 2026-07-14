import 'package:flutter/services.dart';

/// Reads the device's automatic date & time configuration.
///
/// A testable seam so the attendance capture flow can hard-block when the user
/// has switched the device clock to manual (a common timestamp-spoofing
/// vector), while staying trivially fakeable in unit tests.
abstract interface class DeviceTimeSettings {
  /// Whether the device is using network-provided, automatic date & time.
  ///
  /// Returns `true` only when BOTH "Automatic date & time" and "Automatic time
  /// zone" are enabled. Returns `false` when either is off. Returns `null` when
  /// the value cannot be determined (non-Android platforms, tests, or a read
  /// error) — callers MUST treat `null` as "not verifiable" and must NOT
  /// hard-block on it.
  Future<bool?> isAutomaticEnabled();

  /// Open the system Date & Time settings screen so the user can enable the
  /// automatic clock. Returns whether the screen was opened.
  Future<bool> openDateTimeSettings();
}

/// Thrown by the capture flow when attendance is blocked because the device is
/// not using automatic date & time (and time zone).
class AutomaticTimeDisabledException implements Exception {
  const AutomaticTimeDisabledException([this.message = _defaultMessage]);

  static const _defaultMessage =
      'Aktifkan Tanggal & Waktu otomatis (termasuk zona waktu otomatis) di '
      'perangkat Anda sebelum melakukan absensi.';

  final String message;

  @override
  String toString() => 'AutomaticTimeDisabledException: $message';
}

/// [DeviceTimeSettings] backed by a platform method channel (Android only).
///
/// The native side reads `Settings.Global.AUTO_TIME` and
/// `Settings.Global.AUTO_TIME_ZONE` and returns their combined result. On
/// platforms without the channel (iOS today, unit tests) the calls fall back to
/// `null` / `false` so nothing hard-blocks on an unverifiable device.
class MethodChannelDeviceTimeSettings implements DeviceTimeSettings {
  MethodChannelDeviceTimeSettings([MethodChannel? channel])
    : _channel = channel ?? const MethodChannel(_channelName);

  static const _channelName = 'id.aura.app/device_time';

  final MethodChannel _channel;

  @override
  Future<bool?> isAutomaticEnabled() async {
    try {
      return await _channel.invokeMethod<bool>('isAutomaticTimeEnabled');
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  @override
  Future<bool> openDateTimeSettings() async {
    try {
      final opened = await _channel.invokeMethod<bool>('openDateTimeSettings');
      return opened ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
