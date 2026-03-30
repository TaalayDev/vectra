import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/painting.dart';

import '../../core/pathfinder/pathfinder.dart';
import '../../data/models/vec_fill.dart';
import '../../data/models/vec_gradient.dart';
import '../../data/models/vec_layer.dart';
import '../../data/models/vec_path_node.dart';
import '../../data/models/vec_shape.dart';
import '../../data/models/vec_stroke.dart';
import '../../data/models/vec_symbol.dart';
import '../../data/models/vec_transform.dart';
import 'blend_mode_mapper.dart';

/// Converts a [VecShape] into a Flutter [Path] and applies fills/strokes
/// onto a [Canvas].
class ShapeRenderer {
  const ShapeRenderer({this.symbols = const [], this.imageCache = const {}});

  /// The symbol library — used to resolve [VecSymbolInstanceShape] references.
  final List<VecSymbol> symbols;

  /// Cache of assetId → decoded [Image] for [VecImageShape] rendering.
  final Map<String, Image> imageCache;

  /// Renders a single shape (with transform, fills, strokes, opacity, blend).
  void render(Canvas canvas, VecShape shape) {
    final transform = shape.transform;
    final shapeOpacity = shape.opacity.clamp(0.0, 1.0);
    if (shapeOpacity <= 0) return;

    canvas.save();

    // Apply shape-level blend mode via saveLayer when not normal or opacity < 1
    final needsLayer = shapeOpacity < 1.0 || shape.blendMode != VecBlendMode.normal;
    if (needsLayer) {
      canvas.saveLayer(
        null,
        Paint()
          ..color = Color.fromARGB((shapeOpacity * 255).round(), 255, 255, 255)
          ..blendMode = mapBlendMode(shape.blendMode),
      );
    }

    // Apply affine transform: translate to position, rotate around pivot, scale, skew.
    // Compounds also go through this now — _renderCompound normalises the path
    // to local-origin coordinates so it can be positioned/rotated like any shape.
    _applyTransform(canvas, transform);

    // Build path and paint
    shape.map(
      path: (s) => _renderPath(canvas, s),
      rectangle: (s) => _renderRectangle(canvas, s),
      ellipse: (s) => _renderEllipse(canvas, s),
      polygon: (s) => _renderPolygon(canvas, s),
      text: (s) => _renderText(canvas, s),
      group: (s) => _renderGroup(canvas, s),
      compound: (s) => _renderCompound(canvas, s),
      symbolInstance: (s) => _renderSymbolInstance(canvas, s),
      image: (s) => _renderImage(canvas, s),
    );

    if (needsLayer) canvas.restore();
    canvas.restore();
  }

  // ===========================================================================
  // Transform
  // ===========================================================================

  void _applyTransform(Canvas canvas, VecTransform t) {
    // Pivot defaults to center of bounding box
    final px = t.pivot?.x ?? (t.width / 2);
    final py = t.pivot?.y ?? (t.height / 2);

    // Translate to shape position
    canvas.translate(t.x, t.y);

    // Translate to pivot, apply rotation/scale/skew, translate back
    canvas.translate(px, py);

    if (t.rotation != 0) {
      canvas.rotate(t.rotation * math.pi / 180);
    }
    if (t.scaleX != 1 || t.scaleY != 1) {
      canvas.scale(t.scaleX, t.scaleY);
    }
    if (t.skewX != 0 || t.skewY != 0) {
      final skewMatrix = Float64List(16);
      _identity(skewMatrix);
      skewMatrix[4] = math.tan(t.skewX * math.pi / 180); // shear X
      skewMatrix[1] = math.tan(t.skewY * math.pi / 180); // shear Y
      canvas.transform(skewMatrix);
    }

    canvas.translate(-px, -py);
  }

  void _identity(Float64List m) {
    for (var i = 0; i < 16; i++) {
      m[i] = 0;
    }
    m[0] = 1;
    m[5] = 1;
    m[10] = 1;
    m[15] = 1;
  }

  // ===========================================================================
  // Path shape
  // ===========================================================================

  void _renderPath(Canvas canvas, VecPathShape s) {
    final path = _buildPathFromNodes(s.nodes, s.isClosed);
    _applyFillsAndStrokes(canvas, path, s.data.fills, s.data.strokes);
  }

  Path _buildPathFromNodes(List<VecPathNode> nodes, bool isClosed) {
    final path = Path();
    if (nodes.isEmpty) return path;

    path.moveTo(nodes.first.position.x, nodes.first.position.y);

    for (var i = 1; i < nodes.length; i++) {
      _curveToNode(path, nodes[i - 1], nodes[i]);
    }

    if (isClosed && nodes.length > 1) {
      _curveToNode(path, nodes.last, nodes.first);
      path.close();
    }

    return path;
  }

  void _curveToNode(Path path, VecPathNode from, VecPathNode to) {
    final hasHandleOut = from.handleOut != null;
    final hasHandleIn = to.handleIn != null;

    if (hasHandleOut || hasHandleIn) {
      // Cubic bezier
      final cp1x = hasHandleOut ? from.handleOut!.x : from.position.x;
      final cp1y = hasHandleOut ? from.handleOut!.y : from.position.y;
      final cp2x = hasHandleIn ? to.handleIn!.x : to.position.x;
      final cp2y = hasHandleIn ? to.handleIn!.y : to.position.y;
      path.cubicTo(cp1x, cp1y, cp2x, cp2y, to.position.x, to.position.y);
    } else {
      path.lineTo(to.position.x, to.position.y);
    }
  }

  // ===========================================================================
  // Rectangle
  // ===========================================================================

  void _renderRectangle(Canvas canvas, VecRectangleShape s) {
    final w = s.transform.width;
    final h = s.transform.height;
    final radii = s.cornerRadii;
    final r = Rect.fromLTWH(0, 0, w, h);

    Path path;
    if (radii.every((v) => v == 0)) {
      path = Path()..addRect(r);
    } else {
      final tl = radii.isNotEmpty ? radii[0] : 0.0;
      final tr = radii.length > 1 ? radii[1] : tl;
      final br = radii.length > 2 ? radii[2] : tl;
      final bl = radii.length > 3 ? radii[3] : tr;

      switch (s.cornerStyle) {
        case VecCornerStyle.round:
          path = Path()
            ..addRRect(RRect.fromRectAndCorners(
              r,
              topLeft: Radius.circular(tl),
              topRight: Radius.circular(tr),
              bottomRight: Radius.circular(br),
              bottomLeft: Radius.circular(bl),
            ));
          break;
        case VecCornerStyle.chamfer:
          path = _chamferRect(r, tl, tr, br, bl);
          break;
        case VecCornerStyle.inverted:
          path = _invertedRoundRect(r, tl, tr, br, bl);
          break;
      }
    }

    _applyFillsAndStrokes(canvas, path, s.data.fills, s.data.strokes);
  }

  Path _chamferRect(Rect r, double tl, double tr, double br, double bl) {
    return Path()
      ..moveTo(r.left + tl, r.top)
      ..lineTo(r.right - tr, r.top)
      ..lineTo(r.right, r.top + tr)
      ..lineTo(r.right, r.bottom - br)
      ..lineTo(r.right - br, r.bottom)
      ..lineTo(r.left + bl, r.bottom)
      ..lineTo(r.left, r.bottom - bl)
      ..lineTo(r.left, r.top + tl)
      ..close();
  }

  Path _invertedRoundRect(Rect r, double tl, double tr, double br, double bl) {
    // Inverted corners — concave arcs
    final path = Path();
    path.moveTo(r.left, r.top);
    if (tl > 0) {
      path.arcToPoint(Offset(r.left + tl, r.top), radius: Radius.circular(tl), clockwise: false);
    }
    path.lineTo(r.right - tr, r.top);
    if (tr > 0) {
      path.arcToPoint(Offset(r.right, r.top + tr), radius: Radius.circular(tr), clockwise: false);
    }
    path.lineTo(r.right, r.bottom - br);
    if (br > 0) {
      path.arcToPoint(Offset(r.right - br, r.bottom), radius: Radius.circular(br), clockwise: false);
    }
    path.lineTo(r.left + bl, r.bottom);
    if (bl > 0) {
      path.arcToPoint(Offset(r.left, r.bottom - bl), radius: Radius.circular(bl), clockwise: false);
    }
    path.close();
    return path;
  }

  // ===========================================================================
  // Ellipse (supports arcs and donuts via startAngle/endAngle/innerRadius)
  // ===========================================================================

  void _renderEllipse(Canvas canvas, VecEllipseShape s) {
    final w = s.transform.width;
    final h = s.transform.height;
    final cx = w / 2;
    final cy = h / 2;

    final isFullCircle = (s.endAngle - s.startAngle).abs() >= 360;
    final hasInner = s.innerRadius > 0 && s.innerRadius < 1;

    Path path;
    if (isFullCircle && !hasInner) {
      // Simple ellipse
      path = Path()..addOval(Rect.fromLTWH(0, 0, w, h));
    } else {
      // Arc / pie / donut
      path = Path();
      final startRad = s.startAngle * math.pi / 180;
      final endRad = s.endAngle * math.pi / 180;
      final sweepRad = endRad - startRad;

      // Outer arc
      final outerRect = Rect.fromLTWH(0, 0, w, h);
      path.arcTo(outerRect, startRad - math.pi / 2, sweepRad, true);

      if (hasInner) {
        // Donut — inner arc in reverse
        final iw = w * s.innerRadius;
        final ih = h * s.innerRadius;
        final innerRect = Rect.fromCenter(center: Offset(cx, cy), width: iw, height: ih);
        path.arcTo(innerRect, endRad - math.pi / 2, -sweepRad, false);
        path.close();
      } else if (!isFullCircle) {
        // Pie slice — line back to center
        path.lineTo(cx, cy);
        path.close();
      }
    }

    _applyFillsAndStrokes(canvas, path, s.data.fills, s.data.strokes);
  }

  // ===========================================================================
  // Polygon / Star
  // ===========================================================================

  void _renderPolygon(Canvas canvas, VecPolygonShape s) {
    final w = s.transform.width;
    final h = s.transform.height;
    final cx = w / 2;
    final cy = h / 2;
    final rx = w / 2;
    final ry = h / 2;
    final sides = s.sideCount.clamp(3, 128);
    final hasStar = s.starDepth != null && s.starDepth! > 0;

    final path = Path();
    final angleStep = (2 * math.pi) / sides;
    const startAngle = -math.pi / 2; // start at top

    for (var i = 0; i < sides; i++) {
      final angle = startAngle + angleStep * i;
      final x = cx + rx * math.cos(angle);
      final y = cy + ry * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      if (hasStar) {
        final depth = s.starDepth!.clamp(0.01, 0.99);
        final irx = rx * (1 - depth);
        final iry = ry * (1 - depth);
        final midAngle = angle + angleStep / 2;
        final mx = cx + irx * math.cos(midAngle);
        final my = cy + iry * math.sin(midAngle);
        path.lineTo(mx, my);
      }
    }
    path.close();

    _applyFillsAndStrokes(canvas, path, s.data.fills, s.data.strokes);
  }

  // ===========================================================================
  // Text
  // ===========================================================================

  void _renderText(Canvas canvas, VecTextShape s) {
    final w = s.transform.width;

    TextAlign align;
    switch (s.alignment) {
      case VecTextAlign.left:
        align = TextAlign.left;
        break;
      case VecTextAlign.center:
        align = TextAlign.center;
        break;
      case VecTextAlign.right:
        align = TextAlign.right;
        break;
      case VecTextAlign.justify:
        align = TextAlign.justify;
        break;
    }

    // Use first fill color for text, default to black
    final textColor = s.data.fills.isNotEmpty
        ? s.data.fills.first.color.toFlutterColor().withAlpha((s.data.fills.first.opacity * 255).round())
        : const Color(0xFF000000);

    final tp = TextPainter(
      text: TextSpan(
        text: s.content,
        style: TextStyle(
          fontFamily: s.fontFamily,
          fontSize: s.fontSize,
          fontWeight: FontWeight.values[((s.fontWeight / 100).clamp(1, 9).round() - 1)],
          letterSpacing: s.tracking,
          height: s.leading,
          color: textColor,
        ),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
    );

    tp.layout(maxWidth: w > 0 ? w : double.infinity);
    tp.paint(canvas, Offset.zero);
  }

  // ===========================================================================
  // Group — recurse into children
  // ===========================================================================

  void _renderGroup(Canvas canvas, VecGroupShape s) {
    for (final child in s.children) {
      render(canvas, child);
    }
  }

  // ===========================================================================
  // Symbol instance — resolve master and render its layers
  // ===========================================================================

  void _renderSymbolInstance(Canvas canvas, VecSymbolInstanceShape s) {
    final symbol = symbols.cast<VecSymbol?>().firstWhere(
      (sym) => sym!.id == s.symbolId,
      orElse: () => null,
    );

    if (symbol == null) {
      // Render a placeholder when symbol is missing
      _renderMissingSymbolPlaceholder(canvas, s);
      return;
    }

    // Apply alpha override as an additional layer
    final effectiveAlpha = s.alphaOverride.clamp(0.0, 1.0);
    final needsAlphaLayer = effectiveAlpha < 1.0;
    if (needsAlphaLayer) {
      canvas.saveLayer(
        null,
        Paint()
          ..color = Color.fromARGB((effectiveAlpha * 255).round(), 255, 255, 255),
      );
    }

    // Apply registration point offset so symbol origin aligns with instance origin
    if (symbol.registrationPoint != null) {
      canvas.translate(-symbol.registrationPoint!.x, -symbol.registrationPoint!.y);
    }

    // Render symbol layers bottom-to-top
    _renderSymbolLayers(canvas, symbol.layers);

    // Apply color tint as an overlay if tintAmount > 0
    if (s.colorTint != null && s.tintAmount > 0) {
      _applyTint(canvas, s, symbol);
    }

    if (needsAlphaLayer) canvas.restore();
  }

  void _renderSymbolLayers(Canvas canvas, List<VecLayer> layers) {
    final sorted = List<VecLayer>.from(layers)
      ..sort((a, b) => a.order.compareTo(b.order));
    for (final layer in sorted) {
      if (!layer.visible) continue;
      for (final shape in layer.shapes) {
        render(canvas, shape);
      }
    }
  }

  void _applyTint(Canvas canvas, VecSymbolInstanceShape s, VecSymbol symbol) {
    // Measure the symbol's bounding box to draw the tint overlay
    var minX = double.infinity, minY = double.infinity;
    var maxX = double.negativeInfinity, maxY = double.negativeInfinity;
    for (final layer in symbol.layers) {
      for (final shape in layer.shapes) {
        final t = shape.transform;
        if (t.x < minX) minX = t.x;
        if (t.y < minY) minY = t.y;
        if (t.x + t.width > maxX) maxX = t.x + t.width;
        if (t.y + t.height > maxY) maxY = t.y + t.height;
      }
    }
    if (minX == double.infinity) return;

    final tintColor = s.colorTint!.toFlutterColor()
        .withAlpha((s.tintAmount.clamp(0.0, 1.0) * 255).round());
    canvas.drawRect(
      Rect.fromLTRB(minX, minY, maxX, maxY),
      Paint()
        ..color = tintColor
        ..blendMode = BlendMode.srcATop,
    );
  }

  // ===========================================================================
  // Image shape
  // ===========================================================================

  void _renderImage(Canvas canvas, VecImageShape s) {
    final t = s.transform;
    final dstRect = Rect.fromLTWH(0, 0, t.width, t.height);
    final image = imageCache[s.assetId];

    if (image == null) {
      // Placeholder: grey rect with a dashed border and image icon cross
      final paint = Paint()
        ..color = const Color(0x22888888)
        ..style = PaintingStyle.fill;
      canvas.drawRect(dstRect, paint);
      final border = Paint()
        ..color = const Color(0x88888888)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawRect(dstRect, border);
      // Draw a simple X to indicate missing image
      canvas.drawLine(dstRect.topLeft, dstRect.bottomRight, border);
      canvas.drawLine(dstRect.topRight, dstRect.bottomLeft, border);
      return;
    }

    final imgW = image.width.toDouble();
    final imgH = image.height.toDouble();

    Rect srcRect;
    Rect finalDst;

    switch (s.fit) {
      case VecImageFit.fill:
        srcRect = Rect.fromLTWH(0, 0, imgW, imgH);
        finalDst = dstRect;
        break;
      case VecImageFit.contain:
        {
          final scaleX = dstRect.width / imgW;
          final scaleY = dstRect.height / imgH;
          final scale = math.min(scaleX, scaleY);
          final fw = imgW * scale;
          final fh = imgH * scale;
          finalDst = Rect.fromLTWH(
            (dstRect.width - fw) / 2,
            (dstRect.height - fh) / 2,
            fw,
            fh,
          );
          srcRect = Rect.fromLTWH(0, 0, imgW, imgH);
        }
        break;
      case VecImageFit.cover:
        {
          final scaleX = dstRect.width / imgW;
          final scaleY = dstRect.height / imgH;
          final scale = math.max(scaleX, scaleY);
          final fw = imgW * scale;
          final fh = imgH * scale;
          final ox = (fw - dstRect.width) / 2;
          final oy = (fh - dstRect.height) / 2;
          srcRect = Rect.fromLTWH(
            ox / scale,
            oy / scale,
            dstRect.width / scale,
            dstRect.height / scale,
          );
          finalDst = dstRect;
        }
        break;
      case VecImageFit.none:
        srcRect = Rect.fromLTWH(0, 0, math.min(imgW, dstRect.width), math.min(imgH, dstRect.height));
        finalDst = Rect.fromLTWH(0, 0, srcRect.width, srcRect.height);
        break;
    }

    canvas.save();
    canvas.clipRect(dstRect);
    canvas.drawImageRect(image, srcRect, finalDst, Paint());
    canvas.restore();

    // Apply fills/strokes on top of the image (e.g. color overlay, border)
    if (s.fills.isNotEmpty || s.strokes.isNotEmpty) {
      final path = Path()..addRect(dstRect);
      _applyFillsAndStrokes(canvas, path, s.fills, s.strokes);
    }
  }

  void _renderMissingSymbolPlaceholder(Canvas canvas, VecSymbolInstanceShape s) {
    final t = s.transform;
    final rect = Rect.fromLTWH(0, 0, t.width, t.height);
    final paint = Paint()
      ..color = const Color(0x44FF0000)
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, paint);
    final border = Paint()
      ..color = const Color(0xFFFF0000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRect(rect, border);
  }

  // ===========================================================================
  // Compound (live pathfinder result)
  // ===========================================================================

  static const _shapeToPath = ShapeToPath();

  void _renderCompound(Canvas canvas, VecCompoundShape s) {
    // computeCompoundPath() returns a path in the original canvas space of the
    // input shapes (absolute coordinates).  We normalise it to local-origin
    // space (top-left = 0,0) so that _applyTransform (already applied to the
    // canvas above) positions, rotates, and scales it correctly — just like
    // any other shape type.
    var path = _shapeToPath.computeCompoundPath(s);
    final naturalBounds = path.getBounds();
    if (!naturalBounds.isEmpty) {
      path = path.shift(Offset(-naturalBounds.left, -naturalBounds.top));
    }
    _applyFillsAndStrokes(canvas, path, s.data.fills, s.data.strokes);
  }

  // ===========================================================================
  // Fills & Strokes
  // ===========================================================================

  void _applyFillsAndStrokes(
    Canvas canvas,
    Path path,
    List<VecFill> fills,
    List<VecStroke> strokes,
  ) {
    // Fills first (bottom), then strokes (on top)
    for (final fill in fills) {
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..blendMode = mapBlendMode(fill.blendMode);

      if (fill.gradient != null) {
        final bounds = path.getBounds();
        if (!bounds.isEmpty) {
          paint.shader = _buildGradientShader(fill.gradient!, bounds, fill.opacity);
        }
      } else {
        paint.color = fill.color.toFlutterColor().withAlpha((fill.opacity * 255).round());
      }

      canvas.drawPath(path, paint);
    }

    for (final stroke in strokes) {
      _applyStroke(canvas, path, stroke);
    }
  }

  Shader _buildGradientShader(VecGradient g, Rect bounds, double opacity) {
    final alphaFactor = opacity.clamp(0.0, 1.0);
    final colors = g.stops
        .map((s) => s.color.toFlutterColor().withAlpha((alphaFactor * 255).round()))
        .toList();
    final positions = g.stops.map((s) => s.position.toDouble()).toList();

    if (g.type == VecGradientType.linear) {
      // angle 0° = left→right, 90° = top→bottom (CSS-like)
      final rad = g.angle * math.pi / 180.0;
      final cx = bounds.left + bounds.width * 0.5;
      final cy = bounds.top + bounds.height * 0.5;
      final halfDiag = math.sqrt(bounds.width * bounds.width + bounds.height * bounds.height) / 2;
      final bx = math.cos(rad) * halfDiag;
      final by = math.sin(rad) * halfDiag;
      return LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: colors,
        stops: positions,
      ).createShader(Rect.fromLTWH(
        cx - bx, cy - by, bx * 2, by * 2,
      ));
    } else {
      return RadialGradient(
        center: Alignment(g.centerX * 2 - 1, g.centerY * 2 - 1),
        radius: g.radius,
        colors: colors,
        stops: positions,
      ).createShader(bounds);
    }
  }

  void _applyStroke(Canvas canvas, Path path, VecStroke stroke) {
    final color = stroke.color.toFlutterColor().withAlpha((stroke.opacity * 255).round());

    StrokeCap cap;
    switch (stroke.cap) {
      case VecStrokeCap.butt:
        cap = StrokeCap.butt;
        break;
      case VecStrokeCap.round:
        cap = StrokeCap.round;
        break;
      case VecStrokeCap.square:
        cap = StrokeCap.square;
        break;
    }

    StrokeJoin join;
    switch (stroke.join) {
      case VecStrokeJoin.miter:
        join = StrokeJoin.miter;
        break;
      case VecStrokeJoin.round:
        join = StrokeJoin.round;
        break;
      case VecStrokeJoin.bevel:
        join = StrokeJoin.bevel;
        break;
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke.width
      ..strokeCap = cap
      ..strokeJoin = join
      ..blendMode = mapBlendMode(stroke.blendMode);

    // Stroke alignment: inside/outside is approximated by scaling the path
    switch (stroke.align) {
      case VecStrokeAlign.center:
        _drawStrokeWithDash(canvas, path, paint, stroke);
        break;
      case VecStrokeAlign.inside:
        canvas.save();
        canvas.clipPath(path);
        paint.strokeWidth = stroke.width * 2;
        _drawStrokeWithDash(canvas, path, paint, stroke);
        canvas.restore();
        break;
      case VecStrokeAlign.outside:
        canvas.save();
        // Clip to inverse of path
        final outerRect = path.getBounds().inflate(stroke.width * 4);
        final inversePath = Path()
          ..addRect(outerRect)
          ..addPath(path, Offset.zero);
        inversePath.fillType = PathFillType.evenOdd;
        canvas.clipPath(inversePath);
        paint.strokeWidth = stroke.width * 2;
        _drawStrokeWithDash(canvas, path, paint, stroke);
        canvas.restore();
        break;
    }
  }

  void _drawStrokeWithDash(Canvas canvas, Path path, Paint paint, VecStroke stroke) {
    if (stroke.dashPattern.isEmpty) {
      canvas.drawPath(path, paint);
    } else {
      // Compute dashed path
      final dashedPath = _dashPath(path, stroke.dashPattern, stroke.dashOffset);
      canvas.drawPath(dashedPath, paint);
    }
  }

  /// Creates a dashed version of [source] using the given [pattern] and [offset].
  Path _dashPath(Path source, List<double> pattern, double offset) {
    if (pattern.isEmpty) return source;

    final result = Path();
    for (final metric in source.computeMetrics()) {
      var distance = offset % _patternLength(pattern);
      var patternIndex = 0;
      var draw = true;

      while (distance < metric.length) {
        final segmentLength = pattern[patternIndex % pattern.length];
        final end = (distance + segmentLength).clamp(0.0, metric.length);

        if (draw) {
          final segment = metric.extractPath(distance, end);
          result.addPath(segment, Offset.zero);
        }

        distance = end;
        draw = !draw;
        patternIndex++;
      }
    }
    return result;
  }

  double _patternLength(List<double> pattern) {
    var sum = 0.0;
    for (final v in pattern) {
      sum += v;
    }
    return sum;
  }

  // ===========================================================================
  // Hit testing — returns the path for a shape (for selection)
  // ===========================================================================

  /// Returns the transformed bounding rect for a shape (for selection overlays).
  Rect? getBounds(VecShape shape) {
    final t = shape.transform;
    return Rect.fromLTWH(t.x, t.y, t.width, t.height);
  }
}
