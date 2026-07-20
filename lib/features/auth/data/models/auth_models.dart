import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_model.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

/// Request body for `POST /auth/login`.
///
/// Interns authenticate with the `(university_id, nim)` pair plus a password.
/// `device_name` is optional and only labels the issued token server-side.
@freezed
abstract class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    @JsonKey(name: 'university_id') required int universityId,
    required String nim,
    required String password,
    @JsonKey(name: 'device_name', includeIfNull: false) String? deviceName,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}

/// Successful response body for `POST /auth/login`.
@freezed
abstract class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    required String token,
    @JsonKey(name: 'token_type') required String tokenType,
    required UserModel user,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}

/// Request body for `PATCH /auth/profile/contact`.
///
/// Both fields are optional and only the account's contact details are
/// editable: [email] lives on the user account, [phone] on the intern profile.
/// Nulls are still sent so the backend can clear a value, matching the web
/// profile form.
@freezed
abstract class ContactUpdateRequest with _$ContactUpdateRequest {
  const factory ContactUpdateRequest({String? email, String? phone}) =
      _ContactUpdateRequest;

  factory ContactUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$ContactUpdateRequestFromJson(json);
}

/// Request body for `PUT /auth/password`.
///
/// Mirrors the backend rules: the current password is verified and the new
/// password must be confirmed.
@freezed
abstract class PasswordUpdateRequest with _$PasswordUpdateRequest {
  const factory PasswordUpdateRequest({
    @JsonKey(name: 'current_password') required String currentPassword,
    required String password,
    @JsonKey(name: 'password_confirmation')
    required String passwordConfirmation,
  }) = _PasswordUpdateRequest;

  factory PasswordUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$PasswordUpdateRequestFromJson(json);
}
