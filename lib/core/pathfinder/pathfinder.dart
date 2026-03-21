import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/vec_fill.dart';
import '../../data/models/vec_path_node.dart';
import '../../data/models/vec_point.dart';
import '../../data/models/vec_shape.dart';
import '../../data/models/vec_stroke.dart';
import '../../data/models/vec_transform.dart';

// ignore: unused_import
import '../../data/models/vec_color.dart';

const _uuid = Uuid();

// =============================================================================
// ShapeToPath — VecShape → canvas-space dart:ui Path
// =============================================================================

class ShapeToPath {
  const ShapeToPath();

  /// Returns this shape's outline as a [ui.Path] in canvas coordinates.
  ui.Path convert(VecShape shape) {
    return shape.map(
      path: (s) => _buildPathFromNodes(s.nodes, s.isClosed)
          .transform(_transformMatrix(s.data.transform)),
      rectangle: (s) => _rectanglePath(s).transform(_transformMatrix(s.data.transform)),
      ellipse: (s) => _ellipsePath(s).transform(_transformMatrix(s.data.transform)),
      polygon: (s) => _polygonPath(s).transform(_transformMatrix(s.data.transform)),
      text: (_) => ui.Path(), // Text outlines not supported in pathfinder
      group: (s) {
        var result = ui.Path();
        for (final child in s.children) {
          // Apply group transform then child transform
          final childPath = convert(child);
          final gt = _transformMatrix(s.data.transform);
          result = ui.Path.combine(
              ui.PathOperation.union, result, childPath.transform(gt));
        }
        return result;
      },
      compound: (s) => computeCompoundPath(s),
      symbolInstance: (_) => ui.Path(),
    );
  }

  // ---------------------------------------------------------------------------
  // Per-shape local-space path builders
  // ---------------------------------------------------------------------------

  ui.Path _buildPathFromNodes(List<VecPathNode> nodes, bool isClosed) {
    final path = ui.Path();
    if (nodes.isEmpty) return path;
    path.moveTo(nodes.first.position.x, nodes.first.position.y);
    for (var i = 1; i < nodes.length; i++) {
      _addSegment(path, nodes[i - 1], nodes[i]);
    }
    if (isClosed && nodes.length > 1) {
      _addSegment(path, nodes.last, nodes.first);
      path.close();
    }
    return path;
  }

  void _addSegment(ui.Path path, VecPathNode from, VecPathNode to) {
    if (from.handleOut != null || to.handleIn != null) {
      path.cubicTo(
        from.handleOut?.x ?? from.position.x,
        from.handleOut?.y ?? from.position.y,
        to.handleIn?.x ?? to.position.x,
        to.handleIn?.y ?? to.position.y,
        to.position.x,
        to.position.y,
      );
    } else {
      path.lineTo(to.position.x, to.position.y);
    }
  }

  ui.Path _rectanglePath(VecRectangleShape s) {
    final w = s.transform.width;
    final h = s.transform.height;
    final radii = s.cornerRadii;
    final rect = Rect.fromLTWH(0, 0, w, h);
    if (radii.every((v) => v == 0)) return ui.Path()..addRect(rect);
    final tl = radii.isNotEmpty ? radii[0] : 0.0;
    final tr = radii.length > 1 ? radii[1] : tl;
    final br = radii.length > 2 ? radii[2] : tl;
    final bl = radii.length > 3 ? radii[3] : tr;
    return ui.Path()
      ..addRRect(RRect.fromRectAndCorners(
        rect,
        topLeft: Radius.circular(tl),
        topRight: Radius.circular(tr),
        bottomRight: Radius.circular(br),
        bottomLeft: Radius.circular(bl),
      ));
  }

  ui.Path _ellipsePath(VecEllipseShape s) {
    final w = s.transform.width;
    final h = s.transform.height;
    final isFullCircle = (s.endAngle - s.startAngle).abs() >= 360;
    final hasInner = s.innerRadius > 0 && s.innerRadius < 1;
    if (isFullCircle && !hasInner) {
      return ui.Path()..addOval(Rect.fromLTWH(0, 0, w, h));
    }
    final path = ui.Path();
    final startRad = s.startAngle * math.pi / 180 - math.pi / 2;
    final sweepRad = (s.endAngle - s.startAngle) * math.pi / 180;
    path.arcTo(Rect.fromLTWH(0, 0, w, h), startRad, sweepRad, true);
    if (hasInner) {
      final iw = w * s.innerRadius;
      final ih = h * s.innerRadius;
      final innerRect =
          Rect.fromCenter(center: Offset(w / 2, h / 2), width: iw, height: ih);
      path.arcTo(innerRect, startRad + sweepRad, -sweepRad, false);
      path.close();
    } else {
      path.lineTo(w / 2, h / 2);
      path.close();
    }
    return path;
  }

  ui.Path _polygonPath(VecPolygonShape s) {
    final w = s.transform.width;
    final h = s.transform.height;
    final cx = w / 2;
    final cy = h / 2;
    final sides = s.sideCount.clamp(3, 128);
    final hasStar = s.starDepth != null && s.starDepth! > 0;
    final path = ui.Path();
    final angleStep = (2 * math.pi) / sides;
    const startAngle = -math.pi / 2;
    for (var i = 0; i < sides; i++) {
      final angle = startAngle + angleStep * i;
      final x = cx + cx * math.cos(angle);
      final y = cy + cy * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      if (hasStar) {
        final depth = s.starDepth!.clamp(0.01, 0.99);
        final irx = cx * (1 - depth);
        final iry = cy * (1 - depth);
        final mid = angle + angleStep / 2;
        path.lineTo(cx + irx * math.cos(mid), cy + iry * math.sin(mid));
      }
    }
    path.close();
    return path;
  }

  // ---------------------------------------------------------------------------
  // Transform matrix builder
  // ---------------------------------------------------------------------------

  /// Builds a 4×4 column-major Float64List representing the canvas-space
  /// affine transform for [t] (skew is intentionally ignored for now).
  Float64List _transformMatrix(VecTransform t) {
    final px = t.pivot?.x ?? (t.width / 2);
    final py = t.pivot?.y ?? (t.height / 2);
    final angle = t.rotation * math.pi / 180;
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);
    final sx = t.scaleX;
    final sy = t.scaleY;

    // 2×2 rotation-scale block
    final a = cosA * sx;
    final b = -sinA * sy;
    final c = sinA * sx;
    final d = cosA * sy;

    // Translation accounting for pivot
    final tx = -a * px - b * py + t.x + px;
    final ty = -c * px - d * py + t.y + py;

    // 4×4 column-major
    return Float64List.fromList([
      a, c, 0, 0, //  col 0
      b, d, 0, 0, //  col 1
      0, 0, 1, 0, //  col 2
      tx, ty, 0, 1, //  col 3
    ]);
  }

  // ---------------------------------------------------------------------------
  // Compound path computation
  // ---------------------------------------------------------------------------

  /// Computes the canvas-space path for a live compound shape.
  ui.Path computeCompoundPath(VecCompoundShape s) {
    if (s.inputs.isEmpty) return ui.Path();
    final paths = s.inputs.map(convert).toList();
    return _applyOp(paths, s.op);
  }

  /// Applies [op] to a list of canvas-space paths and returns the result.
  ui.Path _applyOp(List<ui.Path> paths, PathfinderOp op) {
    if (paths.isEmpty) return ui.Path();
    switch (op) {
      case PathfinderOp.unite:
        return paths.fold(ui.Path(),
            (acc, p) => ui.Path.combine(ui.PathOperation.union, acc, p));

      case PathfinderOp.minusFront:
        if (paths.length == 1) return paths.first;
        // front = topmost (last in inputs list), back = union of all others
        final front = paths.last;
        final back = paths
            .take(paths.length - 1)
            .fold(ui.Path(),
                (acc, p) => ui.Path.combine(ui.PathOperation.union, acc, p));
        return ui.Path.combine(ui.PathOperation.difference, back, front);

      case PathfinderOp.intersect:
        return paths
            .skip(1)
            .fold(paths.first,
                (acc, p) => ui.Path.combine(ui.PathOperation.intersect, acc, p));

      case PathfinderOp.exclude:
        return paths.fold(ui.Path(),
            (acc, p) => ui.Path.combine(ui.PathOperation.xor, acc, p));

      // divide / trim / outline are always flattened immediately (non-live)
      default:
        return paths.fold(ui.Path(),
            (acc, p) => ui.Path.combine(ui.PathOperation.union, acc, p));
    }
  }
}

// =============================================================================
// PathfinderOps — high-level API that produces VecShape results
// =============================================================================

class PathfinderOps {
  PathfinderOps._();

  static const _converter = ShapeToPath();

  // ---------------------------------------------------------------------------
  // apply — main entry point
  // ---------------------------------------------------------------------------

  /// Applies [op] to [inputs] (bottom-to-top order) and returns the result
  /// shapes to be inserted into the layer (replacing the originals).
  ///
  /// - unite / minusFront / intersect / exclude → returns one live compound.
  /// - divide / trim → returns multiple flat VecPathShape results (non-live).
  /// - outline → returns stroked path results (non-live).
  static List<VecShape> apply(
    List<VecShape> inputs,
    PathfinderOp op,
  ) {
    if (inputs.isEmpty) return [];

    switch (op) {
      case PathfinderOp.unite:
      case PathfinderOp.minusFront:
      case PathfinderOp.intersect:
      case PathfinderOp.exclude:
        return [_makeLiveCompound(inputs, op)];

      case PathfinderOp.divide:
        return _divide(inputs);

      case PathfinderOp.trim:
        return _trim(inputs);

      case PathfinderOp.outline:
        return _outline(inputs);
    }
  }

  // ---------------------------------------------------------------------------
  // expand — flatten a live compound to VecPathShape
  // ---------------------------------------------------------------------------

  static VecShape expand(VecCompoundShape compound) {
    final canvasPath = _converter.computeCompoundPath(compound);
    final bounds = canvasPath.getBounds();
    if (bounds.isEmpty) {
      return VecShape.path(
        data: compound.data.copyWith(id: _uuid.v4()),
        nodes: const [],
        isClosed: true,
      );
    }

    final nodes = _samplePath(canvasPath, bounds);
    return VecShape.path(
      data: compound.data.copyWith(
        id: _uuid.v4(),
        transform: compound.data.transform.copyWith(
          x: bounds.left,
          y: bounds.top,
          width: bounds.width,
          height: bounds.height,
        ),
      ),
      nodes: nodes,
      isClosed: true,
    );
  }

  // ---------------------------------------------------------------------------
  // Live compound helper
  // ---------------------------------------------------------------------------

  static VecShape _makeLiveCompound(List<VecShape> inputs, PathfinderOp op) {
    final paths = inputs.map(_converter.convert).toList();
    final combined = _converter._applyOp(paths, op);
    final bounds = combined.getBounds();

    final firstFills = inputs.isNotEmpty ? inputs.first.fills : <VecFill>[];
    final firstStrokes = inputs.isNotEmpty ? inputs.first.strokes : <VecStroke>[];

    return VecShape.compound(
      data: VecShapeData(
        id: _uuid.v4(),
        transform: VecTransform(
          x: bounds.left,
          y: bounds.top,
          width: bounds.isEmpty ? 0 : bounds.width,
          height: bounds.isEmpty ? 0 : bounds.height,
        ),
        fills: firstFills,
        strokes: firstStrokes,
      ),
      op: op,
      inputs: inputs,
    );
  }

  // ---------------------------------------------------------------------------
  // Divide
  // ---------------------------------------------------------------------------

  static List<VecShape> _divide(List<VecShape> shapes) {
    if (shapes.length < 2) return shapes;
    final paths = shapes.map(_converter.convert).toList();
    final results = <VecShape>[];

    // For each shape: exclusive region (shape minus all others)
    for (var i = 0; i < shapes.length; i++) {
      var piece = paths[i];
      for (var j = 0; j < paths.length; j++) {
        if (j == i) continue;
        piece = ui.Path.combine(ui.PathOperation.difference, piece, paths[j]);
      }
      final shape = _flattenToShape(piece, shapes[i]);
      if (shape != null) results.add(shape);
    }

    // For each pair: intersection region (minus all other shapes)
    for (var i = 0; i < shapes.length; i++) {
      for (var j = i + 1; j < shapes.length; j++) {
        var inter =
            ui.Path.combine(ui.PathOperation.intersect, paths[i], paths[j]);
        for (var k = 0; k < shapes.length; k++) {
          if (k == i || k == j) continue;
          inter = ui.Path.combine(ui.PathOperation.difference, inter, paths[k]);
        }
        // Use the topmost (front) shape's style for the intersection piece
        final shape = _flattenToShape(inter, shapes[j]);
        if (shape != null) results.add(shape);
      }
    }

    return results.isEmpty ? shapes : results;
  }

  // ---------------------------------------------------------------------------
  // Trim
  // ---------------------------------------------------------------------------

  static List<VecShape> _trim(List<VecShape> shapes) {
    if (shapes.length < 2) return shapes;
    final paths = shapes.map(_converter.convert).toList();
    final results = <VecShape>[];

    for (var i = 0; i < shapes.length; i++) {
      // Subtract all shapes that are ABOVE (higher index = higher z-order)
      var trimmed = paths[i];
      for (var j = i + 1; j < shapes.length; j++) {
        trimmed =
            ui.Path.combine(ui.PathOperation.difference, trimmed, paths[j]);
      }
      final shape = _flattenToShape(trimmed, shapes[i]);
      if (shape != null) results.add(shape);
    }

    return results.isEmpty ? shapes : results;
  }

  // ---------------------------------------------------------------------------
  // Outline
  // ---------------------------------------------------------------------------

  static List<VecShape> _outline(List<VecShape> shapes) {
    // Converts fills to stroked outlines: keep each shape as a path with
    // no fill, a stroke matching the fill color, and no fill.
    return shapes.map((s) {
      final fillColor =
          s.fills.isNotEmpty ? s.fills.first.color : VecColor.black;
      final outlineStroke = VecStroke(
        color: fillColor,
        width: s.strokes.isNotEmpty ? s.strokes.first.width : 1.0,
      );
      return s.copyWith(
        data: s.data.copyWith(
          fills: const [],
          strokes: [outlineStroke],
        ),
      );
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Shared helpers
  // ---------------------------------------------------------------------------

  /// Converts a canvas-space [path] to a [VecPathShape] using the style from [source].
  static VecShape? _flattenToShape(ui.Path path, VecShape source) {
    final bounds = path.getBounds();
    if (bounds.isEmpty || bounds.width < 0.5 && bounds.height < 0.5) return null;
    final nodes = _samplePath(path, bounds);
    if (nodes.isEmpty) return null;
    return VecShape.path(
      data: source.data.copyWith(
        id: _uuid.v4(),
        transform: source.data.transform.copyWith(
          x: bounds.left,
          y: bounds.top,
          width: bounds.width,
          height: bounds.height,
        ),
      ),
      nodes: nodes,
      isClosed: true,
    );
  }

  /// Samples [path] (canvas-space) into [VecPathNode] list in local
  /// coordinates (origin = [bounds].topLeft).
  static List<VecPathNode> _samplePath(ui.Path path, Rect bounds) {
    final nodes = <VecPathNode>[];
    for (final metric in path.computeMetrics()) {
      if (metric.length < 0.5) continue;
      // Adaptive step: target ~150 points per contour, minimum 1 px
      final step = math.max(1.0, metric.length / 150);
      // Add first point of this contour
      var first = true;
      for (var d = 0.0; d < metric.length; d += step) {
        final tangent = metric.getTangentForOffset(d);
        if (tangent == null) continue;
        if (!first) {
          nodes.add(VecPathNode(
            position: VecPoint(
              x: tangent.position.dx - bounds.left,
              y: tangent.position.dy - bounds.top,
            ),
          ));
        } else {
          // Mark contour start with a separate node to break the path naturally
          // (we close each contour; outer/inner contours are both closed)
          nodes.add(VecPathNode(
            position: VecPoint(
              x: tangent.position.dx - bounds.left,
              y: tangent.position.dy - bounds.top,
            ),
          ));
          first = false;
        }
      }
    }
    return nodes;
  }
}
