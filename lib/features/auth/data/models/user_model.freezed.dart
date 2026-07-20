// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserModel {

 int get id; String get name; String? get email; String get role;@JsonKey(name: 'is_active') bool get isActive; InternModel? get intern;
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.intern, intern) || other.intern == intern));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,role,isActive,intern);

@override
String toString() {
  return 'UserModel(id: $id, name: $name, email: $email, role: $role, isActive: $isActive, intern: $intern)';
}


}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? email, String role,@JsonKey(name: 'is_active') bool isActive, InternModel? intern
});


$InternModelCopyWith<$Res>? get intern;

}
/// @nodoc
class _$UserModelCopyWithImpl<$Res>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = freezed,Object? role = null,Object? isActive = null,Object? intern = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,intern: freezed == intern ? _self.intern : intern // ignore: cast_nullable_to_non_nullable
as InternModel?,
  ));
}
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InternModelCopyWith<$Res>? get intern {
    if (_self.intern == null) {
    return null;
  }

  return $InternModelCopyWith<$Res>(_self.intern!, (value) {
    return _then(_self.copyWith(intern: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserModel].
extension UserModelPatterns on UserModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserModel value)  $default,){
final _that = this;
switch (_that) {
case _UserModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? email,  String role, @JsonKey(name: 'is_active')  bool isActive,  InternModel? intern)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.role,_that.isActive,_that.intern);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? email,  String role, @JsonKey(name: 'is_active')  bool isActive,  InternModel? intern)  $default,) {final _that = this;
switch (_that) {
case _UserModel():
return $default(_that.id,_that.name,_that.email,_that.role,_that.isActive,_that.intern);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? email,  String role, @JsonKey(name: 'is_active')  bool isActive,  InternModel? intern)?  $default,) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.role,_that.isActive,_that.intern);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserModel implements UserModel {
  const _UserModel({required this.id, required this.name, this.email, required this.role, @JsonKey(name: 'is_active') this.isActive = true, this.intern});
  factory _UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? email;
@override final  String role;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override final  InternModel? intern;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserModelCopyWith<_UserModel> get copyWith => __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.intern, intern) || other.intern == intern));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,role,isActive,intern);

@override
String toString() {
  return 'UserModel(id: $id, name: $name, email: $email, role: $role, isActive: $isActive, intern: $intern)';
}


}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(_UserModel value, $Res Function(_UserModel) _then) = __$UserModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? email, String role,@JsonKey(name: 'is_active') bool isActive, InternModel? intern
});


@override $InternModelCopyWith<$Res>? get intern;

}
/// @nodoc
class __$UserModelCopyWithImpl<$Res>
    implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = freezed,Object? role = null,Object? isActive = null,Object? intern = freezed,}) {
  return _then(_UserModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,intern: freezed == intern ? _self.intern : intern // ignore: cast_nullable_to_non_nullable
as InternModel?,
  ));
}

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InternModelCopyWith<$Res>? get intern {
    if (_self.intern == null) {
    return null;
  }

  return $InternModelCopyWith<$Res>(_self.intern!, (value) {
    return _then(_self.copyWith(intern: value));
  });
}
}


/// @nodoc
mixin _$InternModel {

 int get id; String get nim; String? get phone; String get status; String? get university; String? get major; String? get program; String? get division;@JsonKey(name: 'start_date') String? get startDate;@JsonKey(name: 'end_date') String? get endDate;@JsonKey(name: 'division_id') int? get divisionId;
/// Create a copy of InternModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InternModelCopyWith<InternModel> get copyWith => _$InternModelCopyWithImpl<InternModel>(this as InternModel, _$identity);

  /// Serializes this InternModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InternModel&&(identical(other.id, id) || other.id == id)&&(identical(other.nim, nim) || other.nim == nim)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.status, status) || other.status == status)&&(identical(other.university, university) || other.university == university)&&(identical(other.major, major) || other.major == major)&&(identical(other.program, program) || other.program == program)&&(identical(other.division, division) || other.division == division)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.divisionId, divisionId) || other.divisionId == divisionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nim,phone,status,university,major,program,division,startDate,endDate,divisionId);

@override
String toString() {
  return 'InternModel(id: $id, nim: $nim, phone: $phone, status: $status, university: $university, major: $major, program: $program, division: $division, startDate: $startDate, endDate: $endDate, divisionId: $divisionId)';
}


}

/// @nodoc
abstract mixin class $InternModelCopyWith<$Res>  {
  factory $InternModelCopyWith(InternModel value, $Res Function(InternModel) _then) = _$InternModelCopyWithImpl;
@useResult
$Res call({
 int id, String nim, String? phone, String status, String? university, String? major, String? program, String? division,@JsonKey(name: 'start_date') String? startDate,@JsonKey(name: 'end_date') String? endDate,@JsonKey(name: 'division_id') int? divisionId
});




}
/// @nodoc
class _$InternModelCopyWithImpl<$Res>
    implements $InternModelCopyWith<$Res> {
  _$InternModelCopyWithImpl(this._self, this._then);

  final InternModel _self;
  final $Res Function(InternModel) _then;

/// Create a copy of InternModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nim = null,Object? phone = freezed,Object? status = null,Object? university = freezed,Object? major = freezed,Object? program = freezed,Object? division = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? divisionId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nim: null == nim ? _self.nim : nim // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,university: freezed == university ? _self.university : university // ignore: cast_nullable_to_non_nullable
as String?,major: freezed == major ? _self.major : major // ignore: cast_nullable_to_non_nullable
as String?,program: freezed == program ? _self.program : program // ignore: cast_nullable_to_non_nullable
as String?,division: freezed == division ? _self.division : division // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,divisionId: freezed == divisionId ? _self.divisionId : divisionId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [InternModel].
extension InternModelPatterns on InternModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InternModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InternModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InternModel value)  $default,){
final _that = this;
switch (_that) {
case _InternModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InternModel value)?  $default,){
final _that = this;
switch (_that) {
case _InternModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String nim,  String? phone,  String status,  String? university,  String? major,  String? program,  String? division, @JsonKey(name: 'start_date')  String? startDate, @JsonKey(name: 'end_date')  String? endDate, @JsonKey(name: 'division_id')  int? divisionId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InternModel() when $default != null:
return $default(_that.id,_that.nim,_that.phone,_that.status,_that.university,_that.major,_that.program,_that.division,_that.startDate,_that.endDate,_that.divisionId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String nim,  String? phone,  String status,  String? university,  String? major,  String? program,  String? division, @JsonKey(name: 'start_date')  String? startDate, @JsonKey(name: 'end_date')  String? endDate, @JsonKey(name: 'division_id')  int? divisionId)  $default,) {final _that = this;
switch (_that) {
case _InternModel():
return $default(_that.id,_that.nim,_that.phone,_that.status,_that.university,_that.major,_that.program,_that.division,_that.startDate,_that.endDate,_that.divisionId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String nim,  String? phone,  String status,  String? university,  String? major,  String? program,  String? division, @JsonKey(name: 'start_date')  String? startDate, @JsonKey(name: 'end_date')  String? endDate, @JsonKey(name: 'division_id')  int? divisionId)?  $default,) {final _that = this;
switch (_that) {
case _InternModel() when $default != null:
return $default(_that.id,_that.nim,_that.phone,_that.status,_that.university,_that.major,_that.program,_that.division,_that.startDate,_that.endDate,_that.divisionId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InternModel implements InternModel {
  const _InternModel({required this.id, required this.nim, this.phone, required this.status, this.university, this.major, this.program, this.division, @JsonKey(name: 'start_date') this.startDate, @JsonKey(name: 'end_date') this.endDate, @JsonKey(name: 'division_id') this.divisionId});
  factory _InternModel.fromJson(Map<String, dynamic> json) => _$InternModelFromJson(json);

@override final  int id;
@override final  String nim;
@override final  String? phone;
@override final  String status;
@override final  String? university;
@override final  String? major;
@override final  String? program;
@override final  String? division;
@override@JsonKey(name: 'start_date') final  String? startDate;
@override@JsonKey(name: 'end_date') final  String? endDate;
@override@JsonKey(name: 'division_id') final  int? divisionId;

/// Create a copy of InternModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InternModelCopyWith<_InternModel> get copyWith => __$InternModelCopyWithImpl<_InternModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InternModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InternModel&&(identical(other.id, id) || other.id == id)&&(identical(other.nim, nim) || other.nim == nim)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.status, status) || other.status == status)&&(identical(other.university, university) || other.university == university)&&(identical(other.major, major) || other.major == major)&&(identical(other.program, program) || other.program == program)&&(identical(other.division, division) || other.division == division)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.divisionId, divisionId) || other.divisionId == divisionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nim,phone,status,university,major,program,division,startDate,endDate,divisionId);

@override
String toString() {
  return 'InternModel(id: $id, nim: $nim, phone: $phone, status: $status, university: $university, major: $major, program: $program, division: $division, startDate: $startDate, endDate: $endDate, divisionId: $divisionId)';
}


}

/// @nodoc
abstract mixin class _$InternModelCopyWith<$Res> implements $InternModelCopyWith<$Res> {
  factory _$InternModelCopyWith(_InternModel value, $Res Function(_InternModel) _then) = __$InternModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String nim, String? phone, String status, String? university, String? major, String? program, String? division,@JsonKey(name: 'start_date') String? startDate,@JsonKey(name: 'end_date') String? endDate,@JsonKey(name: 'division_id') int? divisionId
});




}
/// @nodoc
class __$InternModelCopyWithImpl<$Res>
    implements _$InternModelCopyWith<$Res> {
  __$InternModelCopyWithImpl(this._self, this._then);

  final _InternModel _self;
  final $Res Function(_InternModel) _then;

/// Create a copy of InternModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nim = null,Object? phone = freezed,Object? status = null,Object? university = freezed,Object? major = freezed,Object? program = freezed,Object? division = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? divisionId = freezed,}) {
  return _then(_InternModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nim: null == nim ? _self.nim : nim // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,university: freezed == university ? _self.university : university // ignore: cast_nullable_to_non_nullable
as String?,major: freezed == major ? _self.major : major // ignore: cast_nullable_to_non_nullable
as String?,program: freezed == program ? _self.program : program // ignore: cast_nullable_to_non_nullable
as String?,division: freezed == division ? _self.division : division // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,divisionId: freezed == divisionId ? _self.divisionId : divisionId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$UserEnvelope {

 UserModel get data;
/// Create a copy of UserEnvelope
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserEnvelopeCopyWith<UserEnvelope> get copyWith => _$UserEnvelopeCopyWithImpl<UserEnvelope>(this as UserEnvelope, _$identity);

  /// Serializes this UserEnvelope to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserEnvelope&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'UserEnvelope(data: $data)';
}


}

/// @nodoc
abstract mixin class $UserEnvelopeCopyWith<$Res>  {
  factory $UserEnvelopeCopyWith(UserEnvelope value, $Res Function(UserEnvelope) _then) = _$UserEnvelopeCopyWithImpl;
@useResult
$Res call({
 UserModel data
});


$UserModelCopyWith<$Res> get data;

}
/// @nodoc
class _$UserEnvelopeCopyWithImpl<$Res>
    implements $UserEnvelopeCopyWith<$Res> {
  _$UserEnvelopeCopyWithImpl(this._self, this._then);

  final UserEnvelope _self;
  final $Res Function(UserEnvelope) _then;

/// Create a copy of UserEnvelope
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,}) {
  return _then(_self.copyWith(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as UserModel,
  ));
}
/// Create a copy of UserEnvelope
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserModelCopyWith<$Res> get data {
  
  return $UserModelCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserEnvelope].
extension UserEnvelopePatterns on UserEnvelope {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserEnvelope value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserEnvelope() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserEnvelope value)  $default,){
final _that = this;
switch (_that) {
case _UserEnvelope():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserEnvelope value)?  $default,){
final _that = this;
switch (_that) {
case _UserEnvelope() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UserModel data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserEnvelope() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UserModel data)  $default,) {final _that = this;
switch (_that) {
case _UserEnvelope():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UserModel data)?  $default,) {final _that = this;
switch (_that) {
case _UserEnvelope() when $default != null:
return $default(_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserEnvelope implements UserEnvelope {
  const _UserEnvelope({required this.data});
  factory _UserEnvelope.fromJson(Map<String, dynamic> json) => _$UserEnvelopeFromJson(json);

@override final  UserModel data;

/// Create a copy of UserEnvelope
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserEnvelopeCopyWith<_UserEnvelope> get copyWith => __$UserEnvelopeCopyWithImpl<_UserEnvelope>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserEnvelopeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserEnvelope&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'UserEnvelope(data: $data)';
}


}

/// @nodoc
abstract mixin class _$UserEnvelopeCopyWith<$Res> implements $UserEnvelopeCopyWith<$Res> {
  factory _$UserEnvelopeCopyWith(_UserEnvelope value, $Res Function(_UserEnvelope) _then) = __$UserEnvelopeCopyWithImpl;
@override @useResult
$Res call({
 UserModel data
});


@override $UserModelCopyWith<$Res> get data;

}
/// @nodoc
class __$UserEnvelopeCopyWithImpl<$Res>
    implements _$UserEnvelopeCopyWith<$Res> {
  __$UserEnvelopeCopyWithImpl(this._self, this._then);

  final _UserEnvelope _self;
  final $Res Function(_UserEnvelope) _then;

/// Create a copy of UserEnvelope
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(_UserEnvelope(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as UserModel,
  ));
}

/// Create a copy of UserEnvelope
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserModelCopyWith<$Res> get data {
  
  return $UserModelCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

// dart format on
