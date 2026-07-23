import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/core_providers.dart';
import '../domain/repositories/device_token_repository.dart';
import 'datasources/device_token_api.dart';
import 'repositories/device_token_repository_impl.dart';

part 'device_token_providers.g.dart';

/// Retrofit device-token client bound to the shared Dio instance (so the
/// bearer token is attached by the existing AuthInterceptor).
@riverpod
DeviceTokenApi deviceTokenApi(Ref ref) =>
    DeviceTokenApi(ref.watch(dioProvider));

/// The device-token repository seam consumed by the registrar.
@riverpod
DeviceTokenRepository deviceTokenRepository(Ref ref) =>
    DeviceTokenRepositoryImpl(ref.watch(deviceTokenApiProvider));
