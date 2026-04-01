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
  const DrawingToolHandler({
    this.fillColor = const VecColor(a: 255, r: 120, g: 160, b: 230),
    this.strokeColor = const VecColor(a: 255, r: 50, g: 60, b: 80),
  });

  final VecColor fillColor;
  final VecColor strokeColor;

  List<VecFill> get _fills => [VecFill(color: fillColor)];
  List<VecFill> get _textFills => [const VecFill(color: VecColor.black)];
  List<VecStroke> get _strokes => [VecStroke(color: strokeColor, width: 2)];

  /// Creates a rectangle shape from a drag region.
  VecShape createRectangle(DrawingState drawing) {
    return VecShape.rectangle(data: _shapeData(drawing), cornerRadii: const [0, 0, 0, 0]);
  }

  /// Creates an ellipse shape from a drag region.
  VecShape createEllipse(DrawingState drawing) {
    return VecShape.ellipse(data: _shapeData(drawing));
  }

  /// Creates a 2-node line (open path) from a drag. No fill, stroke only.
  VecShape createLine(DrawingState drawing) {
    final left = drawing.left;
    final top = drawing.top;
    final w = drawing.width < 1 ? 1.0 : drawing.width;
    final h = drawing.height < 1 ? 1.0 : drawing.height;

    final startLocal = VecPoint(x: drawing.startPoint.dx - left, y: drawing.startPoint.dy - top);
    final endLocal = VecPoint(x: drawing.currentPoint.dx - left, y: drawing.currentPoint.dy - top);

    return VecShape.path(
      data: VecShapeData(
        id: _uuid.v4(),
        transform: VecTransform(x: left, y: top, width: w, height: h),
        fills: const [],
        strokes: _strokes,
      ),
      nodes: [
        VecPathNode(position: startLocal, type: VecNodeType.corner),
        VecPathNode(position: endLocal, type: VecNodeType.corner),
      ],
      isClosed: false,
    );
  }

  /// Creates a text shape from a drag region.
  VecShape createText(DrawingState drawing) {
    return VecShape.text(
      data: VecShapeData(
        id: _uuid.v4(),
        transform: VecTransform(x: drawing.left, y: drawing.top, width: drawing.width, height: drawing.height),
        fills: _textFills,
        strokes: const [],
      ),
      content: 'Text',
      fontSize: 24,
    );
  }

  /// Creates a path shape from pen tool nodes, preserving bezier handles.
  VecShape createPath(PenDrawingState pen, {bool closed = false}) {
    if (pen.nodes.isEmpty) {
      return VecShape.path(
        data: VecShapeData(
          id: _uuid.v4(),
          transform: const VecTransform(),
          fills: closed ? _fills : const [],
          strokes: _strokes,
        ),
        nodes: const [],
        isClosed: closed,
      );
    }

    // Bounding box from node positions only (handles may extend slightly outside)
    var minX = pen.nodes.first.position.dx;
    var minY = pen.nodes.first.position.dy;
    var maxX = minX;
    var maxY = minY;
    for (final n in pen.nodes) {
      final p = n.position;
      if (p.dx < minX) minX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy > maxY) maxY = p.dy;
    }
    // Avoid degenerate (zero-size) bounding box
    if (maxX - minX < 1) maxX = minX + 1;
    if (maxY - minY < 1) maxY = minY + 1;

    // Convert canvas-space PenNodes to shape-local VecPathNodes
    final nodes = pen.nodes.map((n) {
      final localPos = VecPoint(x: n.position.dx - minX, y: n.position.dy - minY);
      VecPoint? handleOut;
      VecPoint? handleIn;
      if (n.isCurve) {
        handleOut = VecPoint(x: n.handleOut!.dx - minX, y: n.handleOut!.dy - minY);
        final hi = n.handleIn!;
        handleIn = VecPoint(x: hi.dx - minX, y: hi.dy - minY);
      }
      return VecPathNode(
        position: localPos,
        handleOut: handleOut,
        handleIn: handleIn,
        type: n.isCurve ? VecNodeType.smooth : VecNodeType.corner,
      );
    }).toList();

    return VecShape.path(
      data: VecShapeData(
        id: _uuid.v4(),
        transform: VecTransform(x: minX, y: minY, width: maxX - minX, height: maxY - minY),
        fills: closed ? _fills : const [],
        strokes: _strokes,
      ),
      nodes: nodes,
      isClosed: closed,
    );
  }

  VecShapeData _shapeData(DrawingState drawing) {
    return VecShapeData(
      id: _uuid.v4(),
      transform: VecTransform(x: drawing.left, y: drawing.top, width: drawing.width, height: drawing.height),
      fills: _fills,
      strokes: _strokes,
    );
  }
}
