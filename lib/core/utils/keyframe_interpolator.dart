import '../../data/models/vec_color.dart';
import '../../data/models/vec_fill.dart';
import '../../data/models/vec_keyframe.dart';
import '../../data/models/vec_shape.dart';
import '../../data/models/vec_stroke.dart';
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
  static VecShape applyAtFrame(
    VecShape shape,
    List<VecKeyframe> keyframes,
    int frame,
  ) {
    if (keyframes.isEmpty) return shape;

    final sorted = List<VecKeyframe>.from(keyframes)
      ..sort((a, b) => a.frame.compareTo(b.frame));

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
    final t = EasingEvaluator.evaluate(before.easing, rawT);
    return _lerp(shape, before, after, t);
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

  static VecShape _lerp(
    VecShape shape,
    VecKeyframe a,
    VecKeyframe b,
    double t,
  ) {
    var data = shape.data;

    // Transform
    final ta = a.transform, tb = b.transform;
    if (ta != null && tb != null) {
      data = data.copyWith(transform: _lerpTransform(ta, tb, t));
    } else if (ta != null) {
      data = data.copyWith(transform: ta);
    }

    // Opacity
    final oa = a.opacity, ob = b.opacity;
    if (oa != null && ob != null) {
      data = data.copyWith(opacity: (oa + (ob - oa) * t).clamp(0.0, 1.0));
    } else if (oa != null) {
      data = data.copyWith(opacity: oa);
    }

    // Fills: lerp first fill's color
    final fa = a.fills, fb = b.fills;
    if (fa != null && fb != null && fa.isNotEmpty && fb.isNotEmpty) {
      final lerpedFills = [
        fa[0].copyWith(color: _lerpColor(fa[0].color, fb[0].color, t)),
        ...fa.skip(1),
      ];
      data = data.copyWith(fills: lerpedFills);
    } else if (fa != null) {
      data = data.copyWith(fills: fa);
    }

    // Strokes: lerp first stroke's color + width
    final sa = a.strokes, sb = b.strokes;
    if (sa != null && sb != null && sa.isNotEmpty && sb.isNotEmpty) {
      final lerpedStrokes = [
        sa[0].copyWith(
          color: _lerpColor(sa[0].color, sb[0].color, t),
          width: sa[0].width + (sb[0].width - sa[0].width) * t,
        ),
        ...sa.skip(1),
      ];
      data = data.copyWith(strokes: lerpedStrokes);
    } else if (sa != null) {
      data = data.copyWith(strokes: sa);
    }

    return shape.copyWith(data: data);
  }

  static VecTransform _lerpTransform(VecTransform a, VecTransform b, double t) {
    return VecTransform(
      x: _ld(a.x, b.x, t),
      y: _ld(a.y, b.y, t),
      width: _ld(a.width, b.width, t),
      height: _ld(a.height, b.height, t),
      rotation: _lerpAngle(a.rotation, b.rotation, t),
      scaleX: _ld(a.scaleX, b.scaleX, t),
      scaleY: _ld(a.scaleY, b.scaleY, t),
      skewX: _ld(a.skewX, b.skewX, t),
      skewY: _ld(a.skewY, b.skewY, t),
    );
  }

  static VecColor _lerpColor(VecColor a, VecColor b, double t) => VecColor(
        a: (a.a + (b.a - a.a) * t).round().clamp(0, 255),
        r: (a.r + (b.r - a.r) * t).round().clamp(0, 255),
        g: (a.g + (b.g - a.g) * t).round().clamp(0, 255),
        b: (a.b + (b.b - a.b) * t).round().clamp(0, 255),
      );

  static double _ld(double a, double b, double t) => a + (b - a) * t;

  static double _lerpAngle(double a, double b, double t) {
    var diff = (b - a) % 360;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    return a + diff * t;
  }
}
