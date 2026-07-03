import 'package:dio/dio.dart';

import '../config/env.dart';
import '../storage/secure_storage.dart';
import 'auth_interceptor.dart';

/// Builds the single, shared [Dio] instance for the app.
///
/// Base URL comes from [AppEnv]; the [AuthInterceptor] injects the bearer
/// token. See the architecture doc §7.
Dio buildDio({
  required AppEnv env,
  required SecureStorageService storage,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: env.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      responseType: ResponseType.json,
      headers: const {
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(AuthInterceptor(storage));

  return dio;
}
