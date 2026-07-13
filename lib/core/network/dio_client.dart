import 'package:dio/dio.dart';

import '../config/env.dart';
import '../storage/secure_storage.dart';
import 'auth_interceptor.dart';

/// Builds the single, shared [Dio] instance for the app.
///
/// Base URL comes from [AppEnv]; the [AuthInterceptor] injects the bearer
/// token. See the architecture doc §7.
Dio buildDio({required AppEnv env, required SecureStorageService storage}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: env.baseUrl,
      // Fail fast when the host is unreachable (e.g. connected to a different
      // network than the backend) so callers can fall back to cached data
      // instead of leaving the UI stuck for a long time.
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      responseType: ResponseType.json,
      // Ensures request bodies are JSON-encoded (Dio's transformer only
      // auto-encodes Map/List otherwise). jsonEncode invokes each DTO's
      // generated `toJson()`, so typed @Body models serialize correctly.
      contentType: Headers.jsonContentType,
      headers: const {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(AuthInterceptor(storage));

  return dio;
}
