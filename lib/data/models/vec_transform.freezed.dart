// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vec_transform.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VecTransform _$VecTransformFromJson(Map<String, dynamic> json) {
  return _VecTransform.fromJson(json);
}

/// @nodoc
mixin _$VecTransform {
  double get x => throw _privateConstructorUsedError;
  double get y => throw _privateConstructorUsedError;
  double get width => throw _privateConstructorUsedError;
  double get height => throw _privateConstructorUsedError;
  double get rotation => throw _privateConstructorUsedError;
  double get scaleX => throw _privateConstructorUsedError;
  double get scaleY => throw _privateConstructorUsedError;
  double get skewX => throw _privateConstructorUsedError;
  double get skewY => throw _privateConstructorUsedError;
  VecPoint? get pivot => throw _privateConstructorUsedError;

  /// Serializes this VecTransform to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VecTransform
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VecTransformCopyWith<VecTransform> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VecTransformCopyWith<$Res> {
  factory $VecTransformCopyWith(
    VecTransform value,
    $Res Function(VecTransform) then,
  ) = _$VecTransformCopyWithImpl<$Res, VecTransform>;
  @useResult
  $Res call({
    double x,
    double y,
    double width,
    double height,
    double rotation,
    double scaleX,
    double scaleY,
    double skewX,
    double skewY,
    VecPoint? pivot,
  });

  $VecPointCopyWith<$Res>? get pivot;
}

/// @nodoc
class _$VecTransformCopyWithImpl<$Res, $Val extends VecTransform>
    implements $VecTransformCopyWith<$Res> {
  _$VecTransformCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VecTransform
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? x = null,
    Object? y = null,
    Object? width = null,
    Object? height = null,
    Object? rotation = null,
    Object? scaleX = null,
    Object? scaleY = null,
    Object? skewX = null,
    Object? skewY = null,
    Object? pivot = freezed,
  }) {
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
            width: null == width
                ? _value.width
                : width // ignore: cast_nullable_to_non_nullable
                      as double,
            height: null == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                      as double,
            rotation: null == rotation
                ? _value.rotation
                : rotation // ignore: cast_nullable_to_non_nullable
                      as double,
            scaleX: null == scaleX
                ? _value.scaleX
                : scaleX // ignore: cast_nullable_to_non_nullable
                      as double,
            scaleY: null == scaleY
                ? _value.scaleY
                : scaleY // ignore: cast_nullable_to_non_nullable
                      as double,
            skewX: null == skewX
                ? _value.skewX
                : skewX // ignore: cast_nullable_to_non_nullable
                      as double,
            skewY: null == skewY
                ? _value.skewY
                : skewY // ignore: cast_nullable_to_non_nullable
                      as double,
            pivot: freezed == pivot
                ? _value.pivot
                : pivot // ignore: cast_nullable_to_non_nullable
                      as VecPoint?,
          )
          as $Val,
    );
  }

  /// Create a copy of VecTransform
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VecPointCopyWith<$Res>? get pivot {
    if (_value.pivot == null) {
      return null;
    }

    return $VecPointCopyWith<$Res>(_value.pivot!, (value) {
      return _then(_value.copyWith(pivot: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$VecTransformImplCopyWith<$Res>
    implements $VecTransformCopyWith<$Res> {
  factory _$$VecTransformImplCopyWith(
    _$VecTransformImpl value,
    $Res Function(_$VecTransformImpl) then,
  ) = __$$VecTransformImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double x,
    double y,
    double width,
    double height,
    double rotation,
    double scaleX,
    double scaleY,
    double skewX,
    double skewY,
    VecPoint? pivot,
  });

  @override
  $VecPointCopyWith<$Res>? get pivot;
}

/// @nodoc
class __$$VecTransformImplCopyWithImpl<$Res>
    extends _$VecTransformCopyWithImpl<$Res, _$VecTransformImpl>
    implements _$$VecTransformImplCopyWith<$Res> {
  __$$VecTransformImplCopyWithImpl(
    _$VecTransformImpl _value,
    $Res Function(_$VecTransformImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VecTransform
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? x = null,
    Object? y = null,
    Object? width = null,
    Object? height = null,
    Object? rotation = null,
    Object? scaleX = null,
    Object? scaleY = null,
    Object? skewX = null,
    Object? skewY = null,
    Object? pivot = freezed,
  }) {
    return _then(
      _$VecTransformImpl(
        x: null == x
            ? _value.x
            : x // ignore: cast_nullable_to_non_nullable
                  as double,
        y: null == y
            ? _value.y
            : y // ignore: cast_nullable_to_non_nullable
                  as double,
        width: null == width
            ? _value.width
            : width // ignore: cast_nullable_to_non_nullable
                  as double,
        height: null == height
            ? _value.height
            : height // ignore: cast_nullable_to_non_nullable
                  as double,
        rotation: null == rotation
            ? _value.rotation
            : rotation // ignore: cast_nullable_to_non_nullable
                  as double,
        scaleX: null == scaleX
            ? _value.scaleX
            : scaleX // ignore: cast_nullable_to_non_nullable
                  as double,
        scaleY: null == scaleY
            ? _value.scaleY
            : scaleY // ignore: cast_nullable_to_non_nullable
                  as double,
        skewX: null == skewX
            ? _value.skewX
            : skewX // ignore: cast_nullable_to_non_nullable
                  as double,
        skewY: null == skewY
            ? _value.skewY
            : skewY // ignore: cast_nullable_to_non_nullable
                  as double,
        pivot: freezed == pivot
            ? _value.pivot
            : pivot // ignore: cast_nullable_to_non_nullable
                  as VecPoint?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VecTransformImpl implements _VecTransform {
  const _$VecTransformImpl({
    this.x = 0,
    this.y = 0,
    this.width = 0,
    this.height = 0,
    this.rotation = 0,
    this.scaleX = 1,
    this.scaleY = 1,
    this.skewX = 0,
    this.skewY = 0,
    this.pivot,
  });

  factory _$VecTransformImpl.fromJson(Map<String, dynamic> json) =>
      _$$VecTransformImplFromJson(json);

  @override
  @JsonKey()
  final double x;
  @override
  @JsonKey()
  final double y;
  @override
  @JsonKey()
  final double width;
  @override
  @JsonKey()
  final double height;
  @override
  @JsonKey()
  final double rotation;
  @override
  @JsonKey()
  final double scaleX;
  @override
  @JsonKey()
  final double scaleY;
  @override
  @JsonKey()
  final double skewX;
  @override
  @JsonKey()
  final double skewY;
  @override
  final VecPoint? pivot;

  @override
  String toString() {
    return 'VecTransform(x: $x, y: $y, width: $width, height: $height, rotation: $rotation, scaleX: $scaleX, scaleY: $scaleY, skewX: $skewX, skewY: $skewY, pivot: $pivot)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VecTransformImpl &&
            (identical(other.x, x) || other.x == x) &&
            (identical(other.y, y) || other.y == y) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.rotation, rotation) ||
                other.rotation == rotation) &&
            (identical(other.scaleX, scaleX) || other.scaleX == scaleX) &&
            (identical(other.scaleY, scaleY) || other.scaleY == scaleY) &&
            (identical(other.skewX, skewX) || other.skewX == skewX) &&
            (identical(other.skewY, skewY) || other.skewY == skewY) &&
            (identical(other.pivot, pivot) || other.pivot == pivot));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    x,
    y,
    width,
    height,
    rotation,
    scaleX,
    scaleY,
    skewX,
    skewY,
    pivot,
  );

  /// Create a copy of VecTransform
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VecTransformImplCopyWith<_$VecTransformImpl> get copyWith =>
      __$$VecTransformImplCopyWithImpl<_$VecTransformImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VecTransformImplToJson(this);
  }
}

abstract class _VecTransform implements VecTransform {
  const factory _VecTransform({
    final double x,
    final double y,
    final double width,
    final double height,
    final double rotation,
    final double scaleX,
    final double scaleY,
    final double skewX,
    final double skewY,
    final VecPoint? pivot,
  }) = _$VecTransformImpl;

  factory _VecTransform.fromJson(Map<String, dynamic> json) =
      _$VecTransformImpl.fromJson;

  @override
  double get x;
  @override
  double get y;
  @override
  double get width;
  @override
  double get height;
  @override
  double get rotation;
  @override
  double get scaleX;
  @override
  double get scaleY;
  @override
  double get skewX;
  @override
  double get skewY;
  @override
  VecPoint? get pivot;

  /// Create a copy of VecTransform
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VecTransformImplCopyWith<_$VecTransformImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
