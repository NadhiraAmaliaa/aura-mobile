import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/attendance/presentation/providers/attendance_queue_controller.dart';
import '../features/auth/presentation/providers/auth_notifier.dart';
import '../features/auth/presentation/providers/auth_state.dart';

part 'session_sync.g.dart';

/// App-level glue that drives the offline attendance queue from the *session*,
/// not from any screen.
///
/// The queue lives in sqflite and therefore survives logout. Whenever the user
/// becomes authenticated — a fresh login, a cold-start session restore, or a
/// re-login after logging out — any events left pending are flushed, so a
/// capture made offline before logging out syncs automatically on the next
/// authenticated launch without having to open the attendance page.
///
/// While a session is active the queue controller is also kept alive, so its
/// own connectivity-regain flush stays armed everywhere in the app. Nothing is
/// touched (and the database is not opened) until there is an authenticated
/// session, keeping the login screen and cold start cheap.
@Riverpod(keepAlive: true)
void sessionQueueSync(Ref ref) {
  final isAuthenticated =
      ref.watch(authProvider).asData?.value is Authenticated;
  if (!isAuthenticated) return;

  // Keep the queue controller alive for the whole session (its connectivity
  // regain flush stays active) and drain anything left pending right now.
  ref.watch(attendanceQueueControllerProvider);
  unawaited(ref.read(attendanceQueueControllerProvider.notifier).flush());
}
