import 'dart:math' as math;

import '../../data/models/vec_easing.dart';

/// Evaluates [VecEasing] curves at a normalised time t ∈ [0, 1].
///
/// All preset curves that can be expressed as a CSS cubic-bezier are
/// forwarded to the same solver, giving pixel-perfect results.
/// Bounce / Elastic / Spring are computed analytically and may
/// produce values outside [0, 1] (overshoot / undershoot).
class EasingEvaluator {
  const EasingEvaluator._();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Evaluates [easing] at [t]. Null easing → linear.
  static double evaluate(VecEasing? easing, double t) {
    if (t <= 0) return 0;
    if (t >= 1) return 1;
    if (easing == null) return t;
    return easing.map(
      preset: (p) => _preset(p.preset, t),
      cubicBezier: (cb) => _cubicBezier(cb.x1, cb.y1, cb.x2, cb.y2, t),
    );
  }

  /// Returns (x1, y1, x2, y2) for presets that map to a cubic bezier.
  /// Returns null for Bounce / Elastic / Spring.
  static (double, double, double, double)? controlPoints(VecEasing? easing) {
    if (easing == null) return (0.0, 0.0, 1.0, 1.0); // linear
    return easing.map(
      preset: (p) => _presetPoints[p.preset],
      cubicBezier: (cb) => (cb.x1, cb.y1, cb.x2, cb.y2),
    );
  }

  // Map preset → CSS bezier control points (null for non-bezier presets)
  static const _presetPoints =
      <VecEasingPreset, (double, double, double, double)?>{
    VecEasingPreset.linear: (0.0, 0.0, 1.0, 1.0),
    VecEasingPreset.easeIn: (0.42, 0.0, 1.0, 1.0),
    VecEasingPreset.easeOut: (0.0, 0.0, 0.58, 1.0),
    VecEasingPreset.easeInOut: (0.42, 0.0, 0.58, 1.0),
    VecEasingPreset.bounce: null,
    VecEasingPreset.elastic: null,
    VecEasingPreset.spring: null,
  };

  // ---------------------------------------------------------------------------
  // Private
  // ---------------------------------------------------------------------------

  static double _preset(VecEasingPreset preset, double t) => switch (preset) {
        VecEasingPreset.linear => t,
        VecEasingPreset.easeIn => _cubicBezier(0.42, 0.0, 1.0, 1.0, t),
        VecEasingPreset.easeOut => _cubicBezier(0.0, 0.0, 0.58, 1.0, t),
        VecEasingPreset.easeInOut => _cubicBezier(0.42, 0.0, 0.58, 1.0, t),
        VecEasingPreset.bounce => _bounceOut(t),
        VecEasingPreset.elastic => _elasticOut(t),
        VecEasingPreset.spring => _spring(t),
      };

  // CSS cubic-bezier: endpoints fixed at (0,0) and (1,1).
  // Solves Bx(u) = x via binary search, then returns By(u).
  static double _cubicBezier(
      double x1, double y1, double x2, double y2, double t) {
    double lo = 0, hi = 1;
    for (var i = 0; i < 30; i++) {
      final mid = (lo + hi) * 0.5;
      final bx = _bComp(x1, x2, mid);
      if ((bx - t).abs() < 1e-8) return _bComp(y1, y2, mid);
      if (bx < t) lo = mid; else hi = mid;
    }
    return _bComp(y1, y2, (lo + hi) * 0.5);
  }

  /// Cubic component: 3(1-u)²u·p1 + 3(1-u)u²·p2 + u³
  static double _bComp(double p1, double p2, double u) {
    final mu = 1 - u;
    return 3 * mu * mu * u * p1 + 3 * mu * u * u * p2 + u * u * u;
  }

  static double _bounceOut(double t) {
    const n1 = 7.5625, d1 = 2.75;
    if (t < 1 / d1) return n1 * t * t;
    if (t < 2 / d1) { final s = t - 1.5 / d1; return n1 * s * s + 0.75; }
    if (t < 2.5 / d1) { final s = t - 2.25 / d1; return n1 * s * s + 0.9375; }
    final s = t - 2.625 / d1;
    return n1 * s * s + 0.984375;
  }

  static double _elasticOut(double t) {
    if (t == 0 || t == 1) return t;
    const c4 = 2 * math.pi / 3;
    return math.pow(2, -10 * t).toDouble() *
            math.sin((t * 10 - 0.75) * c4) +
        1;
  }

  static double _spring(double t) {
    if (t == 0) return 0;
    if (t == 1) return 1;
    const omega = 10.0, zeta = 0.5;
    final wd = omega * math.sqrt(1 - zeta * zeta);
    return 1 -
        math.exp(-zeta * omega * t) *
            (math.cos(wd * t) + (zeta * omega / wd) * math.sin(wd * t));
  }
}
