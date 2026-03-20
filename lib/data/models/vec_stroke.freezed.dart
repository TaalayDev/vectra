// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vec_stroke.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VecStroke _$VecStrokeFromJson(Map<String, dynamic> json) {
  return _VecStroke.fromJson(json);
}

/// @nodoc
mixin _$VecStroke {
  VecColor get color => throw _privateConstructorUsedError;
  double get width => throw _privateConstructorUsedError;
  double get opacity => throw _privateConstructorUsedError;
  VecBlendMode get blendMode => throw _privateConstructorUsedError;
  VecStrokeCap get cap => throw _privateConstructorUsedError;
  VecStrokeJoin get join => throw _privateConstructorUsedError;
  VecStrokeAlign get align => throw _privateConstructorUsedError;
  List<double> get dashPattern => throw _privateConstructorUsedError;
  double get dashOffset => throw _privateConstructorUsedError;
  VecWidthProfile? get widthProfile => throw _privateConstructorUsedError;

  /// Serializes this VecStroke to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VecStroke
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VecStrokeCopyWith<VecStroke> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VecStrokeCopyWith<$Res> {
  factory $VecStrokeCopyWith(VecStroke value, $Res Function(VecStroke) then) =
      _$VecStrokeCopyWithImpl<$Res, VecStroke>;
  @useResult
  $Res call({
    VecColor color,
    double width,
    double opacity,
    VecBlendMode blendMode,
    VecStrokeCap cap,
    VecStrokeJoin join,
    VecStrokeAlign align,
    List<double> dashPattern,
    double dashOffset,
    VecWidthProfile? widthProfile,
  });

  $VecColorCopyWith<$Res> get color;
  $VecWidthProfileCopyWith<$Res>? get widthProfile;
}

/// @nodoc
class _$VecStrokeCopyWithImpl<$Res, $Val extends VecStroke>
    implements $VecStrokeCopyWith<$Res> {
  _$VecStrokeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VecStroke
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? color = null,
    Object? width = null,
    Object? opacity = null,
    Object? blendMode = null,
    Object? cap = null,
    Object? join = null,
    Object? align = null,
    Object? dashPattern = null,
    Object? dashOffset = null,
    Object? widthProfile = freezed,
  }) {
    return _then(
      _value.copyWith(
            color: null == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as VecColor,
            width: null == width
                ? _value.width
                : width // ignore: cast_nullable_to_non_nullable
                      as double,
            opacity: null == opacity
                ? _value.opacity
                : opacity // ignore: cast_nullable_to_non_nullable
                      as double,
            blendMode: null == blendMode
                ? _value.blendMode
                : blendMode // ignore: cast_nullable_to_non_nullable
                      as VecBlendMode,
            cap: null == cap
                ? _value.cap
                : cap // ignore: cast_nullable_to_non_nullable
                      as VecStrokeCap,
            join: null == join
                ? _value.join
                : join // ignore: cast_nullable_to_non_nullable
                      as VecStrokeJoin,
            align: null == align
                ? _value.align
                : align // ignore: cast_nullable_to_non_nullable
                      as VecStrokeAlign,
            dashPattern: null == dashPattern
                ? _value.dashPattern
                : dashPattern // ignore: cast_nullable_to_non_nullable
                      as List<double>,
            dashOffset: null == dashOffset
                ? _value.dashOffset
                : dashOffset // ignore: cast_nullable_to_non_nullable
                      as double,
            widthProfile: freezed == widthProfile
                ? _value.widthProfile
                : widthProfile // ignore: cast_nullable_to_non_nullable
                      as VecWidthProfile?,
          )
          as $Val,
    );
  }

  /// Create a copy of VecStroke
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VecColorCopyWith<$Res> get color {
    return $VecColorCopyWith<$Res>(_value.color, (value) {
      return _then(_value.copyWith(color: value) as $Val);
    });
  }

  /// Create a copy of VecStroke
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VecWidthProfileCopyWith<$Res>? get widthProfile {
    if (_value.widthProfile == null) {
      return null;
    }

    return $VecWidthProfileCopyWith<$Res>(_value.widthProfile!, (value) {
      return _then(_value.copyWith(widthProfile: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$VecStrokeImplCopyWith<$Res>
    implements $VecStrokeCopyWith<$Res> {
  factory _$$VecStrokeImplCopyWith(
    _$VecStrokeImpl value,
    $Res Function(_$VecStrokeImpl) then,
  ) = __$$VecStrokeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    VecColor color,
    double width,
    double opacity,
    VecBlendMode blendMode,
    VecStrokeCap cap,
    VecStrokeJoin join,
    VecStrokeAlign align,
    List<double> dashPattern,
    double dashOffset,
    VecWidthProfile? widthProfile,
  });

  @override
  $VecColorCopyWith<$Res> get color;
  @override
  $VecWidthProfileCopyWith<$Res>? get widthProfile;
}

/// @nodoc
class __$$VecStrokeImplCopyWithImpl<$Res>
    extends _$VecStrokeCopyWithImpl<$Res, _$VecStrokeImpl>
    implements _$$VecStrokeImplCopyWith<$Res> {
  __$$VecStrokeImplCopyWithImpl(
    _$VecStrokeImpl _value,
    $Res Function(_$VecStrokeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VecStroke
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? color = null,
    Object? width = null,
    Object? opacity = null,
    Object? blendMode = null,
    Object? cap = null,
    Object? join = null,
    Object? align = null,
    Object? dashPattern = null,
    Object? dashOffset = null,
    Object? widthProfile = freezed,
  }) {
    return _then(
      _$VecStrokeImpl(
        color: null == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as VecColor,
        width: null == width
            ? _value.width
            : width // ignore: cast_nullable_to_non_nullable
                  as double,
        opacity: null == opacity
            ? _value.opacity
            : opacity // ignore: cast_nullable_to_non_nullable
                  as double,
        blendMode: null == blendMode
            ? _value.blendMode
            : blendMode // ignore: cast_nullable_to_non_nullable
                  as VecBlendMode,
        cap: null == cap
            ? _value.cap
            : cap // ignore: cast_nullable_to_non_nullable
                  as VecStrokeCap,
        join: null == join
            ? _value.join
            : join // ignore: cast_nullable_to_non_nullable
                  as VecStrokeJoin,
        align: null == align
            ? _value.align
            : align // ignore: cast_nullable_to_non_nullable
                  as VecStrokeAlign,
        dashPattern: null == dashPattern
            ? _value._dashPattern
            : dashPattern // ignore: cast_nullable_to_non_nullable
                  as List<double>,
        dashOffset: null == dashOffset
            ? _value.dashOffset
            : dashOffset // ignore: cast_nullable_to_non_nullable
                  as double,
        widthProfile: freezed == widthProfile
            ? _value.widthProfile
            : widthProfile // ignore: cast_nullable_to_non_nullable
                  as VecWidthProfile?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VecStrokeImpl implements _VecStroke {
  const _$VecStrokeImpl({
    required this.color,
    this.width = 1.0,
    this.opacity = 1.0,
    this.blendMode = VecBlendMode.normal,
    this.cap = VecStrokeCap.butt,
    this.join = VecStrokeJoin.miter,
    this.align = VecStrokeAlign.center,
    final List<double> dashPattern = const [],
    this.dashOffset = 0,
    this.widthProfile,
  }) : _dashPattern = dashPattern;

  factory _$VecStrokeImpl.fromJson(Map<String, dynamic> json) =>
      _$$VecStrokeImplFromJson(json);

  @override
  final VecColor color;
  @override
  @JsonKey()
  final double width;
  @override
  @JsonKey()
  final double opacity;
  @override
  @JsonKey()
  final VecBlendMode blendMode;
  @override
  @JsonKey()
  final VecStrokeCap cap;
  @override
  @JsonKey()
  final VecStrokeJoin join;
  @override
  @JsonKey()
  final VecStrokeAlign align;
  final List<double> _dashPattern;
  @override
  @JsonKey()
  List<double> get dashPattern {
    if (_dashPattern is EqualUnmodifiableListView) return _dashPattern;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dashPattern);
  }

  @override
  @JsonKey()
  final double dashOffset;
  @override
  final VecWidthProfile? widthProfile;

  @override
  String toString() {
    return 'VecStroke(color: $color, width: $width, opacity: $opacity, blendMode: $blendMode, cap: $cap, join: $join, align: $align, dashPattern: $dashPattern, dashOffset: $dashOffset, widthProfile: $widthProfile)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VecStrokeImpl &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.opacity, opacity) || other.opacity == opacity) &&
            (identical(other.blendMode, blendMode) ||
                other.blendMode == blendMode) &&
            (identical(other.cap, cap) || other.cap == cap) &&
            (identical(other.join, join) || other.join == join) &&
            (identical(other.align, align) || other.align == align) &&
            const DeepCollectionEquality().equals(
              other._dashPattern,
              _dashPattern,
            ) &&
            (identical(other.dashOffset, dashOffset) ||
                other.dashOffset == dashOffset) &&
            (identical(other.widthProfile, widthProfile) ||
                other.widthProfile == widthProfile));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    color,
    width,
    opacity,
    blendMode,
    cap,
    join,
    align,
    const DeepCollectionEquality().hash(_dashPattern),
    dashOffset,
    widthProfile,
  );

  /// Create a copy of VecStroke
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VecStrokeImplCopyWith<_$VecStrokeImpl> get copyWith =>
      __$$VecStrokeImplCopyWithImpl<_$VecStrokeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VecStrokeImplToJson(this);
  }
}

abstract class _VecStroke implements VecStroke {
  const factory _VecStroke({
    required final VecColor color,
    final double width,
    final double opacity,
    final VecBlendMode blendMode,
    final VecStrokeCap cap,
    final VecStrokeJoin join,
    final VecStrokeAlign align,
    final List<double> dashPattern,
    final double dashOffset,
    final VecWidthProfile? widthProfile,
  }) = _$VecStrokeImpl;

  factory _VecStroke.fromJson(Map<String, dynamic> json) =
      _$VecStrokeImpl.fromJson;

  @override
  VecColor get color;
  @override
  double get width;
  @override
  double get opacity;
  @override
  VecBlendMode get blendMode;
  @override
  VecStrokeCap get cap;
  @override
  VecStrokeJoin get join;
  @override
  VecStrokeAlign get align;
  @override
  List<double> get dashPattern;
  @override
  double get dashOffset;
  @override
  VecWidthProfile? get widthProfile;

  /// Create a copy of VecStroke
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VecStrokeImplCopyWith<_$VecStrokeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
