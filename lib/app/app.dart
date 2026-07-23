import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/messaging/messaging_providers.dart';
import '../features/notifications/presentation/providers/device_token_registrar.dart';
import '../features/notifications/presentation/providers/notification_deep_link_handler.dart';
import 'router/app_router.dart';
import 'session_sync.dart';
import 'theme/app_theme.dart';

/// Root widget. Wires the router and theme into [MaterialApp.router].
class AuraApp extends ConsumerWidget {
  const AuraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Arm the session-level offline-queue sync for the whole app lifetime, so a
    // queue drained on login/reconnect never depends on opening a screen.
    ref.watch(sessionQueueSyncProvider);

    // Arm Firebase Cloud Messaging for the whole app lifetime (permission,
    // token logging and foreground/opened listeners). Fire-and-forget: the
    // async result is intentionally not surfaced in the UI.
    ref.watch(fcmBootstrapProvider);

    // Keep the backend's copy of this device's FCM token in sync for the whole
    // session (register after login, follow token refreshes, clear on logout).
    // Non-blocking: failures never affect startup or navigation.
    ref.watch(deviceTokenRegistrarProvider);

    // Own notification-tap deep linking for the whole app lifetime: route a
    // tapped approval/rejection notification to its Leave Detail page (or the
    // Leave History list as a fallback), for both background and terminated
    // launches. Deferred until the session is ready, so it never fights the
    // router's redirect.
    ref.watch(notificationDeepLinkHandlerProvider);

    return MaterialApp.router(
      title: 'AURA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
    );
  }
}
