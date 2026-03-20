import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../providers/drawing_state_provider.dart';
import '../../providers/editor_state_provider.dart';

/// Paints a live preview of the shape being drawn (drag in progress).
class DrawingPreviewPainter extends CustomPainter {
  DrawingPreviewPainter({
    required this.tool,
    this.drawing,
    this.penDrawing,
    required this.previewColor,
    required this.strokeColor,
  });

  final VecTool tool;
  final DrawingState? drawing;
  final PenDrawingState? penDrawing;
  final Color previewColor;
  final Color strokeColor;

  @override
  void paint(Canvas canvas, Size size) {
    switch (tool) {
      case VecTool.rectangle:
        if (drawing != null) _paintRectanglePreview(canvas);
        break;
      case VecTool.ellipse:
        if (drawing != null) _paintEllipsePreview(canvas);
        break;
      case VecTool.pen:
        if (penDrawing != null) _paintPenPreview(canvas);
        break;
      case VecTool.text:
        if (drawing != null) _paintTextPreview(canvas);
        break;
      default:
        break;
    }
  }

  void _paintRectanglePreview(Canvas canvas) {
    final d = drawing!;
    final rect = Rect.fromLTWH(d.left, d.top, d.width, d.height);
    if (rect.isEmpty) return;

    canvas.drawRect(rect, _fillPaint);
    canvas.drawRect(rect, _strokePaint);
    _drawDimensionHint(canvas, rect);
  }

  void _paintEllipsePreview(Canvas canvas) {
    final d = drawing!;
    final rect = Rect.fromLTWH(d.left, d.top, d.width, d.height);
    if (rect.isEmpty) return;

    canvas.drawOval(rect, _fillPaint);
    canvas.drawOval(rect, _strokePaint);
    _drawDimensionHint(canvas, rect);
  }

  void _paintTextPreview(Canvas canvas) {
    final d = drawing!;
    final rect = Rect.fromLTWH(d.left, d.top, d.width, d.height);
    if (rect.isEmpty) return;

    // Dashed border for text frame
    final dashPaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    _drawDashedRect(canvas, rect, dashPaint);

    // Text cursor hint
    final cursorPaint = Paint()
      ..color = strokeColor
      ..strokeWidth = 1.5;
    final cursorX = rect.left + 8;
    canvas.drawLine(
      Offset(cursorX, rect.top + 6),
      Offset(cursorX, rect.bottom - 6),
      cursorPaint,
    );
  }

  void _paintPenPreview(Canvas canvas) {
    final points = penDrawing!.points;
    if (points.isEmpty) return;

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, _strokePaint);

    // Draw node dots
    final dotPaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.fill;
    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final p in points) {
      canvas.drawCircle(p, 4, dotPaint);
      canvas.drawCircle(p, 4, dotBorderPaint);
    }
  }

  void _drawDimensionHint(Canvas canvas, Rect rect) {
    final text = '${rect.width.round()} x ${rect.height.round()}';
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final pillW = tp.width + 12;
    final pillH = tp.height + 6;
    final pillRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(rect.center.dx, rect.bottom + 16),
        width: pillW,
        height: pillH,
      ),
      const Radius.circular(4),
    );

    canvas.drawRRect(pillRect, Paint()..color = strokeColor.withAlpha(200));
    tp.paint(canvas, Offset(pillRect.left + 6, pillRect.top + 3));
  }

  void _drawDashedRect(Canvas canvas, Rect rect, Paint paint) {
    const dashLen = 5.0;
    const gapLen = 3.0;

    void drawDashedLine(Offset from, Offset to) {
      final dx = to.dx - from.dx;
      final dy = to.dy - from.dy;
      final len = math.sqrt(dx * dx + dy * dy);
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
        dist = end;
        draw = !draw;
      }
    }

    drawDashedLine(rect.topLeft, rect.topRight);
    drawDashedLine(rect.topRight, rect.bottomRight);
    drawDashedLine(rect.bottomRight, rect.bottomLeft);
    drawDashedLine(rect.bottomLeft, rect.topLeft);
  }

  Paint get _fillPaint => Paint()
    ..color = previewColor.withAlpha(50)
    ..style = PaintingStyle.fill;

  Paint get _strokePaint => Paint()
    ..color = strokeColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  @override
  bool shouldRepaint(covariant DrawingPreviewPainter old) {
    return old.drawing != drawing ||
        old.penDrawing != penDrawing ||
        old.tool != tool;
  }
}
