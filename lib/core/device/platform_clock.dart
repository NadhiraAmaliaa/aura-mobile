import 'dart:io';

import 'package:flutter/services.dart';

/// Platform-specific monotonic clock and boot-session identity.
///
/// Reads values from the `id.aura.app/device_time` MethodChannel (Android) or
/// the iOS channel registered in `AppDelegate.swift`. Testable via constructor
/// injection (override the methods or use [FakePlatformClock]).
abstract interface class PlatformClock {
  /// Monotonic milliseconds since last boot, including device sleep.
  /// Returns `null` when the platform does not support the call.
  Future<int?> monotonicMs();

  /// Android-only: `Settings.Global.BOOT_COUNT` (API 24+).
  /// Returns `null` on iOS, older Android, or when the setting is unreadable.
  Future<int?> bootCount();
}

/// The real implementation backed by the existing native MethodChannel.
class MethodChannelPlatformClock implements PlatformClock {
  MethodChannelPlatformClock([MethodChannel? channel])
    : _channel = channel ?? const MethodChannel(_channelName);

  static const _channelName = 'id.aura.app/device_time';

  final MethodChannel _channel;

  @override
  Future<int?> monotonicMs() async {
    try {
      if (Platform.isAndroid) {
        return await _channel.invokeMethod<int>('getElapsedRealtimeMs');
      } else if (Platform.isIOS) {
        return await _channel.invokeMethod<int>('getMonotonicMs');
      }
      return null;
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  @override
  Future<int?> bootCount() async {
    try {
      if (!Platform.isAndroid) return null;
      return await _channel.invokeMethod<int>('getBootCount');
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }
}
