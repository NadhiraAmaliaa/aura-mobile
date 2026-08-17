import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

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

  /// RFC-1123 date format as used in HTTP `Date` headers.
  static final _httpDateFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss', 'en');

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final dateHeader = response.headers.value('date');
    if (dateHeader != null) {
      final serverTime = _parseHttpDate(dateHeader);
      if (serverTime != null) {
        // Fire-and-forget: anchor refresh must never block or fail the
        // response pipeline.
        _trustedTimeFuture
            .then((service) => service.setAnchor(serverTime))
            .ignore();
      }
    }
    handler.next(response);
  }

  /// Parses an HTTP `Date` header (RFC-1123) to a UTC [DateTime].
  /// Returns `null` on parse failure so the anchor simply isn't refreshed.
  static DateTime? _parseHttpDate(String value) {
    try {
      // The header ends with " GMT"; strip it for DateFormat parsing, then
      // treat the result as UTC.
      final cleaned = value.replaceAll(' GMT', '').trim();
      final parsed = _httpDateFormat.parseUtc(cleaned);
      return parsed;
    } catch (_) {
      return null;
    }
  }
}
