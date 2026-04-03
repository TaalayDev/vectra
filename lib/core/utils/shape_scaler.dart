import '../../data/models/vec_point.dart';
import '../../data/models/vec_shape.dart';

/// Utilities for scaling the raw geometry of structural shapes (Paths, Groups)
/// when their bounding box is resized by the user.
class ShapeScaler {
  const ShapeScaler._();

  /// Applies a physical scaling factor [sx] and [sy] to the internal geometry of [shape].
  /// This is required for `VecPathShape` (to scale its bezier nodes) and
  /// `VecGroupShape` (to scale/translate its children relative to the group bounds).
  static VecShape scaleGeometry(VecShape shape, double sx, double sy) {
    if (sx == 1.0 && sy == 1.0) return shape;

    return shape.map(
      // 1. Primitive shapes (Rectangle, Ellipse, Polygon, Image, SymbolInstance)
      // They draw themselves fluidly based on `transform.width` and `transform.height`.
      // We do NOT need to scale internal vectors, because their geometry is intrinsically
      // bound to the transform box. (Text is also typically structurally bound by the box).
      rectangle: (s) => s,
      ellipse: (s) => s,
      polygon: (s) => s,
      text: (s) => s,
      image: (s) => s,
      symbolInstance: (s) => s,

      // 2. Path
      // Paths have absolute nodes. We must multiply their coordinates.
      path: (s) {
        final scaledNodes = s.nodes.map((node) {
          return node.copyWith(
            position: VecPoint(
              x: node.position.x * sx,
              y: node.position.y * sy,
            ),
            handleIn: node.handleIn != null
                ? VecPoint(x: node.handleIn!.x * sx, y: node.handleIn!.y * sy)
                : null,
            handleOut: node.handleOut != null
                ? VecPoint(x: node.handleOut!.x * sx, y: node.handleOut!.y * sy)
                : null,
          );
        }).toList();

        return s.copyWith(nodes: scaledNodes);
      },

      // 3. Group
      // Groups act as logical containers. If a group is resized, all children must be
      // moved and resized proportionally.
      group: (s) {
        final scaledChildren = s.children.map((child) {
          final t = child.transform;

          // 1. Scale translation relative to group origin
          final newX = t.x * sx;
          final newY = t.y * sy;
          
          // 2. Calculate the new width/height of the child
          final newW = t.width * sx;
          final newH = t.height * sy;

          // 3. Create the new transform
          final newT = t.copyWith(
            x: newX,
            y: newY,
            width: newW,
            height: newH,
            // If the child has pivot, scale pivot proportionally
            pivot: t.pivot != null
                ? VecPoint(x: t.pivot!.x * sx, y: t.pivot!.y * sy)
                : null,
          );

          // Apply transform to child, then deeply scale child's inner geometry
          final updatedChild = child.copyWith(data: child.data.copyWith(transform: newT));
          return scaleGeometry(updatedChild, sx, sy);
        }).toList();

        return s.copyWith(children: scaledChildren);
      },

      // 4. Compound (Pathfinder ops)
      // Compounds are live. We scale their inputs exactly like groups.
      compound: (s) {
        final scaledInputs = s.inputs.map((child) {
          final t = child.transform;
          final newT = t.copyWith(
            x: t.x * sx,
            y: t.y * sy,
            width: t.width * sx,
            height: t.height * sy,
            pivot: t.pivot != null ? VecPoint(x: t.pivot!.x * sx, y: t.pivot!.y * sy) : null,
          );
          final updatedChild = child.copyWith(data: child.data.copyWith(transform: newT));
          return scaleGeometry(updatedChild, sx, sy);
        }).toList();

        return s.copyWith(inputs: scaledInputs);
      },
    );
  }
}
