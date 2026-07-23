import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Owns the app's **foreground** Firebase Cloud Messaging lifecycle:
/// notification permission, the registration token, token refresh, and the
/// foreground message stream.
///
/// Notification-tap navigation (both the background `onMessageOpenedApp` tap
/// and the terminated-launch `getInitialMessage`) is intentionally **not** here
/// — it is owned solely by `NotificationDeepLinkHandler`, so each tap entry
/// point has exactly one consumer. Background/terminated delivery is handled
/// separately in `fcm_background_handler.dart`.
class FcmService {
  FcmService(this._messaging);

  final FirebaseMessaging _messaging;

  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;

  /// Wires the full foreground lifecycle. Safe to call once at app start.
  Future<void> initialize() async {
    await _requestPermission();

    // Ask the OS to keep surfacing notifications while the app is foregrounded.
    // Primarily honoured on iOS/web; harmless on Android.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _logToken();
    _listenForTokenRefresh();
    _listenForForegroundMessages();
  }

  Future<void> _requestPermission() async {
    // On Android 13+ this triggers the POST_NOTIFICATIONS runtime prompt; on
    // older Android versions it is a no-op that reports "authorized".
    final settings = await _messaging.requestPermission();
    if (kDebugMode) {
      debugPrint('[FCM] permission status: ${settings.authorizationStatus}');
    }
  }

  Future<void> _logToken() async {
    final token = await _messaging.getToken();
    if (kDebugMode) {
      debugPrint('[FCM] registration token: $token');
    }
    // Extension point: send [token] to the backend once server wiring lands.
  }

  void _listenForTokenRefresh() {
    // FCM can rotate the token at any time; the app must always use the latest.
    _tokenRefreshSub = _messaging.onTokenRefresh.listen((token) {
      if (kDebugMode) {
        debugPrint('[FCM] token refreshed: $token');
      }
      // Extension point: propagate the rotated [token] to the backend.
    });
  }

  void _listenForForegroundMessages() {
    // Fired while the app is in the foreground. Android does not auto-display
    // notification payloads in this state, so this is where they'd be surfaced.
    _foregroundSub = FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        debugPrint(
          '[FCM][foreground] message=${message.messageId} '
          'notification=${message.notification?.title} data=${message.data}',
        );
      }
    });
  }

  /// Cancels all stream subscriptions. Wired to the provider's disposal.
  Future<void> dispose() async {
    await _tokenRefreshSub?.cancel();
    await _foregroundSub?.cancel();
  }
}
