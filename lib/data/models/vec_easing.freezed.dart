// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vec_easing.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VecEasing _$VecEasingFromJson(Map<String, dynamic> json) {
  switch (json['type']) {
    case 'preset':
      return VecPresetEasing.fromJson(json);
    case 'cubicBezier':
      return VecCubicBezierEasing.fromJson(json);

    default:
      throw CheckedFromJsonException(
        json,
        'type',
        'VecEasing',
        'Invalid union type "${json['type']}"!',
      );
  }
}

/// @nodoc
mixin _$VecEasing {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(VecEasingPreset preset) preset,
    required TResult Function(double x1, double y1, double x2, double y2)
    cubicBezier,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(VecEasingPreset preset)? preset,
    TResult? Function(double x1, double y1, double x2, double y2)? cubicBezier,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(VecEasingPreset preset)? preset,
    TResult Function(double x1, double y1, double x2, double y2)? cubicBezier,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VecPresetEasing value) preset,
    required TResult Function(VecCubicBezierEasing value) cubicBezier,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VecPresetEasing value)? preset,
    TResult? Function(VecCubicBezierEasing value)? cubicBezier,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VecPresetEasing value)? preset,
    TResult Function(VecCubicBezierEasing value)? cubicBezier,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this VecEasing to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VecEasingCopyWith<$Res> {
  factory $VecEasingCopyWith(VecEasing value, $Res Function(VecEasing) then) =
      _$VecEasingCopyWithImpl<$Res, VecEasing>;
}

/// @nodoc
class _$VecEasingCopyWithImpl<$Res, $Val extends VecEasing>
    implements $VecEasingCopyWith<$Res> {
  _$VecEasingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VecEasing
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$VecPresetEasingImplCopyWith<$Res> {
  factory _$$VecPresetEasingImplCopyWith(
    _$VecPresetEasingImpl value,
    $Res Function(_$VecPresetEasingImpl) then,
  ) = __$$VecPresetEasingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({VecEasingPreset preset});
}

/// @nodoc
class __$$VecPresetEasingImplCopyWithImpl<$Res>
    extends _$VecEasingCopyWithImpl<$Res, _$VecPresetEasingImpl>
    implements _$$VecPresetEasingImplCopyWith<$Res> {
  __$$VecPresetEasingImplCopyWithImpl(
    _$VecPresetEasingImpl _value,
    $Res Function(_$VecPresetEasingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VecEasing
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? preset = null}) {
    return _then(
      _$VecPresetEasingImpl(
        preset: null == preset
            ? _value.preset
            : preset // ignore: cast_nullable_to_non_nullable
                  as VecEasingPreset,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VecPresetEasingImpl implements VecPresetEasing {
  const _$VecPresetEasingImpl({required this.preset, final String? $type})
    : $type = $type ?? 'preset';

  factory _$VecPresetEasingImpl.fromJson(Map<String, dynamic> json) =>
      _$$VecPresetEasingImplFromJson(json);

  @override
  final VecEasingPreset preset;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'VecEasing.preset(preset: $preset)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VecPresetEasingImpl &&
            (identical(other.preset, preset) || other.preset == preset));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, preset);

  /// Create a copy of VecEasing
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VecPresetEasingImplCopyWith<_$VecPresetEasingImpl> get copyWith =>
      __$$VecPresetEasingImplCopyWithImpl<_$VecPresetEasingImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(VecEasingPreset preset) preset,
    required TResult Function(double x1, double y1, double x2, double y2)
    cubicBezier,
  }) {
    return preset(this.preset);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(VecEasingPreset preset)? preset,
    TResult? Function(double x1, double y1, double x2, double y2)? cubicBezier,
  }) {
    return preset?.call(this.preset);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(VecEasingPreset preset)? preset,
    TResult Function(double x1, double y1, double x2, double y2)? cubicBezier,
    required TResult orElse(),
  }) {
    if (preset != null) {
      return preset(this.preset);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VecPresetEasing value) preset,
    required TResult Function(VecCubicBezierEasing value) cubicBezier,
  }) {
    return preset(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VecPresetEasing value)? preset,
    TResult? Function(VecCubicBezierEasing value)? cubicBezier,
  }) {
    return preset?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VecPresetEasing value)? preset,
    TResult Function(VecCubicBezierEasing value)? cubicBezier,
    required TResult orElse(),
  }) {
    if (preset != null) {
      return preset(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$VecPresetEasingImplToJson(this);
  }
}

abstract class VecPresetEasing implements VecEasing {
  const factory VecPresetEasing({required final VecEasingPreset preset}) =
      _$VecPresetEasingImpl;

  factory VecPresetEasing.fromJson(Map<String, dynamic> json) =
      _$VecPresetEasingImpl.fromJson;

  VecEasingPreset get preset;

  /// Create a copy of VecEasing
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VecPresetEasingImplCopyWith<_$VecPresetEasingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$VecCubicBezierEasingImplCopyWith<$Res> {
  factory _$$VecCubicBezierEasingImplCopyWith(
    _$VecCubicBezierEasingImpl value,
    $Res Function(_$VecCubicBezierEasingImpl) then,
  ) = __$$VecCubicBezierEasingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({double x1, double y1, double x2, double y2});
}

/// @nodoc
class __$$VecCubicBezierEasingImplCopyWithImpl<$Res>
    extends _$VecEasingCopyWithImpl<$Res, _$VecCubicBezierEasingImpl>
    implements _$$VecCubicBezierEasingImplCopyWith<$Res> {
  __$$VecCubicBezierEasingImplCopyWithImpl(
    _$VecCubicBezierEasingImpl _value,
    $Res Function(_$VecCubicBezierEasingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VecEasing
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? x1 = null,
    Object? y1 = null,
    Object? x2 = null,
    Object? y2 = null,
  }) {
    return _then(
      _$VecCubicBezierEasingImpl(
        x1: null == x1
            ? _value.x1
            : x1 // ignore: cast_nullable_to_non_nullable
                  as double,
        y1: null == y1
            ? _value.y1
            : y1 // ignore: cast_nullable_to_non_nullable
                  as double,
        x2: null == x2
            ? _value.x2
            : x2 // ignore: cast_nullable_to_non_nullable
                  as double,
        y2: null == y2
            ? _value.y2
            : y2 // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VecCubicBezierEasingImpl implements VecCubicBezierEasing {
  const _$VecCubicBezierEasingImpl({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    final String? $type,
  }) : $type = $type ?? 'cubicBezier';

  factory _$VecCubicBezierEasingImpl.fromJson(Map<String, dynamic> json) =>
      _$$VecCubicBezierEasingImplFromJson(json);

  @override
  final double x1;
  @override
  final double y1;
  @override
  final double x2;
  @override
  final double y2;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'VecEasing.cubicBezier(x1: $x1, y1: $y1, x2: $x2, y2: $y2)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VecCubicBezierEasingImpl &&
            (identical(other.x1, x1) || other.x1 == x1) &&
            (identical(other.y1, y1) || other.y1 == y1) &&
            (identical(other.x2, x2) || other.x2 == x2) &&
            (identical(other.y2, y2) || other.y2 == y2));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, x1, y1, x2, y2);

  /// Create a copy of VecEasing
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VecCubicBezierEasingImplCopyWith<_$VecCubicBezierEasingImpl>
  get copyWith =>
      __$$VecCubicBezierEasingImplCopyWithImpl<_$VecCubicBezierEasingImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(VecEasingPreset preset) preset,
    required TResult Function(double x1, double y1, double x2, double y2)
    cubicBezier,
  }) {
    return cubicBezier(x1, y1, x2, y2);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(VecEasingPreset preset)? preset,
    TResult? Function(double x1, double y1, double x2, double y2)? cubicBezier,
  }) {
    return cubicBezier?.call(x1, y1, x2, y2);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(VecEasingPreset preset)? preset,
    TResult Function(double x1, double y1, double x2, double y2)? cubicBezier,
    required TResult orElse(),
  }) {
    if (cubicBezier != null) {
      return cubicBezier(x1, y1, x2, y2);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VecPresetEasing value) preset,
    required TResult Function(VecCubicBezierEasing value) cubicBezier,
  }) {
    return cubicBezier(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VecPresetEasing value)? preset,
    TResult? Function(VecCubicBezierEasing value)? cubicBezier,
  }) {
    return cubicBezier?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VecPresetEasing value)? preset,
    TResult Function(VecCubicBezierEasing value)? cubicBezier,
    required TResult orElse(),
  }) {
    if (cubicBezier != null) {
      return cubicBezier(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$VecCubicBezierEasingImplToJson(this);
  }
}

abstract class VecCubicBezierEasing implements VecEasing {
  const factory VecCubicBezierEasing({
    required final double x1,
    required final double y1,
    required final double x2,
    required final double y2,
  }) = _$VecCubicBezierEasingImpl;

  factory VecCubicBezierEasing.fromJson(Map<String, dynamic> json) =
      _$VecCubicBezierEasingImpl.fromJson;

  double get x1;
  double get y1;
  double get x2;
  double get y2;

  /// Create a copy of VecEasing
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VecCubicBezierEasingImplCopyWith<_$VecCubicBezierEasingImpl>
  get copyWith => throw _privateConstructorUsedError;
}
