import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/messaging/messaging_providers.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../data/device_token_providers.dart';
import '../../data/models/device_token_request.dart';

part 'device_token_registrar.g.dart';

/// Session-lifetime side effect that keeps the backend's copy of this device's
/// FCM token in sync with Firebase.
///
/// Armed once by the root widget (the same pattern as the offline-queue session
/// sync). It stays inert while the session is resolving or unauthenticated;
/// once authenticated it registers the current token and re-registers whenever
/// FCM rotates it. Failures never block login or startup — they are logged in
/// debug and (for unexpected errors) reported to Sentry inside the repository,
/// then simply retried on the next arm or refresh. On logout it clears only the
/// local "already registered" marker; the Firebase token itself is left intact.
@Riverpod(keepAlive: true)
class DeviceTokenRegistrar extends _$DeviceTokenRegistrar {
  StreamSubscription<String>? _refreshSub;

  /// The token last confirmed-registered this session — an in-memory fast path
  /// layered on top of the persisted [StorageKeys.registeredFcmToken].
  String? _lastSentToken;

  @override
  Future<void> build() async {
    // Tear down the previous refresh listener before this (re)build rewires.
    ref.onDispose(() {
      _refreshSub?.cancel();
      _refreshSub = null;
    });

    final session = ref.watch(authProvider).asData?.value;

    // Session still resolving (loading/error): do nothing, keep local state.
    if (session == null) return;

    // Resolved but not signed in: drop only the local registration marker.
    if (session is! Authenticated) {
      await _clearLocalRegistration();
      return;
    }

    final messaging = ref.watch(firebaseMessagingProvider);

    // Re-register whenever FCM rotates the token during this session.
    _refreshSub = messaging.onTokenRefresh.listen(
      (token) => unawaited(_register(token)),
    );

    // Register the token we currently hold (if any is available yet).
    final current = await messaging.getToken();
    if (current != null) {
      await _register(current);
    }
  }

  Future<void> _register(String token) async {
    if (token.isEmpty) return;

    // Skip an unchanged token: check the in-memory marker first, falling back
    // to the persisted one so a restart does not re-send the same token.
    _lastSentToken ??= await ref
        .read(secureStorageProvider)
        .read(StorageKeys.registeredFcmToken);
    if (token == _lastSentToken) return;

    final result = await ref
        .read(deviceTokenRepositoryProvider)
        .register(DeviceTokenRequest(token: token, platform: _platform));

    switch (result) {
      case Success():
        _lastSentToken = token;
        await ref
            .read(secureStorageProvider)
            .write(StorageKeys.registeredFcmToken, token);
        if (kDebugMode) {
          debugPrint('[FCM] device token registered with backend');
        }
      case Failure(:final exception):
        // Leave the token unmarked so it is retried on the next arm/refresh.
        if (kDebugMode) {
          debugPrint(
            '[FCM] device token registration failed: ${exception.message}',
          );
        }
    }
  }

  Future<void> _clearLocalRegistration() async {
    _lastSentToken = null;
    await ref
        .read(secureStorageProvider)
        .delete(StorageKeys.registeredFcmToken);
  }

  String get _platform => switch (defaultTargetPlatform) {
    TargetPlatform.iOS => 'ios',
    _ => 'android',
  };
}
