// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'leave_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LeaveRequestModel {

 int get id;@JsonKey(name: 'request_number') String get requestNumber; String get type;@JsonKey(name: 'type_label') String get typeLabel; String get reason;@JsonKey(name: 'start_date') String? get startDate;@JsonKey(name: 'end_date') String? get endDate;@JsonKey(name: 'total_days') int? get totalDays;@JsonKey(name: 'contact_phone') String? get contactPhone; String? get address;@JsonKey(name: 'evidence_url') String? get evidenceUrl; String get status;@JsonKey(name: 'status_label') String get statusLabel;@JsonKey(name: 'admin_note') String? get adminNote;@JsonKey(name: 'approver_name') String? get approverName;@JsonKey(name: 'approved_at') String? get approvedAt;@JsonKey(name: 'can_download_pdf') bool get canDownloadPdf;@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of LeaveRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaveRequestModelCopyWith<LeaveRequestModel> get copyWith => _$LeaveRequestModelCopyWithImpl<LeaveRequestModel>(this as LeaveRequestModel, _$identity);

  /// Serializes this LeaveRequestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeaveRequestModel&&(identical(other.id, id) || other.id == id)&&(identical(other.requestNumber, requestNumber) || other.requestNumber == requestNumber)&&(identical(other.type, type) || other.type == type)&&(identical(other.typeLabel, typeLabel) || other.typeLabel == typeLabel)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.totalDays, totalDays) || other.totalDays == totalDays)&&(identical(other.contactPhone, contactPhone) || other.contactPhone == contactPhone)&&(identical(other.address, address) || other.address == address)&&(identical(other.evidenceUrl, evidenceUrl) || other.evidenceUrl == evidenceUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusLabel, statusLabel) || other.statusLabel == statusLabel)&&(identical(other.adminNote, adminNote) || other.adminNote == adminNote)&&(identical(other.approverName, approverName) || other.approverName == approverName)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.canDownloadPdf, canDownloadPdf) || other.canDownloadPdf == canDownloadPdf)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,requestNumber,type,typeLabel,reason,startDate,endDate,totalDays,contactPhone,address,evidenceUrl,status,statusLabel,adminNote,approverName,approvedAt,canDownloadPdf,createdAt);

@override
String toString() {
  return 'LeaveRequestModel(id: $id, requestNumber: $requestNumber, type: $type, typeLabel: $typeLabel, reason: $reason, startDate: $startDate, endDate: $endDate, totalDays: $totalDays, contactPhone: $contactPhone, address: $address, evidenceUrl: $evidenceUrl, status: $status, statusLabel: $statusLabel, adminNote: $adminNote, approverName: $approverName, approvedAt: $approvedAt, canDownloadPdf: $canDownloadPdf, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $LeaveRequestModelCopyWith<$Res>  {
  factory $LeaveRequestModelCopyWith(LeaveRequestModel value, $Res Function(LeaveRequestModel) _then) = _$LeaveRequestModelCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'request_number') String requestNumber, String type,@JsonKey(name: 'type_label') String typeLabel, String reason,@JsonKey(name: 'start_date') String? startDate,@JsonKey(name: 'end_date') String? endDate,@JsonKey(name: 'total_days') int? totalDays,@JsonKey(name: 'contact_phone') String? contactPhone, String? address,@JsonKey(name: 'evidence_url') String? evidenceUrl, String status,@JsonKey(name: 'status_label') String statusLabel,@JsonKey(name: 'admin_note') String? adminNote,@JsonKey(name: 'approver_name') String? approverName,@JsonKey(name: 'approved_at') String? approvedAt,@JsonKey(name: 'can_download_pdf') bool canDownloadPdf,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class _$LeaveRequestModelCopyWithImpl<$Res>
    implements $LeaveRequestModelCopyWith<$Res> {
  _$LeaveRequestModelCopyWithImpl(this._self, this._then);

  final LeaveRequestModel _self;
  final $Res Function(LeaveRequestModel) _then;

/// Create a copy of LeaveRequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? requestNumber = null,Object? type = null,Object? typeLabel = null,Object? reason = null,Object? startDate = freezed,Object? endDate = freezed,Object? totalDays = freezed,Object? contactPhone = freezed,Object? address = freezed,Object? evidenceUrl = freezed,Object? status = null,Object? statusLabel = null,Object? adminNote = freezed,Object? approverName = freezed,Object? approvedAt = freezed,Object? canDownloadPdf = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,requestNumber: null == requestNumber ? _self.requestNumber : requestNumber // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,typeLabel: null == typeLabel ? _self.typeLabel : typeLabel // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,totalDays: freezed == totalDays ? _self.totalDays : totalDays // ignore: cast_nullable_to_non_nullable
as int?,contactPhone: freezed == contactPhone ? _self.contactPhone : contactPhone // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,evidenceUrl: freezed == evidenceUrl ? _self.evidenceUrl : evidenceUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,statusLabel: null == statusLabel ? _self.statusLabel : statusLabel // ignore: cast_nullable_to_non_nullable
as String,adminNote: freezed == adminNote ? _self.adminNote : adminNote // ignore: cast_nullable_to_non_nullable
as String?,approverName: freezed == approverName ? _self.approverName : approverName // ignore: cast_nullable_to_non_nullable
as String?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as String?,canDownloadPdf: null == canDownloadPdf ? _self.canDownloadPdf : canDownloadPdf // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LeaveRequestModel].
extension LeaveRequestModelPatterns on LeaveRequestModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeaveRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeaveRequestModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeaveRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _LeaveRequestModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeaveRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _LeaveRequestModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'request_number')  String requestNumber,  String type, @JsonKey(name: 'type_label')  String typeLabel,  String reason, @JsonKey(name: 'start_date')  String? startDate, @JsonKey(name: 'end_date')  String? endDate, @JsonKey(name: 'total_days')  int? totalDays, @JsonKey(name: 'contact_phone')  String? contactPhone,  String? address, @JsonKey(name: 'evidence_url')  String? evidenceUrl,  String status, @JsonKey(name: 'status_label')  String statusLabel, @JsonKey(name: 'admin_note')  String? adminNote, @JsonKey(name: 'approver_name')  String? approverName, @JsonKey(name: 'approved_at')  String? approvedAt, @JsonKey(name: 'can_download_pdf')  bool canDownloadPdf, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeaveRequestModel() when $default != null:
return $default(_that.id,_that.requestNumber,_that.type,_that.typeLabel,_that.reason,_that.startDate,_that.endDate,_that.totalDays,_that.contactPhone,_that.address,_that.evidenceUrl,_that.status,_that.statusLabel,_that.adminNote,_that.approverName,_that.approvedAt,_that.canDownloadPdf,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'request_number')  String requestNumber,  String type, @JsonKey(name: 'type_label')  String typeLabel,  String reason, @JsonKey(name: 'start_date')  String? startDate, @JsonKey(name: 'end_date')  String? endDate, @JsonKey(name: 'total_days')  int? totalDays, @JsonKey(name: 'contact_phone')  String? contactPhone,  String? address, @JsonKey(name: 'evidence_url')  String? evidenceUrl,  String status, @JsonKey(name: 'status_label')  String statusLabel, @JsonKey(name: 'admin_note')  String? adminNote, @JsonKey(name: 'approver_name')  String? approverName, @JsonKey(name: 'approved_at')  String? approvedAt, @JsonKey(name: 'can_download_pdf')  bool canDownloadPdf, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _LeaveRequestModel():
return $default(_that.id,_that.requestNumber,_that.type,_that.typeLabel,_that.reason,_that.startDate,_that.endDate,_that.totalDays,_that.contactPhone,_that.address,_that.evidenceUrl,_that.status,_that.statusLabel,_that.adminNote,_that.approverName,_that.approvedAt,_that.canDownloadPdf,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'request_number')  String requestNumber,  String type, @JsonKey(name: 'type_label')  String typeLabel,  String reason, @JsonKey(name: 'start_date')  String? startDate, @JsonKey(name: 'end_date')  String? endDate, @JsonKey(name: 'total_days')  int? totalDays, @JsonKey(name: 'contact_phone')  String? contactPhone,  String? address, @JsonKey(name: 'evidence_url')  String? evidenceUrl,  String status, @JsonKey(name: 'status_label')  String statusLabel, @JsonKey(name: 'admin_note')  String? adminNote, @JsonKey(name: 'approver_name')  String? approverName, @JsonKey(name: 'approved_at')  String? approvedAt, @JsonKey(name: 'can_download_pdf')  bool canDownloadPdf, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _LeaveRequestModel() when $default != null:
return $default(_that.id,_that.requestNumber,_that.type,_that.typeLabel,_that.reason,_that.startDate,_that.endDate,_that.totalDays,_that.contactPhone,_that.address,_that.evidenceUrl,_that.status,_that.statusLabel,_that.adminNote,_that.approverName,_that.approvedAt,_that.canDownloadPdf,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeaveRequestModel implements LeaveRequestModel {
  const _LeaveRequestModel({required this.id, @JsonKey(name: 'request_number') required this.requestNumber, required this.type, @JsonKey(name: 'type_label') required this.typeLabel, required this.reason, @JsonKey(name: 'start_date') this.startDate, @JsonKey(name: 'end_date') this.endDate, @JsonKey(name: 'total_days') this.totalDays, @JsonKey(name: 'contact_phone') this.contactPhone, this.address, @JsonKey(name: 'evidence_url') this.evidenceUrl, required this.status, @JsonKey(name: 'status_label') required this.statusLabel, @JsonKey(name: 'admin_note') this.adminNote, @JsonKey(name: 'approver_name') this.approverName, @JsonKey(name: 'approved_at') this.approvedAt, @JsonKey(name: 'can_download_pdf') this.canDownloadPdf = false, @JsonKey(name: 'created_at') this.createdAt});
  factory _LeaveRequestModel.fromJson(Map<String, dynamic> json) => _$LeaveRequestModelFromJson(json);

@override final  int id;
@override@JsonKey(name: 'request_number') final  String requestNumber;
@override final  String type;
@override@JsonKey(name: 'type_label') final  String typeLabel;
@override final  String reason;
@override@JsonKey(name: 'start_date') final  String? startDate;
@override@JsonKey(name: 'end_date') final  String? endDate;
@override@JsonKey(name: 'total_days') final  int? totalDays;
@override@JsonKey(name: 'contact_phone') final  String? contactPhone;
@override final  String? address;
@override@JsonKey(name: 'evidence_url') final  String? evidenceUrl;
@override final  String status;
@override@JsonKey(name: 'status_label') final  String statusLabel;
@override@JsonKey(name: 'admin_note') final  String? adminNote;
@override@JsonKey(name: 'approver_name') final  String? approverName;
@override@JsonKey(name: 'approved_at') final  String? approvedAt;
@override@JsonKey(name: 'can_download_pdf') final  bool canDownloadPdf;
@override@JsonKey(name: 'created_at') final  String? createdAt;

/// Create a copy of LeaveRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeaveRequestModelCopyWith<_LeaveRequestModel> get copyWith => __$LeaveRequestModelCopyWithImpl<_LeaveRequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeaveRequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeaveRequestModel&&(identical(other.id, id) || other.id == id)&&(identical(other.requestNumber, requestNumber) || other.requestNumber == requestNumber)&&(identical(other.type, type) || other.type == type)&&(identical(other.typeLabel, typeLabel) || other.typeLabel == typeLabel)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.totalDays, totalDays) || other.totalDays == totalDays)&&(identical(other.contactPhone, contactPhone) || other.contactPhone == contactPhone)&&(identical(other.address, address) || other.address == address)&&(identical(other.evidenceUrl, evidenceUrl) || other.evidenceUrl == evidenceUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusLabel, statusLabel) || other.statusLabel == statusLabel)&&(identical(other.adminNote, adminNote) || other.adminNote == adminNote)&&(identical(other.approverName, approverName) || other.approverName == approverName)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.canDownloadPdf, canDownloadPdf) || other.canDownloadPdf == canDownloadPdf)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,requestNumber,type,typeLabel,reason,startDate,endDate,totalDays,contactPhone,address,evidenceUrl,status,statusLabel,adminNote,approverName,approvedAt,canDownloadPdf,createdAt);

@override
String toString() {
  return 'LeaveRequestModel(id: $id, requestNumber: $requestNumber, type: $type, typeLabel: $typeLabel, reason: $reason, startDate: $startDate, endDate: $endDate, totalDays: $totalDays, contactPhone: $contactPhone, address: $address, evidenceUrl: $evidenceUrl, status: $status, statusLabel: $statusLabel, adminNote: $adminNote, approverName: $approverName, approvedAt: $approvedAt, canDownloadPdf: $canDownloadPdf, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$LeaveRequestModelCopyWith<$Res> implements $LeaveRequestModelCopyWith<$Res> {
  factory _$LeaveRequestModelCopyWith(_LeaveRequestModel value, $Res Function(_LeaveRequestModel) _then) = __$LeaveRequestModelCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'request_number') String requestNumber, String type,@JsonKey(name: 'type_label') String typeLabel, String reason,@JsonKey(name: 'start_date') String? startDate,@JsonKey(name: 'end_date') String? endDate,@JsonKey(name: 'total_days') int? totalDays,@JsonKey(name: 'contact_phone') String? contactPhone, String? address,@JsonKey(name: 'evidence_url') String? evidenceUrl, String status,@JsonKey(name: 'status_label') String statusLabel,@JsonKey(name: 'admin_note') String? adminNote,@JsonKey(name: 'approver_name') String? approverName,@JsonKey(name: 'approved_at') String? approvedAt,@JsonKey(name: 'can_download_pdf') bool canDownloadPdf,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class __$LeaveRequestModelCopyWithImpl<$Res>
    implements _$LeaveRequestModelCopyWith<$Res> {
  __$LeaveRequestModelCopyWithImpl(this._self, this._then);

  final _LeaveRequestModel _self;
  final $Res Function(_LeaveRequestModel) _then;

/// Create a copy of LeaveRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? requestNumber = null,Object? type = null,Object? typeLabel = null,Object? reason = null,Object? startDate = freezed,Object? endDate = freezed,Object? totalDays = freezed,Object? contactPhone = freezed,Object? address = freezed,Object? evidenceUrl = freezed,Object? status = null,Object? statusLabel = null,Object? adminNote = freezed,Object? approverName = freezed,Object? approvedAt = freezed,Object? canDownloadPdf = null,Object? createdAt = freezed,}) {
  return _then(_LeaveRequestModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,requestNumber: null == requestNumber ? _self.requestNumber : requestNumber // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,typeLabel: null == typeLabel ? _self.typeLabel : typeLabel // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,totalDays: freezed == totalDays ? _self.totalDays : totalDays // ignore: cast_nullable_to_non_nullable
as int?,contactPhone: freezed == contactPhone ? _self.contactPhone : contactPhone // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,evidenceUrl: freezed == evidenceUrl ? _self.evidenceUrl : evidenceUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,statusLabel: null == statusLabel ? _self.statusLabel : statusLabel // ignore: cast_nullable_to_non_nullable
as String,adminNote: freezed == adminNote ? _self.adminNote : adminNote // ignore: cast_nullable_to_non_nullable
as String?,approverName: freezed == approverName ? _self.approverName : approverName // ignore: cast_nullable_to_non_nullable
as String?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as String?,canDownloadPdf: null == canDownloadPdf ? _self.canDownloadPdf : canDownloadPdf // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$LeavePaginationModel {

@JsonKey(name: 'current_page') int get currentPage;@JsonKey(name: 'per_page') int get perPage; int get total;@JsonKey(name: 'last_page') int get lastPage;@JsonKey(name: 'has_more') bool get hasMore;
/// Create a copy of LeavePaginationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeavePaginationModelCopyWith<LeavePaginationModel> get copyWith => _$LeavePaginationModelCopyWithImpl<LeavePaginationModel>(this as LeavePaginationModel, _$identity);

  /// Serializes this LeavePaginationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeavePaginationModel&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.perPage, perPage) || other.perPage == perPage)&&(identical(other.total, total) || other.total == total)&&(identical(other.lastPage, lastPage) || other.lastPage == lastPage)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentPage,perPage,total,lastPage,hasMore);

@override
String toString() {
  return 'LeavePaginationModel(currentPage: $currentPage, perPage: $perPage, total: $total, lastPage: $lastPage, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class $LeavePaginationModelCopyWith<$Res>  {
  factory $LeavePaginationModelCopyWith(LeavePaginationModel value, $Res Function(LeavePaginationModel) _then) = _$LeavePaginationModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'current_page') int currentPage,@JsonKey(name: 'per_page') int perPage, int total,@JsonKey(name: 'last_page') int lastPage,@JsonKey(name: 'has_more') bool hasMore
});




}
/// @nodoc
class _$LeavePaginationModelCopyWithImpl<$Res>
    implements $LeavePaginationModelCopyWith<$Res> {
  _$LeavePaginationModelCopyWithImpl(this._self, this._then);

  final LeavePaginationModel _self;
  final $Res Function(LeavePaginationModel) _then;

/// Create a copy of LeavePaginationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentPage = null,Object? perPage = null,Object? total = null,Object? lastPage = null,Object? hasMore = null,}) {
  return _then(_self.copyWith(
currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,perPage: null == perPage ? _self.perPage : perPage // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,lastPage: null == lastPage ? _self.lastPage : lastPage // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LeavePaginationModel].
extension LeavePaginationModelPatterns on LeavePaginationModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeavePaginationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeavePaginationModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeavePaginationModel value)  $default,){
final _that = this;
switch (_that) {
case _LeavePaginationModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeavePaginationModel value)?  $default,){
final _that = this;
switch (_that) {
case _LeavePaginationModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'current_page')  int currentPage, @JsonKey(name: 'per_page')  int perPage,  int total, @JsonKey(name: 'last_page')  int lastPage, @JsonKey(name: 'has_more')  bool hasMore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeavePaginationModel() when $default != null:
return $default(_that.currentPage,_that.perPage,_that.total,_that.lastPage,_that.hasMore);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'current_page')  int currentPage, @JsonKey(name: 'per_page')  int perPage,  int total, @JsonKey(name: 'last_page')  int lastPage, @JsonKey(name: 'has_more')  bool hasMore)  $default,) {final _that = this;
switch (_that) {
case _LeavePaginationModel():
return $default(_that.currentPage,_that.perPage,_that.total,_that.lastPage,_that.hasMore);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'current_page')  int currentPage, @JsonKey(name: 'per_page')  int perPage,  int total, @JsonKey(name: 'last_page')  int lastPage, @JsonKey(name: 'has_more')  bool hasMore)?  $default,) {final _that = this;
switch (_that) {
case _LeavePaginationModel() when $default != null:
return $default(_that.currentPage,_that.perPage,_that.total,_that.lastPage,_that.hasMore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeavePaginationModel implements LeavePaginationModel {
  const _LeavePaginationModel({@JsonKey(name: 'current_page') this.currentPage = 1, @JsonKey(name: 'per_page') this.perPage = 15, this.total = 0, @JsonKey(name: 'last_page') this.lastPage = 1, @JsonKey(name: 'has_more') this.hasMore = false});
  factory _LeavePaginationModel.fromJson(Map<String, dynamic> json) => _$LeavePaginationModelFromJson(json);

@override@JsonKey(name: 'current_page') final  int currentPage;
@override@JsonKey(name: 'per_page') final  int perPage;
@override@JsonKey() final  int total;
@override@JsonKey(name: 'last_page') final  int lastPage;
@override@JsonKey(name: 'has_more') final  bool hasMore;

/// Create a copy of LeavePaginationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeavePaginationModelCopyWith<_LeavePaginationModel> get copyWith => __$LeavePaginationModelCopyWithImpl<_LeavePaginationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeavePaginationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeavePaginationModel&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.perPage, perPage) || other.perPage == perPage)&&(identical(other.total, total) || other.total == total)&&(identical(other.lastPage, lastPage) || other.lastPage == lastPage)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentPage,perPage,total,lastPage,hasMore);

@override
String toString() {
  return 'LeavePaginationModel(currentPage: $currentPage, perPage: $perPage, total: $total, lastPage: $lastPage, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class _$LeavePaginationModelCopyWith<$Res> implements $LeavePaginationModelCopyWith<$Res> {
  factory _$LeavePaginationModelCopyWith(_LeavePaginationModel value, $Res Function(_LeavePaginationModel) _then) = __$LeavePaginationModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'current_page') int currentPage,@JsonKey(name: 'per_page') int perPage, int total,@JsonKey(name: 'last_page') int lastPage,@JsonKey(name: 'has_more') bool hasMore
});




}
/// @nodoc
class __$LeavePaginationModelCopyWithImpl<$Res>
    implements _$LeavePaginationModelCopyWith<$Res> {
  __$LeavePaginationModelCopyWithImpl(this._self, this._then);

  final _LeavePaginationModel _self;
  final $Res Function(_LeavePaginationModel) _then;

/// Create a copy of LeavePaginationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentPage = null,Object? perPage = null,Object? total = null,Object? lastPage = null,Object? hasMore = null,}) {
  return _then(_LeavePaginationModel(
currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,perPage: null == perPage ? _self.perPage : perPage // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,lastPage: null == lastPage ? _self.lastPage : lastPage // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$LeaveListModel {

 List<LeaveRequestModel> get items; LeavePaginationModel get pagination;
/// Create a copy of LeaveListModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaveListModelCopyWith<LeaveListModel> get copyWith => _$LeaveListModelCopyWithImpl<LeaveListModel>(this as LeaveListModel, _$identity);

  /// Serializes this LeaveListModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeaveListModel&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.pagination, pagination) || other.pagination == pagination));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),pagination);

@override
String toString() {
  return 'LeaveListModel(items: $items, pagination: $pagination)';
}


}

/// @nodoc
abstract mixin class $LeaveListModelCopyWith<$Res>  {
  factory $LeaveListModelCopyWith(LeaveListModel value, $Res Function(LeaveListModel) _then) = _$LeaveListModelCopyWithImpl;
@useResult
$Res call({
 List<LeaveRequestModel> items, LeavePaginationModel pagination
});


$LeavePaginationModelCopyWith<$Res> get pagination;

}
/// @nodoc
class _$LeaveListModelCopyWithImpl<$Res>
    implements $LeaveListModelCopyWith<$Res> {
  _$LeaveListModelCopyWithImpl(this._self, this._then);

  final LeaveListModel _self;
  final $Res Function(LeaveListModel) _then;

/// Create a copy of LeaveListModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? pagination = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<LeaveRequestModel>,pagination: null == pagination ? _self.pagination : pagination // ignore: cast_nullable_to_non_nullable
as LeavePaginationModel,
  ));
}
/// Create a copy of LeaveListModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LeavePaginationModelCopyWith<$Res> get pagination {
  
  return $LeavePaginationModelCopyWith<$Res>(_self.pagination, (value) {
    return _then(_self.copyWith(pagination: value));
  });
}
}


/// Adds pattern-matching-related methods to [LeaveListModel].
extension LeaveListModelPatterns on LeaveListModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeaveListModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeaveListModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeaveListModel value)  $default,){
final _that = this;
switch (_that) {
case _LeaveListModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeaveListModel value)?  $default,){
final _that = this;
switch (_that) {
case _LeaveListModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<LeaveRequestModel> items,  LeavePaginationModel pagination)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeaveListModel() when $default != null:
return $default(_that.items,_that.pagination);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<LeaveRequestModel> items,  LeavePaginationModel pagination)  $default,) {final _that = this;
switch (_that) {
case _LeaveListModel():
return $default(_that.items,_that.pagination);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<LeaveRequestModel> items,  LeavePaginationModel pagination)?  $default,) {final _that = this;
switch (_that) {
case _LeaveListModel() when $default != null:
return $default(_that.items,_that.pagination);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeaveListModel implements LeaveListModel {
  const _LeaveListModel({final  List<LeaveRequestModel> items = const <LeaveRequestModel>[], required this.pagination}): _items = items;
  factory _LeaveListModel.fromJson(Map<String, dynamic> json) => _$LeaveListModelFromJson(json);

 final  List<LeaveRequestModel> _items;
@override@JsonKey() List<LeaveRequestModel> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  LeavePaginationModel pagination;

/// Create a copy of LeaveListModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeaveListModelCopyWith<_LeaveListModel> get copyWith => __$LeaveListModelCopyWithImpl<_LeaveListModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeaveListModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeaveListModel&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.pagination, pagination) || other.pagination == pagination));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),pagination);

@override
String toString() {
  return 'LeaveListModel(items: $items, pagination: $pagination)';
}


}

/// @nodoc
abstract mixin class _$LeaveListModelCopyWith<$Res> implements $LeaveListModelCopyWith<$Res> {
  factory _$LeaveListModelCopyWith(_LeaveListModel value, $Res Function(_LeaveListModel) _then) = __$LeaveListModelCopyWithImpl;
@override @useResult
$Res call({
 List<LeaveRequestModel> items, LeavePaginationModel pagination
});


@override $LeavePaginationModelCopyWith<$Res> get pagination;

}
/// @nodoc
class __$LeaveListModelCopyWithImpl<$Res>
    implements _$LeaveListModelCopyWith<$Res> {
  __$LeaveListModelCopyWithImpl(this._self, this._then);

  final _LeaveListModel _self;
  final $Res Function(_LeaveListModel) _then;

/// Create a copy of LeaveListModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? pagination = null,}) {
  return _then(_LeaveListModel(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<LeaveRequestModel>,pagination: null == pagination ? _self.pagination : pagination // ignore: cast_nullable_to_non_nullable
as LeavePaginationModel,
  ));
}

/// Create a copy of LeaveListModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LeavePaginationModelCopyWith<$Res> get pagination {
  
  return $LeavePaginationModelCopyWith<$Res>(_self.pagination, (value) {
    return _then(_self.copyWith(pagination: value));
  });
}
}


/// @nodoc
mixin _$LeaveListEnvelope {

 LeaveListModel get data;
/// Create a copy of LeaveListEnvelope
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaveListEnvelopeCopyWith<LeaveListEnvelope> get copyWith => _$LeaveListEnvelopeCopyWithImpl<LeaveListEnvelope>(this as LeaveListEnvelope, _$identity);

  /// Serializes this LeaveListEnvelope to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeaveListEnvelope&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'LeaveListEnvelope(data: $data)';
}


}

/// @nodoc
abstract mixin class $LeaveListEnvelopeCopyWith<$Res>  {
  factory $LeaveListEnvelopeCopyWith(LeaveListEnvelope value, $Res Function(LeaveListEnvelope) _then) = _$LeaveListEnvelopeCopyWithImpl;
@useResult
$Res call({
 LeaveListModel data
});


$LeaveListModelCopyWith<$Res> get data;

}
/// @nodoc
class _$LeaveListEnvelopeCopyWithImpl<$Res>
    implements $LeaveListEnvelopeCopyWith<$Res> {
  _$LeaveListEnvelopeCopyWithImpl(this._self, this._then);

  final LeaveListEnvelope _self;
  final $Res Function(LeaveListEnvelope) _then;

/// Create a copy of LeaveListEnvelope
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,}) {
  return _then(_self.copyWith(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as LeaveListModel,
  ));
}
/// Create a copy of LeaveListEnvelope
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LeaveListModelCopyWith<$Res> get data {
  
  return $LeaveListModelCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [LeaveListEnvelope].
extension LeaveListEnvelopePatterns on LeaveListEnvelope {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeaveListEnvelope value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeaveListEnvelope() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeaveListEnvelope value)  $default,){
final _that = this;
switch (_that) {
case _LeaveListEnvelope():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeaveListEnvelope value)?  $default,){
final _that = this;
switch (_that) {
case _LeaveListEnvelope() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LeaveListModel data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeaveListEnvelope() when $default != null:
return $default(_that.data);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LeaveListModel data)  $default,) {final _that = this;
switch (_that) {
case _LeaveListEnvelope():
return $default(_that.data);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LeaveListModel data)?  $default,) {final _that = this;
switch (_that) {
case _LeaveListEnvelope() when $default != null:
return $default(_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeaveListEnvelope implements LeaveListEnvelope {
  const _LeaveListEnvelope({required this.data});
  factory _LeaveListEnvelope.fromJson(Map<String, dynamic> json) => _$LeaveListEnvelopeFromJson(json);

@override final  LeaveListModel data;

/// Create a copy of LeaveListEnvelope
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeaveListEnvelopeCopyWith<_LeaveListEnvelope> get copyWith => __$LeaveListEnvelopeCopyWithImpl<_LeaveListEnvelope>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeaveListEnvelopeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeaveListEnvelope&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'LeaveListEnvelope(data: $data)';
}


}

/// @nodoc
abstract mixin class _$LeaveListEnvelopeCopyWith<$Res> implements $LeaveListEnvelopeCopyWith<$Res> {
  factory _$LeaveListEnvelopeCopyWith(_LeaveListEnvelope value, $Res Function(_LeaveListEnvelope) _then) = __$LeaveListEnvelopeCopyWithImpl;
@override @useResult
$Res call({
 LeaveListModel data
});


@override $LeaveListModelCopyWith<$Res> get data;

}
/// @nodoc
class __$LeaveListEnvelopeCopyWithImpl<$Res>
    implements _$LeaveListEnvelopeCopyWith<$Res> {
  __$LeaveListEnvelopeCopyWithImpl(this._self, this._then);

  final _LeaveListEnvelope _self;
  final $Res Function(_LeaveListEnvelope) _then;

/// Create a copy of LeaveListEnvelope
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(_LeaveListEnvelope(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as LeaveListModel,
  ));
}

/// Create a copy of LeaveListEnvelope
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LeaveListModelCopyWith<$Res> get data {
  
  return $LeaveListModelCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// @nodoc
mixin _$LeaveDetailEnvelope {

 LeaveRequestModel get data;
/// Create a copy of LeaveDetailEnvelope
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaveDetailEnvelopeCopyWith<LeaveDetailEnvelope> get copyWith => _$LeaveDetailEnvelopeCopyWithImpl<LeaveDetailEnvelope>(this as LeaveDetailEnvelope, _$identity);

  /// Serializes this LeaveDetailEnvelope to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeaveDetailEnvelope&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'LeaveDetailEnvelope(data: $data)';
}


}

/// @nodoc
abstract mixin class $LeaveDetailEnvelopeCopyWith<$Res>  {
  factory $LeaveDetailEnvelopeCopyWith(LeaveDetailEnvelope value, $Res Function(LeaveDetailEnvelope) _then) = _$LeaveDetailEnvelopeCopyWithImpl;
@useResult
$Res call({
 LeaveRequestModel data
});


$LeaveRequestModelCopyWith<$Res> get data;

}
/// @nodoc
class _$LeaveDetailEnvelopeCopyWithImpl<$Res>
    implements $LeaveDetailEnvelopeCopyWith<$Res> {
  _$LeaveDetailEnvelopeCopyWithImpl(this._self, this._then);

  final LeaveDetailEnvelope _self;
  final $Res Function(LeaveDetailEnvelope) _then;

/// Create a copy of LeaveDetailEnvelope
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,}) {
  return _then(_self.copyWith(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as LeaveRequestModel,
  ));
}
/// Create a copy of LeaveDetailEnvelope
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LeaveRequestModelCopyWith<$Res> get data {
  
  return $LeaveRequestModelCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [LeaveDetailEnvelope].
extension LeaveDetailEnvelopePatterns on LeaveDetailEnvelope {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeaveDetailEnvelope value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeaveDetailEnvelope() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeaveDetailEnvelope value)  $default,){
final _that = this;
switch (_that) {
case _LeaveDetailEnvelope():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeaveDetailEnvelope value)?  $default,){
final _that = this;
switch (_that) {
case _LeaveDetailEnvelope() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LeaveRequestModel data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeaveDetailEnvelope() when $default != null:
return $default(_that.data);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LeaveRequestModel data)  $default,) {final _that = this;
switch (_that) {
case _LeaveDetailEnvelope():
return $default(_that.data);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LeaveRequestModel data)?  $default,) {final _that = this;
switch (_that) {
case _LeaveDetailEnvelope() when $default != null:
return $default(_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeaveDetailEnvelope implements LeaveDetailEnvelope {
  const _LeaveDetailEnvelope({required this.data});
  factory _LeaveDetailEnvelope.fromJson(Map<String, dynamic> json) => _$LeaveDetailEnvelopeFromJson(json);

@override final  LeaveRequestModel data;

/// Create a copy of LeaveDetailEnvelope
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeaveDetailEnvelopeCopyWith<_LeaveDetailEnvelope> get copyWith => __$LeaveDetailEnvelopeCopyWithImpl<_LeaveDetailEnvelope>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeaveDetailEnvelopeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeaveDetailEnvelope&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'LeaveDetailEnvelope(data: $data)';
}


}

/// @nodoc
abstract mixin class _$LeaveDetailEnvelopeCopyWith<$Res> implements $LeaveDetailEnvelopeCopyWith<$Res> {
  factory _$LeaveDetailEnvelopeCopyWith(_LeaveDetailEnvelope value, $Res Function(_LeaveDetailEnvelope) _then) = __$LeaveDetailEnvelopeCopyWithImpl;
@override @useResult
$Res call({
 LeaveRequestModel data
});


@override $LeaveRequestModelCopyWith<$Res> get data;

}
/// @nodoc
class __$LeaveDetailEnvelopeCopyWithImpl<$Res>
    implements _$LeaveDetailEnvelopeCopyWith<$Res> {
  __$LeaveDetailEnvelopeCopyWithImpl(this._self, this._then);

  final _LeaveDetailEnvelope _self;
  final $Res Function(_LeaveDetailEnvelope) _then;

/// Create a copy of LeaveDetailEnvelope
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(_LeaveDetailEnvelope(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as LeaveRequestModel,
  ));
}

/// Create a copy of LeaveDetailEnvelope
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LeaveRequestModelCopyWith<$Res> get data {
  
  return $LeaveRequestModelCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

// dart format on
