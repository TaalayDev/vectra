import 'package:freezed_annotation/freezed_annotation.dart';

import 'vec_color.dart';
import 'vec_easing.dart';
import 'vec_fill.dart';
import 'vec_path_node.dart';
import 'vec_point.dart';
import 'vec_shape_hint.dart';
import 'vec_stroke.dart';
import 'vec_transform.dart';

part 'vec_keyframe.freezed.dart';
part 'vec_keyframe.g.dart';

enum VecKeyframeType { keyframe, blank }

enum VecTweenType { none, motion, shape, classic }

@freezed
class VecKeyframe with _$VecKeyframe {
  const factory VecKeyframe({
    required int frame,
    @Default(VecKeyframeType.keyframe) VecKeyframeType type,
    @Default(VecTweenType.none) VecTweenType tweenType,

    // Full-snapshot values (set when adding a keyframe in the timeline)
    VecTransform? transform,
    List<VecFill>? fills,
    List<VecStroke>? strokes,

    // General easing applied to all snapshot properties (transform/opacity/fills/strokes)
    VecEasing? easing,

    // Per-property values (null = not keyed at this frame)
    VecPoint? position,
    VecPoint? scale,
    double? rotation,
    double? opacity,
    VecColor? fillColor,
    VecColor? strokeColor,
    List<VecPathNode>? pathNodes,

    // Per-property easing (null = linear)
    VecEasing? positionEasing,
    VecEasing? scaleEasing,
    VecEasing? rotationEasing,
    VecEasing? opacityEasing,
    VecEasing? fillColorEasing,
    VecEasing? strokeColorEasing,
    VecEasing? pathEasing,

    // Shape hints for shape tweens
    @Default([]) List<VecShapeHint> shapeHints,
  }) = _VecKeyframe;

  factory VecKeyframe.fromJson(Map<String, dynamic> json) =>
      _$VecKeyframeFromJson(json);
}
