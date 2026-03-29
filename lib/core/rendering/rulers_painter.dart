import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Paints horizontal (top) and vertical (left) rulers.
/// Overlay on the main canvas Stack — not inside the stage transform.
class RulersPainter extends CustomPainter {
  const RulersPainter({
    required this.zoom,
    required this.stageLeft,
    required this.stageTop,
    required this.cursorPos,
    required this.bgColor,
    required this.tickColor,
    required this.borderColor,
  });

  final double zoom;
  final double stageLeft;
  final double stageTop;
  final Offset cursorPos;
  final Color bgColor;
  final Color tickColor;
  final Color borderColor;

  static const rulerSize = 20.0;

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = bgColor;
    // Draw ruler backgrounds
    canvas.drawRect(Rect.fromLTWH(rulerSize, 0, size.width - rulerSize, rulerSize), bgPaint);
    canvas.drawRect(Rect.fromLTWH(0, rulerSize, rulerSize, size.height - rulerSize), bgPaint);
    canvas.drawRect(Rect.fromLTWH(0, 0, rulerSize, rulerSize), bgPaint);

    // Bottom border of horizontal ruler
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 0.5;
    canvas.drawLine(Offset(0, rulerSize), Offset(size.width, rulerSize), borderPaint);
    canvas.drawLine(Offset(rulerSize, 0), Offset(rulerSize, size.height), borderPaint);

    final step = _niceStep(50.0 / zoom);
    _drawHRuler(canvas, size, step);
    _drawVRuler(canvas, size, step);
    _drawCursorMark(canvas, size);
  }

  static double _niceStep(double rawStep) {
    const nice = [2000.0, 1000.0, 500.0, 200.0, 100.0, 50.0, 20.0, 10.0, 5.0, 2.0, 1.0, 0.5];
    for (final v in nice) {
      if (rawStep <= v) return v;
    }
    return 0.25;
  }

  void _drawHRuler(Canvas canvas, Size size, double step) {
    final tick = Paint()
      ..color = tickColor
      ..strokeWidth = 0.5;
    final tp = TextPainter(textDirection: TextDirection.ltr);

    final startC = ((rulerSize - stageLeft) / zoom / step).floorToDouble() * step;
    final endC = (size.width - stageLeft) / zoom;

    for (double cx = startC; cx <= endC + step; cx += step) {
      final sx = stageLeft + cx * zoom;
      if (sx < rulerSize) continue;
      if (sx > size.width) break;
      canvas.drawLine(Offset(sx, rulerSize - 6), Offset(sx, rulerSize), tick);

      final label = _fmt(cx.round());
      tp.text = TextSpan(
        text: label,
        style: TextStyle(fontSize: 8, color: tickColor.withAlpha(160)),
      );
      tp.layout(maxWidth: 40);
      if (sx + tp.width + 2 < size.width) {
        tp.paint(canvas, Offset(sx + 2, 4));
      }
    }
  }

  void _drawVRuler(Canvas canvas, Size size, double step) {
    final tick = Paint()
      ..color = tickColor
      ..strokeWidth = 0.5;
    final tp = TextPainter(textDirection: TextDirection.ltr);

    final startC = ((rulerSize - stageTop) / zoom / step).floorToDouble() * step;
    final endC = (size.height - stageTop) / zoom;

    for (double cy = startC; cy <= endC + step; cy += step) {
      final sy = stageTop + cy * zoom;
      if (sy < rulerSize) continue;
      if (sy > size.height) break;
      canvas.drawLine(Offset(rulerSize - 6, sy), Offset(rulerSize, sy), tick);

      // Rotated label
      canvas.save();
      canvas.translate(3, sy - 2);
      canvas.rotate(-math.pi / 2);
      final label = _fmt(cy.round());
      tp.text = TextSpan(
        text: label,
        style: TextStyle(fontSize: 8, color: tickColor.withAlpha(160)),
      );
      tp.layout(maxWidth: 40);
      tp.paint(canvas, Offset(0, 0));
      canvas.restore();
    }
  }

  void _drawCursorMark(Canvas canvas, Size size) {
    final mark = Paint()
      ..color = tickColor.withAlpha(220)
      ..strokeWidth = 1.0;
    if (cursorPos.dx >= rulerSize && cursorPos.dx <= size.width) {
      canvas.drawLine(Offset(cursorPos.dx, 0), Offset(cursorPos.dx, rulerSize), mark);
    }
    if (cursorPos.dy >= rulerSize && cursorPos.dy <= size.height) {
      canvas.drawLine(Offset(0, cursorPos.dy), Offset(rulerSize, cursorPos.dy), mark);
    }
  }

  static String _fmt(int v) {
    if (v.abs() >= 10000) return '${v ~/ 1000}k';
    return v.toString();
  }

  @override
  bool shouldRepaint(covariant RulersPainter old) =>
      old.zoom != zoom ||
      old.stageLeft != stageLeft ||
      old.stageTop != stageTop ||
      old.cursorPos != cursorPos ||
      old.bgColor != bgColor ||
      old.tickColor != tickColor;
}
