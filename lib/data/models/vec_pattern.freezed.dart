// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vec_pattern.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VecPattern _$VecPatternFromJson(Map<String, dynamic> json) {
  return _VecPattern.fromJson(json);
}

/// @nodoc
mixin _$VecPattern {
  VecPatternType get type => throw _privateConstructorUsedError;
  double get scale => throw _privateConstructorUsedError;
  double get rotation => throw _privateConstructorUsedError;
  VecColor? get backgroundColor => throw _privateConstructorUsedError;
  double get thickness => throw _privateConstructorUsedError;
  double get spacing => throw _privateConstructorUsedError;
  String? get tileAssetId => throw _privateConstructorUsedError;

  /// Serializes this VecPattern to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VecPattern
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VecPatternCopyWith<VecPattern> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VecPatternCopyWith<$Res> {
  factory $VecPatternCopyWith(
    VecPattern value,
    $Res Function(VecPattern) then,
  ) = _$VecPatternCopyWithImpl<$Res, VecPattern>;
  @useResult
  $Res call({
    VecPatternType type,
    double scale,
    double rotation,
    VecColor? backgroundColor,
    double thickness,
    double spacing,
    String? tileAssetId,
  });

  $VecColorCopyWith<$Res>? get backgroundColor;
}

/// @nodoc
class _$VecPatternCopyWithImpl<$Res, $Val extends VecPattern>
    implements $VecPatternCopyWith<$Res> {
  _$VecPatternCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VecPattern
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? scale = null,
    Object? rotation = null,
    Object? backgroundColor = freezed,
    Object? thickness = null,
    Object? spacing = null,
    Object? tileAssetId = freezed,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as VecPatternType,
            scale: null == scale
                ? _value.scale
                : scale // ignore: cast_nullable_to_non_nullable
                      as double,
            rotation: null == rotation
                ? _value.rotation
                : rotation // ignore: cast_nullable_to_non_nullable
                      as double,
            backgroundColor: freezed == backgroundColor
                ? _value.backgroundColor
                : backgroundColor // ignore: cast_nullable_to_non_nullable
                      as VecColor?,
            thickness: null == thickness
                ? _value.thickness
                : thickness // ignore: cast_nullable_to_non_nullable
                      as double,
            spacing: null == spacing
                ? _value.spacing
                : spacing // ignore: cast_nullable_to_non_nullable
                      as double,
            tileAssetId: freezed == tileAssetId
                ? _value.tileAssetId
                : tileAssetId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of VecPattern
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VecColorCopyWith<$Res>? get backgroundColor {
    if (_value.backgroundColor == null) {
      return null;
    }

    return $VecColorCopyWith<$Res>(_value.backgroundColor!, (value) {
      return _then(_value.copyWith(backgroundColor: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$VecPatternImplCopyWith<$Res>
    implements $VecPatternCopyWith<$Res> {
  factory _$$VecPatternImplCopyWith(
    _$VecPatternImpl value,
    $Res Function(_$VecPatternImpl) then,
  ) = __$$VecPatternImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    VecPatternType type,
    double scale,
    double rotation,
    VecColor? backgroundColor,
    double thickness,
    double spacing,
    String? tileAssetId,
  });

  @override
  $VecColorCopyWith<$Res>? get backgroundColor;
}

/// @nodoc
class __$$VecPatternImplCopyWithImpl<$Res>
    extends _$VecPatternCopyWithImpl<$Res, _$VecPatternImpl>
    implements _$$VecPatternImplCopyWith<$Res> {
  __$$VecPatternImplCopyWithImpl(
    _$VecPatternImpl _value,
    $Res Function(_$VecPatternImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VecPattern
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? scale = null,
    Object? rotation = null,
    Object? backgroundColor = freezed,
    Object? thickness = null,
    Object? spacing = null,
    Object? tileAssetId = freezed,
  }) {
    return _then(
      _$VecPatternImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as VecPatternType,
        scale: null == scale
            ? _value.scale
            : scale // ignore: cast_nullable_to_non_nullable
                  as double,
        rotation: null == rotation
            ? _value.rotation
            : rotation // ignore: cast_nullable_to_non_nullable
                  as double,
        backgroundColor: freezed == backgroundColor
            ? _value.backgroundColor
            : backgroundColor // ignore: cast_nullable_to_non_nullable
                  as VecColor?,
        thickness: null == thickness
            ? _value.thickness
            : thickness // ignore: cast_nullable_to_non_nullable
                  as double,
        spacing: null == spacing
            ? _value.spacing
            : spacing // ignore: cast_nullable_to_non_nullable
                  as double,
        tileAssetId: freezed == tileAssetId
            ? _value.tileAssetId
            : tileAssetId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VecPatternImpl implements _VecPattern {
  const _$VecPatternImpl({
    this.type = VecPatternType.dots,
    this.scale = 10.0,
    this.rotation = 0.0,
    this.backgroundColor,
    this.thickness = 2.0,
    this.spacing = 5.0,
    this.tileAssetId,
  });

  factory _$VecPatternImpl.fromJson(Map<String, dynamic> json) =>
      _$$VecPatternImplFromJson(json);

  @override
  @JsonKey()
  final VecPatternType type;
  @override
  @JsonKey()
  final double scale;
  @override
  @JsonKey()
  final double rotation;
  @override
  final VecColor? backgroundColor;
  @override
  @JsonKey()
  final double thickness;
  @override
  @JsonKey()
  final double spacing;
  @override
  final String? tileAssetId;

  @override
  String toString() {
    return 'VecPattern(type: $type, scale: $scale, rotation: $rotation, backgroundColor: $backgroundColor, thickness: $thickness, spacing: $spacing, tileAssetId: $tileAssetId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VecPatternImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.scale, scale) || other.scale == scale) &&
            (identical(other.rotation, rotation) ||
                other.rotation == rotation) &&
            (identical(other.backgroundColor, backgroundColor) ||
                other.backgroundColor == backgroundColor) &&
            (identical(other.thickness, thickness) ||
                other.thickness == thickness) &&
            (identical(other.spacing, spacing) || other.spacing == spacing) &&
            (identical(other.tileAssetId, tileAssetId) ||
                other.tileAssetId == tileAssetId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    scale,
    rotation,
    backgroundColor,
    thickness,
    spacing,
    tileAssetId,
  );

  /// Create a copy of VecPattern
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VecPatternImplCopyWith<_$VecPatternImpl> get copyWith =>
      __$$VecPatternImplCopyWithImpl<_$VecPatternImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VecPatternImplToJson(this);
  }
}

abstract class _VecPattern implements VecPattern {
  const factory _VecPattern({
    final VecPatternType type,
    final double scale,
    final double rotation,
    final VecColor? backgroundColor,
    final double thickness,
    final double spacing,
    final String? tileAssetId,
  }) = _$VecPatternImpl;

  factory _VecPattern.fromJson(Map<String, dynamic> json) =
      _$VecPatternImpl.fromJson;

  @override
  VecPatternType get type;
  @override
  double get scale;
  @override
  double get rotation;
  @override
  VecColor? get backgroundColor;
  @override
  double get thickness;
  @override
  double get spacing;
  @override
  String? get tileAssetId;

  /// Create a copy of VecPattern
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VecPatternImplCopyWith<_$VecPatternImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
