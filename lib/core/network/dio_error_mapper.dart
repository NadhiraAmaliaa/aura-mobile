import 'package:dio/dio.dart';

import '../error/app_exception.dart';

/// Translates a [DioException] into a typed [AppException].
///
/// Repositories call this in their `catch` blocks so the presentation layer
/// only ever sees [AppException]s. See the architecture doc §7.
AppException mapDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return RequestTimeoutException(cause: e);

    case DioExceptionType.badResponse:
      final status = e.response?.statusCode;
      final data = e.response?.data;
      if (status == 401) {
        return UnauthorizedException(cause: e);
      }
      if (status == 422) {
        return ValidationException(
          message: _extractMessage(data) ?? 'Some fields are invalid.',
          errors: _extractErrors(data),
          cause: e,
        );
      }
      return ServerException(
        message: _extractMessage(data) ?? 'Something went wrong on the server.',
        statusCode: status,
        cause: e,
      );

    case DioExceptionType.connectionError:
      return NetworkException(cause: e);

    case DioExceptionType.cancel:
      return RequestCancelledException(cause: e);

    case DioExceptionType.badCertificate:
      return NetworkException(
        message: 'Could not verify the server certificate.',
        cause: e,
      );

    case DioExceptionType.unknown:
      return UnknownException(cause: e.error ?? e);
  }
}

/// Extracts a top-level `message` from a Laravel-style JSON error body.
String? _extractMessage(Object? data) {
  if (data is Map && data['message'] is String) {
    return data['message'] as String;
  }
  return null;
}

/// Extracts Laravel's `errors` map (`{field: [messages]}`).
Map<String, List<String>> _extractErrors(Object? data) {
  if (data is! Map || data['errors'] is! Map) {
    return const {};
  }
  final raw = data['errors'] as Map;
  final result = <String, List<String>>{};
  raw.forEach((key, value) {
    if (value is List) {
      result['$key'] = value.map((e) => '$e').toList();
    } else {
      result['$key'] = ['$value'];
    }
  });
  return result;
}
