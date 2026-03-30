import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/models/vec_shape.dart';
import '../tools/select_tool_handler.dart';

/// Paints a bend-point handle for a 2-node line shape.
///
/// When the line is straight (no handles), the bend point sits at the midpoint.
/// When bent, it sits at the conceptual quadratic control point H derived from
/// the stored cubic control point C1:  H = (3·C1 + end) / 4.
///
/// Dragging H updates both C1 and C2 so the Bézier passes through H at t=0.5
/// using a symmetric quadratic-to-cubic conversion.
class BendHandleOverlayPainter extends CustomPainter {
  BendHandleOverlayPainter({required this.shape, required this.zoom, required this.isHovered, required this.color});

  final VecPathShape shape;
  final double zoom;
  final bool isHovered;
  final Color color;

  static const double _handleRadius = 5.0;

  // ---------------------------------------------------------------------------
  // Public geometry helpers
  // ---------------------------------------------------------------------------

  /// Returns the bend handle position in shape-local space, or null if not applicable.
  static Offset? bendHandleLocalPos(VecPathShape shape) {
    if (shape.nodes.length != 2) return null;
    final n0 = shape.nodes[0];
    final n1 = shape.nodes[1];
    final start = Offset(n0.position.x, n0.position.y);
    final end = Offset(n1.position.x, n1.position.y);

    if (n0.handleOut == null) {
      // Straight line — show handle at midpoint
      return (start + end) / 2;
    }

    // Bent — recover H = (3·C1 + end) / 4
    final c1 = Offset(n0.handleOut!.x, n0.handleOut!.y);
    return (c1 * 3 + end) / 4;
  }

  /// Returns the bend handle position in canvas space, or null.
  static Offset? bendHandleCanvasPos(VecPathShape shape) {
    final localPos = bendHandleLocalPos(shape);
    if (localPos == null) return null;
    return SelectToolHandler.localToCanvas(shape.data.transform, localPos);
  }

  /// Hit-tests [canvasPoint] against the bend handle.
  /// Returns 0 if hit, -1 if miss.
  static int hitTestHandle(VecPathShape shape, double zoom, Offset canvasPoint) {
    final localPos = bendHandleLocalPos(shape);
    if (localPos == null) return -1;
    final canvasPos = SelectToolHandler.localToCanvas(shape.data.transform, localPos);
    final hitRadius = 8.0 / zoom;
    return (canvasPoint - canvasPos).distance < hitRadius ? 0 : -1;
  }

  // ---------------------------------------------------------------------------
  // Painting
  // ---------------------------------------------------------------------------

  @override
  void paint(Canvas canvas, Size size) {
    if (shape.nodes.length != 2) return;

    final t = shape.data.transform;
    final px = t.pivot?.x ?? (t.width / 2);
    final py = t.pivot?.y ?? (t.height / 2);

    canvas.save();
    canvas.translate(t.x, t.y);
    canvas.translate(px, py);
    if (t.rotation != 0) canvas.rotate(t.rotation * math.pi / 180);
    if (t.scaleX != 1 || t.scaleY != 1) canvas.scale(t.scaleX, t.scaleY);
    canvas.translate(-px, -py);

    final n0 = shape.nodes[0];
    final n1 = shape.nodes[1];
    final startLocal = Offset(n0.position.x, n0.position.y);
    final endLocal = Offset(n1.position.x, n1.position.y);
    final handleLocal = bendHandleLocalPos(shape)!;

    // Only draw dashed lines when the handle is offset from midpoint (bent or hovered)
    _drawDashedLine(canvas, handleLocal, startLocal);
    _drawDashedLine(canvas, handleLocal, endLocal);

    // Handle circle
    final hr = _handleRadius / zoom;
    final fillAlpha = isHovered ? 220 : 160;

    canvas.drawCircle(
      handleLocal,
      hr,
      Paint()
        ..color = color.withAlpha(fillAlpha)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      handleLocal,
      hr * 0.4,
      Paint()
        ..color = Colors.white.withAlpha(220)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      handleLocal,
      hr,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2 / zoom,
    );

    canvas.restore();
  }

  void _drawDashedLine(Canvas canvas, Offset from, Offset to) {
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len < 0.1) return;

    final paint = Paint()
      ..color = color.withAlpha(100)
      ..strokeWidth = 1.0 / zoom
      ..style = PaintingStyle.stroke;

    final dashLen = 4.0 / zoom;
    final gapLen = 3.0 / zoom;
    final ux = dx / len;
    final uy = dy / len;

    var dist = 0.0;
    var draw = true;
    while (dist < len) {
      final segLen = draw ? dashLen : gapLen;
      final end = (dist + segLen).clamp(0.0, len);
      if (draw) {
        canvas.drawLine(
          Offset(from.dx + ux * dist, from.dy + uy * dist),
          Offset(from.dx + ux * end, from.dy + uy * end),
          paint,
        );
      }
      dist += segLen;
      draw = !draw;
    }
  }

  @override
  bool shouldRepaint(covariant BendHandleOverlayPainter old) =>
      old.shape != shape || old.zoom != zoom || old.isHovered != isHovered || old.color != color;
}

// =============================================================================
// SegmentBendOverlayPainter — n-node paths
// =============================================================================

/// Paints a diamond bend-point handle at the midpoint of every segment of an
/// n-node [VecPathShape].  Used by the Bend tool.
///
/// For each segment i → i+1 the midpoint is the cubic Bézier evaluation at
/// t = 0.5.  On hover the hovered segment's handle is highlighted and dashed
/// tangent lines are drawn from the handle back to the segment endpoints.
class SegmentBendOverlayPainter extends CustomPainter {
  const SegmentBendOverlayPainter({
    required this.shape,
    required this.zoom,
    required this.hoveredSegment,
    required this.color,
  });

  final VecPathShape shape;
  final double zoom;

  /// Index of the segment whose handle is highlighted, or -1 for none.
  final int hoveredSegment;
  final Color color;

  static const double _handleRadius = 5.0;

  // ---------------------------------------------------------------------------
  // Public geometry helpers
  // ---------------------------------------------------------------------------

  static int _segmentCount(VecPathShape shape) {
    final n = shape.nodes.length;
    if (n < 2) return 0;
    return shape.isClosed ? n : n - 1;
  }

  static Offset _evalCubic(Offset p0, Offset c1, Offset c2, Offset p1, double t) {
    final mt = 1.0 - t;
    return p0 * (mt * mt * mt) + c1 * (3 * mt * mt * t) + c2 * (3 * mt * t * t) + p1 * (t * t * t);
  }

  /// Returns the midpoint (t = 0.5) of segment [segmentIndex] in **local**
  /// shape space, or `null` if the index is out of range.
  static Offset? segmentHandleLocalPos(VecPathShape shape, int segmentIndex) {
    final n = shape.nodes.length;
    if (n < 2) return null;
    final count = shape.isClosed ? n : n - 1;
    if (segmentIndex < 0 || segmentIndex >= count) return null;
    final i0 = segmentIndex;
    final i1 = (segmentIndex + 1) % n;
    final nd0 = shape.nodes[i0];
    final nd1 = shape.nodes[i1];
    final p0 = Offset(nd0.position.x, nd0.position.y);
    final p1 = Offset(nd1.position.x, nd1.position.y);
    final c1 = nd0.handleOut != null ? Offset(nd0.handleOut!.x, nd0.handleOut!.y) : p0;
    final c2 = nd1.handleIn != null ? Offset(nd1.handleIn!.x, nd1.handleIn!.y) : p1;
    return _evalCubic(p0, c1, c2, p1, 0.5);
  }

  /// Returns the index of the segment whose handle is within hit-radius of
  /// [canvasPoint], or -1 for no hit.
  static int hitTestHandle(VecPathShape shape, double zoom, Offset canvasPoint) {
    final count = _segmentCount(shape);
    final t = shape.data.transform;
    final hitRadius = 8.0 / zoom;
    for (var i = 0; i < count; i++) {
      final local = segmentHandleLocalPos(shape, i);
      if (local == null) continue;
      final canvas = SelectToolHandler.localToCanvas(t, local);
      if ((canvasPoint - canvas).distance < hitRadius) return i;
    }
    return -1;
  }

  /// Returns the index of the nearest segment whose curve passes within
  /// [thresholdPx] / [zoom] canvas-space units of [canvasPoint], or -1 if
  /// none is close enough.  Uses 20-sample uniform search along the Bézier.
  static int nearestSegmentToPoint(VecPathShape shape, double zoom, Offset canvasPoint, {double thresholdPx = 20.0}) {
    final count = _segmentCount(shape);
    if (count == 0) return -1;
    final tr = shape.data.transform;
    final hitRadius = thresholdPx / zoom;
    final n = shape.nodes.length;
    var nearestIdx = -1;
    var nearestDist = double.infinity;
    for (var i = 0; i < count; i++) {
      final i1 = (i + 1) % n;
      final nd0 = shape.nodes[i];
      final nd1 = shape.nodes[i1];
      final p0 = SelectToolHandler.localToCanvas(tr, Offset(nd0.position.x, nd0.position.y));
      final p1 = SelectToolHandler.localToCanvas(tr, Offset(nd1.position.x, nd1.position.y));
      final c1 = nd0.handleOut != null
          ? SelectToolHandler.localToCanvas(tr, Offset(nd0.handleOut!.x, nd0.handleOut!.y))
          : p0;
      final c2 = nd1.handleIn != null
          ? SelectToolHandler.localToCanvas(tr, Offset(nd1.handleIn!.x, nd1.handleIn!.y))
          : p1;
      final dist = _nearestDistOnCubic(p0, c1, c2, p1, canvasPoint);
      if (dist < nearestDist) {
        nearestDist = dist;
        nearestIdx = i;
      }
    }
    return nearestDist < hitRadius ? nearestIdx : -1;
  }

  static double _nearestDistOnCubic(Offset p0, Offset c1, Offset c2, Offset p1, Offset query) {
    var minDist = double.infinity;
    for (var j = 0; j <= 20; j++) {
      final pt = _evalCubic(p0, c1, c2, p1, j / 20.0);
      final d = (pt - query).distance;
      if (d < minDist) minDist = d;
    }
    return minDist;
  }

  /// Finds the parameter t ∈ [0,1] on segment [segIndex] of [shape] (in local
  /// space) that is closest to [localPoint].
  static double nearestTOnSegment(VecPathShape shape, int segIndex, Offset localPoint) {
    final n = shape.nodes.length;
    final i1 = (segIndex + 1) % n;
    final nd0 = shape.nodes[segIndex];
    final nd1 = shape.nodes[i1];
    final p0 = Offset(nd0.position.x, nd0.position.y);
    final p1 = Offset(nd1.position.x, nd1.position.y);
    final c1 = nd0.handleOut != null ? Offset(nd0.handleOut!.x, nd0.handleOut!.y) : p0;
    final c2 = nd1.handleIn != null ? Offset(nd1.handleIn!.x, nd1.handleIn!.y) : p1;
    // Coarse pass: 20 uniform samples.
    var bestT = 0.5;
    var bestDist = double.infinity;
    for (var j = 0; j <= 20; j++) {
      final tt = j / 20.0;
      final d = (_evalCubic(p0, c1, c2, p1, tt) - localPoint).distance;
      if (d < bestDist) {
        bestDist = d;
        bestT = tt;
      }
    }
    // Refine with bisection.
    var lo = (bestT - 0.05).clamp(0.0, 1.0);
    var hi = (bestT + 0.05).clamp(0.0, 1.0);
    for (var k = 0; k < 10; k++) {
      final mid = (lo + hi) / 2;
      final dLo = (_evalCubic(p0, c1, c2, p1, lo) - localPoint).distance;
      final dHi = (_evalCubic(p0, c1, c2, p1, hi) - localPoint).distance;
      if (dLo < dHi) {
        hi = mid;
      } else {
        lo = mid;
      }
    }
    return (lo + hi) / 2;
  }

  /// De Casteljau subdivision of a cubic Bézier at parameter [t].
  ///
  /// Returns `(leftC1, leftC2, midPt, rightC1, rightC2)` where:
  /// - Left sub-segment:  p0 → [leftC1,  leftC2]  → midPt
  /// - Right sub-segment: midPt → [rightC1, rightC2] → p1
  static (Offset, Offset, Offset, Offset, Offset) subdivideSegment(
    Offset p0,
    Offset c1,
    Offset c2,
    Offset p1,
    double t,
  ) {
    final m0 = Offset.lerp(p0, c1, t)!;
    final m1 = Offset.lerp(c1, c2, t)!;
    final m2 = Offset.lerp(c2, p1, t)!;
    final n0 = Offset.lerp(m0, m1, t)!;
    final n1 = Offset.lerp(m1, m2, t)!;
    final midPt = Offset.lerp(n0, n1, t)!;
    return (m0, n0, midPt, n1, m2);
  }

  // ---------------------------------------------------------------------------
  // Painting
  // ---------------------------------------------------------------------------

  @override
  void paint(Canvas canvas, Size size) {
    final count = _segmentCount(shape);
    if (count == 0) return;

    final t = shape.data.transform;
    final px = t.pivot?.x ?? (t.width / 2);
    final py = t.pivot?.y ?? (t.height / 2);

    canvas.save();
    canvas.translate(t.x, t.y);
    canvas.translate(px, py);
    if (t.rotation != 0) canvas.rotate(t.rotation * math.pi / 180);
    if (t.scaleX != 1 || t.scaleY != 1) canvas.scale(t.scaleX, t.scaleY);
    canvas.translate(-px, -py);

    final hr = _handleRadius / zoom;
    final n = shape.nodes.length;

    for (var i = 0; i < count; i++) {
      final local = segmentHandleLocalPos(shape, i);
      if (local == null) continue;
      final isHovered = i == hoveredSegment;

      if (isHovered) {
        final i1 = (i + 1) % n;
        final p0 = Offset(shape.nodes[i].position.x, shape.nodes[i].position.y);
        final p1 = Offset(shape.nodes[i1].position.x, shape.nodes[i1].position.y);
        _drawDashedLine(canvas, local, p0);
        _drawDashedLine(canvas, local, p1);
      }

      _drawDiamond(canvas, local, hr, isHovered);
    }

    canvas.restore();
  }

  void _drawDiamond(Canvas canvas, Offset center, double r, bool hovered) {
    final path = Path()
      ..moveTo(center.dx, center.dy - r)
      ..lineTo(center.dx + r, center.dy)
      ..lineTo(center.dx, center.dy + r)
      ..lineTo(center.dx - r, center.dy)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withAlpha(hovered ? 220 : 160)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2 / zoom,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset from, Offset to) {
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len < 0.1) return;

    final paint = Paint()
      ..color = color.withAlpha(100)
      ..strokeWidth = 1.0 / zoom
      ..style = PaintingStyle.stroke;

    final dashLen = 4.0 / zoom;
    final gapLen = 3.0 / zoom;
    final ux = dx / len;
    final uy = dy / len;

    var dist = 0.0;
    var draw = true;
    while (dist < len) {
      final segLen = draw ? dashLen : gapLen;
      final end = (dist + segLen).clamp(0.0, len);
      if (draw) {
        canvas.drawLine(
          Offset(from.dx + ux * dist, from.dy + uy * dist),
          Offset(from.dx + ux * end, from.dy + uy * end),
          paint,
        );
      }
      dist += segLen;
      draw = !draw;
    }
  }

  @override
  bool shouldRepaint(covariant SegmentBendOverlayPainter old) =>
      old.shape != shape || old.zoom != zoom || old.hoveredSegment != hoveredSegment || old.color != color;
}
