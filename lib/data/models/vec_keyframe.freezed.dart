// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vec_keyframe.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VecKeyframe _$VecKeyframeFromJson(Map<String, dynamic> json) {
  return _VecKeyframe.fromJson(json);
}

/// @nodoc
mixin _$VecKeyframe {
  int get frame => throw _privateConstructorUsedError;
  VecKeyframeType get type => throw _privateConstructorUsedError;
  VecTweenType get tweenType =>
      throw _privateConstructorUsedError; // Full-snapshot values (set when adding a keyframe in the timeline)
  VecTransform? get transform => throw _privateConstructorUsedError;
  List<VecFill>? get fills => throw _privateConstructorUsedError;
  List<VecStroke>? get strokes =>
      throw _privateConstructorUsedError; // General easing applied to all snapshot properties (transform/opacity/fills/strokes)
  VecEasing? get easing =>
      throw _privateConstructorUsedError; // Per-property values (null = not keyed at this frame)
  VecPoint? get position => throw _privateConstructorUsedError;
  VecPoint? get scale => throw _privateConstructorUsedError;
  double? get rotation => throw _privateConstructorUsedError;
  double? get opacity => throw _privateConstructorUsedError;
  VecColor? get fillColor => throw _privateConstructorUsedError;
  VecColor? get strokeColor => throw _privateConstructorUsedError;
  List<VecPathNode>? get pathNodes =>
      throw _privateConstructorUsedError; // Per-property easing (null = linear)
  VecEasing? get positionEasing => throw _privateConstructorUsedError;
  VecEasing? get scaleEasing => throw _privateConstructorUsedError;
  VecEasing? get rotationEasing => throw _privateConstructorUsedError;
  VecEasing? get opacityEasing => throw _privateConstructorUsedError;
  VecEasing? get fillColorEasing => throw _privateConstructorUsedError;
  VecEasing? get strokeColorEasing => throw _privateConstructorUsedError;
  VecEasing? get pathEasing =>
      throw _privateConstructorUsedError; // Shape hints for shape tweens
  List<VecShapeHint> get shapeHints => throw _privateConstructorUsedError;

  /// Serializes this VecKeyframe to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VecKeyframe
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VecKeyframeCopyWith<VecKeyframe> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VecKeyframeCopyWith<$Res> {
  factory $VecKeyframeCopyWith(
    VecKeyframe value,
    $Res Function(VecKeyframe) then,
  ) = _$VecKeyframeCopyWithImpl<$Res, VecKeyframe>;
  @useResult
  $Res call({
    int frame,
    VecKeyframeType type,
    VecTweenType tweenType,
    VecTransform? transform,
    List<VecFill>? fills,
    List<VecStroke>? strokes,
    VecEasing? easing,
    VecPoint? position,
    VecPoint? scale,
    double? rotation,
    double? opacity,
    VecColor? fillColor,
    VecColor? strokeColor,
    List<VecPathNode>? pathNodes,
    VecEasing? positionEasing,
    VecEasing? scaleEasing,
    VecEasing? rotationEasing,
    VecEasing? opacityEasing,
    VecEasing? fillColorEasing,
    VecEasing? strokeColorEasing,
    VecEasing? pathEasing,
    List<VecShapeHint> shapeHints,
  });

  $VecTransformCopyWith<$Res>? get transform;
  $VecEasingCopyWith<$Res>? get easing;
  $VecPointCopyWith<$Res>? get position;
  $VecPointCopyWith<$Res>? get scale;
  $VecColorCopyWith<$Res>? get fillColor;
  $VecColorCopyWith<$Res>? get strokeColor;
  $VecEasingCopyWith<$Res>? get positionEasing;
  $VecEasingCopyWith<$Res>? get scaleEasing;
  $VecEasingCopyWith<$Res>? get rotationEasing;
  $VecEasingCopyWith<$Res>? get opacityEasing;
  $VecEasingCopyWith<$Res>? get fillColorEasing;
  $VecEasingCopyWith<$Res>? get strokeColorEasing;
  $VecEasingCopyWith<$Res>? get pathEasing;
}

/// @nodoc
class _$VecKeyframeCopyWithImpl<$Res, $Val extends VecKeyframe>
    implements $VecKeyframeCopyWith<$Res> {
  _$VecKeyframeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VecKeyframe
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? frame = null,
    Object? type = null,
    Object? tweenType = null,
    Object? transform = freezed,
    Object? fills = freezed,
    Object? strokes = freezed,
    Object? easing = freezed,
    Object? position = freezed,
    Object? scale = freezed,
    Object? rotation = freezed,
    Object? opacity = freezed,
    Object? fillColor = freezed,
    Object? strokeColor = freezed,
    Object? pathNodes = freezed,
    Object? positionEasing = freezed,
    Object? scaleEasing = freezed,
    Object? rotationEasing = freezed,
    Object? opacityEasing = freezed,
    Object? fillColorEasing = freezed,
    Object? strokeColorEasing = freezed,
    Object? pathEasing = freezed,
    Object? shapeHints = null,
  }) {
    return _then(
      _value.copyWith(
            frame: null == frame
                ? _value.frame
                : frame // ignore: cast_nullable_to_non_nullable
                      as int,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as VecKeyframeType,
            tweenType: null == tweenType
                ? _value.tweenType
                : tweenType // ignore: cast_nullable_to_non_nullable
                      as VecTweenType,
            transform: freezed == transform
                ? _value.transform
                : transform // ignore: cast_nullable_to_non_nullable
                      as VecTransform?,
            fills: freezed == fills
                ? _value.fills
                : fills // ignore: cast_nullable_to_non_nullable
                      as List<VecFill>?,
            strokes: freezed == strokes
                ? _value.strokes
                : strokes // ignore: cast_nullable_to_non_nullable
                      as List<VecStroke>?,
            easing: freezed == easing
                ? _value.easing
                : easing // ignore: cast_nullable_to_non_nullable
                      as VecEasing?,
            position: freezed == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                      as VecPoint?,
            scale: freezed == scale
                ? _value.scale
                : scale // ignore: cast_nullable_to_non_nullable
                      as VecPoint?,
            rotation: freezed == rotation
                ? _value.rotation
                : rotation // ignore: cast_nullable_to_non_nullable
                      as double?,
            opacity: freezed == opacity
                ? _value.opacity
                : opacity // ignore: cast_nullable_to_non_nullable
                      as double?,
            fillColor: freezed == fillColor
                ? _value.fillColor
                : fillColor // ignore: cast_nullable_to_non_nullable
                      as VecColor?,
            strokeColor: freezed == strokeColor
                ? _value.strokeColor
                : strokeColor // ignore: cast_nullable_to_non_nullable
                      as VecColor?,
            pathNodes: freezed == pathNodes
                ? _value.pathNodes
                : pathNodes // ignore: cast_nullable_to_non_nullable
                      as List<VecPathNode>?,
            positionEasing: freezed == positionEasing
                ? _value.positionEasing
                : positionEasing // ignore: cast_nullable_to_non_nullable
                      as VecEasing?,
            scaleEasing: freezed == scaleEasing
                ? _value.scaleEasing
                : scaleEasing // ignore: cast_nullable_to_non_nullable
                      as VecEasing?,
            rotationEasing: freezed == rotationEasing
                ? _value.rotationEasing
                : rotationEasing // ignore: cast_nullable_to_non_nullable
                      as VecEasing?,
            opacityEasing: freezed == opacityEasing
                ? _value.opacityEasing
                : opacityEasing // ignore: cast_nullable_to_non_nullable
                      as VecEasing?,
            fillColorEasing: freezed == fillColorEasing
                ? _value.fillColorEasing
                : fillColorEasing // ignore: cast_nullable_to_non_nullable
                      as VecEasing?,
            strokeColorEasing: freezed == strokeColorEasing
                ? _value.strokeColorEasing
                : strokeColorEasing // ignore: cast_nullable_to_non_nullable
                      as VecEasing?,
            pathEasing: freezed == pathEasing
                ? _value.pathEasing
                : pathEasing // ignore: cast_nullable_to_non_nullable
                      as VecEasing?,
            shapeHints: null == shapeHints
                ? _value.shapeHints
                : shapeHints // ignore: cast_nullable_to_non_nullable
                      as List<VecShapeHint>,
          )
          as $Val,
    );
  }

  /// Create a copy of VecKeyframe
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VecTransformCopyWith<$Res>? get transform {
    if (_value.transform == null) {
      return null;
    }

    return $VecTransformCopyWith<$Res>(_value.transform!, (value) {
      return _then(_value.copyWith(transform: value) as $Val);
    });
  }

  /// Create a copy of VecKeyframe
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VecEasingCopyWith<$Res>? get easing {
    if (_value.easing == null) {
      return null;
    }

    return $VecEasingCopyWith<$Res>(_value.easing!, (value) {
      return _then(_value.copyWith(easing: value) as $Val);
    });
  }

  /// Create a copy of VecKeyframe
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VecPointCopyWith<$Res>? get position {
    if (_value.position == null) {
      return null;
    }

    return $VecPointCopyWith<$Res>(_value.position!, (value) {
      return _then(_value.copyWith(position: value) as $Val);
    });
  }

  /// Create a copy of VecKeyframe
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VecPointCopyWith<$Res>? get scale {
    if (_value.scale == null) {
      return null;
    }

    return $VecPointCopyWith<$Res>(_value.scale!, (value) {
      return _then(_value.copyWith(scale: value) as $Val);
    });
  }

  /// Create a copy of VecKeyframe
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VecColorCopyWith<$Res>? get fillColor {
    if (_value.fillColor == null) {
      return null;
    }

    return $VecColorCopyWith<$Res>(_value.fillColor!, (value) {
      return _then(_value.copyWith(fillColor: value) as $Val);
    });
  }

  /// Create a copy of VecKeyframe
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VecColorCopyWith<$Res>? get strokeColor {
    if (_value.strokeColor == null) {
      return null;
    }

    return $VecColorCopyWith<$Res>(_value.strokeColor!, (value) {
      return _then(_value.copyWith(strokeColor: value) as $Val);
    });
  }

  /// Create a copy of VecKeyframe
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VecEasingCopyWith<$Res>? get positionEasing {
    if (_value.positionEasing == null) {
      return null;
    }

    return $VecEasingCopyWith<$Res>(_value.positionEasing!, (value) {
      return _then(_value.copyWith(positionEasing: value) as $Val);
    });
  }

  /// Create a copy of VecKeyframe
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VecEasingCopyWith<$Res>? get scaleEasing {
    if (_value.scaleEasing == null) {
      return null;
    }

    return $VecEasingCopyWith<$Res>(_value.scaleEasing!, (value) {
      return _then(_value.copyWith(scaleEasing: value) as $Val);
    });
  }

  /// Create a copy of VecKeyframe
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VecEasingCopyWith<$Res>? get rotationEasing {
    if (_value.rotationEasing == null) {
      return null;
    }

    return $VecEasingCopyWith<$Res>(_value.rotationEasing!, (value) {
      return _then(_value.copyWith(rotationEasing: value) as $Val);
    });
  }

  /// Create a copy of VecKeyframe
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VecEasingCopyWith<$Res>? get opacityEasing {
    if (_value.opacityEasing == null) {
      return null;
    }

    return $VecEasingCopyWith<$Res>(_value.opacityEasing!, (value) {
      return _then(_value.copyWith(opacityEasing: value) as $Val);
    });
  }

  /// Create a copy of VecKeyframe
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VecEasingCopyWith<$Res>? get fillColorEasing {
    if (_value.fillColorEasing == null) {
      return null;
    }

    return $VecEasingCopyWith<$Res>(_value.fillColorEasing!, (value) {
      return _then(_value.copyWith(fillColorEasing: value) as $Val);
    });
  }

  /// Create a copy of VecKeyframe
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VecEasingCopyWith<$Res>? get strokeColorEasing {
    if (_value.strokeColorEasing == null) {
      return null;
    }

    return $VecEasingCopyWith<$Res>(_value.strokeColorEasing!, (value) {
      return _then(_value.copyWith(strokeColorEasing: value) as $Val);
    });
  }

  /// Create a copy of VecKeyframe
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VecEasingCopyWith<$Res>? get pathEasing {
    if (_value.pathEasing == null) {
      return null;
    }

    return $VecEasingCopyWith<$Res>(_value.pathEasing!, (value) {
      return _then(_value.copyWith(pathEasing: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$VecKeyframeImplCopyWith<$Res>
    implements $VecKeyframeCopyWith<$Res> {
  factory _$$VecKeyframeImplCopyWith(
    _$VecKeyframeImpl value,
    $Res Function(_$VecKeyframeImpl) then,
  ) = __$$VecKeyframeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int frame,
    VecKeyframeType type,
    VecTweenType tweenType,
    VecTransform? transform,
    List<VecFill>? fills,
    List<VecStroke>? strokes,
    VecEasing? easing,
    VecPoint? position,
    VecPoint? scale,
    double? rotation,
    double? opacity,
    VecColor? fillColor,
    VecColor? strokeColor,
    List<VecPathNode>? pathNodes,
    VecEasing? positionEasing,
    VecEasing? scaleEasing,
    VecEasing? rotationEasing,
    VecEasing? opacityEasing,
    VecEasing? fillColorEasing,
    VecEasing? strokeColorEasing,
    VecEasing? pathEasing,
    List<VecShapeHint> shapeHints,
  });

  @override
  $VecTransformCopyWith<$Res>? get transform;
  @override
  $VecEasingCopyWith<$Res>? get easing;
  @override
  $VecPointCopyWith<$Res>? get position;
  @override
  $VecPointCopyWith<$Res>? get scale;
  @override
  $VecColorCopyWith<$Res>? get fillColor;
  @override
  $VecColorCopyWith<$Res>? get strokeColor;
  @override
  $VecEasingCopyWith<$Res>? get positionEasing;
  @override
  $VecEasingCopyWith<$Res>? get scaleEasing;
  @override
  $VecEasingCopyWith<$Res>? get rotationEasing;
  @override
  $VecEasingCopyWith<$Res>? get opacityEasing;
  @override
  $VecEasingCopyWith<$Res>? get fillColorEasing;
  @override
  $VecEasingCopyWith<$Res>? get strokeColorEasing;
  @override
  $VecEasingCopyWith<$Res>? get pathEasing;
}

/// @nodoc
class __$$VecKeyframeImplCopyWithImpl<$Res>
    extends _$VecKeyframeCopyWithImpl<$Res, _$VecKeyframeImpl>
    implements _$$VecKeyframeImplCopyWith<$Res> {
  __$$VecKeyframeImplCopyWithImpl(
    _$VecKeyframeImpl _value,
    $Res Function(_$VecKeyframeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VecKeyframe
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? frame = null,
    Object? type = null,
    Object? tweenType = null,
    Object? transform = freezed,
    Object? fills = freezed,
    Object? strokes = freezed,
    Object? easing = freezed,
    Object? position = freezed,
    Object? scale = freezed,
    Object? rotation = freezed,
    Object? opacity = freezed,
    Object? fillColor = freezed,
    Object? strokeColor = freezed,
    Object? pathNodes = freezed,
    Object? positionEasing = freezed,
    Object? scaleEasing = freezed,
    Object? rotationEasing = freezed,
    Object? opacityEasing = freezed,
    Object? fillColorEasing = freezed,
    Object? strokeColorEasing = freezed,
    Object? pathEasing = freezed,
    Object? shapeHints = null,
  }) {
    return _then(
      _$VecKeyframeImpl(
        frame: null == frame
            ? _value.frame
            : frame // ignore: cast_nullable_to_non_nullable
                  as int,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as VecKeyframeType,
        tweenType: null == tweenType
            ? _value.tweenType
            : tweenType // ignore: cast_nullable_to_non_nullable
                  as VecTweenType,
        transform: freezed == transform
            ? _value.transform
            : transform // ignore: cast_nullable_to_non_nullable
                  as VecTransform?,
        fills: freezed == fills
            ? _value._fills
            : fills // ignore: cast_nullable_to_non_nullable
                  as List<VecFill>?,
        strokes: freezed == strokes
            ? _value._strokes
            : strokes // ignore: cast_nullable_to_non_nullable
                  as List<VecStroke>?,
        easing: freezed == easing
            ? _value.easing
            : easing // ignore: cast_nullable_to_non_nullable
                  as VecEasing?,
        position: freezed == position
            ? _value.position
            : position // ignore: cast_nullable_to_non_nullable
                  as VecPoint?,
        scale: freezed == scale
            ? _value.scale
            : scale // ignore: cast_nullable_to_non_nullable
                  as VecPoint?,
        rotation: freezed == rotation
            ? _value.rotation
            : rotation // ignore: cast_nullable_to_non_nullable
                  as double?,
        opacity: freezed == opacity
            ? _value.opacity
            : opacity // ignore: cast_nullable_to_non_nullable
                  as double?,
        fillColor: freezed == fillColor
            ? _value.fillColor
            : fillColor // ignore: cast_nullable_to_non_nullable
                  as VecColor?,
        strokeColor: freezed == strokeColor
            ? _value.strokeColor
            : strokeColor // ignore: cast_nullable_to_non_nullable
                  as VecColor?,
        pathNodes: freezed == pathNodes
            ? _value._pathNodes
            : pathNodes // ignore: cast_nullable_to_non_nullable
                  as List<VecPathNode>?,
        positionEasing: freezed == positionEasing
            ? _value.positionEasing
            : positionEasing // ignore: cast_nullable_to_non_nullable
                  as VecEasing?,
        scaleEasing: freezed == scaleEasing
            ? _value.scaleEasing
            : scaleEasing // ignore: cast_nullable_to_non_nullable
                  as VecEasing?,
        rotationEasing: freezed == rotationEasing
            ? _value.rotationEasing
            : rotationEasing // ignore: cast_nullable_to_non_nullable
                  as VecEasing?,
        opacityEasing: freezed == opacityEasing
            ? _value.opacityEasing
            : opacityEasing // ignore: cast_nullable_to_non_nullable
                  as VecEasing?,
        fillColorEasing: freezed == fillColorEasing
            ? _value.fillColorEasing
            : fillColorEasing // ignore: cast_nullable_to_non_nullable
                  as VecEasing?,
        strokeColorEasing: freezed == strokeColorEasing
            ? _value.strokeColorEasing
            : strokeColorEasing // ignore: cast_nullable_to_non_nullable
                  as VecEasing?,
        pathEasing: freezed == pathEasing
            ? _value.pathEasing
            : pathEasing // ignore: cast_nullable_to_non_nullable
                  as VecEasing?,
        shapeHints: null == shapeHints
            ? _value._shapeHints
            : shapeHints // ignore: cast_nullable_to_non_nullable
                  as List<VecShapeHint>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VecKeyframeImpl implements _VecKeyframe {
  const _$VecKeyframeImpl({
    required this.frame,
    this.type = VecKeyframeType.keyframe,
    this.tweenType = VecTweenType.none,
    this.transform,
    final List<VecFill>? fills,
    final List<VecStroke>? strokes,
    this.easing,
    this.position,
    this.scale,
    this.rotation,
    this.opacity,
    this.fillColor,
    this.strokeColor,
    final List<VecPathNode>? pathNodes,
    this.positionEasing,
    this.scaleEasing,
    this.rotationEasing,
    this.opacityEasing,
    this.fillColorEasing,
    this.strokeColorEasing,
    this.pathEasing,
    final List<VecShapeHint> shapeHints = const [],
  }) : _fills = fills,
       _strokes = strokes,
       _pathNodes = pathNodes,
       _shapeHints = shapeHints;

  factory _$VecKeyframeImpl.fromJson(Map<String, dynamic> json) =>
      _$$VecKeyframeImplFromJson(json);

  @override
  final int frame;
  @override
  @JsonKey()
  final VecKeyframeType type;
  @override
  @JsonKey()
  final VecTweenType tweenType;
  // Full-snapshot values (set when adding a keyframe in the timeline)
  @override
  final VecTransform? transform;
  final List<VecFill>? _fills;
  @override
  List<VecFill>? get fills {
    final value = _fills;
    if (value == null) return null;
    if (_fills is EqualUnmodifiableListView) return _fills;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<VecStroke>? _strokes;
  @override
  List<VecStroke>? get strokes {
    final value = _strokes;
    if (value == null) return null;
    if (_strokes is EqualUnmodifiableListView) return _strokes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  // General easing applied to all snapshot properties (transform/opacity/fills/strokes)
  @override
  final VecEasing? easing;
  // Per-property values (null = not keyed at this frame)
  @override
  final VecPoint? position;
  @override
  final VecPoint? scale;
  @override
  final double? rotation;
  @override
  final double? opacity;
  @override
  final VecColor? fillColor;
  @override
  final VecColor? strokeColor;
  final List<VecPathNode>? _pathNodes;
  @override
  List<VecPathNode>? get pathNodes {
    final value = _pathNodes;
    if (value == null) return null;
    if (_pathNodes is EqualUnmodifiableListView) return _pathNodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  // Per-property easing (null = linear)
  @override
  final VecEasing? positionEasing;
  @override
  final VecEasing? scaleEasing;
  @override
  final VecEasing? rotationEasing;
  @override
  final VecEasing? opacityEasing;
  @override
  final VecEasing? fillColorEasing;
  @override
  final VecEasing? strokeColorEasing;
  @override
  final VecEasing? pathEasing;
  // Shape hints for shape tweens
  final List<VecShapeHint> _shapeHints;
  // Shape hints for shape tweens
  @override
  @JsonKey()
  List<VecShapeHint> get shapeHints {
    if (_shapeHints is EqualUnmodifiableListView) return _shapeHints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_shapeHints);
  }

  @override
  String toString() {
    return 'VecKeyframe(frame: $frame, type: $type, tweenType: $tweenType, transform: $transform, fills: $fills, strokes: $strokes, easing: $easing, position: $position, scale: $scale, rotation: $rotation, opacity: $opacity, fillColor: $fillColor, strokeColor: $strokeColor, pathNodes: $pathNodes, positionEasing: $positionEasing, scaleEasing: $scaleEasing, rotationEasing: $rotationEasing, opacityEasing: $opacityEasing, fillColorEasing: $fillColorEasing, strokeColorEasing: $strokeColorEasing, pathEasing: $pathEasing, shapeHints: $shapeHints)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VecKeyframeImpl &&
            (identical(other.frame, frame) || other.frame == frame) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.tweenType, tweenType) ||
                other.tweenType == tweenType) &&
            (identical(other.transform, transform) ||
                other.transform == transform) &&
            const DeepCollectionEquality().equals(other._fills, _fills) &&
            const DeepCollectionEquality().equals(other._strokes, _strokes) &&
            (identical(other.easing, easing) || other.easing == easing) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.scale, scale) || other.scale == scale) &&
            (identical(other.rotation, rotation) ||
                other.rotation == rotation) &&
            (identical(other.opacity, opacity) || other.opacity == opacity) &&
            (identical(other.fillColor, fillColor) ||
                other.fillColor == fillColor) &&
            (identical(other.strokeColor, strokeColor) ||
                other.strokeColor == strokeColor) &&
            const DeepCollectionEquality().equals(
              other._pathNodes,
              _pathNodes,
            ) &&
            (identical(other.positionEasing, positionEasing) ||
                other.positionEasing == positionEasing) &&
            (identical(other.scaleEasing, scaleEasing) ||
                other.scaleEasing == scaleEasing) &&
            (identical(other.rotationEasing, rotationEasing) ||
                other.rotationEasing == rotationEasing) &&
            (identical(other.opacityEasing, opacityEasing) ||
                other.opacityEasing == opacityEasing) &&
            (identical(other.fillColorEasing, fillColorEasing) ||
                other.fillColorEasing == fillColorEasing) &&
            (identical(other.strokeColorEasing, strokeColorEasing) ||
                other.strokeColorEasing == strokeColorEasing) &&
            (identical(other.pathEasing, pathEasing) ||
                other.pathEasing == pathEasing) &&
            const DeepCollectionEquality().equals(
              other._shapeHints,
              _shapeHints,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    frame,
    type,
    tweenType,
    transform,
    const DeepCollectionEquality().hash(_fills),
    const DeepCollectionEquality().hash(_strokes),
    easing,
    position,
    scale,
    rotation,
    opacity,
    fillColor,
    strokeColor,
    const DeepCollectionEquality().hash(_pathNodes),
    positionEasing,
    scaleEasing,
    rotationEasing,
    opacityEasing,
    fillColorEasing,
    strokeColorEasing,
    pathEasing,
    const DeepCollectionEquality().hash(_shapeHints),
  ]);

  /// Create a copy of VecKeyframe
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VecKeyframeImplCopyWith<_$VecKeyframeImpl> get copyWith =>
      __$$VecKeyframeImplCopyWithImpl<_$VecKeyframeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VecKeyframeImplToJson(this);
  }
}

abstract class _VecKeyframe implements VecKeyframe {
  const factory _VecKeyframe({
    required final int frame,
    final VecKeyframeType type,
    final VecTweenType tweenType,
    final VecTransform? transform,
    final List<VecFill>? fills,
    final List<VecStroke>? strokes,
    final VecEasing? easing,
    final VecPoint? position,
    final VecPoint? scale,
    final double? rotation,
    final double? opacity,
    final VecColor? fillColor,
    final VecColor? strokeColor,
    final List<VecPathNode>? pathNodes,
    final VecEasing? positionEasing,
    final VecEasing? scaleEasing,
    final VecEasing? rotationEasing,
    final VecEasing? opacityEasing,
    final VecEasing? fillColorEasing,
    final VecEasing? strokeColorEasing,
    final VecEasing? pathEasing,
    final List<VecShapeHint> shapeHints,
  }) = _$VecKeyframeImpl;

  factory _VecKeyframe.fromJson(Map<String, dynamic> json) =
      _$VecKeyframeImpl.fromJson;

  @override
  int get frame;
  @override
  VecKeyframeType get type;
  @override
  VecTweenType get tweenType; // Full-snapshot values (set when adding a keyframe in the timeline)
  @override
  VecTransform? get transform;
  @override
  List<VecFill>? get fills;
  @override
  List<VecStroke>? get strokes; // General easing applied to all snapshot properties (transform/opacity/fills/strokes)
  @override
  VecEasing? get easing; // Per-property values (null = not keyed at this frame)
  @override
  VecPoint? get position;
  @override
  VecPoint? get scale;
  @override
  double? get rotation;
  @override
  double? get opacity;
  @override
  VecColor? get fillColor;
  @override
  VecColor? get strokeColor;
  @override
  List<VecPathNode>? get pathNodes; // Per-property easing (null = linear)
  @override
  VecEasing? get positionEasing;
  @override
  VecEasing? get scaleEasing;
  @override
  VecEasing? get rotationEasing;
  @override
  VecEasing? get opacityEasing;
  @override
  VecEasing? get fillColorEasing;
  @override
  VecEasing? get strokeColorEasing;
  @override
  VecEasing? get pathEasing; // Shape hints for shape tweens
  @override
  List<VecShapeHint> get shapeHints;

  /// Create a copy of VecKeyframe
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VecKeyframeImplCopyWith<_$VecKeyframeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
