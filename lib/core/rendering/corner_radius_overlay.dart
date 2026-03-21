import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/models/vec_shape.dart';
import '../tools/select_tool_handler.dart';

/// Paints the four corner-radius drag handles for a selected rectangle,
/// mirroring Illustrator's corner-widget behaviour.
///
/// Handle order: 0 = TL, 1 = TR, 2 = BR, 3 = BL.
class CornerRadiusOverlayPainter extends CustomPainter {
  CornerRadiusOverlayPainter({
    required this.shape,
    required this.zoom,
    required this.selectedCorners,
    required this.hoverCornerIndex,
    required this.color,
  });

  final VecRectangleShape shape;
  final double zoom;
  final Set<int> selectedCorners;
  final int hoverCornerIndex;
  final Color color;

  static const double _handleRadius = 5.0;

  // -------------------------------------------------------------------------
  // Public geometry helpers
  // -------------------------------------------------------------------------

  /// Returns the 4 handle positions in shape-local space.
  /// Order: 0=TL, 1=TR, 2=BR, 3=BL.
  static List<Offset> handleLocalPositions(
      VecRectangleShape shape, double zoom) {
    final t = shape.data.transform;
    final w = t.width;
    final h = t.height;
    final maxR = math.min(w, h) / 2;
    final minInset = math.max(6.0 / zoom, 0.5);

    final corners = [
      Offset(0, 0),
      Offset(w, 0),
      Offset(w, h),
      Offset(0, h),
    ];
    // Inward direction signs per corner
    const signs = [
      Offset(1, 1),   // TL → right+down
      Offset(-1, 1),  // TR → left+down
      Offset(-1, -1), // BR → left+up
      Offset(1, -1),  // BL → right+up
    ];

    final radii = shape.cornerRadii.length == 4
        ? shape.cornerRadii
        : [0.0, 0.0, 0.0, 0.0];

    return List.generate(4, (i) {
      final r = radii[i].clamp(0.0, maxR);
      // When r=0 show handle at minInset so it's always clickable.
      final inset =
          math.max(r, minInset).clamp(minInset, math.max(minInset, maxR));
      return corners[i] +
          Offset(signs[i].dx * inset, signs[i].dy * inset);
    });
  }

  /// Hit-tests [canvasPoint] against all four handles.
  /// Returns 0-3 for the matching corner, or -1 for no hit.
  static int hitTestHandle(
      VecRectangleShape shape, double zoom, Offset canvasPoint) {
    final t = shape.data.transform;
    final positions = handleLocalPositions(shape, zoom);
    final hitRadius = 8.0 / zoom;

    for (var i = 0; i < 4; i++) {
      final canvasPos = SelectToolHandler.localToCanvas(t, positions[i]);
      if ((canvasPoint - canvasPos).distance < hitRadius) return i;
    }
    return -1;
  }

  // -------------------------------------------------------------------------
  // Painting
  // -------------------------------------------------------------------------

  @override
  void paint(Canvas canvas, Size size) {
    final t = shape.data.transform;
    final px = t.pivot?.x ?? (t.width / 2);
    final py = t.pivot?.y ?? (t.height / 2);

    canvas.save();
    canvas.translate(t.x, t.y);
    canvas.translate(px, py);
    if (t.rotation != 0) canvas.rotate(t.rotation * math.pi / 180);
    if (t.scaleX != 1 || t.scaleY != 1) canvas.scale(t.scaleX, t.scaleY);
    canvas.translate(-px, -py);

    final positions = handleLocalPositions(shape, zoom);
    final hr = _handleRadius / zoom;

    for (var i = 0; i < 4; i++) {
      final isSelected = selectedCorners.contains(i);
      final isHovered = hoverCornerIndex == i;

      // Fill: solid when selected, semi-transparent when hovered, hollow when neither
      final fillAlpha = isSelected
          ? 255
          : isHovered
              ? 120
              : 0;
      // Stroke: full color always
      final strokeAlpha = isSelected || isHovered ? 255 : 180;

      if (fillAlpha > 0) {
        canvas.drawCircle(
          positions[i],
          hr,
          Paint()
            ..color = color.withAlpha(fillAlpha)
            ..style = PaintingStyle.fill,
        );
      }

      // White inner dot when selected (like Illustrator)
      if (isSelected) {
        canvas.drawCircle(
          positions[i],
          hr * 0.4,
          Paint()
            ..color = Colors.white.withAlpha(220)
            ..style = PaintingStyle.fill,
        );
      }

      canvas.drawCircle(
        positions[i],
        hr,
        Paint()
          ..color = color.withAlpha(strokeAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2 / zoom,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CornerRadiusOverlayPainter old) =>
      old.shape != shape ||
      old.zoom != zoom ||
      old.selectedCorners != selectedCorners ||
      old.hoverCornerIndex != hoverCornerIndex ||
      old.color != color;
}
