// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'balance_history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BalanceHistory {

 DateTime get date; double get balance; String? get walletId;
/// Create a copy of BalanceHistory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BalanceHistoryCopyWith<BalanceHistory> get copyWith => _$BalanceHistoryCopyWithImpl<BalanceHistory>(this as BalanceHistory, _$identity);

  /// Serializes this BalanceHistory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BalanceHistory&&(identical(other.date, date) || other.date == date)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.walletId, walletId) || other.walletId == walletId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,balance,walletId);

@override
String toString() {
  return 'BalanceHistory(date: $date, balance: $balance, walletId: $walletId)';
}


}

/// @nodoc
abstract mixin class $BalanceHistoryCopyWith<$Res>  {
  factory $BalanceHistoryCopyWith(BalanceHistory value, $Res Function(BalanceHistory) _then) = _$BalanceHistoryCopyWithImpl;
@useResult
$Res call({
 DateTime date, double balance, String? walletId
});




}
/// @nodoc
class _$BalanceHistoryCopyWithImpl<$Res>
    implements $BalanceHistoryCopyWith<$Res> {
  _$BalanceHistoryCopyWithImpl(this._self, this._then);

  final BalanceHistory _self;
  final $Res Function(BalanceHistory) _then;

/// Create a copy of BalanceHistory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? balance = null,Object? walletId = freezed,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,walletId: freezed == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BalanceHistory].
extension BalanceHistoryPatterns on BalanceHistory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BalanceHistory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BalanceHistory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BalanceHistory value)  $default,){
final _that = this;
switch (_that) {
case _BalanceHistory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BalanceHistory value)?  $default,){
final _that = this;
switch (_that) {
case _BalanceHistory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  double balance,  String? walletId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BalanceHistory() when $default != null:
return $default(_that.date,_that.balance,_that.walletId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  double balance,  String? walletId)  $default,) {final _that = this;
switch (_that) {
case _BalanceHistory():
return $default(_that.date,_that.balance,_that.walletId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  double balance,  String? walletId)?  $default,) {final _that = this;
switch (_that) {
case _BalanceHistory() when $default != null:
return $default(_that.date,_that.balance,_that.walletId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BalanceHistory implements BalanceHistory {
  const _BalanceHistory({required this.date, required this.balance, this.walletId});
  factory _BalanceHistory.fromJson(Map<String, dynamic> json) => _$BalanceHistoryFromJson(json);

@override final  DateTime date;
@override final  double balance;
@override final  String? walletId;

/// Create a copy of BalanceHistory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BalanceHistoryCopyWith<_BalanceHistory> get copyWith => __$BalanceHistoryCopyWithImpl<_BalanceHistory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BalanceHistoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BalanceHistory&&(identical(other.date, date) || other.date == date)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.walletId, walletId) || other.walletId == walletId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,balance,walletId);

@override
String toString() {
  return 'BalanceHistory(date: $date, balance: $balance, walletId: $walletId)';
}


}

/// @nodoc
abstract mixin class _$BalanceHistoryCopyWith<$Res> implements $BalanceHistoryCopyWith<$Res> {
  factory _$BalanceHistoryCopyWith(_BalanceHistory value, $Res Function(_BalanceHistory) _then) = __$BalanceHistoryCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, double balance, String? walletId
});




}
/// @nodoc
class __$BalanceHistoryCopyWithImpl<$Res>
    implements _$BalanceHistoryCopyWith<$Res> {
  __$BalanceHistoryCopyWithImpl(this._self, this._then);

  final _BalanceHistory _self;
  final $Res Function(_BalanceHistory) _then;

/// Create a copy of BalanceHistory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? balance = null,Object? walletId = freezed,}) {
  return _then(_BalanceHistory(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,walletId: freezed == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
