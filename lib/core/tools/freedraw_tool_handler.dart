import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/vec_color.dart';
import '../../data/models/vec_fill.dart';
import '../../data/models/vec_path_node.dart';
import '../../data/models/vec_point.dart';
import '../../data/models/vec_shape.dart';
import '../../data/models/vec_stroke.dart';
import '../../data/models/vec_transform.dart';
import '../../providers/freedraw_state_provider.dart';

const _uuid = Uuid();

class FreeDrawToolHandler {
  const FreeDrawToolHandler();

  /// Converts a [FreeDrawStroke] into a [VecPathShape] using the current
  /// [FreeDrawSettings] for style.
  VecShape create(FreeDrawStroke stroke, FreeDrawSettings settings) {
    final raw = stroke.points;
    if (raw.length < 2) {
      // Single-point stroke — tiny horizontal segment so it still renders
      final p = raw.first;
      return _build([p, p + const Offset(0.5, 0)], settings);
    }
    final smoothed = _chaikin(raw, passes: 2);
    return _build(smoothed, settings);
  }

  // ---------------------------------------------------------------------------
  // Chaikin corner-cutting subdivision
  // ---------------------------------------------------------------------------

  /// Two passes of Chaikin smoothing over [pts].
  /// Each pass replaces every segment (P0, P1) with two new points:
  ///   Q = 0.75*P0 + 0.25*P1
  ///   R = 0.25*P0 + 0.75*P1
  /// The first and last original points are preserved so the stroke endpoints
  /// don't drift.
  List<Offset> _chaikin(List<Offset> pts, {int passes = 2}) {
    var current = pts;
    for (var p = 0; p < passes; p++) {
      if (current.length < 3) break;
      final next = <Offset>[current.first];
      for (var i = 0; i < current.length - 1; i++) {
        final p0 = current[i];
        final p1 = current[i + 1];
        next.add(p0 * 0.75 + p1 * 0.25);
        next.add(p0 * 0.25 + p1 * 0.75);
      }
      next.add(current.last);
      current = next;
    }
    return current;
  }

  // ---------------------------------------------------------------------------
  // Build VecShape from point list
  // ---------------------------------------------------------------------------

  VecShape _build(List<Offset> pts, FreeDrawSettings settings) {
    // Compute bounding box
    var minX = double.infinity;
    var minY = double.infinity;
    var maxX = double.negativeInfinity;
    var maxY = double.negativeInfinity;
    for (final p in pts) {
      if (p.dx < minX) minX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy > maxY) maxY = p.dy;
    }

    // Degenerate: zero-size bounding box — add a tiny epsilon
    if (maxX - minX < 0.5) { maxX = minX + 0.5; }
    if (maxY - minY < 0.5) { maxY = minY + 0.5; }

    final w = maxX - minX;
    final h = maxY - minY;

    // Localise to bounding-box origin
    final nodes = pts.map((p) => VecPathNode(
      position: VecPoint(x: p.dx - minX, y: p.dy - minY),
    )).toList();

    final vecColor = VecColor.fromFlutterColor(settings.color);

    final fills = settings.fill
        ? [VecFill(color: vecColor, opacity: settings.opacity)]
        : <VecFill>[];

    final strokes = [
      VecStroke(
        color: vecColor,
        width: settings.width,
        opacity: settings.opacity,
        cap: settings.cap,
        join: VecStrokeJoin.round,
      ),
    ];

    return VecShape.path(
      data: VecShapeData(
        id: _uuid.v4(),
        transform: VecTransform(x: minX, y: minY, width: w, height: h),
        fills: fills,
        strokes: strokes,
        opacity: 1.0,
      ),
      nodes: nodes,
      isClosed: settings.close,
    );
  }
}

// Dart doesn't have operator* for Offset × double from the other side, so
// the _chaikin method uses Offset's built-in * operator (Offset * double).
// The addition `p0 * 0.75 + p1 * 0.25` uses Offset's + operator.
// Both are defined on dart:ui Offset — no extension needed.
// ignore: unused_element
double _unused = 0; // suppress lint about no public API
