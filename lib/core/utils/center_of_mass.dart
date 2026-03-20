import '../../data/models/vec_path_node.dart';
import '../../data/models/vec_point.dart';
import '../../data/models/vec_shape.dart';
import '../../data/models/vec_transform.dart';
import 'path_utils.dart';

/// Computes the center of mass (centroid) for vector shapes.
///
/// - Filled closed paths: area centroid via the shoelace formula.
/// - Open strokes: arc-length midpoint.
/// - Groups/symbols: area-weighted average of children.
/// - Text: bounding-box center (layout centroid deferred until path conversion).
class CenterOfMassCalculator {
  CenterOfMassCalculator._();

  /// Dispatches to the correct algorithm based on shape type.
  static VecPoint forShape(VecShape shape) {
    return shape.map(
      path: (s) => s.isClosed
          ? filledPathCentroid(s.nodes)
          : strokeCentroid(s.nodes),
      rectangle: (s) => _transformCenter(s.data.transform),
      ellipse: (s) => _transformCenter(s.data.transform),
      polygon: (s) => _transformCenter(s.data.transform),
      text: (s) => _transformCenter(s.data.transform),
      group: (s) => groupCentroid(s.children),
      symbolInstance: (s) => _transformCenter(s.data.transform),
    );
  }

  /// Area centroid of a filled closed polygon via the shoelace formula.
  ///
  /// The path nodes are first flattened into line segments, then the standard
  /// polygon centroid formula is applied:
  ///   Cx = (1/6A) * Σ (xi + xi+1)(xi*yi+1 - xi+1*yi)
  ///   Cy = (1/6A) * Σ (yi + yi+1)(xi*yi+1 - xi+1*yi)
  static VecPoint filledPathCentroid(List<VecPathNode> nodes) {
    final points = PathUtils.flattenPath(nodes, closed: true);
    if (points.length < 3) {
      return _averagePoints(points);
    }

    var area = 0.0;
    var cx = 0.0;
    var cy = 0.0;

    for (var i = 0; i < points.length; i++) {
      final j = (i + 1) % points.length;
      final cross = points[i].x * points[j].y - points[j].x * points[i].y;
      area += cross;
      cx += (points[i].x + points[j].x) * cross;
      cy += (points[i].y + points[j].y) * cross;
    }

    area *= 0.5;

    if (area.abs() < 1e-10) {
      return _averagePoints(points);
    }

    final factor = 1.0 / (6.0 * area);
    return VecPoint(x: cx * factor, y: cy * factor);
  }

  /// Arc-length centroid of an open stroke path.
  ///
  /// Returns the point at t=0.5 along the total arc length.
  static VecPoint strokeCentroid(List<VecPathNode> nodes) {
    final points = PathUtils.flattenPath(nodes, closed: false);
    if (points.isEmpty) return VecPoint.zero();
    return PathUtils.pointAtParameter(points, 0.5);
  }

  /// Compound path centroid using signed areas.
  ///
  /// Counter-clockwise sub-paths (holes) subtract their area. The centroid
  /// is the area-weighted average of all sub-path centroids.
  static VecPoint compoundPathCentroid(List<List<VecPathNode>> subPaths) {
    if (subPaths.isEmpty) return VecPoint.zero();

    var totalArea = 0.0;
    var wx = 0.0;
    var wy = 0.0;

    for (final nodes in subPaths) {
      final points = PathUtils.flattenPath(nodes, closed: true);
      final area = _signedArea(points);
      final centroid = filledPathCentroid(nodes);

      totalArea += area;
      wx += area * centroid.x;
      wy += area * centroid.y;
    }

    if (totalArea.abs() < 1e-10) {
      return filledPathCentroid(subPaths.first);
    }

    return VecPoint(x: wx / totalArea, y: wy / totalArea);
  }

  /// Area-weighted average of children centroids.
  static VecPoint groupCentroid(List<VecShape> children) {
    if (children.isEmpty) return VecPoint.zero();

    // Use bounding-box area as a proxy for visual weight
    var totalWeight = 0.0;
    var wx = 0.0;
    var wy = 0.0;

    for (final child in children) {
      final centroid = forShape(child);
      final t = child.transform;
      final weight = (t.width * t.scaleX).abs() * (t.height * t.scaleY).abs();
      final w = weight < 1e-10 ? 1.0 : weight;

      totalWeight += w;
      wx += w * centroid.x;
      wy += w * centroid.y;
    }

    if (totalWeight < 1e-10) {
      return _averagePoints(children.map((c) => forShape(c)).toList());
    }

    return VecPoint(x: wx / totalWeight, y: wy / totalWeight);
  }

  // -- Helpers ---------------------------------------------------------------

  static VecPoint _transformCenter(VecTransform t) {
    return VecPoint(
      x: t.x + t.width * 0.5,
      y: t.y + t.height * 0.5,
    );
  }

  static VecPoint _averagePoints(List<VecPoint> points) {
    if (points.isEmpty) return VecPoint.zero();
    var sx = 0.0;
    var sy = 0.0;
    for (final p in points) {
      sx += p.x;
      sy += p.y;
    }
    return VecPoint(x: sx / points.length, y: sy / points.length);
  }

  static double _signedArea(List<VecPoint> points) {
    if (points.length < 3) return 0;
    var area = 0.0;
    for (var i = 0; i < points.length; i++) {
      final j = (i + 1) % points.length;
      area += points[i].x * points[j].y - points[j].x * points[i].y;
    }
    return area * 0.5;
  }
}
