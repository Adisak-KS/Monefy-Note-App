// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'export_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExportState {

 ExportDataType get dataType; ExportFormat get format; DateTimeRange? get dateRange;
/// Create a copy of ExportState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportStateCopyWith<ExportState> get copyWith => _$ExportStateCopyWithImpl<ExportState>(this as ExportState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportState&&(identical(other.dataType, dataType) || other.dataType == dataType)&&(identical(other.format, format) || other.format == format)&&(identical(other.dateRange, dateRange) || other.dateRange == dateRange));
}


@override
int get hashCode => Object.hash(runtimeType,dataType,format,dateRange);

@override
String toString() {
  return 'ExportState(dataType: $dataType, format: $format, dateRange: $dateRange)';
}


}

/// @nodoc
abstract mixin class $ExportStateCopyWith<$Res>  {
  factory $ExportStateCopyWith(ExportState value, $Res Function(ExportState) _then) = _$ExportStateCopyWithImpl;
@useResult
$Res call({
 ExportDataType dataType, ExportFormat format, DateTimeRange<DateTime>? dateRange
});




}
/// @nodoc
class _$ExportStateCopyWithImpl<$Res>
    implements $ExportStateCopyWith<$Res> {
  _$ExportStateCopyWithImpl(this._self, this._then);

  final ExportState _self;
  final $Res Function(ExportState) _then;

/// Create a copy of ExportState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dataType = null,Object? format = null,Object? dateRange = freezed,}) {
  return _then(_self.copyWith(
dataType: null == dataType ? _self.dataType : dataType // ignore: cast_nullable_to_non_nullable
as ExportDataType,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as ExportFormat,dateRange: freezed == dateRange ? _self.dateRange : dateRange // ignore: cast_nullable_to_non_nullable
as DateTimeRange<DateTime>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExportState].
extension ExportStatePatterns on ExportState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ExportInitial value)?  initial,TResult Function( ExportLoading value)?  loading,TResult Function( ExportSuccess value)?  success,TResult Function( ExportError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ExportInitial() when initial != null:
return initial(_that);case ExportLoading() when loading != null:
return loading(_that);case ExportSuccess() when success != null:
return success(_that);case ExportError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ExportInitial value)  initial,required TResult Function( ExportLoading value)  loading,required TResult Function( ExportSuccess value)  success,required TResult Function( ExportError value)  error,}){
final _that = this;
switch (_that) {
case ExportInitial():
return initial(_that);case ExportLoading():
return loading(_that);case ExportSuccess():
return success(_that);case ExportError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ExportInitial value)?  initial,TResult? Function( ExportLoading value)?  loading,TResult? Function( ExportSuccess value)?  success,TResult? Function( ExportError value)?  error,}){
final _that = this;
switch (_that) {
case ExportInitial() when initial != null:
return initial(_that);case ExportLoading() when loading != null:
return loading(_that);case ExportSuccess() when success != null:
return success(_that);case ExportError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( ExportDataType dataType,  ExportFormat format,  DateTimeRange? dateRange)?  initial,TResult Function( ExportDataType dataType,  ExportFormat format,  DateTimeRange? dateRange)?  loading,TResult Function( String filePath,  ExportDataType dataType,  ExportFormat format,  DateTimeRange? dateRange)?  success,TResult Function( String message,  ExportDataType dataType,  ExportFormat format,  DateTimeRange? dateRange)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ExportInitial() when initial != null:
return initial(_that.dataType,_that.format,_that.dateRange);case ExportLoading() when loading != null:
return loading(_that.dataType,_that.format,_that.dateRange);case ExportSuccess() when success != null:
return success(_that.filePath,_that.dataType,_that.format,_that.dateRange);case ExportError() when error != null:
return error(_that.message,_that.dataType,_that.format,_that.dateRange);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( ExportDataType dataType,  ExportFormat format,  DateTimeRange? dateRange)  initial,required TResult Function( ExportDataType dataType,  ExportFormat format,  DateTimeRange? dateRange)  loading,required TResult Function( String filePath,  ExportDataType dataType,  ExportFormat format,  DateTimeRange? dateRange)  success,required TResult Function( String message,  ExportDataType dataType,  ExportFormat format,  DateTimeRange? dateRange)  error,}) {final _that = this;
switch (_that) {
case ExportInitial():
return initial(_that.dataType,_that.format,_that.dateRange);case ExportLoading():
return loading(_that.dataType,_that.format,_that.dateRange);case ExportSuccess():
return success(_that.filePath,_that.dataType,_that.format,_that.dateRange);case ExportError():
return error(_that.message,_that.dataType,_that.format,_that.dateRange);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( ExportDataType dataType,  ExportFormat format,  DateTimeRange? dateRange)?  initial,TResult? Function( ExportDataType dataType,  ExportFormat format,  DateTimeRange? dateRange)?  loading,TResult? Function( String filePath,  ExportDataType dataType,  ExportFormat format,  DateTimeRange? dateRange)?  success,TResult? Function( String message,  ExportDataType dataType,  ExportFormat format,  DateTimeRange? dateRange)?  error,}) {final _that = this;
switch (_that) {
case ExportInitial() when initial != null:
return initial(_that.dataType,_that.format,_that.dateRange);case ExportLoading() when loading != null:
return loading(_that.dataType,_that.format,_that.dateRange);case ExportSuccess() when success != null:
return success(_that.filePath,_that.dataType,_that.format,_that.dateRange);case ExportError() when error != null:
return error(_that.message,_that.dataType,_that.format,_that.dateRange);case _:
  return null;

}
}

}

/// @nodoc


class ExportInitial implements ExportState {
  const ExportInitial({this.dataType = ExportDataType.transactions, this.format = ExportFormat.excel, this.dateRange});
  

@override@JsonKey() final  ExportDataType dataType;
@override@JsonKey() final  ExportFormat format;
@override final  DateTimeRange? dateRange;

/// Create a copy of ExportState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportInitialCopyWith<ExportInitial> get copyWith => _$ExportInitialCopyWithImpl<ExportInitial>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportInitial&&(identical(other.dataType, dataType) || other.dataType == dataType)&&(identical(other.format, format) || other.format == format)&&(identical(other.dateRange, dateRange) || other.dateRange == dateRange));
}


@override
int get hashCode => Object.hash(runtimeType,dataType,format,dateRange);

@override
String toString() {
  return 'ExportState.initial(dataType: $dataType, format: $format, dateRange: $dateRange)';
}


}

/// @nodoc
abstract mixin class $ExportInitialCopyWith<$Res> implements $ExportStateCopyWith<$Res> {
  factory $ExportInitialCopyWith(ExportInitial value, $Res Function(ExportInitial) _then) = _$ExportInitialCopyWithImpl;
@override @useResult
$Res call({
 ExportDataType dataType, ExportFormat format, DateTimeRange? dateRange
});




}
/// @nodoc
class _$ExportInitialCopyWithImpl<$Res>
    implements $ExportInitialCopyWith<$Res> {
  _$ExportInitialCopyWithImpl(this._self, this._then);

  final ExportInitial _self;
  final $Res Function(ExportInitial) _then;

/// Create a copy of ExportState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dataType = null,Object? format = null,Object? dateRange = freezed,}) {
  return _then(ExportInitial(
dataType: null == dataType ? _self.dataType : dataType // ignore: cast_nullable_to_non_nullable
as ExportDataType,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as ExportFormat,dateRange: freezed == dateRange ? _self.dateRange : dateRange // ignore: cast_nullable_to_non_nullable
as DateTimeRange?,
  ));
}


}

/// @nodoc


class ExportLoading implements ExportState {
  const ExportLoading({required this.dataType, required this.format, this.dateRange});
  

@override final  ExportDataType dataType;
@override final  ExportFormat format;
@override final  DateTimeRange? dateRange;

/// Create a copy of ExportState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportLoadingCopyWith<ExportLoading> get copyWith => _$ExportLoadingCopyWithImpl<ExportLoading>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportLoading&&(identical(other.dataType, dataType) || other.dataType == dataType)&&(identical(other.format, format) || other.format == format)&&(identical(other.dateRange, dateRange) || other.dateRange == dateRange));
}


@override
int get hashCode => Object.hash(runtimeType,dataType,format,dateRange);

@override
String toString() {
  return 'ExportState.loading(dataType: $dataType, format: $format, dateRange: $dateRange)';
}


}

/// @nodoc
abstract mixin class $ExportLoadingCopyWith<$Res> implements $ExportStateCopyWith<$Res> {
  factory $ExportLoadingCopyWith(ExportLoading value, $Res Function(ExportLoading) _then) = _$ExportLoadingCopyWithImpl;
@override @useResult
$Res call({
 ExportDataType dataType, ExportFormat format, DateTimeRange? dateRange
});




}
/// @nodoc
class _$ExportLoadingCopyWithImpl<$Res>
    implements $ExportLoadingCopyWith<$Res> {
  _$ExportLoadingCopyWithImpl(this._self, this._then);

  final ExportLoading _self;
  final $Res Function(ExportLoading) _then;

/// Create a copy of ExportState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dataType = null,Object? format = null,Object? dateRange = freezed,}) {
  return _then(ExportLoading(
dataType: null == dataType ? _self.dataType : dataType // ignore: cast_nullable_to_non_nullable
as ExportDataType,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as ExportFormat,dateRange: freezed == dateRange ? _self.dateRange : dateRange // ignore: cast_nullable_to_non_nullable
as DateTimeRange?,
  ));
}


}

/// @nodoc


class ExportSuccess implements ExportState {
  const ExportSuccess({required this.filePath, required this.dataType, required this.format, this.dateRange});
  

 final  String filePath;
@override final  ExportDataType dataType;
@override final  ExportFormat format;
@override final  DateTimeRange? dateRange;

/// Create a copy of ExportState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportSuccessCopyWith<ExportSuccess> get copyWith => _$ExportSuccessCopyWithImpl<ExportSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportSuccess&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.dataType, dataType) || other.dataType == dataType)&&(identical(other.format, format) || other.format == format)&&(identical(other.dateRange, dateRange) || other.dateRange == dateRange));
}


@override
int get hashCode => Object.hash(runtimeType,filePath,dataType,format,dateRange);

@override
String toString() {
  return 'ExportState.success(filePath: $filePath, dataType: $dataType, format: $format, dateRange: $dateRange)';
}


}

/// @nodoc
abstract mixin class $ExportSuccessCopyWith<$Res> implements $ExportStateCopyWith<$Res> {
  factory $ExportSuccessCopyWith(ExportSuccess value, $Res Function(ExportSuccess) _then) = _$ExportSuccessCopyWithImpl;
@override @useResult
$Res call({
 String filePath, ExportDataType dataType, ExportFormat format, DateTimeRange? dateRange
});




}
/// @nodoc
class _$ExportSuccessCopyWithImpl<$Res>
    implements $ExportSuccessCopyWith<$Res> {
  _$ExportSuccessCopyWithImpl(this._self, this._then);

  final ExportSuccess _self;
  final $Res Function(ExportSuccess) _then;

/// Create a copy of ExportState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? filePath = null,Object? dataType = null,Object? format = null,Object? dateRange = freezed,}) {
  return _then(ExportSuccess(
filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,dataType: null == dataType ? _self.dataType : dataType // ignore: cast_nullable_to_non_nullable
as ExportDataType,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as ExportFormat,dateRange: freezed == dateRange ? _self.dateRange : dateRange // ignore: cast_nullable_to_non_nullable
as DateTimeRange?,
  ));
}


}

/// @nodoc


class ExportError implements ExportState {
  const ExportError({required this.message, required this.dataType, required this.format, this.dateRange});
  

 final  String message;
@override final  ExportDataType dataType;
@override final  ExportFormat format;
@override final  DateTimeRange? dateRange;

/// Create a copy of ExportState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportErrorCopyWith<ExportError> get copyWith => _$ExportErrorCopyWithImpl<ExportError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportError&&(identical(other.message, message) || other.message == message)&&(identical(other.dataType, dataType) || other.dataType == dataType)&&(identical(other.format, format) || other.format == format)&&(identical(other.dateRange, dateRange) || other.dateRange == dateRange));
}


@override
int get hashCode => Object.hash(runtimeType,message,dataType,format,dateRange);

@override
String toString() {
  return 'ExportState.error(message: $message, dataType: $dataType, format: $format, dateRange: $dateRange)';
}


}

/// @nodoc
abstract mixin class $ExportErrorCopyWith<$Res> implements $ExportStateCopyWith<$Res> {
  factory $ExportErrorCopyWith(ExportError value, $Res Function(ExportError) _then) = _$ExportErrorCopyWithImpl;
@override @useResult
$Res call({
 String message, ExportDataType dataType, ExportFormat format, DateTimeRange? dateRange
});




}
/// @nodoc
class _$ExportErrorCopyWithImpl<$Res>
    implements $ExportErrorCopyWith<$Res> {
  _$ExportErrorCopyWithImpl(this._self, this._then);

  final ExportError _self;
  final $Res Function(ExportError) _then;

/// Create a copy of ExportState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? dataType = null,Object? format = null,Object? dateRange = freezed,}) {
  return _then(ExportError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,dataType: null == dataType ? _self.dataType : dataType // ignore: cast_nullable_to_non_nullable
as ExportDataType,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as ExportFormat,dateRange: freezed == dateRange ? _self.dateRange : dateRange // ignore: cast_nullable_to_non_nullable
as DateTimeRange?,
  ));
}


}

// dart format on
