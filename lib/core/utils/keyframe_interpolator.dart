import '../../data/models/vec_color.dart';
import '../../data/models/vec_easing.dart';
import '../../data/models/vec_gradient.dart';
import '../../data/models/vec_keyframe.dart';
import '../../data/models/vec_point.dart';
import '../../data/models/vec_shape.dart';
import '../../data/models/vec_transform.dart';
import 'easing_evaluator.dart';

/// Pure utility: applies keyframe interpolation to a [VecShape] at [frame].
class KeyframeInterpolator {
  const KeyframeInterpolator._();

  /// Returns a copy of [shape] with its data (transform, opacity, fills,
  /// strokes) blended to the correct value at [frame] based on [keyframes].
  ///
  /// Rules:
  ///  • Before the first keyframe → shape is unchanged (not keyed yet).
  ///  • At / after the last keyframe → last keyframe value is held.
  ///  • Between two keyframes → lerp based on [VecTweenType] of the left kf.
  ///    - [VecTweenType.none]  → hold: keeps left keyframe value.
  ///    - anything else        → linear interpolation.
  static VecShape applyAtFrame(VecShape shape, List<VecKeyframe> keyframes, int frame) {
    if (keyframes.isEmpty) return shape;

    final sorted = List<VecKeyframe>.from(keyframes)..sort((a, b) => a.frame.compareTo(b.frame));

    // Before first keyframe → unchanged
    if (frame < sorted.first.frame) return shape;

    // Find surrounding pair
    VecKeyframe? before, after;
    for (final kf in sorted) {
      if (kf.frame <= frame) {
        before = kf;
      } else if (after == null) {
        after = kf;
      }
    }

    // At or past last keyframe → hold last
    if (after == null) return _apply(shape, before!);

    // Exact match → hold
    if (before!.frame == frame) return _apply(shape, before);

    // Hold tween → snap to before
    if (before.tweenType == VecTweenType.none) return _apply(shape, before);

    // Apply easing to the raw linear t
    final rawT = (frame - before.frame) / (after.frame - before.frame);
    return _lerp(shape, before, after, rawT);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static VecShape _apply(VecShape shape, VecKeyframe kf) {
    var data = shape.data;
    if (kf.transform != null) data = data.copyWith(transform: kf.transform!);
    if (kf.opacity != null) data = data.copyWith(opacity: kf.opacity!);
    if (kf.fills != null) data = data.copyWith(fills: kf.fills!);
    if (kf.strokes != null) data = data.copyWith(strokes: kf.strokes!);
    return shape.copyWith(data: data);
  }

  static VecShape _lerp(VecShape shape, VecKeyframe a, VecKeyframe b, double rawT) {
    // Resolve per-property easing, falling back to the general easing field.
    double t(VecEasing? perProp) => EasingEvaluator.evaluate(perProp ?? a.easing, rawT);

    var data = shape.data;

    // Transform (split into position, scale, rotation sub-properties)
    final ta = a.transform, tb = b.transform;
    if (ta != null && tb != null) {
      data = data.copyWith(transform: _lerpTransformPerProperty(ta, tb, a, b, rawT));
    } else if (ta != null) {
      data = data.copyWith(transform: ta);
    }

    // Opacity
    final oa = a.opacity, ob = b.opacity;
    if (oa != null && ob != null) {
      final tOp = t(a.opacityEasing);
      data = data.copyWith(opacity: (oa + (ob - oa) * tOp).clamp(0.0, 1.0));
    } else if (oa != null) {
      data = data.copyWith(opacity: oa);
    }

    // Fills: lerp corresponding fill entries (color + gradient)
    final fa = a.fills, fb = b.fills;
    if (fa != null && fb != null && fa.isNotEmpty && fb.isNotEmpty) {
      final tFill = t(a.fillColorEasing);
      final count = fa.length < fb.length ? fa.length : fb.length;
      final lerpedFills = [
        for (var i = 0; i < count; i++)
          fa[i].copyWith(
            color: _lerpColor(fa[i].color, fb[i].color, tFill),
            gradient: _lerpGradient(fa[i].gradient, fb[i].gradient, tFill),
          ),
        ...fa.skip(count),
      ];
      data = data.copyWith(fills: lerpedFills);
    } else if (fa != null) {
      data = data.copyWith(fills: fa);
    }

    // Strokes: lerp first stroke's color + width
    final sa = a.strokes, sb = b.strokes;
    if (sa != null && sb != null && sa.isNotEmpty && sb.isNotEmpty) {
      final tStroke = t(a.strokeColorEasing);
      final lerpedStrokes = [
        sa[0].copyWith(
          color: _lerpColor(sa[0].color, sb[0].color, tStroke),
          width: sa[0].width + (sb[0].width - sa[0].width) * tStroke,
        ),
        ...sa.skip(1),
      ];
      data = data.copyWith(strokes: lerpedStrokes);
    } else if (sa != null) {
      data = data.copyWith(strokes: sa);
    }

    return shape.copyWith(data: data);
  }

  /// Lerps a transform using per-property easings for position, scale, and rotation.
  static VecTransform _lerpTransformPerProperty(
    VecTransform a,
    VecTransform b,
    VecKeyframe ka,
    VecKeyframe kb,
    double rawT,
  ) {
    final tPos = EasingEvaluator.evaluate(ka.positionEasing ?? ka.easing, rawT);
    final tScale = EasingEvaluator.evaluate(ka.scaleEasing ?? ka.easing, rawT);
    final tRot = EasingEvaluator.evaluate(ka.rotationEasing ?? ka.easing, rawT);

    final VecPoint? pivot;
    if (a.pivot != null && b.pivot != null) {
      pivot = VecPoint(x: _ld(a.pivot!.x, b.pivot!.x, tPos), y: _ld(a.pivot!.y, b.pivot!.y, tPos));
    } else {
      pivot = a.pivot ?? b.pivot;
    }

    return VecTransform(
      x: _ld(a.x, b.x, tPos),
      y: _ld(a.y, b.y, tPos),
      width: _ld(a.width, b.width, tScale),
      height: _ld(a.height, b.height, tScale),
      rotation: _lerpAngle(a.rotation, b.rotation, tRot),
      scaleX: _ld(a.scaleX, b.scaleX, tScale),
      scaleY: _ld(a.scaleY, b.scaleY, tScale),
      skewX: _ld(a.skewX, b.skewX, tScale),
      skewY: _ld(a.skewY, b.skewY, tScale),
      pivot: pivot,
    );
  }

  static VecColor _lerpColor(VecColor a, VecColor b, double t) => VecColor(
    a: (a.a + (b.a - a.a) * t).round().clamp(0, 255),
    r: (a.r + (b.r - a.r) * t).round().clamp(0, 255),
    g: (a.g + (b.g - a.g) * t).round().clamp(0, 255),
    b: (a.b + (b.b - a.b) * t).round().clamp(0, 255),
  );

  static VecGradient? _lerpGradient(VecGradient? a, VecGradient? b, double t) {
    if (a == null && b == null) return null;
    if (a == null) return t < 0.5 ? null : b;
    if (b == null) return t < 0.5 ? a : null;

    final stopCount = a.stops.length < b.stops.length ? a.stops.length : b.stops.length;
    final stops = [
      for (var i = 0; i < stopCount; i++)
        VecGradientStop(
          color: _lerpColor(a.stops[i].color, b.stops[i].color, t),
          position: _ld(a.stops[i].position, b.stops[i].position, t),
        ),
    ];

    // Interpolate gradient geometry when types match. If types differ,
    // cross-fade by switching type halfway while still interpolating shared fields.
    final resolvedType = t < 0.5 ? a.type : b.type;
    return VecGradient(
      type: resolvedType,
      stops: stops,
      angle: _ld(a.angle, b.angle, t),
      centerX: _ld(a.centerX, b.centerX, t),
      centerY: _ld(a.centerY, b.centerY, t),
      radius: _ld(a.radius, b.radius, t),
    );
  }

  static double _ld(double a, double b, double t) => a + (b - a) * t;

  static double _lerpAngle(double a, double b, double t) {
    var diff = (b - a) % 360;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    return a + diff * t;
  }
}
