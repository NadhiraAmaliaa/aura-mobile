// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AttendanceModel {

 int get id;@JsonKey(name: 'attendance_date') String? get attendanceDate;@JsonKey(name: 'check_in_time') String? get checkInTime;@JsonKey(name: 'check_out_time') String? get checkOutTime;@JsonKey(name: 'check_in_latitude') String? get checkInLatitude;@JsonKey(name: 'check_in_longitude') String? get checkInLongitude;@JsonKey(name: 'check_out_latitude') String? get checkOutLatitude;@JsonKey(name: 'check_out_longitude') String? get checkOutLongitude; String get status;@JsonKey(name: 'status_label') String get statusLabel;@JsonKey(name: 'work_mode') String? get workMode;@JsonKey(name: 'work_mode_label') String? get workModeLabel;
/// Create a copy of AttendanceModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceModelCopyWith<AttendanceModel> get copyWith => _$AttendanceModelCopyWithImpl<AttendanceModel>(this as AttendanceModel, _$identity);

  /// Serializes this AttendanceModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceModel&&(identical(other.id, id) || other.id == id)&&(identical(other.attendanceDate, attendanceDate) || other.attendanceDate == attendanceDate)&&(identical(other.checkInTime, checkInTime) || other.checkInTime == checkInTime)&&(identical(other.checkOutTime, checkOutTime) || other.checkOutTime == checkOutTime)&&(identical(other.checkInLatitude, checkInLatitude) || other.checkInLatitude == checkInLatitude)&&(identical(other.checkInLongitude, checkInLongitude) || other.checkInLongitude == checkInLongitude)&&(identical(other.checkOutLatitude, checkOutLatitude) || other.checkOutLatitude == checkOutLatitude)&&(identical(other.checkOutLongitude, checkOutLongitude) || other.checkOutLongitude == checkOutLongitude)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusLabel, statusLabel) || other.statusLabel == statusLabel)&&(identical(other.workMode, workMode) || other.workMode == workMode)&&(identical(other.workModeLabel, workModeLabel) || other.workModeLabel == workModeLabel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,attendanceDate,checkInTime,checkOutTime,checkInLatitude,checkInLongitude,checkOutLatitude,checkOutLongitude,status,statusLabel,workMode,workModeLabel);

@override
String toString() {
  return 'AttendanceModel(id: $id, attendanceDate: $attendanceDate, checkInTime: $checkInTime, checkOutTime: $checkOutTime, checkInLatitude: $checkInLatitude, checkInLongitude: $checkInLongitude, checkOutLatitude: $checkOutLatitude, checkOutLongitude: $checkOutLongitude, status: $status, statusLabel: $statusLabel, workMode: $workMode, workModeLabel: $workModeLabel)';
}


}

/// @nodoc
abstract mixin class $AttendanceModelCopyWith<$Res>  {
  factory $AttendanceModelCopyWith(AttendanceModel value, $Res Function(AttendanceModel) _then) = _$AttendanceModelCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'attendance_date') String? attendanceDate,@JsonKey(name: 'check_in_time') String? checkInTime,@JsonKey(name: 'check_out_time') String? checkOutTime,@JsonKey(name: 'check_in_latitude') String? checkInLatitude,@JsonKey(name: 'check_in_longitude') String? checkInLongitude,@JsonKey(name: 'check_out_latitude') String? checkOutLatitude,@JsonKey(name: 'check_out_longitude') String? checkOutLongitude, String status,@JsonKey(name: 'status_label') String statusLabel,@JsonKey(name: 'work_mode') String? workMode,@JsonKey(name: 'work_mode_label') String? workModeLabel
});




}
/// @nodoc
class _$AttendanceModelCopyWithImpl<$Res>
    implements $AttendanceModelCopyWith<$Res> {
  _$AttendanceModelCopyWithImpl(this._self, this._then);

  final AttendanceModel _self;
  final $Res Function(AttendanceModel) _then;

/// Create a copy of AttendanceModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? attendanceDate = freezed,Object? checkInTime = freezed,Object? checkOutTime = freezed,Object? checkInLatitude = freezed,Object? checkInLongitude = freezed,Object? checkOutLatitude = freezed,Object? checkOutLongitude = freezed,Object? status = null,Object? statusLabel = null,Object? workMode = freezed,Object? workModeLabel = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,attendanceDate: freezed == attendanceDate ? _self.attendanceDate : attendanceDate // ignore: cast_nullable_to_non_nullable
as String?,checkInTime: freezed == checkInTime ? _self.checkInTime : checkInTime // ignore: cast_nullable_to_non_nullable
as String?,checkOutTime: freezed == checkOutTime ? _self.checkOutTime : checkOutTime // ignore: cast_nullable_to_non_nullable
as String?,checkInLatitude: freezed == checkInLatitude ? _self.checkInLatitude : checkInLatitude // ignore: cast_nullable_to_non_nullable
as String?,checkInLongitude: freezed == checkInLongitude ? _self.checkInLongitude : checkInLongitude // ignore: cast_nullable_to_non_nullable
as String?,checkOutLatitude: freezed == checkOutLatitude ? _self.checkOutLatitude : checkOutLatitude // ignore: cast_nullable_to_non_nullable
as String?,checkOutLongitude: freezed == checkOutLongitude ? _self.checkOutLongitude : checkOutLongitude // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,statusLabel: null == statusLabel ? _self.statusLabel : statusLabel // ignore: cast_nullable_to_non_nullable
as String,workMode: freezed == workMode ? _self.workMode : workMode // ignore: cast_nullable_to_non_nullable
as String?,workModeLabel: freezed == workModeLabel ? _self.workModeLabel : workModeLabel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AttendanceModel].
extension AttendanceModelPatterns on AttendanceModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceModel value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceModel value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'attendance_date')  String? attendanceDate, @JsonKey(name: 'check_in_time')  String? checkInTime, @JsonKey(name: 'check_out_time')  String? checkOutTime, @JsonKey(name: 'check_in_latitude')  String? checkInLatitude, @JsonKey(name: 'check_in_longitude')  String? checkInLongitude, @JsonKey(name: 'check_out_latitude')  String? checkOutLatitude, @JsonKey(name: 'check_out_longitude')  String? checkOutLongitude,  String status, @JsonKey(name: 'status_label')  String statusLabel, @JsonKey(name: 'work_mode')  String? workMode, @JsonKey(name: 'work_mode_label')  String? workModeLabel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceModel() when $default != null:
return $default(_that.id,_that.attendanceDate,_that.checkInTime,_that.checkOutTime,_that.checkInLatitude,_that.checkInLongitude,_that.checkOutLatitude,_that.checkOutLongitude,_that.status,_that.statusLabel,_that.workMode,_that.workModeLabel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'attendance_date')  String? attendanceDate, @JsonKey(name: 'check_in_time')  String? checkInTime, @JsonKey(name: 'check_out_time')  String? checkOutTime, @JsonKey(name: 'check_in_latitude')  String? checkInLatitude, @JsonKey(name: 'check_in_longitude')  String? checkInLongitude, @JsonKey(name: 'check_out_latitude')  String? checkOutLatitude, @JsonKey(name: 'check_out_longitude')  String? checkOutLongitude,  String status, @JsonKey(name: 'status_label')  String statusLabel, @JsonKey(name: 'work_mode')  String? workMode, @JsonKey(name: 'work_mode_label')  String? workModeLabel)  $default,) {final _that = this;
switch (_that) {
case _AttendanceModel():
return $default(_that.id,_that.attendanceDate,_that.checkInTime,_that.checkOutTime,_that.checkInLatitude,_that.checkInLongitude,_that.checkOutLatitude,_that.checkOutLongitude,_that.status,_that.statusLabel,_that.workMode,_that.workModeLabel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'attendance_date')  String? attendanceDate, @JsonKey(name: 'check_in_time')  String? checkInTime, @JsonKey(name: 'check_out_time')  String? checkOutTime, @JsonKey(name: 'check_in_latitude')  String? checkInLatitude, @JsonKey(name: 'check_in_longitude')  String? checkInLongitude, @JsonKey(name: 'check_out_latitude')  String? checkOutLatitude, @JsonKey(name: 'check_out_longitude')  String? checkOutLongitude,  String status, @JsonKey(name: 'status_label')  String statusLabel, @JsonKey(name: 'work_mode')  String? workMode, @JsonKey(name: 'work_mode_label')  String? workModeLabel)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceModel() when $default != null:
return $default(_that.id,_that.attendanceDate,_that.checkInTime,_that.checkOutTime,_that.checkInLatitude,_that.checkInLongitude,_that.checkOutLatitude,_that.checkOutLongitude,_that.status,_that.statusLabel,_that.workMode,_that.workModeLabel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttendanceModel implements AttendanceModel {
  const _AttendanceModel({required this.id, @JsonKey(name: 'attendance_date') this.attendanceDate, @JsonKey(name: 'check_in_time') this.checkInTime, @JsonKey(name: 'check_out_time') this.checkOutTime, @JsonKey(name: 'check_in_latitude') this.checkInLatitude, @JsonKey(name: 'check_in_longitude') this.checkInLongitude, @JsonKey(name: 'check_out_latitude') this.checkOutLatitude, @JsonKey(name: 'check_out_longitude') this.checkOutLongitude, required this.status, @JsonKey(name: 'status_label') required this.statusLabel, @JsonKey(name: 'work_mode') this.workMode, @JsonKey(name: 'work_mode_label') this.workModeLabel});
  factory _AttendanceModel.fromJson(Map<String, dynamic> json) => _$AttendanceModelFromJson(json);

@override final  int id;
@override@JsonKey(name: 'attendance_date') final  String? attendanceDate;
@override@JsonKey(name: 'check_in_time') final  String? checkInTime;
@override@JsonKey(name: 'check_out_time') final  String? checkOutTime;
@override@JsonKey(name: 'check_in_latitude') final  String? checkInLatitude;
@override@JsonKey(name: 'check_in_longitude') final  String? checkInLongitude;
@override@JsonKey(name: 'check_out_latitude') final  String? checkOutLatitude;
@override@JsonKey(name: 'check_out_longitude') final  String? checkOutLongitude;
@override final  String status;
@override@JsonKey(name: 'status_label') final  String statusLabel;
@override@JsonKey(name: 'work_mode') final  String? workMode;
@override@JsonKey(name: 'work_mode_label') final  String? workModeLabel;

/// Create a copy of AttendanceModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceModelCopyWith<_AttendanceModel> get copyWith => __$AttendanceModelCopyWithImpl<_AttendanceModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceModel&&(identical(other.id, id) || other.id == id)&&(identical(other.attendanceDate, attendanceDate) || other.attendanceDate == attendanceDate)&&(identical(other.checkInTime, checkInTime) || other.checkInTime == checkInTime)&&(identical(other.checkOutTime, checkOutTime) || other.checkOutTime == checkOutTime)&&(identical(other.checkInLatitude, checkInLatitude) || other.checkInLatitude == checkInLatitude)&&(identical(other.checkInLongitude, checkInLongitude) || other.checkInLongitude == checkInLongitude)&&(identical(other.checkOutLatitude, checkOutLatitude) || other.checkOutLatitude == checkOutLatitude)&&(identical(other.checkOutLongitude, checkOutLongitude) || other.checkOutLongitude == checkOutLongitude)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusLabel, statusLabel) || other.statusLabel == statusLabel)&&(identical(other.workMode, workMode) || other.workMode == workMode)&&(identical(other.workModeLabel, workModeLabel) || other.workModeLabel == workModeLabel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,attendanceDate,checkInTime,checkOutTime,checkInLatitude,checkInLongitude,checkOutLatitude,checkOutLongitude,status,statusLabel,workMode,workModeLabel);

@override
String toString() {
  return 'AttendanceModel(id: $id, attendanceDate: $attendanceDate, checkInTime: $checkInTime, checkOutTime: $checkOutTime, checkInLatitude: $checkInLatitude, checkInLongitude: $checkInLongitude, checkOutLatitude: $checkOutLatitude, checkOutLongitude: $checkOutLongitude, status: $status, statusLabel: $statusLabel, workMode: $workMode, workModeLabel: $workModeLabel)';
}


}

/// @nodoc
abstract mixin class _$AttendanceModelCopyWith<$Res> implements $AttendanceModelCopyWith<$Res> {
  factory _$AttendanceModelCopyWith(_AttendanceModel value, $Res Function(_AttendanceModel) _then) = __$AttendanceModelCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'attendance_date') String? attendanceDate,@JsonKey(name: 'check_in_time') String? checkInTime,@JsonKey(name: 'check_out_time') String? checkOutTime,@JsonKey(name: 'check_in_latitude') String? checkInLatitude,@JsonKey(name: 'check_in_longitude') String? checkInLongitude,@JsonKey(name: 'check_out_latitude') String? checkOutLatitude,@JsonKey(name: 'check_out_longitude') String? checkOutLongitude, String status,@JsonKey(name: 'status_label') String statusLabel,@JsonKey(name: 'work_mode') String? workMode,@JsonKey(name: 'work_mode_label') String? workModeLabel
});




}
/// @nodoc
class __$AttendanceModelCopyWithImpl<$Res>
    implements _$AttendanceModelCopyWith<$Res> {
  __$AttendanceModelCopyWithImpl(this._self, this._then);

  final _AttendanceModel _self;
  final $Res Function(_AttendanceModel) _then;

/// Create a copy of AttendanceModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? attendanceDate = freezed,Object? checkInTime = freezed,Object? checkOutTime = freezed,Object? checkInLatitude = freezed,Object? checkInLongitude = freezed,Object? checkOutLatitude = freezed,Object? checkOutLongitude = freezed,Object? status = null,Object? statusLabel = null,Object? workMode = freezed,Object? workModeLabel = freezed,}) {
  return _then(_AttendanceModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,attendanceDate: freezed == attendanceDate ? _self.attendanceDate : attendanceDate // ignore: cast_nullable_to_non_nullable
as String?,checkInTime: freezed == checkInTime ? _self.checkInTime : checkInTime // ignore: cast_nullable_to_non_nullable
as String?,checkOutTime: freezed == checkOutTime ? _self.checkOutTime : checkOutTime // ignore: cast_nullable_to_non_nullable
as String?,checkInLatitude: freezed == checkInLatitude ? _self.checkInLatitude : checkInLatitude // ignore: cast_nullable_to_non_nullable
as String?,checkInLongitude: freezed == checkInLongitude ? _self.checkInLongitude : checkInLongitude // ignore: cast_nullable_to_non_nullable
as String?,checkOutLatitude: freezed == checkOutLatitude ? _self.checkOutLatitude : checkOutLatitude // ignore: cast_nullable_to_non_nullable
as String?,checkOutLongitude: freezed == checkOutLongitude ? _self.checkOutLongitude : checkOutLongitude // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,statusLabel: null == statusLabel ? _self.statusLabel : statusLabel // ignore: cast_nullable_to_non_nullable
as String,workMode: freezed == workMode ? _self.workMode : workMode // ignore: cast_nullable_to_non_nullable
as String?,workModeLabel: freezed == workModeLabel ? _self.workModeLabel : workModeLabel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$WorkHoursModel {

 String? get start; String? get end;
/// Create a copy of WorkHoursModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkHoursModelCopyWith<WorkHoursModel> get copyWith => _$WorkHoursModelCopyWithImpl<WorkHoursModel>(this as WorkHoursModel, _$identity);

  /// Serializes this WorkHoursModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkHoursModel&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,start,end);

@override
String toString() {
  return 'WorkHoursModel(start: $start, end: $end)';
}


}

/// @nodoc
abstract mixin class $WorkHoursModelCopyWith<$Res>  {
  factory $WorkHoursModelCopyWith(WorkHoursModel value, $Res Function(WorkHoursModel) _then) = _$WorkHoursModelCopyWithImpl;
@useResult
$Res call({
 String? start, String? end
});




}
/// @nodoc
class _$WorkHoursModelCopyWithImpl<$Res>
    implements $WorkHoursModelCopyWith<$Res> {
  _$WorkHoursModelCopyWithImpl(this._self, this._then);

  final WorkHoursModel _self;
  final $Res Function(WorkHoursModel) _then;

/// Create a copy of WorkHoursModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? start = freezed,Object? end = freezed,}) {
  return _then(_self.copyWith(
start: freezed == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as String?,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkHoursModel].
extension WorkHoursModelPatterns on WorkHoursModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkHoursModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkHoursModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkHoursModel value)  $default,){
final _that = this;
switch (_that) {
case _WorkHoursModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkHoursModel value)?  $default,){
final _that = this;
switch (_that) {
case _WorkHoursModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? start,  String? end)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkHoursModel() when $default != null:
return $default(_that.start,_that.end);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? start,  String? end)  $default,) {final _that = this;
switch (_that) {
case _WorkHoursModel():
return $default(_that.start,_that.end);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? start,  String? end)?  $default,) {final _that = this;
switch (_that) {
case _WorkHoursModel() when $default != null:
return $default(_that.start,_that.end);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkHoursModel implements WorkHoursModel {
  const _WorkHoursModel({this.start, this.end});
  factory _WorkHoursModel.fromJson(Map<String, dynamic> json) => _$WorkHoursModelFromJson(json);

@override final  String? start;
@override final  String? end;

/// Create a copy of WorkHoursModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkHoursModelCopyWith<_WorkHoursModel> get copyWith => __$WorkHoursModelCopyWithImpl<_WorkHoursModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkHoursModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkHoursModel&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,start,end);

@override
String toString() {
  return 'WorkHoursModel(start: $start, end: $end)';
}


}

/// @nodoc
abstract mixin class _$WorkHoursModelCopyWith<$Res> implements $WorkHoursModelCopyWith<$Res> {
  factory _$WorkHoursModelCopyWith(_WorkHoursModel value, $Res Function(_WorkHoursModel) _then) = __$WorkHoursModelCopyWithImpl;
@override @useResult
$Res call({
 String? start, String? end
});




}
/// @nodoc
class __$WorkHoursModelCopyWithImpl<$Res>
    implements _$WorkHoursModelCopyWith<$Res> {
  __$WorkHoursModelCopyWithImpl(this._self, this._then);

  final _WorkHoursModel _self;
  final $Res Function(_WorkHoursModel) _then;

/// Create a copy of WorkHoursModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? start = freezed,Object? end = freezed,}) {
  return _then(_WorkHoursModel(
start: freezed == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as String?,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TodayLeaveModel {

 String get type;@JsonKey(name: 'type_label') String get typeLabel;
/// Create a copy of TodayLeaveModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodayLeaveModelCopyWith<TodayLeaveModel> get copyWith => _$TodayLeaveModelCopyWithImpl<TodayLeaveModel>(this as TodayLeaveModel, _$identity);

  /// Serializes this TodayLeaveModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodayLeaveModel&&(identical(other.type, type) || other.type == type)&&(identical(other.typeLabel, typeLabel) || other.typeLabel == typeLabel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,typeLabel);

@override
String toString() {
  return 'TodayLeaveModel(type: $type, typeLabel: $typeLabel)';
}


}

/// @nodoc
abstract mixin class $TodayLeaveModelCopyWith<$Res>  {
  factory $TodayLeaveModelCopyWith(TodayLeaveModel value, $Res Function(TodayLeaveModel) _then) = _$TodayLeaveModelCopyWithImpl;
@useResult
$Res call({
 String type,@JsonKey(name: 'type_label') String typeLabel
});




}
/// @nodoc
class _$TodayLeaveModelCopyWithImpl<$Res>
    implements $TodayLeaveModelCopyWith<$Res> {
  _$TodayLeaveModelCopyWithImpl(this._self, this._then);

  final TodayLeaveModel _self;
  final $Res Function(TodayLeaveModel) _then;

/// Create a copy of TodayLeaveModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? typeLabel = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,typeLabel: null == typeLabel ? _self.typeLabel : typeLabel // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TodayLeaveModel].
extension TodayLeaveModelPatterns on TodayLeaveModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodayLeaveModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodayLeaveModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodayLeaveModel value)  $default,){
final _that = this;
switch (_that) {
case _TodayLeaveModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodayLeaveModel value)?  $default,){
final _that = this;
switch (_that) {
case _TodayLeaveModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type, @JsonKey(name: 'type_label')  String typeLabel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodayLeaveModel() when $default != null:
return $default(_that.type,_that.typeLabel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type, @JsonKey(name: 'type_label')  String typeLabel)  $default,) {final _that = this;
switch (_that) {
case _TodayLeaveModel():
return $default(_that.type,_that.typeLabel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type, @JsonKey(name: 'type_label')  String typeLabel)?  $default,) {final _that = this;
switch (_that) {
case _TodayLeaveModel() when $default != null:
return $default(_that.type,_that.typeLabel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TodayLeaveModel implements TodayLeaveModel {
  const _TodayLeaveModel({required this.type, @JsonKey(name: 'type_label') required this.typeLabel});
  factory _TodayLeaveModel.fromJson(Map<String, dynamic> json) => _$TodayLeaveModelFromJson(json);

@override final  String type;
@override@JsonKey(name: 'type_label') final  String typeLabel;

/// Create a copy of TodayLeaveModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodayLeaveModelCopyWith<_TodayLeaveModel> get copyWith => __$TodayLeaveModelCopyWithImpl<_TodayLeaveModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TodayLeaveModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodayLeaveModel&&(identical(other.type, type) || other.type == type)&&(identical(other.typeLabel, typeLabel) || other.typeLabel == typeLabel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,typeLabel);

@override
String toString() {
  return 'TodayLeaveModel(type: $type, typeLabel: $typeLabel)';
}


}

/// @nodoc
abstract mixin class _$TodayLeaveModelCopyWith<$Res> implements $TodayLeaveModelCopyWith<$Res> {
  factory _$TodayLeaveModelCopyWith(_TodayLeaveModel value, $Res Function(_TodayLeaveModel) _then) = __$TodayLeaveModelCopyWithImpl;
@override @useResult
$Res call({
 String type,@JsonKey(name: 'type_label') String typeLabel
});




}
/// @nodoc
class __$TodayLeaveModelCopyWithImpl<$Res>
    implements _$TodayLeaveModelCopyWith<$Res> {
  __$TodayLeaveModelCopyWithImpl(this._self, this._then);

  final _TodayLeaveModel _self;
  final $Res Function(_TodayLeaveModel) _then;

/// Create a copy of TodayLeaveModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? typeLabel = null,}) {
  return _then(_TodayLeaveModel(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,typeLabel: null == typeLabel ? _self.typeLabel : typeLabel // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AttendanceTodayModel {

 String get date;@JsonKey(name: 'is_working_day') bool get isWorkingDay;@JsonKey(name: 'work_hours') WorkHoursModel get workHours; AttendanceModel? get attendance; TodayLeaveModel? get leave;
/// Create a copy of AttendanceTodayModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceTodayModelCopyWith<AttendanceTodayModel> get copyWith => _$AttendanceTodayModelCopyWithImpl<AttendanceTodayModel>(this as AttendanceTodayModel, _$identity);

  /// Serializes this AttendanceTodayModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceTodayModel&&(identical(other.date, date) || other.date == date)&&(identical(other.isWorkingDay, isWorkingDay) || other.isWorkingDay == isWorkingDay)&&(identical(other.workHours, workHours) || other.workHours == workHours)&&(identical(other.attendance, attendance) || other.attendance == attendance)&&(identical(other.leave, leave) || other.leave == leave));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,isWorkingDay,workHours,attendance,leave);

@override
String toString() {
  return 'AttendanceTodayModel(date: $date, isWorkingDay: $isWorkingDay, workHours: $workHours, attendance: $attendance, leave: $leave)';
}


}

/// @nodoc
abstract mixin class $AttendanceTodayModelCopyWith<$Res>  {
  factory $AttendanceTodayModelCopyWith(AttendanceTodayModel value, $Res Function(AttendanceTodayModel) _then) = _$AttendanceTodayModelCopyWithImpl;
@useResult
$Res call({
 String date,@JsonKey(name: 'is_working_day') bool isWorkingDay,@JsonKey(name: 'work_hours') WorkHoursModel workHours, AttendanceModel? attendance, TodayLeaveModel? leave
});


$WorkHoursModelCopyWith<$Res> get workHours;$AttendanceModelCopyWith<$Res>? get attendance;$TodayLeaveModelCopyWith<$Res>? get leave;

}
/// @nodoc
class _$AttendanceTodayModelCopyWithImpl<$Res>
    implements $AttendanceTodayModelCopyWith<$Res> {
  _$AttendanceTodayModelCopyWithImpl(this._self, this._then);

  final AttendanceTodayModel _self;
  final $Res Function(AttendanceTodayModel) _then;

/// Create a copy of AttendanceTodayModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? isWorkingDay = null,Object? workHours = null,Object? attendance = freezed,Object? leave = freezed,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,isWorkingDay: null == isWorkingDay ? _self.isWorkingDay : isWorkingDay // ignore: cast_nullable_to_non_nullable
as bool,workHours: null == workHours ? _self.workHours : workHours // ignore: cast_nullable_to_non_nullable
as WorkHoursModel,attendance: freezed == attendance ? _self.attendance : attendance // ignore: cast_nullable_to_non_nullable
as AttendanceModel?,leave: freezed == leave ? _self.leave : leave // ignore: cast_nullable_to_non_nullable
as TodayLeaveModel?,
  ));
}
/// Create a copy of AttendanceTodayModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkHoursModelCopyWith<$Res> get workHours {
  
  return $WorkHoursModelCopyWith<$Res>(_self.workHours, (value) {
    return _then(_self.copyWith(workHours: value));
  });
}/// Create a copy of AttendanceTodayModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttendanceModelCopyWith<$Res>? get attendance {
    if (_self.attendance == null) {
    return null;
  }

  return $AttendanceModelCopyWith<$Res>(_self.attendance!, (value) {
    return _then(_self.copyWith(attendance: value));
  });
}/// Create a copy of AttendanceTodayModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TodayLeaveModelCopyWith<$Res>? get leave {
    if (_self.leave == null) {
    return null;
  }

  return $TodayLeaveModelCopyWith<$Res>(_self.leave!, (value) {
    return _then(_self.copyWith(leave: value));
  });
}
}


/// Adds pattern-matching-related methods to [AttendanceTodayModel].
extension AttendanceTodayModelPatterns on AttendanceTodayModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceTodayModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceTodayModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceTodayModel value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceTodayModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceTodayModel value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceTodayModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date, @JsonKey(name: 'is_working_day')  bool isWorkingDay, @JsonKey(name: 'work_hours')  WorkHoursModel workHours,  AttendanceModel? attendance,  TodayLeaveModel? leave)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceTodayModel() when $default != null:
return $default(_that.date,_that.isWorkingDay,_that.workHours,_that.attendance,_that.leave);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date, @JsonKey(name: 'is_working_day')  bool isWorkingDay, @JsonKey(name: 'work_hours')  WorkHoursModel workHours,  AttendanceModel? attendance,  TodayLeaveModel? leave)  $default,) {final _that = this;
switch (_that) {
case _AttendanceTodayModel():
return $default(_that.date,_that.isWorkingDay,_that.workHours,_that.attendance,_that.leave);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date, @JsonKey(name: 'is_working_day')  bool isWorkingDay, @JsonKey(name: 'work_hours')  WorkHoursModel workHours,  AttendanceModel? attendance,  TodayLeaveModel? leave)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceTodayModel() when $default != null:
return $default(_that.date,_that.isWorkingDay,_that.workHours,_that.attendance,_that.leave);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttendanceTodayModel implements AttendanceTodayModel {
  const _AttendanceTodayModel({required this.date, @JsonKey(name: 'is_working_day') required this.isWorkingDay, @JsonKey(name: 'work_hours') required this.workHours, this.attendance, this.leave});
  factory _AttendanceTodayModel.fromJson(Map<String, dynamic> json) => _$AttendanceTodayModelFromJson(json);

@override final  String date;
@override@JsonKey(name: 'is_working_day') final  bool isWorkingDay;
@override@JsonKey(name: 'work_hours') final  WorkHoursModel workHours;
@override final  AttendanceModel? attendance;
@override final  TodayLeaveModel? leave;

/// Create a copy of AttendanceTodayModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceTodayModelCopyWith<_AttendanceTodayModel> get copyWith => __$AttendanceTodayModelCopyWithImpl<_AttendanceTodayModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceTodayModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceTodayModel&&(identical(other.date, date) || other.date == date)&&(identical(other.isWorkingDay, isWorkingDay) || other.isWorkingDay == isWorkingDay)&&(identical(other.workHours, workHours) || other.workHours == workHours)&&(identical(other.attendance, attendance) || other.attendance == attendance)&&(identical(other.leave, leave) || other.leave == leave));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,isWorkingDay,workHours,attendance,leave);

@override
String toString() {
  return 'AttendanceTodayModel(date: $date, isWorkingDay: $isWorkingDay, workHours: $workHours, attendance: $attendance, leave: $leave)';
}


}

/// @nodoc
abstract mixin class _$AttendanceTodayModelCopyWith<$Res> implements $AttendanceTodayModelCopyWith<$Res> {
  factory _$AttendanceTodayModelCopyWith(_AttendanceTodayModel value, $Res Function(_AttendanceTodayModel) _then) = __$AttendanceTodayModelCopyWithImpl;
@override @useResult
$Res call({
 String date,@JsonKey(name: 'is_working_day') bool isWorkingDay,@JsonKey(name: 'work_hours') WorkHoursModel workHours, AttendanceModel? attendance, TodayLeaveModel? leave
});


@override $WorkHoursModelCopyWith<$Res> get workHours;@override $AttendanceModelCopyWith<$Res>? get attendance;@override $TodayLeaveModelCopyWith<$Res>? get leave;

}
/// @nodoc
class __$AttendanceTodayModelCopyWithImpl<$Res>
    implements _$AttendanceTodayModelCopyWith<$Res> {
  __$AttendanceTodayModelCopyWithImpl(this._self, this._then);

  final _AttendanceTodayModel _self;
  final $Res Function(_AttendanceTodayModel) _then;

/// Create a copy of AttendanceTodayModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? isWorkingDay = null,Object? workHours = null,Object? attendance = freezed,Object? leave = freezed,}) {
  return _then(_AttendanceTodayModel(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,isWorkingDay: null == isWorkingDay ? _self.isWorkingDay : isWorkingDay // ignore: cast_nullable_to_non_nullable
as bool,workHours: null == workHours ? _self.workHours : workHours // ignore: cast_nullable_to_non_nullable
as WorkHoursModel,attendance: freezed == attendance ? _self.attendance : attendance // ignore: cast_nullable_to_non_nullable
as AttendanceModel?,leave: freezed == leave ? _self.leave : leave // ignore: cast_nullable_to_non_nullable
as TodayLeaveModel?,
  ));
}

/// Create a copy of AttendanceTodayModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkHoursModelCopyWith<$Res> get workHours {
  
  return $WorkHoursModelCopyWith<$Res>(_self.workHours, (value) {
    return _then(_self.copyWith(workHours: value));
  });
}/// Create a copy of AttendanceTodayModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttendanceModelCopyWith<$Res>? get attendance {
    if (_self.attendance == null) {
    return null;
  }

  return $AttendanceModelCopyWith<$Res>(_self.attendance!, (value) {
    return _then(_self.copyWith(attendance: value));
  });
}/// Create a copy of AttendanceTodayModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TodayLeaveModelCopyWith<$Res>? get leave {
    if (_self.leave == null) {
    return null;
  }

  return $TodayLeaveModelCopyWith<$Res>(_self.leave!, (value) {
    return _then(_self.copyWith(leave: value));
  });
}
}


/// @nodoc
mixin _$MonthlySummaryModel {

 String get month; int get hadir; int get terlambat; int get izin; int get sakit; int get dinas;@JsonKey(name: 'tidak_absen') int get tidakAbsen;
/// Create a copy of MonthlySummaryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthlySummaryModelCopyWith<MonthlySummaryModel> get copyWith => _$MonthlySummaryModelCopyWithImpl<MonthlySummaryModel>(this as MonthlySummaryModel, _$identity);

  /// Serializes this MonthlySummaryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthlySummaryModel&&(identical(other.month, month) || other.month == month)&&(identical(other.hadir, hadir) || other.hadir == hadir)&&(identical(other.terlambat, terlambat) || other.terlambat == terlambat)&&(identical(other.izin, izin) || other.izin == izin)&&(identical(other.sakit, sakit) || other.sakit == sakit)&&(identical(other.dinas, dinas) || other.dinas == dinas)&&(identical(other.tidakAbsen, tidakAbsen) || other.tidakAbsen == tidakAbsen));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,month,hadir,terlambat,izin,sakit,dinas,tidakAbsen);

@override
String toString() {
  return 'MonthlySummaryModel(month: $month, hadir: $hadir, terlambat: $terlambat, izin: $izin, sakit: $sakit, dinas: $dinas, tidakAbsen: $tidakAbsen)';
}


}

/// @nodoc
abstract mixin class $MonthlySummaryModelCopyWith<$Res>  {
  factory $MonthlySummaryModelCopyWith(MonthlySummaryModel value, $Res Function(MonthlySummaryModel) _then) = _$MonthlySummaryModelCopyWithImpl;
@useResult
$Res call({
 String month, int hadir, int terlambat, int izin, int sakit, int dinas,@JsonKey(name: 'tidak_absen') int tidakAbsen
});




}
/// @nodoc
class _$MonthlySummaryModelCopyWithImpl<$Res>
    implements $MonthlySummaryModelCopyWith<$Res> {
  _$MonthlySummaryModelCopyWithImpl(this._self, this._then);

  final MonthlySummaryModel _self;
  final $Res Function(MonthlySummaryModel) _then;

/// Create a copy of MonthlySummaryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? hadir = null,Object? terlambat = null,Object? izin = null,Object? sakit = null,Object? dinas = null,Object? tidakAbsen = null,}) {
  return _then(_self.copyWith(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,hadir: null == hadir ? _self.hadir : hadir // ignore: cast_nullable_to_non_nullable
as int,terlambat: null == terlambat ? _self.terlambat : terlambat // ignore: cast_nullable_to_non_nullable
as int,izin: null == izin ? _self.izin : izin // ignore: cast_nullable_to_non_nullable
as int,sakit: null == sakit ? _self.sakit : sakit // ignore: cast_nullable_to_non_nullable
as int,dinas: null == dinas ? _self.dinas : dinas // ignore: cast_nullable_to_non_nullable
as int,tidakAbsen: null == tidakAbsen ? _self.tidakAbsen : tidakAbsen // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MonthlySummaryModel].
extension MonthlySummaryModelPatterns on MonthlySummaryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthlySummaryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthlySummaryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthlySummaryModel value)  $default,){
final _that = this;
switch (_that) {
case _MonthlySummaryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthlySummaryModel value)?  $default,){
final _that = this;
switch (_that) {
case _MonthlySummaryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String month,  int hadir,  int terlambat,  int izin,  int sakit,  int dinas, @JsonKey(name: 'tidak_absen')  int tidakAbsen)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthlySummaryModel() when $default != null:
return $default(_that.month,_that.hadir,_that.terlambat,_that.izin,_that.sakit,_that.dinas,_that.tidakAbsen);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String month,  int hadir,  int terlambat,  int izin,  int sakit,  int dinas, @JsonKey(name: 'tidak_absen')  int tidakAbsen)  $default,) {final _that = this;
switch (_that) {
case _MonthlySummaryModel():
return $default(_that.month,_that.hadir,_that.terlambat,_that.izin,_that.sakit,_that.dinas,_that.tidakAbsen);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String month,  int hadir,  int terlambat,  int izin,  int sakit,  int dinas, @JsonKey(name: 'tidak_absen')  int tidakAbsen)?  $default,) {final _that = this;
switch (_that) {
case _MonthlySummaryModel() when $default != null:
return $default(_that.month,_that.hadir,_that.terlambat,_that.izin,_that.sakit,_that.dinas,_that.tidakAbsen);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MonthlySummaryModel implements MonthlySummaryModel {
  const _MonthlySummaryModel({required this.month, this.hadir = 0, this.terlambat = 0, this.izin = 0, this.sakit = 0, this.dinas = 0, @JsonKey(name: 'tidak_absen') this.tidakAbsen = 0});
  factory _MonthlySummaryModel.fromJson(Map<String, dynamic> json) => _$MonthlySummaryModelFromJson(json);

@override final  String month;
@override@JsonKey() final  int hadir;
@override@JsonKey() final  int terlambat;
@override@JsonKey() final  int izin;
@override@JsonKey() final  int sakit;
@override@JsonKey() final  int dinas;
@override@JsonKey(name: 'tidak_absen') final  int tidakAbsen;

/// Create a copy of MonthlySummaryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthlySummaryModelCopyWith<_MonthlySummaryModel> get copyWith => __$MonthlySummaryModelCopyWithImpl<_MonthlySummaryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MonthlySummaryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthlySummaryModel&&(identical(other.month, month) || other.month == month)&&(identical(other.hadir, hadir) || other.hadir == hadir)&&(identical(other.terlambat, terlambat) || other.terlambat == terlambat)&&(identical(other.izin, izin) || other.izin == izin)&&(identical(other.sakit, sakit) || other.sakit == sakit)&&(identical(other.dinas, dinas) || other.dinas == dinas)&&(identical(other.tidakAbsen, tidakAbsen) || other.tidakAbsen == tidakAbsen));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,month,hadir,terlambat,izin,sakit,dinas,tidakAbsen);

@override
String toString() {
  return 'MonthlySummaryModel(month: $month, hadir: $hadir, terlambat: $terlambat, izin: $izin, sakit: $sakit, dinas: $dinas, tidakAbsen: $tidakAbsen)';
}


}

/// @nodoc
abstract mixin class _$MonthlySummaryModelCopyWith<$Res> implements $MonthlySummaryModelCopyWith<$Res> {
  factory _$MonthlySummaryModelCopyWith(_MonthlySummaryModel value, $Res Function(_MonthlySummaryModel) _then) = __$MonthlySummaryModelCopyWithImpl;
@override @useResult
$Res call({
 String month, int hadir, int terlambat, int izin, int sakit, int dinas,@JsonKey(name: 'tidak_absen') int tidakAbsen
});




}
/// @nodoc
class __$MonthlySummaryModelCopyWithImpl<$Res>
    implements _$MonthlySummaryModelCopyWith<$Res> {
  __$MonthlySummaryModelCopyWithImpl(this._self, this._then);

  final _MonthlySummaryModel _self;
  final $Res Function(_MonthlySummaryModel) _then;

/// Create a copy of MonthlySummaryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? hadir = null,Object? terlambat = null,Object? izin = null,Object? sakit = null,Object? dinas = null,Object? tidakAbsen = null,}) {
  return _then(_MonthlySummaryModel(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,hadir: null == hadir ? _self.hadir : hadir // ignore: cast_nullable_to_non_nullable
as int,terlambat: null == terlambat ? _self.terlambat : terlambat // ignore: cast_nullable_to_non_nullable
as int,izin: null == izin ? _self.izin : izin // ignore: cast_nullable_to_non_nullable
as int,sakit: null == sakit ? _self.sakit : sakit // ignore: cast_nullable_to_non_nullable
as int,dinas: null == dinas ? _self.dinas : dinas // ignore: cast_nullable_to_non_nullable
as int,tidakAbsen: null == tidakAbsen ? _self.tidakAbsen : tidakAbsen // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AttendanceDashboardModel {

 AttendanceTodayModel get today; MonthlySummaryModel get summary;
/// Create a copy of AttendanceDashboardModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceDashboardModelCopyWith<AttendanceDashboardModel> get copyWith => _$AttendanceDashboardModelCopyWithImpl<AttendanceDashboardModel>(this as AttendanceDashboardModel, _$identity);

  /// Serializes this AttendanceDashboardModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceDashboardModel&&(identical(other.today, today) || other.today == today)&&(identical(other.summary, summary) || other.summary == summary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,today,summary);

@override
String toString() {
  return 'AttendanceDashboardModel(today: $today, summary: $summary)';
}


}

/// @nodoc
abstract mixin class $AttendanceDashboardModelCopyWith<$Res>  {
  factory $AttendanceDashboardModelCopyWith(AttendanceDashboardModel value, $Res Function(AttendanceDashboardModel) _then) = _$AttendanceDashboardModelCopyWithImpl;
@useResult
$Res call({
 AttendanceTodayModel today, MonthlySummaryModel summary
});


$AttendanceTodayModelCopyWith<$Res> get today;$MonthlySummaryModelCopyWith<$Res> get summary;

}
/// @nodoc
class _$AttendanceDashboardModelCopyWithImpl<$Res>
    implements $AttendanceDashboardModelCopyWith<$Res> {
  _$AttendanceDashboardModelCopyWithImpl(this._self, this._then);

  final AttendanceDashboardModel _self;
  final $Res Function(AttendanceDashboardModel) _then;

/// Create a copy of AttendanceDashboardModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? today = null,Object? summary = null,}) {
  return _then(_self.copyWith(
today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as AttendanceTodayModel,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as MonthlySummaryModel,
  ));
}
/// Create a copy of AttendanceDashboardModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttendanceTodayModelCopyWith<$Res> get today {
  
  return $AttendanceTodayModelCopyWith<$Res>(_self.today, (value) {
    return _then(_self.copyWith(today: value));
  });
}/// Create a copy of AttendanceDashboardModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MonthlySummaryModelCopyWith<$Res> get summary {
  
  return $MonthlySummaryModelCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}


/// Adds pattern-matching-related methods to [AttendanceDashboardModel].
extension AttendanceDashboardModelPatterns on AttendanceDashboardModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceDashboardModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceDashboardModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceDashboardModel value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceDashboardModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceDashboardModel value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceDashboardModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AttendanceTodayModel today,  MonthlySummaryModel summary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceDashboardModel() when $default != null:
return $default(_that.today,_that.summary);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AttendanceTodayModel today,  MonthlySummaryModel summary)  $default,) {final _that = this;
switch (_that) {
case _AttendanceDashboardModel():
return $default(_that.today,_that.summary);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AttendanceTodayModel today,  MonthlySummaryModel summary)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceDashboardModel() when $default != null:
return $default(_that.today,_that.summary);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttendanceDashboardModel implements AttendanceDashboardModel {
  const _AttendanceDashboardModel({required this.today, required this.summary});
  factory _AttendanceDashboardModel.fromJson(Map<String, dynamic> json) => _$AttendanceDashboardModelFromJson(json);

@override final  AttendanceTodayModel today;
@override final  MonthlySummaryModel summary;

/// Create a copy of AttendanceDashboardModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceDashboardModelCopyWith<_AttendanceDashboardModel> get copyWith => __$AttendanceDashboardModelCopyWithImpl<_AttendanceDashboardModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceDashboardModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceDashboardModel&&(identical(other.today, today) || other.today == today)&&(identical(other.summary, summary) || other.summary == summary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,today,summary);

@override
String toString() {
  return 'AttendanceDashboardModel(today: $today, summary: $summary)';
}


}

/// @nodoc
abstract mixin class _$AttendanceDashboardModelCopyWith<$Res> implements $AttendanceDashboardModelCopyWith<$Res> {
  factory _$AttendanceDashboardModelCopyWith(_AttendanceDashboardModel value, $Res Function(_AttendanceDashboardModel) _then) = __$AttendanceDashboardModelCopyWithImpl;
@override @useResult
$Res call({
 AttendanceTodayModel today, MonthlySummaryModel summary
});


@override $AttendanceTodayModelCopyWith<$Res> get today;@override $MonthlySummaryModelCopyWith<$Res> get summary;

}
/// @nodoc
class __$AttendanceDashboardModelCopyWithImpl<$Res>
    implements _$AttendanceDashboardModelCopyWith<$Res> {
  __$AttendanceDashboardModelCopyWithImpl(this._self, this._then);

  final _AttendanceDashboardModel _self;
  final $Res Function(_AttendanceDashboardModel) _then;

/// Create a copy of AttendanceDashboardModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? today = null,Object? summary = null,}) {
  return _then(_AttendanceDashboardModel(
today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as AttendanceTodayModel,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as MonthlySummaryModel,
  ));
}

/// Create a copy of AttendanceDashboardModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttendanceTodayModelCopyWith<$Res> get today {
  
  return $AttendanceTodayModelCopyWith<$Res>(_self.today, (value) {
    return _then(_self.copyWith(today: value));
  });
}/// Create a copy of AttendanceDashboardModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MonthlySummaryModelCopyWith<$Res> get summary {
  
  return $MonthlySummaryModelCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}


/// @nodoc
mixin _$AttendanceDashboardEnvelope {

 AttendanceDashboardModel get data;
/// Create a copy of AttendanceDashboardEnvelope
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceDashboardEnvelopeCopyWith<AttendanceDashboardEnvelope> get copyWith => _$AttendanceDashboardEnvelopeCopyWithImpl<AttendanceDashboardEnvelope>(this as AttendanceDashboardEnvelope, _$identity);

  /// Serializes this AttendanceDashboardEnvelope to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceDashboardEnvelope&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'AttendanceDashboardEnvelope(data: $data)';
}


}

/// @nodoc
abstract mixin class $AttendanceDashboardEnvelopeCopyWith<$Res>  {
  factory $AttendanceDashboardEnvelopeCopyWith(AttendanceDashboardEnvelope value, $Res Function(AttendanceDashboardEnvelope) _then) = _$AttendanceDashboardEnvelopeCopyWithImpl;
@useResult
$Res call({
 AttendanceDashboardModel data
});


$AttendanceDashboardModelCopyWith<$Res> get data;

}
/// @nodoc
class _$AttendanceDashboardEnvelopeCopyWithImpl<$Res>
    implements $AttendanceDashboardEnvelopeCopyWith<$Res> {
  _$AttendanceDashboardEnvelopeCopyWithImpl(this._self, this._then);

  final AttendanceDashboardEnvelope _self;
  final $Res Function(AttendanceDashboardEnvelope) _then;

/// Create a copy of AttendanceDashboardEnvelope
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,}) {
  return _then(_self.copyWith(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as AttendanceDashboardModel,
  ));
}
/// Create a copy of AttendanceDashboardEnvelope
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttendanceDashboardModelCopyWith<$Res> get data {
  
  return $AttendanceDashboardModelCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [AttendanceDashboardEnvelope].
extension AttendanceDashboardEnvelopePatterns on AttendanceDashboardEnvelope {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceDashboardEnvelope value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceDashboardEnvelope() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceDashboardEnvelope value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceDashboardEnvelope():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceDashboardEnvelope value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceDashboardEnvelope() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AttendanceDashboardModel data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceDashboardEnvelope() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AttendanceDashboardModel data)  $default,) {final _that = this;
switch (_that) {
case _AttendanceDashboardEnvelope():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AttendanceDashboardModel data)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceDashboardEnvelope() when $default != null:
return $default(_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttendanceDashboardEnvelope implements AttendanceDashboardEnvelope {
  const _AttendanceDashboardEnvelope({required this.data});
  factory _AttendanceDashboardEnvelope.fromJson(Map<String, dynamic> json) => _$AttendanceDashboardEnvelopeFromJson(json);

@override final  AttendanceDashboardModel data;

/// Create a copy of AttendanceDashboardEnvelope
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceDashboardEnvelopeCopyWith<_AttendanceDashboardEnvelope> get copyWith => __$AttendanceDashboardEnvelopeCopyWithImpl<_AttendanceDashboardEnvelope>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceDashboardEnvelopeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceDashboardEnvelope&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'AttendanceDashboardEnvelope(data: $data)';
}


}

/// @nodoc
abstract mixin class _$AttendanceDashboardEnvelopeCopyWith<$Res> implements $AttendanceDashboardEnvelopeCopyWith<$Res> {
  factory _$AttendanceDashboardEnvelopeCopyWith(_AttendanceDashboardEnvelope value, $Res Function(_AttendanceDashboardEnvelope) _then) = __$AttendanceDashboardEnvelopeCopyWithImpl;
@override @useResult
$Res call({
 AttendanceDashboardModel data
});


@override $AttendanceDashboardModelCopyWith<$Res> get data;

}
/// @nodoc
class __$AttendanceDashboardEnvelopeCopyWithImpl<$Res>
    implements _$AttendanceDashboardEnvelopeCopyWith<$Res> {
  __$AttendanceDashboardEnvelopeCopyWithImpl(this._self, this._then);

  final _AttendanceDashboardEnvelope _self;
  final $Res Function(_AttendanceDashboardEnvelope) _then;

/// Create a copy of AttendanceDashboardEnvelope
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(_AttendanceDashboardEnvelope(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as AttendanceDashboardModel,
  ));
}

/// Create a copy of AttendanceDashboardEnvelope
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttendanceDashboardModelCopyWith<$Res> get data {
  
  return $AttendanceDashboardModelCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// @nodoc
mixin _$PaginationModel {

@JsonKey(name: 'current_page') int get currentPage;@JsonKey(name: 'per_page') int get perPage; int get total;@JsonKey(name: 'last_page') int get lastPage;@JsonKey(name: 'has_more') bool get hasMore;
/// Create a copy of PaginationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaginationModelCopyWith<PaginationModel> get copyWith => _$PaginationModelCopyWithImpl<PaginationModel>(this as PaginationModel, _$identity);

  /// Serializes this PaginationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaginationModel&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.perPage, perPage) || other.perPage == perPage)&&(identical(other.total, total) || other.total == total)&&(identical(other.lastPage, lastPage) || other.lastPage == lastPage)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentPage,perPage,total,lastPage,hasMore);

@override
String toString() {
  return 'PaginationModel(currentPage: $currentPage, perPage: $perPage, total: $total, lastPage: $lastPage, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class $PaginationModelCopyWith<$Res>  {
  factory $PaginationModelCopyWith(PaginationModel value, $Res Function(PaginationModel) _then) = _$PaginationModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'current_page') int currentPage,@JsonKey(name: 'per_page') int perPage, int total,@JsonKey(name: 'last_page') int lastPage,@JsonKey(name: 'has_more') bool hasMore
});




}
/// @nodoc
class _$PaginationModelCopyWithImpl<$Res>
    implements $PaginationModelCopyWith<$Res> {
  _$PaginationModelCopyWithImpl(this._self, this._then);

  final PaginationModel _self;
  final $Res Function(PaginationModel) _then;

/// Create a copy of PaginationModel
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


/// Adds pattern-matching-related methods to [PaginationModel].
extension PaginationModelPatterns on PaginationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaginationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaginationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaginationModel value)  $default,){
final _that = this;
switch (_that) {
case _PaginationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaginationModel value)?  $default,){
final _that = this;
switch (_that) {
case _PaginationModel() when $default != null:
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
case _PaginationModel() when $default != null:
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
case _PaginationModel():
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
case _PaginationModel() when $default != null:
return $default(_that.currentPage,_that.perPage,_that.total,_that.lastPage,_that.hasMore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaginationModel implements PaginationModel {
  const _PaginationModel({@JsonKey(name: 'current_page') this.currentPage = 1, @JsonKey(name: 'per_page') this.perPage = 15, this.total = 0, @JsonKey(name: 'last_page') this.lastPage = 1, @JsonKey(name: 'has_more') this.hasMore = false});
  factory _PaginationModel.fromJson(Map<String, dynamic> json) => _$PaginationModelFromJson(json);

@override@JsonKey(name: 'current_page') final  int currentPage;
@override@JsonKey(name: 'per_page') final  int perPage;
@override@JsonKey() final  int total;
@override@JsonKey(name: 'last_page') final  int lastPage;
@override@JsonKey(name: 'has_more') final  bool hasMore;

/// Create a copy of PaginationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaginationModelCopyWith<_PaginationModel> get copyWith => __$PaginationModelCopyWithImpl<_PaginationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaginationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaginationModel&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.perPage, perPage) || other.perPage == perPage)&&(identical(other.total, total) || other.total == total)&&(identical(other.lastPage, lastPage) || other.lastPage == lastPage)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentPage,perPage,total,lastPage,hasMore);

@override
String toString() {
  return 'PaginationModel(currentPage: $currentPage, perPage: $perPage, total: $total, lastPage: $lastPage, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class _$PaginationModelCopyWith<$Res> implements $PaginationModelCopyWith<$Res> {
  factory _$PaginationModelCopyWith(_PaginationModel value, $Res Function(_PaginationModel) _then) = __$PaginationModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'current_page') int currentPage,@JsonKey(name: 'per_page') int perPage, int total,@JsonKey(name: 'last_page') int lastPage,@JsonKey(name: 'has_more') bool hasMore
});




}
/// @nodoc
class __$PaginationModelCopyWithImpl<$Res>
    implements _$PaginationModelCopyWith<$Res> {
  __$PaginationModelCopyWithImpl(this._self, this._then);

  final _PaginationModel _self;
  final $Res Function(_PaginationModel) _then;

/// Create a copy of PaginationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentPage = null,Object? perPage = null,Object? total = null,Object? lastPage = null,Object? hasMore = null,}) {
  return _then(_PaginationModel(
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
mixin _$AttendanceHistoryModel {

 List<AttendanceModel> get items; PaginationModel get pagination;
/// Create a copy of AttendanceHistoryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceHistoryModelCopyWith<AttendanceHistoryModel> get copyWith => _$AttendanceHistoryModelCopyWithImpl<AttendanceHistoryModel>(this as AttendanceHistoryModel, _$identity);

  /// Serializes this AttendanceHistoryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceHistoryModel&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.pagination, pagination) || other.pagination == pagination));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),pagination);

@override
String toString() {
  return 'AttendanceHistoryModel(items: $items, pagination: $pagination)';
}


}

/// @nodoc
abstract mixin class $AttendanceHistoryModelCopyWith<$Res>  {
  factory $AttendanceHistoryModelCopyWith(AttendanceHistoryModel value, $Res Function(AttendanceHistoryModel) _then) = _$AttendanceHistoryModelCopyWithImpl;
@useResult
$Res call({
 List<AttendanceModel> items, PaginationModel pagination
});


$PaginationModelCopyWith<$Res> get pagination;

}
/// @nodoc
class _$AttendanceHistoryModelCopyWithImpl<$Res>
    implements $AttendanceHistoryModelCopyWith<$Res> {
  _$AttendanceHistoryModelCopyWithImpl(this._self, this._then);

  final AttendanceHistoryModel _self;
  final $Res Function(AttendanceHistoryModel) _then;

/// Create a copy of AttendanceHistoryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? pagination = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<AttendanceModel>,pagination: null == pagination ? _self.pagination : pagination // ignore: cast_nullable_to_non_nullable
as PaginationModel,
  ));
}
/// Create a copy of AttendanceHistoryModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaginationModelCopyWith<$Res> get pagination {
  
  return $PaginationModelCopyWith<$Res>(_self.pagination, (value) {
    return _then(_self.copyWith(pagination: value));
  });
}
}


/// Adds pattern-matching-related methods to [AttendanceHistoryModel].
extension AttendanceHistoryModelPatterns on AttendanceHistoryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceHistoryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceHistoryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceHistoryModel value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceHistoryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceHistoryModel value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceHistoryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AttendanceModel> items,  PaginationModel pagination)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceHistoryModel() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AttendanceModel> items,  PaginationModel pagination)  $default,) {final _that = this;
switch (_that) {
case _AttendanceHistoryModel():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AttendanceModel> items,  PaginationModel pagination)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceHistoryModel() when $default != null:
return $default(_that.items,_that.pagination);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttendanceHistoryModel implements AttendanceHistoryModel {
  const _AttendanceHistoryModel({final  List<AttendanceModel> items = const <AttendanceModel>[], required this.pagination}): _items = items;
  factory _AttendanceHistoryModel.fromJson(Map<String, dynamic> json) => _$AttendanceHistoryModelFromJson(json);

 final  List<AttendanceModel> _items;
@override@JsonKey() List<AttendanceModel> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  PaginationModel pagination;

/// Create a copy of AttendanceHistoryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceHistoryModelCopyWith<_AttendanceHistoryModel> get copyWith => __$AttendanceHistoryModelCopyWithImpl<_AttendanceHistoryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceHistoryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceHistoryModel&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.pagination, pagination) || other.pagination == pagination));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),pagination);

@override
String toString() {
  return 'AttendanceHistoryModel(items: $items, pagination: $pagination)';
}


}

/// @nodoc
abstract mixin class _$AttendanceHistoryModelCopyWith<$Res> implements $AttendanceHistoryModelCopyWith<$Res> {
  factory _$AttendanceHistoryModelCopyWith(_AttendanceHistoryModel value, $Res Function(_AttendanceHistoryModel) _then) = __$AttendanceHistoryModelCopyWithImpl;
@override @useResult
$Res call({
 List<AttendanceModel> items, PaginationModel pagination
});


@override $PaginationModelCopyWith<$Res> get pagination;

}
/// @nodoc
class __$AttendanceHistoryModelCopyWithImpl<$Res>
    implements _$AttendanceHistoryModelCopyWith<$Res> {
  __$AttendanceHistoryModelCopyWithImpl(this._self, this._then);

  final _AttendanceHistoryModel _self;
  final $Res Function(_AttendanceHistoryModel) _then;

/// Create a copy of AttendanceHistoryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? pagination = null,}) {
  return _then(_AttendanceHistoryModel(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<AttendanceModel>,pagination: null == pagination ? _self.pagination : pagination // ignore: cast_nullable_to_non_nullable
as PaginationModel,
  ));
}

/// Create a copy of AttendanceHistoryModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaginationModelCopyWith<$Res> get pagination {
  
  return $PaginationModelCopyWith<$Res>(_self.pagination, (value) {
    return _then(_self.copyWith(pagination: value));
  });
}
}


/// @nodoc
mixin _$AttendanceHistoryEnvelope {

 AttendanceHistoryModel get data;
/// Create a copy of AttendanceHistoryEnvelope
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceHistoryEnvelopeCopyWith<AttendanceHistoryEnvelope> get copyWith => _$AttendanceHistoryEnvelopeCopyWithImpl<AttendanceHistoryEnvelope>(this as AttendanceHistoryEnvelope, _$identity);

  /// Serializes this AttendanceHistoryEnvelope to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceHistoryEnvelope&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'AttendanceHistoryEnvelope(data: $data)';
}


}

/// @nodoc
abstract mixin class $AttendanceHistoryEnvelopeCopyWith<$Res>  {
  factory $AttendanceHistoryEnvelopeCopyWith(AttendanceHistoryEnvelope value, $Res Function(AttendanceHistoryEnvelope) _then) = _$AttendanceHistoryEnvelopeCopyWithImpl;
@useResult
$Res call({
 AttendanceHistoryModel data
});


$AttendanceHistoryModelCopyWith<$Res> get data;

}
/// @nodoc
class _$AttendanceHistoryEnvelopeCopyWithImpl<$Res>
    implements $AttendanceHistoryEnvelopeCopyWith<$Res> {
  _$AttendanceHistoryEnvelopeCopyWithImpl(this._self, this._then);

  final AttendanceHistoryEnvelope _self;
  final $Res Function(AttendanceHistoryEnvelope) _then;

/// Create a copy of AttendanceHistoryEnvelope
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,}) {
  return _then(_self.copyWith(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as AttendanceHistoryModel,
  ));
}
/// Create a copy of AttendanceHistoryEnvelope
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttendanceHistoryModelCopyWith<$Res> get data {
  
  return $AttendanceHistoryModelCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [AttendanceHistoryEnvelope].
extension AttendanceHistoryEnvelopePatterns on AttendanceHistoryEnvelope {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceHistoryEnvelope value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceHistoryEnvelope() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceHistoryEnvelope value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceHistoryEnvelope():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceHistoryEnvelope value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceHistoryEnvelope() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AttendanceHistoryModel data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceHistoryEnvelope() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AttendanceHistoryModel data)  $default,) {final _that = this;
switch (_that) {
case _AttendanceHistoryEnvelope():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AttendanceHistoryModel data)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceHistoryEnvelope() when $default != null:
return $default(_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttendanceHistoryEnvelope implements AttendanceHistoryEnvelope {
  const _AttendanceHistoryEnvelope({required this.data});
  factory _AttendanceHistoryEnvelope.fromJson(Map<String, dynamic> json) => _$AttendanceHistoryEnvelopeFromJson(json);

@override final  AttendanceHistoryModel data;

/// Create a copy of AttendanceHistoryEnvelope
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceHistoryEnvelopeCopyWith<_AttendanceHistoryEnvelope> get copyWith => __$AttendanceHistoryEnvelopeCopyWithImpl<_AttendanceHistoryEnvelope>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceHistoryEnvelopeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceHistoryEnvelope&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'AttendanceHistoryEnvelope(data: $data)';
}


}

/// @nodoc
abstract mixin class _$AttendanceHistoryEnvelopeCopyWith<$Res> implements $AttendanceHistoryEnvelopeCopyWith<$Res> {
  factory _$AttendanceHistoryEnvelopeCopyWith(_AttendanceHistoryEnvelope value, $Res Function(_AttendanceHistoryEnvelope) _then) = __$AttendanceHistoryEnvelopeCopyWithImpl;
@override @useResult
$Res call({
 AttendanceHistoryModel data
});


@override $AttendanceHistoryModelCopyWith<$Res> get data;

}
/// @nodoc
class __$AttendanceHistoryEnvelopeCopyWithImpl<$Res>
    implements _$AttendanceHistoryEnvelopeCopyWith<$Res> {
  __$AttendanceHistoryEnvelopeCopyWithImpl(this._self, this._then);

  final _AttendanceHistoryEnvelope _self;
  final $Res Function(_AttendanceHistoryEnvelope) _then;

/// Create a copy of AttendanceHistoryEnvelope
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(_AttendanceHistoryEnvelope(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as AttendanceHistoryModel,
  ));
}

/// Create a copy of AttendanceHistoryEnvelope
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttendanceHistoryModelCopyWith<$Res> get data {
  
  return $AttendanceHistoryModelCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

// dart format on
