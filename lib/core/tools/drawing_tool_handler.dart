import 'package:uuid/uuid.dart';

import '../../data/models/vec_color.dart';
import '../../data/models/vec_fill.dart';
import '../../data/models/vec_path_node.dart';
import '../../data/models/vec_point.dart';
import '../../data/models/vec_shape.dart';
import '../../data/models/vec_stroke.dart';
import '../../data/models/vec_transform.dart';
import '../../providers/drawing_state_provider.dart';

const _uuid = Uuid();

/// Creates a [VecShape] from a completed [DrawingState] drag.
class DrawingToolHandler {
  const DrawingToolHandler();

  /// Creates a rectangle shape from a drag region.
  VecShape createRectangle(DrawingState drawing) {
    return VecShape.rectangle(
      data: _shapeData(drawing),
      cornerRadii: const [0, 0, 0, 0],
    );
  }

  /// Creates an ellipse shape from a drag region.
  VecShape createEllipse(DrawingState drawing) {
    return VecShape.ellipse(
      data: _shapeData(drawing),
    );
  }

  /// Creates a text shape from a drag region.
  VecShape createText(DrawingState drawing) {
    return VecShape.text(
      data: _shapeData(drawing),
      content: 'Text',
      fontSize: 24,
    );
  }

  /// Creates a path (polyline) shape from pen tool points.
  VecShape createPath(PenDrawingState pen, {bool closed = false}) {
    if (pen.points.isEmpty) {
      return VecShape.path(
        data: VecShapeData(
          id: _uuid.v4(),
          transform: const VecTransform(),
          fills: closed ? _defaultFills : const [],
          strokes: _defaultStrokes,
        ),
        nodes: const [],
        isClosed: closed,
      );
    }

    // Compute bounding box of all points
    var minX = pen.points.first.dx;
    var minY = pen.points.first.dy;
    var maxX = minX;
    var maxY = minY;
    for (final p in pen.points) {
      if (p.dx < minX) minX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy > maxY) maxY = p.dy;
    }

    // Nodes are relative to the shape's transform position
    final nodes = pen.points.map((p) {
      return VecPathNode(
        position: VecPoint(x: p.dx - minX, y: p.dy - minY),
      );
    }).toList();

    return VecShape.path(
      data: VecShapeData(
        id: _uuid.v4(),
        transform: VecTransform(
          x: minX,
          y: minY,
          width: maxX - minX,
          height: maxY - minY,
        ),
        fills: closed ? _defaultFills : const [],
        strokes: _defaultStrokes,
      ),
      nodes: nodes,
      isClosed: closed,
    );
  }

  VecShapeData _shapeData(DrawingState drawing) {
    return VecShapeData(
      id: _uuid.v4(),
      transform: VecTransform(
        x: drawing.left,
        y: drawing.top,
        width: drawing.width,
        height: drawing.height,
      ),
      fills: _defaultFills,
      strokes: _defaultStrokes,
    );
  }

  static const _defaultFills = [
    VecFill(color: VecColor(a: 255, r: 120, g: 160, b: 230), opacity: 1.0),
  ];

  static const _defaultStrokes = [
    VecStroke(color: VecColor(a: 255, r: 50, g: 60, b: 80), width: 2),
  ];
}
