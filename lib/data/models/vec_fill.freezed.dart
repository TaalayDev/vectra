// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vec_fill.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VecFill _$VecFillFromJson(Map<String, dynamic> json) {
  return _VecFill.fromJson(json);
}

/// @nodoc
mixin _$VecFill {
  VecColor get color => throw _privateConstructorUsedError;
  double get opacity => throw _privateConstructorUsedError;
  VecBlendMode get blendMode => throw _privateConstructorUsedError;
  VecGradient? get gradient => throw _privateConstructorUsedError;
  VecPattern? get pattern => throw _privateConstructorUsedError;
  String? get imageAssetId => throw _privateConstructorUsedError;
  VecFillImageFit get imageFit => throw _privateConstructorUsedError;

  /// Serializes this VecFill to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VecFill
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VecFillCopyWith<VecFill> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VecFillCopyWith<$Res> {
  factory $VecFillCopyWith(VecFill value, $Res Function(VecFill) then) =
      _$VecFillCopyWithImpl<$Res, VecFill>;
  @useResult
  $Res call({
    VecColor color,
    double opacity,
    VecBlendMode blendMode,
    VecGradient? gradient,
    VecPattern? pattern,
    String? imageAssetId,
    VecFillImageFit imageFit,
  });

  $VecColorCopyWith<$Res> get color;
  $VecPatternCopyWith<$Res>? get pattern;
}

/// @nodoc
class _$VecFillCopyWithImpl<$Res, $Val extends VecFill>
    implements $VecFillCopyWith<$Res> {
  _$VecFillCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VecFill
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? color = null,
    Object? opacity = null,
    Object? blendMode = null,
    Object? gradient = freezed,
    Object? pattern = freezed,
    Object? imageAssetId = freezed,
    Object? imageFit = null,
  }) {
    return _then(
      _value.copyWith(
            color: null == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as VecColor,
            opacity: null == opacity
                ? _value.opacity
                : opacity // ignore: cast_nullable_to_non_nullable
                      as double,
            blendMode: null == blendMode
                ? _value.blendMode
                : blendMode // ignore: cast_nullable_to_non_nullable
                      as VecBlendMode,
            gradient: freezed == gradient
                ? _value.gradient
                : gradient // ignore: cast_nullable_to_non_nullable
                      as VecGradient?,
            pattern: freezed == pattern
                ? _value.pattern
                : pattern // ignore: cast_nullable_to_non_nullable
                      as VecPattern?,
            imageAssetId: freezed == imageAssetId
                ? _value.imageAssetId
                : imageAssetId // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageFit: null == imageFit
                ? _value.imageFit
                : imageFit // ignore: cast_nullable_to_non_nullable
                      as VecFillImageFit,
          )
          as $Val,
    );
  }

  /// Create a copy of VecFill
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VecColorCopyWith<$Res> get color {
    return $VecColorCopyWith<$Res>(_value.color, (value) {
      return _then(_value.copyWith(color: value) as $Val);
    });
  }

  /// Create a copy of VecFill
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VecPatternCopyWith<$Res>? get pattern {
    if (_value.pattern == null) {
      return null;
    }

    return $VecPatternCopyWith<$Res>(_value.pattern!, (value) {
      return _then(_value.copyWith(pattern: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$VecFillImplCopyWith<$Res> implements $VecFillCopyWith<$Res> {
  factory _$$VecFillImplCopyWith(
    _$VecFillImpl value,
    $Res Function(_$VecFillImpl) then,
  ) = __$$VecFillImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    VecColor color,
    double opacity,
    VecBlendMode blendMode,
    VecGradient? gradient,
    VecPattern? pattern,
    String? imageAssetId,
    VecFillImageFit imageFit,
  });

  @override
  $VecColorCopyWith<$Res> get color;
  @override
  $VecPatternCopyWith<$Res>? get pattern;
}

/// @nodoc
class __$$VecFillImplCopyWithImpl<$Res>
    extends _$VecFillCopyWithImpl<$Res, _$VecFillImpl>
    implements _$$VecFillImplCopyWith<$Res> {
  __$$VecFillImplCopyWithImpl(
    _$VecFillImpl _value,
    $Res Function(_$VecFillImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VecFill
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? color = null,
    Object? opacity = null,
    Object? blendMode = null,
    Object? gradient = freezed,
    Object? pattern = freezed,
    Object? imageAssetId = freezed,
    Object? imageFit = null,
  }) {
    return _then(
      _$VecFillImpl(
        color: null == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as VecColor,
        opacity: null == opacity
            ? _value.opacity
            : opacity // ignore: cast_nullable_to_non_nullable
                  as double,
        blendMode: null == blendMode
            ? _value.blendMode
            : blendMode // ignore: cast_nullable_to_non_nullable
                  as VecBlendMode,
        gradient: freezed == gradient
            ? _value.gradient
            : gradient // ignore: cast_nullable_to_non_nullable
                  as VecGradient?,
        pattern: freezed == pattern
            ? _value.pattern
            : pattern // ignore: cast_nullable_to_non_nullable
                  as VecPattern?,
        imageAssetId: freezed == imageAssetId
            ? _value.imageAssetId
            : imageAssetId // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageFit: null == imageFit
            ? _value.imageFit
            : imageFit // ignore: cast_nullable_to_non_nullable
                  as VecFillImageFit,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VecFillImpl implements _VecFill {
  const _$VecFillImpl({
    required this.color,
    this.opacity = 1.0,
    this.blendMode = VecBlendMode.normal,
    this.gradient,
    this.pattern,
    this.imageAssetId,
    this.imageFit = VecFillImageFit.cover,
  });

  factory _$VecFillImpl.fromJson(Map<String, dynamic> json) =>
      _$$VecFillImplFromJson(json);

  @override
  final VecColor color;
  @override
  @JsonKey()
  final double opacity;
  @override
  @JsonKey()
  final VecBlendMode blendMode;
  @override
  final VecGradient? gradient;
  @override
  final VecPattern? pattern;
  @override
  final String? imageAssetId;
  @override
  @JsonKey()
  final VecFillImageFit imageFit;

  @override
  String toString() {
    return 'VecFill(color: $color, opacity: $opacity, blendMode: $blendMode, gradient: $gradient, pattern: $pattern, imageAssetId: $imageAssetId, imageFit: $imageFit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VecFillImpl &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.opacity, opacity) || other.opacity == opacity) &&
            (identical(other.blendMode, blendMode) ||
                other.blendMode == blendMode) &&
            (identical(other.gradient, gradient) ||
                other.gradient == gradient) &&
            (identical(other.pattern, pattern) || other.pattern == pattern) &&
            (identical(other.imageAssetId, imageAssetId) ||
                other.imageAssetId == imageAssetId) &&
            (identical(other.imageFit, imageFit) ||
                other.imageFit == imageFit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    color,
    opacity,
    blendMode,
    gradient,
    pattern,
    imageAssetId,
    imageFit,
  );

  /// Create a copy of VecFill
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VecFillImplCopyWith<_$VecFillImpl> get copyWith =>
      __$$VecFillImplCopyWithImpl<_$VecFillImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VecFillImplToJson(this);
  }
}

abstract class _VecFill implements VecFill {
  const factory _VecFill({
    required final VecColor color,
    final double opacity,
    final VecBlendMode blendMode,
    final VecGradient? gradient,
    final VecPattern? pattern,
    final String? imageAssetId,
    final VecFillImageFit imageFit,
  }) = _$VecFillImpl;

  factory _VecFill.fromJson(Map<String, dynamic> json) = _$VecFillImpl.fromJson;

  @override
  VecColor get color;
  @override
  double get opacity;
  @override
  VecBlendMode get blendMode;
  @override
  VecGradient? get gradient;
  @override
  VecPattern? get pattern;
  @override
  String? get imageAssetId;
  @override
  VecFillImageFit get imageFit;

  /// Create a copy of VecFill
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VecFillImplCopyWith<_$VecFillImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
