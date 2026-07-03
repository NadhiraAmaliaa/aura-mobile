/// Typed application exceptions.
///
/// Repositories translate transport/serialization errors into one of these
/// so the presentation layer never has to reason about Dio internals. See the
/// architecture doc §7.
library;

/// Base type for all expected application errors.
sealed class AppException implements Exception {
  const AppException(this.message, {this.cause});

  /// Human-readable, UI-safe message.
  final String message;

  /// Underlying cause, if any (not shown to users).
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

/// No connectivity / DNS / socket failure.
class NetworkException extends AppException {
  const NetworkException({
    String message = 'No internet connection.',
    Object? cause,
  }) : super(message, cause: cause);
}

/// A request exceeded its timeout.
///
/// Named `RequestTimeoutException` to avoid clashing with
/// `dart:async`'s `TimeoutException`.
class RequestTimeoutException extends AppException {
  const RequestTimeoutException({
    String message = 'The request timed out.',
    Object? cause,
  }) : super(message, cause: cause);
}

/// 401 — authentication is missing, expired, or revoked.
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    String message = 'Your session has expired. Please sign in again.',
    Object? cause,
  }) : super(message, cause: cause);
}

/// 422 — server-side validation failed.
class ValidationException extends AppException {
  const ValidationException({
    String message = 'Some fields are invalid.',
    this.errors = const {},
    Object? cause,
  }) : super(message, cause: cause);

  /// Field name -> list of error messages, mirroring Laravel's shape.
  final Map<String, List<String>> errors;
}

/// 5xx or otherwise unexpected server response.
class ServerException extends AppException {
  const ServerException({
    String message = 'Something went wrong on the server.',
    this.statusCode,
    Object? cause,
  }) : super(message, cause: cause);

  final int? statusCode;
}

/// The request was cancelled before completing.
class RequestCancelledException extends AppException {
  const RequestCancelledException({
    String message = 'The request was cancelled.',
    Object? cause,
  }) : super(message, cause: cause);
}

/// Anything not covered above.
class UnknownException extends AppException {
  const UnknownException({
    String message = 'An unexpected error occurred.',
    Object? cause,
  }) : super(message, cause: cause);
}
