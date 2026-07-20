// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) =>
    _LoginRequest(
      universityId: (json['university_id'] as num).toInt(),
      nim: json['nim'] as String,
      password: json['password'] as String,
      deviceName: json['device_name'] as String?,
    );

Map<String, dynamic> _$LoginRequestToJson(_LoginRequest instance) =>
    <String, dynamic>{
      'university_id': instance.universityId,
      'nim': instance.nim,
      'password': instance.password,
      'device_name': ?instance.deviceName,
    };

_LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    _LoginResponse(
      token: json['token'] as String,
      tokenType: json['token_type'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LoginResponseToJson(_LoginResponse instance) =>
    <String, dynamic>{
      'token': instance.token,
      'token_type': instance.tokenType,
      'user': instance.user,
    };

_ContactUpdateRequest _$ContactUpdateRequestFromJson(
  Map<String, dynamic> json,
) => _ContactUpdateRequest(
  email: json['email'] as String?,
  phone: json['phone'] as String?,
);

Map<String, dynamic> _$ContactUpdateRequestToJson(
  _ContactUpdateRequest instance,
) => <String, dynamic>{'email': instance.email, 'phone': instance.phone};

_PasswordUpdateRequest _$PasswordUpdateRequestFromJson(
  Map<String, dynamic> json,
) => _PasswordUpdateRequest(
  currentPassword: json['current_password'] as String,
  password: json['password'] as String,
  passwordConfirmation: json['password_confirmation'] as String,
);

Map<String, dynamic> _$PasswordUpdateRequestToJson(
  _PasswordUpdateRequest instance,
) => <String, dynamic>{
  'current_password': instance.currentPassword,
  'password': instance.password,
  'password_confirmation': instance.passwordConfirmation,
};
