import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'fcm_service.dart';

part 'messaging_providers.g.dart';

/// The singleton [FirebaseMessaging] instance. Isolated behind a provider so it
/// can be overridden with a fake in tests.
@Riverpod(keepAlive: true)
FirebaseMessaging firebaseMessaging(Ref ref) => FirebaseMessaging.instance;

/// The app's FCM service. Its stream subscriptions are cancelled when the
/// container is disposed.
@Riverpod(keepAlive: true)
FcmService fcmService(Ref ref) {
  final service = FcmService(ref.watch(firebaseMessagingProvider));
  ref.onDispose(service.dispose);
  return service;
}

/// App-lifetime arming hook: initializes the foreground FCM lifecycle exactly
/// once.
///
/// Watched by the root widget so permission handling, token logging and the
/// message listeners are wired for the whole app session, independent of any
/// screen being open.
@Riverpod(keepAlive: true)
Future<void> fcmBootstrap(Ref ref) async {
  await ref.watch(fcmServiceProvider).initialize();
}
