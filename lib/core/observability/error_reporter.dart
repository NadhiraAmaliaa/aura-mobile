import 'dart:async';

import 'package:sentry_flutter/sentry_flutter.dart';

import '../error/app_exception.dart';

/// Reports an *unexpected* (non-Dio) error to Sentry and wraps it in a
/// UI-safe [UnknownException].
///
/// Repository `catch` blocks route their generic branch through here so an
/// unmapped runtime error can never be silently swallowed. The user still sees
/// a friendly message, but the real error and stack trace reach observability.
///
/// This closes the exact failure mode behind the `division_id` string→int bug:
/// a `TypeError` thrown inside `fromJson` was caught and flattened into a
/// generic "An unexpected error occurred." with no trace, making it invisible
/// to both the user and Sentry.
///
/// Reporting is fire-and-forget: [Sentry.captureException] enqueues the event
/// on its own transport, so the caller's failure path is not blocked on I/O.
/// When Sentry is not initialised (e.g. local dev or tests) the global hub is a
/// no-op, so this is always safe to call.
UnknownException reportUnexpectedError(Object error, StackTrace stackTrace) {
  unawaited(Sentry.captureException(error, stackTrace: stackTrace));
  return UnknownException(cause: error);
}
