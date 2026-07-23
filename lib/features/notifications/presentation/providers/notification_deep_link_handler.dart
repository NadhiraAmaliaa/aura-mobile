import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/bootstrap/offline_bootstrap_provider.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/messaging/messaging_providers.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../../leave/data/leave_providers.dart';
import '../../domain/notification_deep_link.dart';
import '../../domain/notification_target_resolver.dart';

part 'notification_deep_link_handler.g.dart';

/// Single owner of notification-tap navigation ("deep linking").
///
/// Armed once by the root widget for the whole app session. It owns both tap
/// entry points — [FirebaseMessaging.getInitialMessage] (app launched from a
/// terminated state) and [FirebaseMessaging.onMessageOpenedApp] (tap while
/// backgrounded) — so there is exactly one consumer of each; the foreground
/// [FcmService] deliberately no longer touches them.
///
/// A tapped notification is mapped to a typed [NotificationDeepLink] and held
/// as a pending intent. Navigation is deferred until the router would actually
/// allow an authenticated destination — session resolved, signed in, and the
/// offline bootstrap ready — because a terminated-state launch resolves its
/// initial message before auth/bootstrap finish, and navigating early would be
/// undone by the router's redirect. Watching the auth and bootstrap providers
/// re-runs [build] when readiness changes, at which point the pending intent is
/// flushed.
///
/// Generic by design: adding a notification type is a new variant in
/// [NotificationDeepLink] and a case in [resolveNotificationTarget]; this
/// handler needs no changes.
@Riverpod(keepAlive: true)
class NotificationDeepLinkHandler extends _$NotificationDeepLinkHandler {
  StreamSubscription<RemoteMessage>? _openedAppSub;

  /// Guards the one-time consumption of the terminated-launch message across
  /// rebuilds (unlike the background-tap stream, [FirebaseMessaging.getInitialMessage]
  /// must be read exactly once).
  bool _initialChecked = false;

  /// The most recent actionable tap awaiting a ready session.
  NotificationDeepLink? _pending;

  @override
  Future<void> build() async {
    // Riverpod runs onDispose before every rebuild, so the previous
    // background-tap subscription is torn down here and re-established below on
    // each build. This mirrors DeviceTokenRegistrar and is essential: guarding
    // the subscription behind a one-time flag would leave it cancelled after
    // the first rebuild (triggered by the auth/bootstrap watches), silently
    // breaking background taps.
    ref.onDispose(() {
      _openedAppSub?.cancel();
      _openedAppSub = null;
    });

    final messaging = ref.read(firebaseMessagingProvider);

    // (Re)subscribe to background taps (app alive but backgrounded).
    // `onMessageOpenedApp` is a static stream on FirebaseMessaging.
    _openedAppSub = FirebaseMessaging.onMessageOpenedApp.listen(
      _onMessageOpened,
    );

    // Consume the terminated-launch message exactly once (the instance survives
    // rebuilds because the provider is keepAlive).
    if (!_initialChecked) {
      _initialChecked = true;
      _enqueue(await messaging.getInitialMessage());
    }

    // Re-evaluated whenever session or bootstrap readiness changes, so a
    // pending intent captured before the app was ready flushes as soon as it
    // becomes navigable.
    ref.watch(authProvider);
    ref.watch(offlineBootstrapProvider);
    await _maybeFlush();
  }

  void _onMessageOpened(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('[FCM][tap] onMessageOpenedApp data=${message.data}');
    }
    _enqueue(message);
    unawaited(_maybeFlush());
  }

  /// Parses [message] into a deep link and records it as pending. A `null`
  /// message (no launch notification) or an unrecognised payload is ignored.
  void _enqueue(RemoteMessage? message) {
    if (message == null) return;
    final link = NotificationDeepLink.fromData(message.data);
    if (link == null) {
      if (kDebugMode) {
        debugPrint('[FCM][tap] no deep link for data=${message.data}');
      }
      return;
    }
    _pending = link;
  }

  /// Navigates to the pending intent's target once the session is ready. A
  /// no-op while there is nothing pending or the app is not yet navigable.
  Future<void> _maybeFlush() async {
    final link = _pending;
    if (link == null) return;

    // Gate on the same readiness the router uses to permit an authenticated
    // destination: session resolved + signed in + offline bootstrap ready.
    final session = ref.read(authProvider).asData?.value;
    if (session is! Authenticated) {
      if (kDebugMode) {
        debugPrint('[FCM][tap] deferred: session not authenticated yet');
      }
      return;
    }
    if (!ref.read(offlineBootstrapProvider).hasValue) {
      if (kDebugMode) {
        debugPrint('[FCM][tap] deferred: bootstrap not ready yet');
      }
      return;
    }

    // Claim the intent before the async resolve so a rebuild mid-flight does
    // not navigate twice.
    _pending = null;

    final target = await resolveNotificationTarget(
      link,
      leaveRepository: ref.read(leaveRepositoryProvider),
    );

    // Defer the actual navigation so it never runs during provider build or
    // the router's redirect evaluation.
    Future.microtask(() {
      if (kDebugMode) {
        debugPrint(
          '[FCM][tap] navigating to ${target.name} ${target.pathParameters}',
        );
      }
      ref
          .read(routerProvider)
          .goNamed(target.name, pathParameters: target.pathParameters);
    });
  }
}
