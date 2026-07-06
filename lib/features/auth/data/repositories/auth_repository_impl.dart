import 'package:dio/dio.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_api.dart';
import '../models/auth_models.dart';
import '../models/user_model.dart';

/// Network-backed [AuthRepository]. Owns bearer-token persistence and maps all
/// transport errors to typed [AppException]s so callers only ever see an
/// [ApiResult].
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._api, this._storage);

  final AuthApi _api;
  final SecureStorageService _storage;

  @override
  Future<ApiResult<UserModel>> login(LoginRequest request) async {
    try {
      final response = await _api.login(request);
      await _storage.write(StorageKeys.accessToken, response.token);
      return Success(response.user);
    } on DioException catch (e) {
      return Failure(mapDioException(e));
    } catch (e) {
      return Failure(UnknownException(cause: e));
    }
  }

  @override
  Future<ApiResult<UserModel>> me() async {
    try {
      final response = await _api.me();
      return Success(response.data);
    } on DioException catch (e) {
      return Failure(mapDioException(e));
    } catch (e) {
      return Failure(UnknownException(cause: e));
    }
  }

  @override
  Future<ApiResult<void>> logout() async {
    try {
      await _api.logout();
      return const Success<void>(null);
    } on DioException catch (e) {
      return Failure(mapDioException(e));
    } catch (e) {
      return Failure(UnknownException(cause: e));
    } finally {
      // Always clear the local token, even if the server revoke call failed.
      await _storage.delete(StorageKeys.accessToken);
    }
  }

  @override
  Future<String?> currentToken() => _storage.read(StorageKeys.accessToken);
}
