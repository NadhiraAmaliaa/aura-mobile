// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  email: json['email'] as String?,
  role: json['role'] as String,
  isActive: json['is_active'] as bool? ?? true,
  intern: json['intern'] == null
      ? null
      : InternModel.fromJson(json['intern'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'role': instance.role,
      'is_active': instance.isActive,
      'intern': instance.intern,
    };

_InternModel _$InternModelFromJson(Map<String, dynamic> json) => _InternModel(
  id: (json['id'] as num).toInt(),
  nim: json['nim'] as String,
  phone: json['phone'] as String?,
  status: json['status'] as String,
  university: json['university'] as String?,
  major: json['major'] as String?,
  program: json['program'] as String?,
  division: json['division'] as String?,
  startDate: json['start_date'] as String?,
  endDate: json['end_date'] as String?,
  divisionId: (json['division_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$InternModelToJson(_InternModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nim': instance.nim,
      'phone': instance.phone,
      'status': instance.status,
      'university': instance.university,
      'major': instance.major,
      'program': instance.program,
      'division': instance.division,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'division_id': instance.divisionId,
    };

_UserEnvelope _$UserEnvelopeFromJson(Map<String, dynamic> json) =>
    _UserEnvelope(
      data: UserModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserEnvelopeToJson(_UserEnvelope instance) =>
    <String, dynamic>{'data': instance.data};
