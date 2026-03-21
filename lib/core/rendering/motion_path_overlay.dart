import 'dart:ui' show Offset;

import 'package:flutter/material.dart';

import '../../data/models/vec_motion_path.dart';
import '../../data/models/vec_path_node.dart';

/// Draws all motion paths as dashed lines with node handles.
class MotionPathOverlayPainter extends CustomPainter {
  const MotionPathOverlayPainter({
    required this.motionPaths,
    required this.previewNodes, // non-empty during drawing mode
    required this.zoom,
    required this.pathColor,
    required this.nodeColor,
  });

  final List<VecMotionPath> motionPaths;
  final List<VecPathNode> previewNodes;
  final double zoom;
  final Color pathColor;
  final Color nodeColor;

  static const double _nodeRadius = 4.0;
  static const double _dashLen = 6.0;
  static const double _gapLen = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw committed motion paths
    for (final mp in motionPaths) {
      _drawNodes(canvas, mp.nodes, mp.isClosed, false);
    }
    // Draw live preview (while user is placing nodes)
    if (previewNodes.length >= 2) {
      _drawNodes(canvas, previewNodes, false, true);
    }
    // Draw preview nodes as circles (even single-node preview)
    if (previewNodes.isNotEmpty) {
      _drawHandles(canvas, previewNodes, true);
    }
  }

  void _drawNodes(Canvas canvas, List<VecPathNode> nodes, bool isClosed,
      bool isPreview) {
    if (nodes.length < 2) {
      _drawHandles(canvas, nodes, isPreview);
      return;
    }

    final paint = Paint()
      ..color = pathColor.withAlpha(isPreview ? 160 : 200)
      ..strokeWidth = 1.5 / zoom
      ..style = PaintingStyle.stroke;

    final segCount = isClosed ? nodes.length : nodes.length - 1;

    for (var s = 0; s < segCount; s++) {
      final a = nodes[s];
      final b = nodes[(s + 1) % nodes.length];
      final p0 = _off(a.position.x, a.position.y);
      final p1 = a.handleOut != null
          ? _off(a.handleOut!.x, a.handleOut!.y)
          : p0;
      final p2 = b.handleIn != null
          ? _off(b.handleIn!.x, b.handleIn!.y)
          : _off(b.position.x, b.position.y);
      final p3 = _off(b.position.x, b.position.y);

      _drawDashedCubic(canvas, p0, p1, p2, p3, paint);
    }

    _drawHandles(canvas, nodes, isPreview);
  }

  void _drawHandles(Canvas canvas, List<VecPathNode> nodes, bool isPreview) {
    final circlePaint = Paint()
      ..color = isPreview
          ? nodeColor.withAlpha(180)
          : nodeColor
      ..style = PaintingStyle.fill;
    final outlinePaint = Paint()
      ..color = Colors.white.withAlpha(200)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 / zoom;

    final r = _nodeRadius / zoom;
    for (final n in nodes) {
      final c = _off(n.position.x, n.position.y);
      canvas.drawCircle(c, r, circlePaint);
      canvas.drawCircle(c, r, outlinePaint);

      // Draw bezier handles if present
      if (n.handleIn != null) {
        final h = _off(n.handleIn!.x, n.handleIn!.y);
        _drawHandleLine(canvas, c, h);
        canvas.drawCircle(h, r * 0.7, outlinePaint);
      }
      if (n.handleOut != null) {
        final h = _off(n.handleOut!.x, n.handleOut!.y);
        _drawHandleLine(canvas, c, h);
        canvas.drawCircle(h, r * 0.7, outlinePaint);
      }
    }
  }

  void _drawHandleLine(Canvas canvas, Offset from, Offset to) {
    canvas.drawLine(
      from,
      to,
      Paint()
        ..color = nodeColor.withAlpha(120)
        ..strokeWidth = 0.8 / zoom,
    );
  }

  // ---------------------------------------------------------------------------
  // Dashed cubic Bézier
  // ---------------------------------------------------------------------------

  void _drawDashedCubic(Canvas canvas, Offset p0, Offset p1, Offset p2,
      Offset p3, Paint paint) {
    const samples = 60;
    final pts = [
      for (var i = 0; i <= samples; i++)
        _cubic(p0, p1, p2, p3, i / samples),
    ];

    // Walk along sample list, drawing dashes
    double remainder = _dashLen / zoom;
    bool drawing = true;
    var prev = pts.first;

    for (var i = 1; i < pts.length; i++) {
      var seg = pts[i] - prev;
      var segLen = seg.distance;

      while (segLen > 0) {
        if (segLen <= remainder) {
          if (drawing) canvas.drawLine(prev, pts[i], paint);
          remainder -= segLen;
          prev = pts[i];
          segLen = 0;
        } else {
          final frac = remainder / segLen;
          final mid = prev + seg * frac;
          if (drawing) canvas.drawLine(prev, mid, paint);
          prev = mid;
          seg = pts[i] - mid;
          segLen = seg.distance;
          drawing = !drawing;
          remainder = (drawing ? _dashLen : _gapLen) / zoom;
        }
      }
    }
  }

  Offset _cubic(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
    final mt = 1 - t;
    return p0 * (mt * mt * mt) +
        p1 * (3 * mt * mt * t) +
        p2 * (3 * mt * t * t) +
        p3 * (t * t * t);
  }

  Offset _off(double x, double y) => Offset(x, y);

  @override
  bool shouldRepaint(covariant MotionPathOverlayPainter old) =>
      old.motionPaths != motionPaths ||
      old.previewNodes != previewNodes ||
      old.zoom != zoom;
}

// ---------------------------------------------------------------------------
// Hit-test helpers (used by editor_canvas)
// ---------------------------------------------------------------------------

class MotionPathHitTest {
  const MotionPathHitTest._();

  static const double _hitRadius = 8.0;

  /// Returns the (pathId, nodeIndex) of the node nearest to [canvasPos],
  /// or null if nothing is within [_hitRadius / zoom] canvas units.
  static ({String pathId, int nodeIndex})? hitTestNode(
    List<VecMotionPath> paths,
    Offset canvasPos,
    double zoom,
  ) {
    final threshold = _hitRadius / zoom;
    for (final mp in paths) {
      for (var i = 0; i < mp.nodes.length; i++) {
        final n = mp.nodes[i];
        final d = (Offset(n.position.x, n.position.y) - canvasPos).distance;
        if (d <= threshold) return (pathId: mp.id, nodeIndex: i);
      }
    }
    return null;
  }
}
