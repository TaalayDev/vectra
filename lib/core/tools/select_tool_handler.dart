import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/models/vec_transform.dart';

/// Geometry helpers and hit-testing for the Select tool.
class SelectToolHandler {
  const SelectToolHandler._();

  // Handle layout order (matches SelectionOverlayPainter):
  // 0:topLeft  1:topCenter  2:topRight
  // 3:centerLeft             4:centerRight
  // 5:bottomLeft 6:bottomCenter 7:bottomRight
  static const _handleSize = 8.0;
  static const _rotateHandleOffset = 20.0;

  // ---------------------------------------------------------------------------
  // Coordinate conversions
  // ---------------------------------------------------------------------------

  /// Converts a point in shape-local space to canvas space.
  static Offset localToCanvas(VecTransform t, Offset localPoint) {
    final px = t.pivot?.x ?? (t.width / 2);
    final py = t.pivot?.y ?? (t.height / 2);
    final angle = t.rotation * math.pi / 180;
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);

    final relX = (localPoint.dx - px) * t.scaleX;
    final relY = (localPoint.dy - py) * t.scaleY;

    final rotX = relX * cosA - relY * sinA;
    final rotY = relX * sinA + relY * cosA;

    return Offset(t.x + px + rotX, t.y + py + rotY);
  }

  /// Converts a point in canvas space to shape-local space.
  static Offset canvasToLocal(VecTransform t, Offset canvasPoint) {
    final px = t.pivot?.x ?? (t.width / 2);
    final py = t.pivot?.y ?? (t.height / 2);
    final angle = t.rotation * math.pi / 180;
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);

    final rx = canvasPoint.dx - (t.x + px);
    final ry = canvasPoint.dy - (t.y + py);

    final unrotX = rx * cosA + ry * sinA;
    final unrotY = -rx * sinA + ry * cosA;

    return Offset(unrotX / t.scaleX + px, unrotY / t.scaleY + py);
  }

  // ---------------------------------------------------------------------------
  // Hit testing
  // ---------------------------------------------------------------------------

  /// Returns which handle the [canvasPoint] hits.
  /// Returns -2 for rotation handle, 0-7 for resize handles, -1 for none.
  static int hitTestHandles(
    VecTransform t,
    double zoom,
    Offset canvasPoint,
  ) {
    final hitRadius = _handleSize / zoom;

    // Rotation handle is at local (w/2, -rotateOffset/zoom)
    final rotateLocal = Offset(t.width / 2, -_rotateHandleOffset / zoom);
    final rotateCanvas = localToCanvas(t, rotateLocal);
    if ((canvasPoint - rotateCanvas).distance < hitRadius) return -2;

    // 8 resize handles
    final handles = _handleLocalPositions(t);
    for (var i = 0; i < handles.length; i++) {
      final canvasPos = localToCanvas(t, handles[i]);
      if ((canvasPoint - canvasPos).distance < hitRadius) return i;
    }

    return -1;
  }

  /// Returns true if [canvasPoint] is inside the shape's bounding box.
  static bool hitTestBody(VecTransform t, Offset canvasPoint) {
    final local = canvasToLocal(t, canvasPoint);
    return local.dx >= 0 &&
        local.dx <= t.width &&
        local.dy >= 0 &&
        local.dy <= t.height;
  }

  // ---------------------------------------------------------------------------
  // Transform application
  // ---------------------------------------------------------------------------

  /// Applies a resize delta to [start] transform for the given [handleIndex]
  /// and [canvasDelta]. Returns the updated transform.
  static VecTransform applyResizeHandle(
    VecTransform start,
    int handleIndex,
    Offset canvasDelta,
  ) {
    final angle = start.rotation * math.pi / 180;
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);

    // Convert canvas delta → shape-local delta (unrotate)
    final ldx = canvasDelta.dx * cosA + canvasDelta.dy * sinA;
    final ldy = -canvasDelta.dx * sinA + canvasDelta.dy * cosA;

    double dx = 0, dy = 0, dw = 0, dh = 0;

    switch (handleIndex) {
      case 0: // topLeft
        dx = ldx; dy = ldy; dw = -ldx; dh = -ldy;
      case 1: // topCenter
        dy = ldy; dh = -ldy;
      case 2: // topRight
        dw = ldx; dy = ldy; dh = -ldy;
      case 3: // centerLeft
        dx = ldx; dw = -ldx;
      case 4: // centerRight
        dw = ldx;
      case 5: // bottomLeft
        dx = ldx; dw = -ldx; dh = ldy;
      case 6: // bottomCenter
        dh = ldy;
      case 7: // bottomRight
        dw = ldx; dh = ldy;
    }

    // Convert local position delta back to canvas space
    final canvasDx = dx * cosA - dy * sinA;
    final canvasDy = dx * sinA + dy * cosA;

    final newW = dw != 0 ? math.max(1.0, start.width + dw) : start.width;
    final newH = dh != 0 ? math.max(1.0, start.height + dh) : start.height;

    // Clamp dw/dh if size was clamped (prevents position jumping)
    final actualDw = newW - start.width;
    final actualDh = newH - start.height;
    final finalDx = (dw == 0) ? 0.0 : (dx != 0 ? -actualDw : 0.0);
    final finalDy = (dh == 0) ? 0.0 : (dy != 0 ? -actualDh : 0.0);

    final finalCanvasDx = (dx == 0) ? 0.0 : (finalDx * cosA - finalDy * sinA);
    final finalCanvasDy = (dx == 0 && dy == 0)
        ? 0.0
        : (finalDx * sinA + finalDy * cosA);

    return start.copyWith(
      x: start.x + (dx == 0 ? 0 : canvasDx),
      y: start.y + (dy == 0 ? 0 : canvasDy),
      width: newW,
      height: newH,
    );
  }

  /// Returns the mouse cursor to show based on which handle is hovered.
  static MouseCursor cursorForHandle(int handleIndex) {
    switch (handleIndex) {
      case -2:
        return SystemMouseCursors.grab;
      case 0:
      case 7:
        return SystemMouseCursors.resizeUpLeftDownRight;
      case 2:
      case 5:
        return SystemMouseCursors.resizeUpRightDownLeft;
      case 1:
      case 6:
        return SystemMouseCursors.resizeUpDown;
      case 3:
      case 4:
        return SystemMouseCursors.resizeLeftRight;
      default:
        return SystemMouseCursors.move;
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static List<Offset> _handleLocalPositions(VecTransform t) {
    final w = t.width;
    final h = t.height;
    return [
      Offset(0, 0),       // 0: topLeft
      Offset(w / 2, 0),   // 1: topCenter
      Offset(w, 0),       // 2: topRight
      Offset(0, h / 2),   // 3: centerLeft
      Offset(w, h / 2),   // 4: centerRight
      Offset(0, h),       // 5: bottomLeft
      Offset(w / 2, h),   // 6: bottomCenter
      Offset(w, h),       // 7: bottomRight
    ];
  }
}
