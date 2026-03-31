import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/vec_path_node.dart';
import '../../data/models/vec_shape.dart';
import '../../data/models/vec_transform.dart';
import '../pathfinder/pathfinder.dart';

const _uuid = Uuid();

// -----------------------------------------------------------------------------
// Result type
// -----------------------------------------------------------------------------

class KnifeCutResult {
  const KnifeCutResult({required this.removeIds, required this.addShapes});

  /// IDs of original shapes that were cut and must be removed.
  final List<String> removeIds;

  /// Replacement pieces to add in their place.
  final List<VecShape> addShapes;

  bool get isEmpty => removeIds.isEmpty;
}

// -----------------------------------------------------------------------------
// KnifeTool
// -----------------------------------------------------------------------------

class KnifeTool {
  const KnifeTool();

  /// Cuts all eligible shapes in [shapes] along the polyline defined by
  /// [knifePoints] (canvas-space coordinates).
  ///
  /// Returns a [KnifeCutResult] describing which shapes to remove and what
  /// replacement pieces to insert.  If the knife line misses everything the
  /// result [isEmpty].
  KnifeCutResult cut(List<VecShape> shapes, List<Offset> knifePoints) {
    if (knifePoints.length < 2) return const KnifeCutResult(removeIds: [], addShapes: []);

    // Build the two complementary half-plane paths once for all shapes.
    final (leftPlane, rightPlane) = _buildHalfPlanes(knifePoints);

    final removeIds = <String>[];
    final addShapes = <VecShape>[];

    for (final shape in shapes) {
      final pieces = _cutShape(shape, leftPlane, rightPlane);
      if (pieces == null) continue; // not cut
      removeIds.add(shape.id);
      addShapes.addAll(pieces);
    }

    return KnifeCutResult(removeIds: removeIds, addShapes: addShapes);
  }

  // ---------------------------------------------------------------------------
  // Half-plane construction
  // ---------------------------------------------------------------------------

  /// Builds two complementary infinite half-planes that together tile the
  /// entire canvas plane, divided by the knife polyline.
  ///
  /// The "left" plane is the region to the left of the first→last knife
  /// direction; the "right" plane is its complement.
  (ui.Path left, ui.Path right) _buildHalfPlanes(List<Offset> pts) {
    // Build a large bounding box that certainly contains all canvas geometry.
    const big = 500000.0;
    const bigRect = Rect.fromLTRB(-big, -big, big, big);

    // Extend the knife line's endpoints far beyond the canvas so the cut always
    // exits the bounding region.
    final firstDir = (pts[0] - pts[1]).normalize();
    final lastDir = (pts[pts.length - 1] - pts[pts.length - 2]).normalize();
    final extStart = pts.first + firstDir * big;
    final extEnd = pts.last + lastDir * big;

    // Build the left-of-knife polygon:
    //   extended start → each knife point → extended end → far corners (TL, TR)
    // We choose far corners to always be "left" of the travel direction.
    final leftPath = ui.Path();
    leftPath.moveTo(extStart.dx, extStart.dy);
    for (final p in pts) {
      leftPath.lineTo(p.dx, p.dy);
    }
    leftPath.lineTo(extEnd.dx, extEnd.dy);
    // Close via a far corner arc: go to top-right, then top-left of the big rect
    // (which direction wraps around depends on the knife orientation, but the
    // intersection operation clips everything to the actual shape anyway).
    leftPath.lineTo(big, -big);
    leftPath.lineTo(-big, -big);
    leftPath.close();

    // Right plane = big rect minus the left polygon
    final rightPath = ui.Path.combine(
      ui.PathOperation.difference,
      ui.Path()..addRect(bigRect),
      leftPath,
    );

    return (leftPath, rightPath);
  }

  // ---------------------------------------------------------------------------
  // Per-shape cut
  // ---------------------------------------------------------------------------

  /// Returns null if the shape was not cut (no intersection or unsupported type).
  List<VecPathShape>? _cutShape(
    VecShape shape,
    ui.Path leftPlane,
    ui.Path rightPlane,
  ) {
    // Convert the shape to a canvas-space path
    final shapePath = _toCanvasPath(shape);
    if (shapePath == null) return null;

    // Quick bounding-box rejection before the expensive boolean ops
    final shapeBounds = shapePath.getBounds();
    if (shapeBounds.isEmpty) return null;

    final pieceL = ui.Path.combine(ui.PathOperation.intersect, shapePath, leftPlane);
    final pieceR = ui.Path.combine(ui.PathOperation.intersect, shapePath, rightPlane);

    final boundsL = pieceL.getBounds();
    final boundsR = pieceR.getBounds();

    // If either half is empty or trivially small, the knife missed or was tangent.
    const minArea = 4.0; // px²
    if (boundsL.isEmpty || boundsL.width * boundsL.height < minArea) return null;
    if (boundsR.isEmpty || boundsR.width * boundsR.height < minArea) return null;

    final baseName = shape.data.name ?? _typeLabel(shape);

    final shapeA = _pathToShape(pieceL, boundsL, shape, '$baseName A');
    final shapeB = _pathToShape(pieceR, boundsR, shape, '$baseName B');

    if (shapeA == null && shapeB == null) return null;
    return [
      if (shapeA != null) shapeA,
      if (shapeB != null) shapeB,
    ];
  }

  // ---------------------------------------------------------------------------
  // Shape → canvas Path
  // ---------------------------------------------------------------------------

  static const _shapeToPath = ShapeToPath();

  ui.Path? _toCanvasPath(VecShape shape) {
    return shape.maybeMap(
      // Closed filled paths can be cut directly
      path: (s) => s.isClosed ? _shapeToPath.convert(s) : null,
      // Primitives: convert via ShapeToPath
      rectangle: (s) => _shapeToPath.convert(s),
      ellipse: (s) => _shapeToPath.convert(s),
      polygon: (s) => _shapeToPath.convert(s),
      // Unsupported types
      orElse: () => null,
    );
  }

  // ---------------------------------------------------------------------------
  // Path → VecPathShape
  // ---------------------------------------------------------------------------

  VecPathShape? _pathToShape(
    ui.Path path,
    Rect bounds,
    VecShape source,
    String name,
  ) {
    if (bounds.isEmpty) return null;

    // Handle multi-contour paths: split into one shape per contour.
    // For simplicity we keep them as a single shape — _samplePath handles
    // multi-contour by producing nodes for all contours sequentially.
    final nodes = PathfinderOps.samplePath(path, bounds);
    if (nodes.isEmpty) return null;

    // Build a new transform with the piece's canvas-space bounding box.
    final newTransform = source.data.transform.copyWith(
      x: bounds.left,
      y: bounds.top,
      width: bounds.width,
      height: bounds.height,
      // Clear rotation/scale so the piece sits straight; the nodes already
      // encode the transformed geometry in canvas space.
      rotation: 0,
      scaleX: 1,
      scaleY: 1,
    );

    return VecShape.path(
      data: source.data.copyWith(
        id: _uuid.v4(),
        name: name,
        transform: newTransform,
      ),
      nodes: nodes,
      isClosed: true,
    ) as VecPathShape;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _typeLabel(VecShape shape) => shape.map(
        path: (_) => 'Path',
        rectangle: (_) => 'Rectangle',
        ellipse: (_) => 'Ellipse',
        polygon: (_) => 'Polygon',
        text: (_) => 'Text',
        group: (_) => 'Group',
        symbolInstance: (_) => 'Symbol',
        compound: (_) => 'Compound',
        image: (_) => 'Image',
      );
}

// ---------------------------------------------------------------------------
// Offset normalize extension
// ---------------------------------------------------------------------------

extension _OffsetNorm on Offset {
  Offset normalize() {
    final d = distance;
    if (d < 1e-9) return Offset.zero;
    return this / d;
  }
}

// Re-export so canvas can import just this file
// ignore: unused_element
Rect _emptyRect = Rect.zero;
