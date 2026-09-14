import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/env.dart';
import '../device/trusted_time_providers.dart';
import '../network/dio_client.dart';
import '../network/trusted_time_interceptor.dart';
import '../storage/secure_storage.dart';

part 'core_providers.g.dart';

/// Resolved app environment. Overridden in `main()` with the concrete instance
/// so the whole tree shares one source of truth.
@Riverpod(keepAlive: true)
AppEnv appEnv(Ref ref) => AppEnv.fromDartDefines();

/// Secure storage wrapper (tokens etc.).
@Riverpod(keepAlive: true)
SecureStorageService secureStorage(Ref ref) => SecureStorageService();

/// The single shared Dio instance, configured from [appEnvProvider].
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final env = ref.watch(appEnvProvider);
  final storage = ref.watch(secureStorageProvider);
  final dio = buildDio(env: env, storage: storage);

  // Add the TrustedTime anchor interceptor. The service future resolves
  // almost immediately (just opens the DB). On a Date-bearing response it
  // establishes the in-memory anchor before forwarding (persistence stays in
  // the background), so the response pipeline is never blocked on the DB.
  final trustedTimeFuture = ref.watch(trustedTimeServiceProvider.future);
  dio.interceptors.add(TrustedTimeInterceptor(trustedTimeFuture));

  return dio;
}
