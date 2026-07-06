import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// The authenticated user returned by `/auth/login` and `/auth/me`.
///
/// The mobile app only ever handles interns, so [intern] is expected to be
/// present, but it is modelled as nullable to stay defensive against an
/// unexpected shape.
@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required int id,
    required String name,
    String? email,
    required String role,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    InternModel? intern,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

/// The intern profile nested inside [UserModel].
///
/// `status` mirrors the backend's effective status
/// (`upcoming | active | completed | inactive`); dates are ISO `yyyy-MM-dd`
/// strings as emitted by the API.
@freezed
abstract class InternModel with _$InternModel {
  const factory InternModel({
    required int id,
    required String nim,
    String? phone,
    required String status,
    @JsonKey(name: 'start_date') String? startDate,
    @JsonKey(name: 'end_date') String? endDate,
    @JsonKey(name: 'division_id') int? divisionId,
  }) = _InternModel;

  factory InternModel.fromJson(Map<String, dynamic> json) =>
      _$InternModelFromJson(json);
}

/// Envelope for `GET /auth/me`, which wraps the user in a `data` key (Laravel
/// `JsonResource` default). `/auth/login` does not wrap, so it is parsed
/// directly into [UserModel].
@freezed
abstract class UserEnvelope with _$UserEnvelope {
  const factory UserEnvelope({required UserModel data}) = _UserEnvelope;

  factory UserEnvelope.fromJson(Map<String, dynamic> json) =>
      _$UserEnvelopeFromJson(json);
}
