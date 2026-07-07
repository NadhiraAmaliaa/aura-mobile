// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'current_location_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CurrentLocationState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurrentLocationState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CurrentLocationState()';
}


}

/// @nodoc
class $CurrentLocationStateCopyWith<$Res>  {
$CurrentLocationStateCopyWith(CurrentLocationState _, $Res Function(CurrentLocationState) __);
}


/// Adds pattern-matching-related methods to [CurrentLocationState].
extension CurrentLocationStatePatterns on CurrentLocationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LocationIdle value)?  idle,TResult Function( LocationLoading value)?  loading,TResult Function( LocationReady value)?  success,TResult Function( LocationError value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LocationIdle() when idle != null:
return idle(_that);case LocationLoading() when loading != null:
return loading(_that);case LocationReady() when success != null:
return success(_that);case LocationError() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LocationIdle value)  idle,required TResult Function( LocationLoading value)  loading,required TResult Function( LocationReady value)  success,required TResult Function( LocationError value)  failure,}){
final _that = this;
switch (_that) {
case LocationIdle():
return idle(_that);case LocationLoading():
return loading(_that);case LocationReady():
return success(_that);case LocationError():
return failure(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LocationIdle value)?  idle,TResult? Function( LocationLoading value)?  loading,TResult? Function( LocationReady value)?  success,TResult? Function( LocationError value)?  failure,}){
final _that = this;
switch (_that) {
case LocationIdle() when idle != null:
return idle(_that);case LocationLoading() when loading != null:
return loading(_that);case LocationReady() when success != null:
return success(_that);case LocationError() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  loading,TResult Function( GeoPosition position)?  success,TResult Function( LocationFailureKind kind,  String message)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LocationIdle() when idle != null:
return idle();case LocationLoading() when loading != null:
return loading();case LocationReady() when success != null:
return success(_that.position);case LocationError() when failure != null:
return failure(_that.kind,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  loading,required TResult Function( GeoPosition position)  success,required TResult Function( LocationFailureKind kind,  String message)  failure,}) {final _that = this;
switch (_that) {
case LocationIdle():
return idle();case LocationLoading():
return loading();case LocationReady():
return success(_that.position);case LocationError():
return failure(_that.kind,_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  loading,TResult? Function( GeoPosition position)?  success,TResult? Function( LocationFailureKind kind,  String message)?  failure,}) {final _that = this;
switch (_that) {
case LocationIdle() when idle != null:
return idle();case LocationLoading() when loading != null:
return loading();case LocationReady() when success != null:
return success(_that.position);case LocationError() when failure != null:
return failure(_that.kind,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class LocationIdle implements CurrentLocationState {
  const LocationIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CurrentLocationState.idle()';
}


}




/// @nodoc


class LocationLoading implements CurrentLocationState {
  const LocationLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CurrentLocationState.loading()';
}


}




/// @nodoc


class LocationReady implements CurrentLocationState {
  const LocationReady(this.position);
  

 final  GeoPosition position;

/// Create a copy of CurrentLocationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationReadyCopyWith<LocationReady> get copyWith => _$LocationReadyCopyWithImpl<LocationReady>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationReady&&(identical(other.position, position) || other.position == position));
}


@override
int get hashCode => Object.hash(runtimeType,position);

@override
String toString() {
  return 'CurrentLocationState.success(position: $position)';
}


}

/// @nodoc
abstract mixin class $LocationReadyCopyWith<$Res> implements $CurrentLocationStateCopyWith<$Res> {
  factory $LocationReadyCopyWith(LocationReady value, $Res Function(LocationReady) _then) = _$LocationReadyCopyWithImpl;
@useResult
$Res call({
 GeoPosition position
});




}
/// @nodoc
class _$LocationReadyCopyWithImpl<$Res>
    implements $LocationReadyCopyWith<$Res> {
  _$LocationReadyCopyWithImpl(this._self, this._then);

  final LocationReady _self;
  final $Res Function(LocationReady) _then;

/// Create a copy of CurrentLocationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? position = null,}) {
  return _then(LocationReady(
null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as GeoPosition,
  ));
}


}

/// @nodoc


class LocationError implements CurrentLocationState {
  const LocationError(this.kind, this.message);
  

 final  LocationFailureKind kind;
 final  String message;

/// Create a copy of CurrentLocationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationErrorCopyWith<LocationError> get copyWith => _$LocationErrorCopyWithImpl<LocationError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationError&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,kind,message);

@override
String toString() {
  return 'CurrentLocationState.failure(kind: $kind, message: $message)';
}


}

/// @nodoc
abstract mixin class $LocationErrorCopyWith<$Res> implements $CurrentLocationStateCopyWith<$Res> {
  factory $LocationErrorCopyWith(LocationError value, $Res Function(LocationError) _then) = _$LocationErrorCopyWithImpl;
@useResult
$Res call({
 LocationFailureKind kind, String message
});




}
/// @nodoc
class _$LocationErrorCopyWithImpl<$Res>
    implements $LocationErrorCopyWith<$Res> {
  _$LocationErrorCopyWithImpl(this._self, this._then);

  final LocationError _self;
  final $Res Function(LocationError) _then;

/// Create a copy of CurrentLocationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? message = null,}) {
  return _then(LocationError(
null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as LocationFailureKind,null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
