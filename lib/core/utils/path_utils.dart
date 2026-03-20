import 'dart:math';

import '../../data/models/vec_path_node.dart';
import '../../data/models/vec_point.dart';

class PathUtils {
  PathUtils._();

  /// Subdivides a cubic Bézier curve into line segments within [tolerance].
  static List<VecPoint> flattenCubicBezier(
    VecPoint p0,
    VecPoint cp1,
    VecPoint cp2,
    VecPoint p3, {
    double tolerance = 0.5,
  }) {
    final result = <VecPoint>[p0];
    _subdivideCubic(p0, cp1, cp2, p3, tolerance, result);
    result.add(p3);
    return result;
  }

  static void _subdivideCubic(
    VecPoint p0,
    VecPoint p1,
    VecPoint p2,
    VecPoint p3,
    double tolerance,
    List<VecPoint> result,
  ) {
    // Check if the curve is flat enough
    final dx = p3.x - p0.x;
    final dy = p3.y - p0.y;
    final d2 = ((p1.x - p3.x) * dy - (p1.y - p3.y) * dx).abs();
    final d3 = ((p2.x - p3.x) * dy - (p2.y - p3.y) * dx).abs();

    if ((d2 + d3) * (d2 + d3) <= tolerance * tolerance * (dx * dx + dy * dy)) {
      return;
    }

    // De Casteljau subdivision at t=0.5
    final p01 = VecPoint(
      x: (p0.x + p1.x) * 0.5,
      y: (p0.y + p1.y) * 0.5,
    );
    final p12 = VecPoint(
      x: (p1.x + p2.x) * 0.5,
      y: (p1.y + p2.y) * 0.5,
    );
    final p23 = VecPoint(
      x: (p2.x + p3.x) * 0.5,
      y: (p2.y + p3.y) * 0.5,
    );
    final p012 = VecPoint(
      x: (p01.x + p12.x) * 0.5,
      y: (p01.y + p12.y) * 0.5,
    );
    final p123 = VecPoint(
      x: (p12.x + p23.x) * 0.5,
      y: (p12.y + p23.y) * 0.5,
    );
    final mid = VecPoint(
      x: (p012.x + p123.x) * 0.5,
      y: (p012.y + p123.y) * 0.5,
    );

    _subdivideCubic(p0, p01, p012, mid, tolerance, result);
    result.add(mid);
    _subdivideCubic(mid, p123, p23, p3, tolerance, result);
  }

  /// Flattens a list of [VecPathNode]s into line segments.
  ///
  /// Each consecutive pair of nodes is treated as a cubic Bézier segment
  /// (using handleOut of the first node and handleIn of the second).
  /// If [closed] is true, an extra segment from the last to the first node
  /// is included.
  static List<VecPoint> flattenPath(
    List<VecPathNode> nodes, {
    bool closed = false,
    double tolerance = 0.5,
  }) {
    if (nodes.isEmpty) return [];
    if (nodes.length == 1) return [nodes.first.position];

    final result = <VecPoint>[];
    final count = closed ? nodes.length : nodes.length - 1;

    for (var i = 0; i < count; i++) {
      final a = nodes[i];
      final b = nodes[(i + 1) % nodes.length];

      final p0 = a.position;
      final cp1 = a.handleOut ?? a.position;
      final cp2 = b.handleIn ?? b.position;
      final p3 = b.position;

      final segment = flattenCubicBezier(p0, cp1, cp2, p3, tolerance: tolerance);

      // Avoid duplicating the join point between segments
      if (i == 0) {
        result.addAll(segment);
      } else {
        result.addAll(segment.skip(1));
      }
    }

    return result;
  }

  /// Computes the total arc length of a flattened polyline.
  static double polylineLength(List<VecPoint> points) {
    var length = 0.0;
    for (var i = 1; i < points.length; i++) {
      final dx = points[i].x - points[i - 1].x;
      final dy = points[i].y - points[i - 1].y;
      length += sqrt(dx * dx + dy * dy);
    }
    return length;
  }

  /// Returns the total arc length of a path defined by [nodes].
  static double arcLength(
    List<VecPathNode> nodes, {
    bool closed = false,
    double tolerance = 0.5,
  }) {
    final points = flattenPath(nodes, closed: closed, tolerance: tolerance);
    return polylineLength(points);
  }

  /// Returns the point at parameter [t] (0.0–1.0) along a polyline,
  /// where t is proportional to arc length.
  static VecPoint pointAtParameter(List<VecPoint> points, double t) {
    if (points.isEmpty) return VecPoint.zero();
    if (points.length == 1 || t <= 0) return points.first;
    if (t >= 1) return points.last;

    final totalLength = polylineLength(points);
    final targetLength = t * totalLength;

    var accumulated = 0.0;
    for (var i = 1; i < points.length; i++) {
      final dx = points[i].x - points[i - 1].x;
      final dy = points[i].y - points[i - 1].y;
      final segmentLength = sqrt(dx * dx + dy * dy);

      if (accumulated + segmentLength >= targetLength) {
        final remaining = targetLength - accumulated;
        final ratio = segmentLength > 0 ? remaining / segmentLength : 0.0;
        return VecPoint(
          x: points[i - 1].x + dx * ratio,
          y: points[i - 1].y + dy * ratio,
        );
      }
      accumulated += segmentLength;
    }

    return points.last;
  }
}
