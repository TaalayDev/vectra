import 'package:flutter/material.dart';

import '../../core/tools/select_tool_handler.dart';
import '../../data/models/vec_path_node.dart';
import '../../data/models/vec_shape.dart';
import '../../data/models/vec_transform.dart';

/// Paints editable node dots (and handle circles) for a selected path shape.
///
/// Nodes and handles are drawn in canvas space (same coordinate system as
/// [ScenePainter]), so sizes are divided by [zoom] to keep fixed screen sizes.
class PathEditOverlayPainter extends CustomPainter {
  const PathEditOverlayPainter({
    required this.shape,
    required this.nodeColor,
    required this.zoom,
    this.hoveredNodeIndex = -1,
    this.draggedNodeIndex = -1,
  });

  final VecPathShape shape;
  final Color nodeColor;
  final double zoom;
  final int hoveredNodeIndex;
  final int draggedNodeIndex;

  static const _nodeScreenRadius = 4.5;
  static const _handleScreenRadius = 3.0;
  static const _hitScreenRadius = 8.0;

  @override
  void paint(Canvas canvas, Size size) {
    final nodes = shape.nodes;
    if (nodes.isEmpty) return;
    final t = shape.data.transform;

    final nr = _nodeScreenRadius / zoom;
    final hr = _handleScreenRadius / zoom;
    final sw = 1.5 / zoom;

    final handleLinePaint = Paint()
      ..color = nodeColor.withAlpha(160)
      ..strokeWidth = 1.0 / zoom
      ..style = PaintingStyle.stroke;

    // 1. Handle lines + handle dots (behind node dots)
    for (final n in nodes) {
      final pos = _toCanvas(t, n.position.x, n.position.y);
      if (n.handleOut != null) {
        final ho = _toCanvas(t, n.handleOut!.x, n.handleOut!.y);
        canvas.drawLine(pos, ho, handleLinePaint);
        _drawHandleDot(canvas, ho, hr, sw);
      }
      if (n.handleIn != null) {
        final hi = _toCanvas(t, n.handleIn!.x, n.handleIn!.y);
        canvas.drawLine(pos, hi, handleLinePaint);
        _drawHandleDot(canvas, hi, hr, sw);
      }
    }

    // 2. Node dots (on top)
    for (var i = 0; i < nodes.length; i++) {
      final n = nodes[i];
      final pos = _toCanvas(t, n.position.x, n.position.y);
      final active = i == hoveredNodeIndex || i == draggedNodeIndex;
      _drawNodeDot(canvas, pos, nr, sw, active);
    }
  }

  static Offset _toCanvas(VecTransform t, double lx, double ly) =>
      SelectToolHandler.localToCanvas(t, Offset(lx, ly));

  void _drawNodeDot(Canvas canvas, Offset p, double r, double sw, bool active) {
    canvas.drawCircle(
        p,
        r,
        Paint()
          ..color = active ? nodeColor : nodeColor.withAlpha(210)
          ..style = PaintingStyle.fill);
    canvas.drawCircle(
        p,
        r,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw);
  }

  void _drawHandleDot(Canvas canvas, Offset p, double r, double sw) {
    canvas.drawCircle(
        p,
        r,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill);
    canvas.drawCircle(
        p,
        r,
        Paint()
          ..color = nodeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw);
  }

  /// Returns the node index closest to [canvasPoint] within the hit radius,
  /// or -1 if none.
  static int hitTestNode(
    VecPathShape shape,
    Offset canvasPoint,
    double zoom,
  ) {
    final hitR = _hitScreenRadius / zoom;
    final t = shape.data.transform;
    final nodes = shape.nodes;
    for (var i = 0; i < nodes.length; i++) {
      final nodeCanvas =
          SelectToolHandler.localToCanvas(t, Offset(nodes[i].position.x, nodes[i].position.y));
      if ((nodeCanvas - canvasPoint).distance <= hitR) return i;
    }
    return -1;
  }

  @override
  bool shouldRepaint(covariant PathEditOverlayPainter old) =>
      old.shape != shape ||
      old.zoom != zoom ||
      old.hoveredNodeIndex != hoveredNodeIndex ||
      old.draggedNodeIndex != draggedNodeIndex;
}
