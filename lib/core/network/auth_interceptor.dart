import 'package:dio/dio.dart';

import '../storage/secure_storage.dart';
import '../storage/storage_keys.dart';

/// Attaches the bearer token to outgoing requests and reacts to `401`s.
///
/// Session invalidation is only *cleared* here; surfacing it to the router
/// (redirect to login) is wired up with the auth feature via auth state.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);

  final SecureStorageService _storage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(StorageKeys.accessToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await _storage.delete(StorageKeys.accessToken);
    }
    handler.next(err);
  }
}
