import 'dart:math' as math;
import 'dart:ui' show Offset;

import '../../data/models/vec_path_node.dart';

/// Evaluates positions along a motion path using arc-length parameterization.
///
/// The path is defined as a sequence of cubic Bézier segments (one per pair
/// of adjacent nodes).  Each segment is sampled into [_samplesPerSegment]
/// chord sub-intervals to build a cumulative arc-length table, enabling
/// uniform-speed traversal regardless of segment curvature.
class MotionPathEvaluator {
  const MotionPathEvaluator._();

  static const int _samplesPerSegment = 50;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Evaluates the canvas (x, y) position at normalised time [t] ∈ [0, 1]
  /// along the path defined by [nodes].
  ///
  /// • [t] == 0 → position of first node.
  /// • [t] == 1 → position of last node (open) or first node again (closed).
  /// • Returns [Offset.zero] if [nodes] is empty.
  static Offset evaluate(List<VecPathNode> nodes, bool isClosed, double t) {
    if (nodes.isEmpty) return Offset.zero;
    if (nodes.length == 1) {
      return Offset(nodes.first.position.x, nodes.first.position.y);
    }
    t = t.clamp(0.0, 1.0);
    if (t == 0) return _nodeOffset(nodes.first);
    if (t == 1 && !isClosed) return _nodeOffset(nodes.last);

    final table = _buildTable(nodes, isClosed);
    final totalLength = table.last;
    if (totalLength == 0) return _nodeOffset(nodes.first);

    final targetLength = t * totalLength;
    return _sampleAt(nodes, isClosed, table, targetLength);
  }

  /// Evaluates the tangent angle (in degrees) at normalised time [t].
  /// Returns 0 when the path is degenerate.
  static double evaluateAngle(
      List<VecPathNode> nodes, bool isClosed, double t) {
    if (nodes.length < 2) return 0;
    const eps = 1e-4;
    final t1 = (t - eps).clamp(0.0, 1.0);
    final t2 = (t + eps).clamp(0.0, 1.0);
    final p1 = evaluate(nodes, isClosed, t1);
    final p2 = evaluate(nodes, isClosed, t2);
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    if (dx == 0 && dy == 0) return 0;
    return math.atan2(dy, dx) * 180 / math.pi;
  }

  // ---------------------------------------------------------------------------
  // Arc-length table
  // ---------------------------------------------------------------------------

  /// Builds a flat list of cumulative arc lengths.
  /// Entry at index [s * _samplesPerSegment + i] holds the total length
  /// traversed up to sample [i] within segment [s].
  /// The last entry is the total path length.
  static List<double> _buildTable(List<VecPathNode> nodes, bool isClosed) {
    final segCount = isClosed ? nodes.length : nodes.length - 1;
    final table = <double>[0.0];
    var cumulative = 0.0;

    for (var s = 0; s < segCount; s++) {
      final a = nodes[s];
      final b = nodes[(s + 1) % nodes.length];
      final p0 = _nodeOffset(a);
      final p1 = _cp1(a);
      final p2 = _cp2(b);
      final p3 = _nodeOffset(b);

      var prev = p0;
      for (var i = 1; i <= _samplesPerSegment; i++) {
        final u = i / _samplesPerSegment;
        final cur = _cubicBezier(p0, p1, p2, p3, u);
        cumulative += (cur - prev).distance;
        table.add(cumulative);
        prev = cur;
      }
    }
    return table;
  }

  static Offset _sampleAt(
    List<VecPathNode> nodes,
    bool isClosed,
    List<double> table,
    double targetLength,
  ) {
    // Binary search for surrounding table entries
    var lo = 0;
    var hi = table.length - 1;
    while (lo < hi - 1) {
      final mid = (lo + hi) >> 1;
      if (table[mid] < targetLength) {
        lo = mid;
      } else {
        hi = mid;
      }
    }

    // Interpolate within the sub-interval
    final lengthLo = table[lo];
    final lengthHi = table[hi];
    final subT = (lengthHi == lengthLo)
        ? 0.0
        : (targetLength - lengthLo) / (lengthHi - lengthLo);

    // Resolve which (segment, sample) we're in
    final segCount = isClosed ? nodes.length : nodes.length - 1;
    final globalIdx = lo; // index into the flat table (excl. leading 0)
    final sampleInTable = globalIdx; // table[0] is 0 before any segment

    // Each segment contributes exactly _samplesPerSegment entries after its start
    // table[0] = 0 (pre-path)
    // table[1..50] = segment 0 samples
    // table[51..100] = segment 1 samples, etc.
    final segIdx = ((sampleInTable - 1).clamp(0, segCount * _samplesPerSegment - 1)) ~/
        _samplesPerSegment;
    final withinSeg = lo == 0
        ? 0.0
        : ((lo - 1) % _samplesPerSegment + subT) / _samplesPerSegment;

    final a = nodes[segIdx];
    final b = nodes[(segIdx + 1) % nodes.length];
    return _cubicBezier(
      _nodeOffset(a),
      _cp1(a),
      _cp2(b),
      _nodeOffset(b),
      withinSeg,
    );
  }

  // ---------------------------------------------------------------------------
  // Cubic Bézier helpers
  // ---------------------------------------------------------------------------

  static Offset _cubicBezier(
      Offset p0, Offset p1, Offset p2, Offset p3, double t) {
    final mt = 1 - t;
    final mt2 = mt * mt;
    final t2 = t * t;
    return p0 * (mt2 * mt) +
        p1 * (3 * mt2 * t) +
        p2 * (3 * mt * t2) +
        p3 * (t2 * t);
  }

  /// The "out" control point of node [n] (i.e., the leaving handle).
  static Offset _cp1(VecPathNode n) {
    if (n.handleOut != null) {
      return Offset(n.handleOut!.x, n.handleOut!.y);
    }
    return _nodeOffset(n);
  }

  /// The "in" control point of node [n] (i.e., the arriving handle).
  static Offset _cp2(VecPathNode n) {
    if (n.handleIn != null) {
      return Offset(n.handleIn!.x, n.handleIn!.y);
    }
    return _nodeOffset(n);
  }

  static Offset _nodeOffset(VecPathNode n) =>
      Offset(n.position.x, n.position.y);
}
