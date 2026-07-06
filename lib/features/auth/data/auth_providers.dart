import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/core_providers.dart';
import '../domain/repositories/auth_repository.dart';
import 'datasources/auth_api.dart';
import 'datasources/lookup_api.dart';
import 'repositories/auth_repository_impl.dart';
import 'repositories/lookup_repository.dart';

part 'auth_providers.g.dart';

/// Retrofit auth client bound to the shared Dio instance.
@riverpod
AuthApi authApi(Ref ref) => AuthApi(ref.watch(dioProvider));

/// Retrofit lookup client bound to the shared Dio instance.
@riverpod
LookupApi lookupApi(Ref ref) => LookupApi(ref.watch(dioProvider));

/// The auth repository seam consumed by the presentation layer.
@riverpod
AuthRepository authRepository(Ref ref) => AuthRepositoryImpl(
  ref.watch(authApiProvider),
  ref.watch(secureStorageProvider),
);

/// Reference-data repository for the login screen.
@riverpod
LookupRepository lookupRepository(Ref ref) =>
    LookupRepository(ref.watch(lookupApiProvider));
