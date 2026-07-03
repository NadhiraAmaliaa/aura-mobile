import '../error/app_exception.dart';

/// A sealed, generic result type returned by every repository method.
///
/// The architecture doc (§7) originally described this as a Freezed union.
/// We implement it as a plain Dart 3 `sealed class` instead: for a two-variant
/// generic result, hand-written sealed classes give the same exhaustive
/// `switch` support with less codegen and cleaner generics. Freezed remains
/// reserved for data models and UI state. This is a deliberate, documented
/// deviation.
sealed class ApiResult<T> {
  const ApiResult();
}

/// A successful result carrying [data].
final class Success<T> extends ApiResult<T> {
  const Success(this.data);
  final T data;
}

/// A failed result carrying a typed [exception].
final class Failure<T> extends ApiResult<T> {
  const Failure(this.exception);
  final AppException exception;
}

/// Ergonomic helpers for consuming an [ApiResult] without a manual `switch`.
extension ApiResultX<T> on ApiResult<T> {
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  /// The data when successful, otherwise `null`.
  T? get dataOrNull => switch (this) {
        Success<T>(:final data) => data,
        Failure<T>() => null,
      };

  /// Folds both branches into a single value of type [R].
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppException exception) onFailure,
  }) =>
      switch (this) {
        Success<T>(:final data) => onSuccess(data),
        Failure<T>(:final exception) => onFailure(exception),
      };
}
