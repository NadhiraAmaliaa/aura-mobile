import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Handles messages delivered while the app is in the background or fully
/// terminated.
///
/// This runs in a **dedicated background isolate** with no access to the app's
/// widget tree, navigator or Riverpod container, so it must stay entirely
/// self-contained. It has to be a top-level (or static) function annotated with
/// `@pragma('vm:entry-point')` so the Flutter engine can locate it after a cold
/// isolate spawn (release/AOT builds tree-shake otherwise).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // The background isolate has its own memory space, so Firebase must be
  // initialized here before any Firebase API is touched. On Android the native
  // configuration is read from google-services.json, so no options are needed.
  await Firebase.initializeApp();

  if (kDebugMode) {
    debugPrint(
      '[FCM][background] message=${message.messageId} data=${message.data}',
    );
  }
  // NOTE: Backend sync and leave/sick business handling are intentionally not
  // implemented yet. This is the extension point for background processing.
}

/// Registers [firebaseMessagingBackgroundHandler] with FCM.
///
/// Call once during app bootstrap, after `Firebase.initializeApp()` and before
/// `runApp`, so background/terminated messages are handled from the first
/// launch.
void registerFcmBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}
