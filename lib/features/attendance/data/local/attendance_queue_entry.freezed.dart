// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_queue_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AttendanceQueueEntry {

 String get clientEventId; AttendanceEventType get type; int? get userId; String? get workMode; String? get latitude; String? get longitude; String get capturedAt; int? get officeId; String? get officeName; String? get officeLatitude; String? get officeLongitude; int? get officeRadius; bool? get autoTimeEnabled; QueuedEventStatus get status; int get attempts; String? get lastError; DateTime get createdAt; DateTime? get syncedAt;
/// Create a copy of AttendanceQueueEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceQueueEntryCopyWith<AttendanceQueueEntry> get copyWith => _$AttendanceQueueEntryCopyWithImpl<AttendanceQueueEntry>(this as AttendanceQueueEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceQueueEntry&&(identical(other.clientEventId, clientEventId) || other.clientEventId == clientEventId)&&(identical(other.type, type) || other.type == type)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.workMode, workMode) || other.workMode == workMode)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.capturedAt, capturedAt) || other.capturedAt == capturedAt)&&(identical(other.officeId, officeId) || other.officeId == officeId)&&(identical(other.officeName, officeName) || other.officeName == officeName)&&(identical(other.officeLatitude, officeLatitude) || other.officeLatitude == officeLatitude)&&(identical(other.officeLongitude, officeLongitude) || other.officeLongitude == officeLongitude)&&(identical(other.officeRadius, officeRadius) || other.officeRadius == officeRadius)&&(identical(other.autoTimeEnabled, autoTimeEnabled) || other.autoTimeEnabled == autoTimeEnabled)&&(identical(other.status, status) || other.status == status)&&(identical(other.attempts, attempts) || other.attempts == attempts)&&(identical(other.lastError, lastError) || other.lastError == lastError)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.syncedAt, syncedAt) || other.syncedAt == syncedAt));
}


@override
int get hashCode => Object.hash(runtimeType,clientEventId,type,userId,workMode,latitude,longitude,capturedAt,officeId,officeName,officeLatitude,officeLongitude,officeRadius,autoTimeEnabled,status,attempts,lastError,createdAt,syncedAt);

@override
String toString() {
  return 'AttendanceQueueEntry(clientEventId: $clientEventId, type: $type, userId: $userId, workMode: $workMode, latitude: $latitude, longitude: $longitude, capturedAt: $capturedAt, officeId: $officeId, officeName: $officeName, officeLatitude: $officeLatitude, officeLongitude: $officeLongitude, officeRadius: $officeRadius, autoTimeEnabled: $autoTimeEnabled, status: $status, attempts: $attempts, lastError: $lastError, createdAt: $createdAt, syncedAt: $syncedAt)';
}


}

/// @nodoc
abstract mixin class $AttendanceQueueEntryCopyWith<$Res>  {
  factory $AttendanceQueueEntryCopyWith(AttendanceQueueEntry value, $Res Function(AttendanceQueueEntry) _then) = _$AttendanceQueueEntryCopyWithImpl;
@useResult
$Res call({
 String clientEventId, AttendanceEventType type, int? userId, String? workMode, String? latitude, String? longitude, String capturedAt, int? officeId, String? officeName, String? officeLatitude, String? officeLongitude, int? officeRadius, bool? autoTimeEnabled, QueuedEventStatus status, int attempts, String? lastError, DateTime createdAt, DateTime? syncedAt
});




}
/// @nodoc
class _$AttendanceQueueEntryCopyWithImpl<$Res>
    implements $AttendanceQueueEntryCopyWith<$Res> {
  _$AttendanceQueueEntryCopyWithImpl(this._self, this._then);

  final AttendanceQueueEntry _self;
  final $Res Function(AttendanceQueueEntry) _then;

/// Create a copy of AttendanceQueueEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? clientEventId = null,Object? type = null,Object? userId = freezed,Object? workMode = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? capturedAt = null,Object? officeId = freezed,Object? officeName = freezed,Object? officeLatitude = freezed,Object? officeLongitude = freezed,Object? officeRadius = freezed,Object? autoTimeEnabled = freezed,Object? status = null,Object? attempts = null,Object? lastError = freezed,Object? createdAt = null,Object? syncedAt = freezed,}) {
  return _then(_self.copyWith(
clientEventId: null == clientEventId ? _self.clientEventId : clientEventId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AttendanceEventType,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int?,workMode: freezed == workMode ? _self.workMode : workMode // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as String?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as String?,capturedAt: null == capturedAt ? _self.capturedAt : capturedAt // ignore: cast_nullable_to_non_nullable
as String,officeId: freezed == officeId ? _self.officeId : officeId // ignore: cast_nullable_to_non_nullable
as int?,officeName: freezed == officeName ? _self.officeName : officeName // ignore: cast_nullable_to_non_nullable
as String?,officeLatitude: freezed == officeLatitude ? _self.officeLatitude : officeLatitude // ignore: cast_nullable_to_non_nullable
as String?,officeLongitude: freezed == officeLongitude ? _self.officeLongitude : officeLongitude // ignore: cast_nullable_to_non_nullable
as String?,officeRadius: freezed == officeRadius ? _self.officeRadius : officeRadius // ignore: cast_nullable_to_non_nullable
as int?,autoTimeEnabled: freezed == autoTimeEnabled ? _self.autoTimeEnabled : autoTimeEnabled // ignore: cast_nullable_to_non_nullable
as bool?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as QueuedEventStatus,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,syncedAt: freezed == syncedAt ? _self.syncedAt : syncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AttendanceQueueEntry].
extension AttendanceQueueEntryPatterns on AttendanceQueueEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceQueueEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceQueueEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceQueueEntry value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceQueueEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceQueueEntry value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceQueueEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String clientEventId,  AttendanceEventType type,  int? userId,  String? workMode,  String? latitude,  String? longitude,  String capturedAt,  int? officeId,  String? officeName,  String? officeLatitude,  String? officeLongitude,  int? officeRadius,  bool? autoTimeEnabled,  QueuedEventStatus status,  int attempts,  String? lastError,  DateTime createdAt,  DateTime? syncedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceQueueEntry() when $default != null:
return $default(_that.clientEventId,_that.type,_that.userId,_that.workMode,_that.latitude,_that.longitude,_that.capturedAt,_that.officeId,_that.officeName,_that.officeLatitude,_that.officeLongitude,_that.officeRadius,_that.autoTimeEnabled,_that.status,_that.attempts,_that.lastError,_that.createdAt,_that.syncedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String clientEventId,  AttendanceEventType type,  int? userId,  String? workMode,  String? latitude,  String? longitude,  String capturedAt,  int? officeId,  String? officeName,  String? officeLatitude,  String? officeLongitude,  int? officeRadius,  bool? autoTimeEnabled,  QueuedEventStatus status,  int attempts,  String? lastError,  DateTime createdAt,  DateTime? syncedAt)  $default,) {final _that = this;
switch (_that) {
case _AttendanceQueueEntry():
return $default(_that.clientEventId,_that.type,_that.userId,_that.workMode,_that.latitude,_that.longitude,_that.capturedAt,_that.officeId,_that.officeName,_that.officeLatitude,_that.officeLongitude,_that.officeRadius,_that.autoTimeEnabled,_that.status,_that.attempts,_that.lastError,_that.createdAt,_that.syncedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String clientEventId,  AttendanceEventType type,  int? userId,  String? workMode,  String? latitude,  String? longitude,  String capturedAt,  int? officeId,  String? officeName,  String? officeLatitude,  String? officeLongitude,  int? officeRadius,  bool? autoTimeEnabled,  QueuedEventStatus status,  int attempts,  String? lastError,  DateTime createdAt,  DateTime? syncedAt)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceQueueEntry() when $default != null:
return $default(_that.clientEventId,_that.type,_that.userId,_that.workMode,_that.latitude,_that.longitude,_that.capturedAt,_that.officeId,_that.officeName,_that.officeLatitude,_that.officeLongitude,_that.officeRadius,_that.autoTimeEnabled,_that.status,_that.attempts,_that.lastError,_that.createdAt,_that.syncedAt);case _:
  return null;

}
}

}

/// @nodoc


class _AttendanceQueueEntry implements AttendanceQueueEntry {
  const _AttendanceQueueEntry({required this.clientEventId, required this.type, this.userId, this.workMode, this.latitude, this.longitude, required this.capturedAt, this.officeId, this.officeName, this.officeLatitude, this.officeLongitude, this.officeRadius, this.autoTimeEnabled, this.status = QueuedEventStatus.pending, this.attempts = 0, this.lastError, required this.createdAt, this.syncedAt});
  

@override final  String clientEventId;
@override final  AttendanceEventType type;
@override final  int? userId;
@override final  String? workMode;
@override final  String? latitude;
@override final  String? longitude;
@override final  String capturedAt;
@override final  int? officeId;
@override final  String? officeName;
@override final  String? officeLatitude;
@override final  String? officeLongitude;
@override final  int? officeRadius;
@override final  bool? autoTimeEnabled;
@override@JsonKey() final  QueuedEventStatus status;
@override@JsonKey() final  int attempts;
@override final  String? lastError;
@override final  DateTime createdAt;
@override final  DateTime? syncedAt;

/// Create a copy of AttendanceQueueEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceQueueEntryCopyWith<_AttendanceQueueEntry> get copyWith => __$AttendanceQueueEntryCopyWithImpl<_AttendanceQueueEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceQueueEntry&&(identical(other.clientEventId, clientEventId) || other.clientEventId == clientEventId)&&(identical(other.type, type) || other.type == type)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.workMode, workMode) || other.workMode == workMode)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.capturedAt, capturedAt) || other.capturedAt == capturedAt)&&(identical(other.officeId, officeId) || other.officeId == officeId)&&(identical(other.officeName, officeName) || other.officeName == officeName)&&(identical(other.officeLatitude, officeLatitude) || other.officeLatitude == officeLatitude)&&(identical(other.officeLongitude, officeLongitude) || other.officeLongitude == officeLongitude)&&(identical(other.officeRadius, officeRadius) || other.officeRadius == officeRadius)&&(identical(other.autoTimeEnabled, autoTimeEnabled) || other.autoTimeEnabled == autoTimeEnabled)&&(identical(other.status, status) || other.status == status)&&(identical(other.attempts, attempts) || other.attempts == attempts)&&(identical(other.lastError, lastError) || other.lastError == lastError)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.syncedAt, syncedAt) || other.syncedAt == syncedAt));
}


@override
int get hashCode => Object.hash(runtimeType,clientEventId,type,userId,workMode,latitude,longitude,capturedAt,officeId,officeName,officeLatitude,officeLongitude,officeRadius,autoTimeEnabled,status,attempts,lastError,createdAt,syncedAt);

@override
String toString() {
  return 'AttendanceQueueEntry(clientEventId: $clientEventId, type: $type, userId: $userId, workMode: $workMode, latitude: $latitude, longitude: $longitude, capturedAt: $capturedAt, officeId: $officeId, officeName: $officeName, officeLatitude: $officeLatitude, officeLongitude: $officeLongitude, officeRadius: $officeRadius, autoTimeEnabled: $autoTimeEnabled, status: $status, attempts: $attempts, lastError: $lastError, createdAt: $createdAt, syncedAt: $syncedAt)';
}


}

/// @nodoc
abstract mixin class _$AttendanceQueueEntryCopyWith<$Res> implements $AttendanceQueueEntryCopyWith<$Res> {
  factory _$AttendanceQueueEntryCopyWith(_AttendanceQueueEntry value, $Res Function(_AttendanceQueueEntry) _then) = __$AttendanceQueueEntryCopyWithImpl;
@override @useResult
$Res call({
 String clientEventId, AttendanceEventType type, int? userId, String? workMode, String? latitude, String? longitude, String capturedAt, int? officeId, String? officeName, String? officeLatitude, String? officeLongitude, int? officeRadius, bool? autoTimeEnabled, QueuedEventStatus status, int attempts, String? lastError, DateTime createdAt, DateTime? syncedAt
});




}
/// @nodoc
class __$AttendanceQueueEntryCopyWithImpl<$Res>
    implements _$AttendanceQueueEntryCopyWith<$Res> {
  __$AttendanceQueueEntryCopyWithImpl(this._self, this._then);

  final _AttendanceQueueEntry _self;
  final $Res Function(_AttendanceQueueEntry) _then;

/// Create a copy of AttendanceQueueEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? clientEventId = null,Object? type = null,Object? userId = freezed,Object? workMode = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? capturedAt = null,Object? officeId = freezed,Object? officeName = freezed,Object? officeLatitude = freezed,Object? officeLongitude = freezed,Object? officeRadius = freezed,Object? autoTimeEnabled = freezed,Object? status = null,Object? attempts = null,Object? lastError = freezed,Object? createdAt = null,Object? syncedAt = freezed,}) {
  return _then(_AttendanceQueueEntry(
clientEventId: null == clientEventId ? _self.clientEventId : clientEventId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AttendanceEventType,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int?,workMode: freezed == workMode ? _self.workMode : workMode // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as String?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as String?,capturedAt: null == capturedAt ? _self.capturedAt : capturedAt // ignore: cast_nullable_to_non_nullable
as String,officeId: freezed == officeId ? _self.officeId : officeId // ignore: cast_nullable_to_non_nullable
as int?,officeName: freezed == officeName ? _self.officeName : officeName // ignore: cast_nullable_to_non_nullable
as String?,officeLatitude: freezed == officeLatitude ? _self.officeLatitude : officeLatitude // ignore: cast_nullable_to_non_nullable
as String?,officeLongitude: freezed == officeLongitude ? _self.officeLongitude : officeLongitude // ignore: cast_nullable_to_non_nullable
as String?,officeRadius: freezed == officeRadius ? _self.officeRadius : officeRadius // ignore: cast_nullable_to_non_nullable
as int?,autoTimeEnabled: freezed == autoTimeEnabled ? _self.autoTimeEnabled : autoTimeEnabled // ignore: cast_nullable_to_non_nullable
as bool?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as QueuedEventStatus,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,syncedAt: freezed == syncedAt ? _self.syncedAt : syncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
