import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/models/vec_shape.dart';
import '../../data/models/vec_transform.dart';

/// Paints selection outlines, handles, and rotation/resize affordances
/// around the selected shape.
class SelectionOverlayPainter extends CustomPainter {
  SelectionOverlayPainter({
    required this.shape,
    required this.selectionColor,
    required this.handleColor,
    required this.zoom,
  });

  final VecShape shape;
  final Color selectionColor;
  final Color handleColor;
  final double zoom;

  static const _handleSize = 8.0;
  static const _rotateHandleOffset = 20.0;

  @override
  void paint(Canvas canvas, Size size) {
    final t = shape.transform;
    final rect = Rect.fromLTWH(0, 0, t.width, t.height);

    canvas.save();
    _applyTransformForOverlay(canvas, t);

    // Dashed selection outline
    _drawSelectionBorder(canvas, rect);

    // Corner + edge handles
    _drawHandles(canvas, rect);

    // Rotation handle (line + circle above top center)
    _drawRotationHandle(canvas, rect);

    // Pivot point indicator
    _drawPivotHandle(canvas, t);

    // Dimension label
    _drawDimensionLabel(canvas, rect, t);

    canvas.restore();
  }

  void _applyTransformForOverlay(Canvas canvas, VecTransform t) {
    final px = t.pivot?.x ?? (t.width / 2);
    final py = t.pivot?.y ?? (t.height / 2);

    canvas.translate(t.x, t.y);
    canvas.translate(px, py);

    if (t.rotation != 0) {
      canvas.rotate(t.rotation * math.pi / 180);
    }
    if (t.scaleX != 1 || t.scaleY != 1) {
      canvas.scale(t.scaleX, t.scaleY);
    }

    canvas.translate(-px, -py);
  }

  void _drawSelectionBorder(Canvas canvas, Rect rect) {
    final borderPaint = Paint()
      ..color = selectionColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 / zoom;

    canvas.drawRect(rect, borderPaint);
  }

  void _drawHandles(Canvas canvas, Rect rect) {
    final s = _handleSize / zoom;
    final fillPaint = Paint()
      ..color = handleColor
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = selectionColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 / zoom;

    // 8 handles: 4 corners + 4 edge midpoints
    final handles = [
      rect.topLeft,
      rect.topCenter,
      rect.topRight,
      rect.centerLeft,
      rect.centerRight,
      rect.bottomLeft,
      rect.bottomCenter,
      rect.bottomRight,
    ];

    for (final pos in handles) {
      final handleRect = Rect.fromCenter(center: pos, width: s, height: s);
      canvas.drawRect(handleRect, fillPaint);
      canvas.drawRect(handleRect, borderPaint);
    }
  }

  void _drawRotationHandle(Canvas canvas, Rect rect) {
    final lineLength = _rotateHandleOffset / zoom;
    final top = rect.topCenter;
    final rotatePoint = Offset(top.dx, top.dy - lineLength);

    // Line from top center upward
    final linePaint = Paint()
      ..color = selectionColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 / zoom;
    canvas.drawLine(top, rotatePoint, linePaint);

    // Small circle at the end
    final radius = 4.0 / zoom;
    canvas.drawCircle(
      rotatePoint,
      radius,
      Paint()..color = handleColor,
    );
    canvas.drawCircle(
      rotatePoint,
      radius,
      Paint()
        ..color = selectionColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2 / zoom,
    );
  }

  void _drawPivotHandle(Canvas canvas, VecTransform t) {
    final px = t.pivot?.x ?? (t.width / 2);
    final py = t.pivot?.y ?? (t.height / 2);
    final pivot = Offset(px, py);

    final armLen = 5.0 / zoom;
    final radius = 3.5 / zoom;

    final paint = Paint()
      ..color = selectionColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 / zoom;

    // Crosshair
    canvas.drawLine(Offset(pivot.dx - armLen, pivot.dy), Offset(pivot.dx + armLen, pivot.dy), paint);
    canvas.drawLine(Offset(pivot.dx, pivot.dy - armLen), Offset(pivot.dx, pivot.dy + armLen), paint);

    // Circle
    canvas.drawCircle(pivot, radius, Paint()..color = handleColor);
    canvas.drawCircle(pivot, radius, paint);
  }

  void _drawDimensionLabel(Canvas canvas, Rect rect, VecTransform t) {
    final text = '${t.width.round()} x ${t.height.round()}';
    final fontSize = 10.0 / zoom;

    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          color: handleColor,
          fontWeight: FontWeight.w600,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Position below the bottom edge
    final labelOffset = Offset(
      rect.center.dx - tp.width / 2,
      rect.bottom + (12.0 / zoom),
    );

    // Background pill
    final pillRect = Rect.fromLTWH(
      labelOffset.dx - 6 / zoom,
      labelOffset.dy - 2 / zoom,
      tp.width + 12 / zoom,
      tp.height + 4 / zoom,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(pillRect, Radius.circular(3 / zoom)),
      Paint()..color = selectionColor,
    );

    tp.paint(canvas, labelOffset);
  }

  @override
  bool shouldRepaint(covariant SelectionOverlayPainter old) {
    return old.shape != shape ||
        old.selectionColor != selectionColor ||
        old.zoom != zoom;
  }
}
