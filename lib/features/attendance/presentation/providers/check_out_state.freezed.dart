// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'check_out_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CheckOutState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckOutState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CheckOutState()';
}


}

/// @nodoc
class $CheckOutStateCopyWith<$Res>  {
$CheckOutStateCopyWith(CheckOutState _, $Res Function(CheckOutState) __);
}


/// Adds pattern-matching-related methods to [CheckOutState].
extension CheckOutStatePatterns on CheckOutState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CheckOutIdle value)?  idle,TResult Function( CheckOutSubmitting value)?  submitting,TResult Function( CheckOutSuccess value)?  success,TResult Function( CheckOutFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CheckOutIdle() when idle != null:
return idle(_that);case CheckOutSubmitting() when submitting != null:
return submitting(_that);case CheckOutSuccess() when success != null:
return success(_that);case CheckOutFailure() when failure != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CheckOutIdle value)  idle,required TResult Function( CheckOutSubmitting value)  submitting,required TResult Function( CheckOutSuccess value)  success,required TResult Function( CheckOutFailure value)  failure,}){
final _that = this;
switch (_that) {
case CheckOutIdle():
return idle(_that);case CheckOutSubmitting():
return submitting(_that);case CheckOutSuccess():
return success(_that);case CheckOutFailure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CheckOutIdle value)?  idle,TResult? Function( CheckOutSubmitting value)?  submitting,TResult? Function( CheckOutSuccess value)?  success,TResult? Function( CheckOutFailure value)?  failure,}){
final _that = this;
switch (_that) {
case CheckOutIdle() when idle != null:
return idle(_that);case CheckOutSubmitting() when submitting != null:
return submitting(_that);case CheckOutSuccess() when success != null:
return success(_that);case CheckOutFailure() when failure != null:
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
case CheckOutIdle() when idle != null:
return idle();case CheckOutSubmitting() when submitting != null:
return submitting();case CheckOutSuccess() when success != null:
return success(_that.record);case CheckOutFailure() when failure != null:
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
case CheckOutIdle():
return idle();case CheckOutSubmitting():
return submitting();case CheckOutSuccess():
return success(_that.record);case CheckOutFailure():
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
case CheckOutIdle() when idle != null:
return idle();case CheckOutSubmitting() when submitting != null:
return submitting();case CheckOutSuccess() when success != null:
return success(_that.record);case CheckOutFailure() when failure != null:
return failure(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class CheckOutIdle implements CheckOutState {
  const CheckOutIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckOutIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CheckOutState.idle()';
}


}




/// @nodoc


class CheckOutSubmitting implements CheckOutState {
  const CheckOutSubmitting();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckOutSubmitting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CheckOutState.submitting()';
}


}




/// @nodoc


class CheckOutSuccess implements CheckOutState {
  const CheckOutSuccess(this.record);
  

 final  AttendanceModel record;

/// Create a copy of CheckOutState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckOutSuccessCopyWith<CheckOutSuccess> get copyWith => _$CheckOutSuccessCopyWithImpl<CheckOutSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckOutSuccess&&(identical(other.record, record) || other.record == record));
}


@override
int get hashCode => Object.hash(runtimeType,record);

@override
String toString() {
  return 'CheckOutState.success(record: $record)';
}


}

/// @nodoc
abstract mixin class $CheckOutSuccessCopyWith<$Res> implements $CheckOutStateCopyWith<$Res> {
  factory $CheckOutSuccessCopyWith(CheckOutSuccess value, $Res Function(CheckOutSuccess) _then) = _$CheckOutSuccessCopyWithImpl;
@useResult
$Res call({
 AttendanceModel record
});


$AttendanceModelCopyWith<$Res> get record;

}
/// @nodoc
class _$CheckOutSuccessCopyWithImpl<$Res>
    implements $CheckOutSuccessCopyWith<$Res> {
  _$CheckOutSuccessCopyWithImpl(this._self, this._then);

  final CheckOutSuccess _self;
  final $Res Function(CheckOutSuccess) _then;

/// Create a copy of CheckOutState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? record = null,}) {
  return _then(CheckOutSuccess(
null == record ? _self.record : record // ignore: cast_nullable_to_non_nullable
as AttendanceModel,
  ));
}

/// Create a copy of CheckOutState
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


class CheckOutFailure implements CheckOutState {
  const CheckOutFailure(this.message);
  

 final  String message;

/// Create a copy of CheckOutState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckOutFailureCopyWith<CheckOutFailure> get copyWith => _$CheckOutFailureCopyWithImpl<CheckOutFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckOutFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'CheckOutState.failure(message: $message)';
}


}

/// @nodoc
abstract mixin class $CheckOutFailureCopyWith<$Res> implements $CheckOutStateCopyWith<$Res> {
  factory $CheckOutFailureCopyWith(CheckOutFailure value, $Res Function(CheckOutFailure) _then) = _$CheckOutFailureCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$CheckOutFailureCopyWithImpl<$Res>
    implements $CheckOutFailureCopyWith<$Res> {
  _$CheckOutFailureCopyWithImpl(this._self, this._then);

  final CheckOutFailure _self;
  final $Res Function(CheckOutFailure) _then;

/// Create a copy of CheckOutState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(CheckOutFailure(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
