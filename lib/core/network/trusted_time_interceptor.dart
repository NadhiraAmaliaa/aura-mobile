import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import '../device/trusted_time_service.dart';

/// Refreshes the [TrustedTimeService] anchor from the HTTP `Date` header on
/// every successful API response.
///
/// Accepts a `Future<TrustedTimeService>` so it can be wired into a
/// synchronous Dio provider while the service initializes asynchronously.
/// The `Date` header is produced by the server (Laravel/Nginx) and carries the
/// server's wall-clock in RFC-1123 format (e.g. `Mon, 12 Jul 2026 07:03:07 GMT`).
class TrustedTimeInterceptor extends Interceptor {
  TrustedTimeInterceptor(this._trustedTimeFuture);

  final Future<TrustedTimeService> _trustedTimeFuture;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final dateHeader = response.headers.value('date');
    final serverTime = dateHeader != null ? _parseHttpDate(dateHeader) : null;
    if (serverTime != null) {
      // Establish the in-memory anchor BEFORE forwarding the response so a
      // Date-bearing response can never settle before trusted time is
      // available. Persistence still completes in the background inside
      // establishAnchor, so the DB never blocks response delivery.
      unawaited(_establishThenForward(serverTime, response, handler));
      return;
    }
    // A response without a usable Date header is still a completed verification
    // attempt: record it so the status can resolve out of the loading state.
    _trustedTimeFuture.then((service) => service.noteVerificationAttempt())
        .ignore();
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // A failed/timed-out request is a completed attempt with no anchor, letting
    // the trusted-time status resolve from loading to unavailable.
    _trustedTimeFuture.then((service) => service.noteVerificationAttempt())
        .ignore();
    handler.next(err);
  }

  Future<void> _establishThenForward(
    DateTime serverTime,
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    try {
      final service = await _trustedTimeFuture;
      await service.establishAnchor(serverTime);
    } catch (_) {
      // Anchor refresh must never fail the response pipeline.
    }
    handler.next(response);
  }

  /// Parses an HTTP `Date` header to a UTC [DateTime] using the SDK's
  /// locale-independent [HttpDate] parser (RFC-1123 / RFC-850 / asctime).
  /// Returns `null` on parse failure so the anchor simply isn't refreshed.
  static DateTime? _parseHttpDate(String value) {
    try {
      return HttpDate.parse(value);
    } catch (_) {
      return null;
    }
  }
}
