// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'custom_wallet_type.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CustomWalletType {

 String get id; String get name; String get iconName; String get colorHex; bool get isLiability; DateTime? get createdAt;
/// Create a copy of CustomWalletType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomWalletTypeCopyWith<CustomWalletType> get copyWith => _$CustomWalletTypeCopyWithImpl<CustomWalletType>(this as CustomWalletType, _$identity);

  /// Serializes this CustomWalletType to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomWalletType&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.colorHex, colorHex) || other.colorHex == colorHex)&&(identical(other.isLiability, isLiability) || other.isLiability == isLiability)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,iconName,colorHex,isLiability,createdAt);

@override
String toString() {
  return 'CustomWalletType(id: $id, name: $name, iconName: $iconName, colorHex: $colorHex, isLiability: $isLiability, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $CustomWalletTypeCopyWith<$Res>  {
  factory $CustomWalletTypeCopyWith(CustomWalletType value, $Res Function(CustomWalletType) _then) = _$CustomWalletTypeCopyWithImpl;
@useResult
$Res call({
 String id, String name, String iconName, String colorHex, bool isLiability, DateTime? createdAt
});




}
/// @nodoc
class _$CustomWalletTypeCopyWithImpl<$Res>
    implements $CustomWalletTypeCopyWith<$Res> {
  _$CustomWalletTypeCopyWithImpl(this._self, this._then);

  final CustomWalletType _self;
  final $Res Function(CustomWalletType) _then;

/// Create a copy of CustomWalletType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? iconName = null,Object? colorHex = null,Object? isLiability = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,colorHex: null == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String,isLiability: null == isLiability ? _self.isLiability : isLiability // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomWalletType].
extension CustomWalletTypePatterns on CustomWalletType {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomWalletType value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomWalletType() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomWalletType value)  $default,){
final _that = this;
switch (_that) {
case _CustomWalletType():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomWalletType value)?  $default,){
final _that = this;
switch (_that) {
case _CustomWalletType() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String iconName,  String colorHex,  bool isLiability,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomWalletType() when $default != null:
return $default(_that.id,_that.name,_that.iconName,_that.colorHex,_that.isLiability,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String iconName,  String colorHex,  bool isLiability,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _CustomWalletType():
return $default(_that.id,_that.name,_that.iconName,_that.colorHex,_that.isLiability,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String iconName,  String colorHex,  bool isLiability,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _CustomWalletType() when $default != null:
return $default(_that.id,_that.name,_that.iconName,_that.colorHex,_that.isLiability,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CustomWalletType implements CustomWalletType {
  const _CustomWalletType({required this.id, required this.name, required this.iconName, required this.colorHex, this.isLiability = false, this.createdAt});
  factory _CustomWalletType.fromJson(Map<String, dynamic> json) => _$CustomWalletTypeFromJson(json);

@override final  String id;
@override final  String name;
@override final  String iconName;
@override final  String colorHex;
@override@JsonKey() final  bool isLiability;
@override final  DateTime? createdAt;

/// Create a copy of CustomWalletType
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomWalletTypeCopyWith<_CustomWalletType> get copyWith => __$CustomWalletTypeCopyWithImpl<_CustomWalletType>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomWalletTypeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomWalletType&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.colorHex, colorHex) || other.colorHex == colorHex)&&(identical(other.isLiability, isLiability) || other.isLiability == isLiability)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,iconName,colorHex,isLiability,createdAt);

@override
String toString() {
  return 'CustomWalletType(id: $id, name: $name, iconName: $iconName, colorHex: $colorHex, isLiability: $isLiability, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CustomWalletTypeCopyWith<$Res> implements $CustomWalletTypeCopyWith<$Res> {
  factory _$CustomWalletTypeCopyWith(_CustomWalletType value, $Res Function(_CustomWalletType) _then) = __$CustomWalletTypeCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String iconName, String colorHex, bool isLiability, DateTime? createdAt
});




}
/// @nodoc
class __$CustomWalletTypeCopyWithImpl<$Res>
    implements _$CustomWalletTypeCopyWith<$Res> {
  __$CustomWalletTypeCopyWithImpl(this._self, this._then);

  final _CustomWalletType _self;
  final $Res Function(_CustomWalletType) _then;

/// Create a copy of CustomWalletType
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? iconName = null,Object? colorHex = null,Object? isLiability = null,Object? createdAt = freezed,}) {
  return _then(_CustomWalletType(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,colorHex: null == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String,isLiability: null == isLiability ? _self.isLiability : isLiability // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
