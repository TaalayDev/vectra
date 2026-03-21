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
  BendHandleOverlayPainter({
    required this.shape,
    required this.zoom,
    required this.isHovered,
    required this.color,
  });

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
    final canvasPos =
        SelectToolHandler.localToCanvas(shape.data.transform, localPos);
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
      old.shape != shape ||
      old.zoom != zoom ||
      old.isHovered != isHovered ||
      old.color != color;
}
