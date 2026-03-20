// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vec_point.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VecPoint _$VecPointFromJson(Map<String, dynamic> json) {
  return _VecPoint.fromJson(json);
}

/// @nodoc
mixin _$VecPoint {
  double get x => throw _privateConstructorUsedError;
  double get y => throw _privateConstructorUsedError;

  /// Serializes this VecPoint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VecPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VecPointCopyWith<VecPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VecPointCopyWith<$Res> {
  factory $VecPointCopyWith(VecPoint value, $Res Function(VecPoint) then) =
      _$VecPointCopyWithImpl<$Res, VecPoint>;
  @useResult
  $Res call({double x, double y});
}

/// @nodoc
class _$VecPointCopyWithImpl<$Res, $Val extends VecPoint>
    implements $VecPointCopyWith<$Res> {
  _$VecPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VecPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? x = null, Object? y = null}) {
    return _then(
      _value.copyWith(
            x: null == x
                ? _value.x
                : x // ignore: cast_nullable_to_non_nullable
                      as double,
            y: null == y
                ? _value.y
                : y // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VecPointImplCopyWith<$Res>
    implements $VecPointCopyWith<$Res> {
  factory _$$VecPointImplCopyWith(
    _$VecPointImpl value,
    $Res Function(_$VecPointImpl) then,
  ) = __$$VecPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double x, double y});
}

/// @nodoc
class __$$VecPointImplCopyWithImpl<$Res>
    extends _$VecPointCopyWithImpl<$Res, _$VecPointImpl>
    implements _$$VecPointImplCopyWith<$Res> {
  __$$VecPointImplCopyWithImpl(
    _$VecPointImpl _value,
    $Res Function(_$VecPointImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VecPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? x = null, Object? y = null}) {
    return _then(
      _$VecPointImpl(
        x: null == x
            ? _value.x
            : x // ignore: cast_nullable_to_non_nullable
                  as double,
        y: null == y
            ? _value.y
            : y // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VecPointImpl implements _VecPoint {
  const _$VecPointImpl({required this.x, required this.y});

  factory _$VecPointImpl.fromJson(Map<String, dynamic> json) =>
      _$$VecPointImplFromJson(json);

  @override
  final double x;
  @override
  final double y;

  @override
  String toString() {
    return 'VecPoint(x: $x, y: $y)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VecPointImpl &&
            (identical(other.x, x) || other.x == x) &&
            (identical(other.y, y) || other.y == y));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, x, y);

  /// Create a copy of VecPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VecPointImplCopyWith<_$VecPointImpl> get copyWith =>
      __$$VecPointImplCopyWithImpl<_$VecPointImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VecPointImplToJson(this);
  }
}

abstract class _VecPoint implements VecPoint {
  const factory _VecPoint({required final double x, required final double y}) =
      _$VecPointImpl;

  factory _VecPoint.fromJson(Map<String, dynamic> json) =
      _$VecPointImpl.fromJson;

  @override
  double get x;
  @override
  double get y;

  /// Create a copy of VecPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VecPointImplCopyWith<_$VecPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
