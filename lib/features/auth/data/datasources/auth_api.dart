import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/auth_models.dart';
import '../models/user_model.dart';

part 'auth_api.g.dart';

/// Typed auth endpoints. Paths are **relative to the versioned base URL**
/// (`.../api/v1`) and start with a leading slash so Dio's string-concatenation
/// join preserves the `v1` segment (see architecture doc §7).
@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio, {String baseUrl}) = _AuthApi;

  @POST('/auth/login')
  Future<LoginResponse> login(@Body() LoginRequest body);

  @GET('/auth/me')
  Future<UserEnvelope> me();

  @POST('/auth/logout')
  Future<void> logout();
}
