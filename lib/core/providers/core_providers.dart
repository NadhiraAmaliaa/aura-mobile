import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/env.dart';
import '../network/dio_client.dart';
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
  return buildDio(env: env, storage: storage);
}
