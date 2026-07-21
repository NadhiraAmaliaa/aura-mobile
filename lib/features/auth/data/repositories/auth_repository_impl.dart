import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/observability/error_reporter.dart';
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
      await _cacheUser(response.user);
      return Success(response.user);
    } on DioException catch (e) {
      return Failure(mapDioException(e));
    } catch (e, stackTrace) {
      return Failure(reportUnexpectedError(e, stackTrace));
    }
  }

  @override
  Future<ApiResult<UserModel>> me() async {
    try {
      final response = await _api.me();
      await _cacheUser(response.data);
      return Success(response.data);
    } on DioException catch (e) {
      return Failure(mapDioException(e));
    } catch (e, stackTrace) {
      return Failure(reportUnexpectedError(e, stackTrace));
    }
  }

  @override
  Future<ApiResult<UserModel>> updateContact(
    ContactUpdateRequest request,
  ) async {
    try {
      final response = await _api.updateContact(request);
      await _cacheUser(response.data);
      return Success(response.data);
    } on DioException catch (e) {
      return Failure(mapDioException(e));
    } catch (e, stackTrace) {
      return Failure(reportUnexpectedError(e, stackTrace));
    }
  }

  @override
  Future<ApiResult<void>> updatePassword(PasswordUpdateRequest request) async {
    try {
      await _api.updatePassword(request);
      return const Success<void>(null);
    } on DioException catch (e) {
      return Failure(mapDioException(e));
    } catch (e, stackTrace) {
      return Failure(reportUnexpectedError(e, stackTrace));
    }
  }

  @override
  Future<ApiResult<UserModel>> updateAvatar(File photo) async {
    try {
      final response = await _api.updateAvatar(photo);
      await _cacheUser(response.data);
      return Success(response.data);
    } on DioException catch (e) {
      return Failure(mapDioException(e));
    } catch (e, stackTrace) {
      return Failure(reportUnexpectedError(e, stackTrace));
    }
  }

  @override
  Future<ApiResult<UserModel>> deleteAvatar() async {
    try {
      final response = await _api.deleteAvatar();
      await _cacheUser(response.data);
      return Success(response.data);
    } on DioException catch (e) {
      return Failure(mapDioException(e));
    } catch (e, stackTrace) {
      return Failure(reportUnexpectedError(e, stackTrace));
    }
  }

  @override
  Future<ApiResult<void>> logout() async {
    try {
      await _api.logout();
      return const Success<void>(null);
    } on DioException catch (e) {
      return Failure(mapDioException(e));
    } catch (e, stackTrace) {
      return Failure(reportUnexpectedError(e, stackTrace));
    } finally {
      // Always clear the local session, even if the server revoke call failed.
      await _storage.delete(StorageKeys.accessToken);
      await _storage.delete(StorageKeys.cachedUser);
    }
  }

  @override
  Future<String?> currentToken() => _storage.read(StorageKeys.accessToken);

  @override
  Future<UserModel?> cachedUser() async {
    final raw = await _storage.read(StorageKeys.cachedUser);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return UserModel.fromJson(decoded);
    } on Object {
      // A corrupt/legacy cache is treated as "no cache" rather than fatal.
      return null;
    }
  }

  Future<void> _cacheUser(UserModel user) =>
      _storage.write(StorageKeys.cachedUser, jsonEncode(user.toJson()));
}
