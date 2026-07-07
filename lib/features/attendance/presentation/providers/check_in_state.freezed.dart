// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'check_in_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CheckInState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckInState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CheckInState()';
}


}

/// @nodoc
class $CheckInStateCopyWith<$Res>  {
$CheckInStateCopyWith(CheckInState _, $Res Function(CheckInState) __);
}


/// Adds pattern-matching-related methods to [CheckInState].
extension CheckInStatePatterns on CheckInState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CheckInIdle value)?  idle,TResult Function( CheckInSubmitting value)?  submitting,TResult Function( CheckInSuccess value)?  success,TResult Function( CheckInFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CheckInIdle() when idle != null:
return idle(_that);case CheckInSubmitting() when submitting != null:
return submitting(_that);case CheckInSuccess() when success != null:
return success(_that);case CheckInFailure() when failure != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CheckInIdle value)  idle,required TResult Function( CheckInSubmitting value)  submitting,required TResult Function( CheckInSuccess value)  success,required TResult Function( CheckInFailure value)  failure,}){
final _that = this;
switch (_that) {
case CheckInIdle():
return idle(_that);case CheckInSubmitting():
return submitting(_that);case CheckInSuccess():
return success(_that);case CheckInFailure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CheckInIdle value)?  idle,TResult? Function( CheckInSubmitting value)?  submitting,TResult? Function( CheckInSuccess value)?  success,TResult? Function( CheckInFailure value)?  failure,}){
final _that = this;
switch (_that) {
case CheckInIdle() when idle != null:
return idle(_that);case CheckInSubmitting() when submitting != null:
return submitting(_that);case CheckInSuccess() when success != null:
return success(_that);case CheckInFailure() when failure != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  submitting,TResult Function( AttendanceModel record)?  success,TResult Function( String message)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CheckInIdle() when idle != null:
return idle();case CheckInSubmitting() when submitting != null:
return submitting();case CheckInSuccess() when success != null:
return success(_that.record);case CheckInFailure() when failure != null:
return failure(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  submitting,required TResult Function( AttendanceModel record)  success,required TResult Function( String message)  failure,}) {final _that = this;
switch (_that) {
case CheckInIdle():
return idle();case CheckInSubmitting():
return submitting();case CheckInSuccess():
return success(_that.record);case CheckInFailure():
return failure(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  submitting,TResult? Function( AttendanceModel record)?  success,TResult? Function( String message)?  failure,}) {final _that = this;
switch (_that) {
case CheckInIdle() when idle != null:
return idle();case CheckInSubmitting() when submitting != null:
return submitting();case CheckInSuccess() when success != null:
return success(_that.record);case CheckInFailure() when failure != null:
return failure(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class CheckInIdle implements CheckInState {
  const CheckInIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckInIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CheckInState.idle()';
}


}




/// @nodoc


class CheckInSubmitting implements CheckInState {
  const CheckInSubmitting();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckInSubmitting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CheckInState.submitting()';
}


}




/// @nodoc


class CheckInSuccess implements CheckInState {
  const CheckInSuccess(this.record);
  

 final  AttendanceModel record;

/// Create a copy of CheckInState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckInSuccessCopyWith<CheckInSuccess> get copyWith => _$CheckInSuccessCopyWithImpl<CheckInSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckInSuccess&&(identical(other.record, record) || other.record == record));
}


@override
int get hashCode => Object.hash(runtimeType,record);

@override
String toString() {
  return 'CheckInState.success(record: $record)';
}


}

/// @nodoc
abstract mixin class $CheckInSuccessCopyWith<$Res> implements $CheckInStateCopyWith<$Res> {
  factory $CheckInSuccessCopyWith(CheckInSuccess value, $Res Function(CheckInSuccess) _then) = _$CheckInSuccessCopyWithImpl;
@useResult
$Res call({
 AttendanceModel record
});


$AttendanceModelCopyWith<$Res> get record;

}
/// @nodoc
class _$CheckInSuccessCopyWithImpl<$Res>
    implements $CheckInSuccessCopyWith<$Res> {
  _$CheckInSuccessCopyWithImpl(this._self, this._then);

  final CheckInSuccess _self;
  final $Res Function(CheckInSuccess) _then;

/// Create a copy of CheckInState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? record = null,}) {
  return _then(CheckInSuccess(
null == record ? _self.record : record // ignore: cast_nullable_to_non_nullable
as AttendanceModel,
  ));
}

/// Create a copy of CheckInState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttendanceModelCopyWith<$Res> get record {
  
  return $AttendanceModelCopyWith<$Res>(_self.record, (value) {
    return _then(_self.copyWith(record: value));
  });
}
}

/// @nodoc


class CheckInFailure implements CheckInState {
  const CheckInFailure(this.message);
  

 final  String message;

/// Create a copy of CheckInState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckInFailureCopyWith<CheckInFailure> get copyWith => _$CheckInFailureCopyWithImpl<CheckInFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckInFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'CheckInState.failure(message: $message)';
}


}

/// @nodoc
abstract mixin class $CheckInFailureCopyWith<$Res> implements $CheckInStateCopyWith<$Res> {
  factory $CheckInFailureCopyWith(CheckInFailure value, $Res Function(CheckInFailure) _then) = _$CheckInFailureCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$CheckInFailureCopyWithImpl<$Res>
    implements $CheckInFailureCopyWith<$Res> {
  _$CheckInFailureCopyWithImpl(this._self, this._then);

  final CheckInFailure _self;
  final $Res Function(CheckInFailure) _then;

/// Create a copy of CheckInState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(CheckInFailure(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
