import 'dart:math' as math;

import '../../data/models/vec_asset.dart';
import '../pathfinder/pathfinder.dart';
import '../../data/models/vec_color.dart';
import '../../data/models/vec_document.dart';
import '../../data/models/vec_effect.dart';
import '../../data/models/vec_fill.dart';
import '../../data/models/vec_gradient.dart';
import '../../data/models/vec_keyframe.dart';
import '../../data/models/vec_layer.dart';
import '../../data/models/vec_path_node.dart';
import '../../data/models/vec_pattern.dart';
import '../../data/models/vec_scene.dart';
import '../../data/models/vec_shape.dart';
import '../../data/models/vec_stroke.dart';
import '../../data/models/vec_symbol.dart';
import '../../data/models/vec_timeline.dart';
import '../../data/models/vec_track.dart';
import '../../data/models/vec_transform.dart';

/// Exports a [VecScene] to an SVG string.
class SvgExporter {
  SvgExporter();

  // ---------------------------------------------------------------------------
  // Per-export state — populated at start of export(), cleared at end.
  // Safe in Dart because isolates share no mutable state.
  // ---------------------------------------------------------------------------

  /// Maps a VecGradient → SVG id (e.g. "lg0", "rg1") for the current export.
  final Map<VecGradient, String> _gradientMap = {};

  /// Maps a (VecPattern, foreground-hex) key → SVG id for the current export.
  final Map<String, String> _patternMap = {};

  /// Document assets for the current export (used by _imageToSvg).
  List<VecAsset> _assets = const [];

  int _gradId = 0;
  int _patId = 0;

  void _clearExportState() {
    _gradientMap.clear();
    _patternMap.clear();
    _assets = const [];
    _gradId = 0;
    _patId = 0;
  }

  String export(VecDocument doc, VecScene scene, {bool minify = false}) {
    _assets = doc.assets;
    final symbols = doc.symbols;
    final w = doc.meta.stageWidth;
    final h = doc.meta.stageHeight;
    final bg = doc.meta.backgroundColor;

    final buf = StringBuffer();
    final nl = minify ? '' : '\n';
    final ind = minify ? '' : '  ';

    // Collect all shapes for clip mask resolution.
    final allShapes = <VecShape>[];
    for (final layer in scene.layers) {
      allShapes.addAll(layer.shapes);
    }

    // Track which shapes are used as clip masks (should not be rendered).
    final maskShapeIds = <String>{};
    for (final s in allShapes) {
      if (s.clipMaskId != null && s.clipMaskId!.isNotEmpty) {
        maskShapeIds.add(s.clipMaskId!);
      }
    }

    // Collect all filter definitions from shapes with effects.
    final defs = StringBuffer();
    var filterId = 0;
    final filterMap = <String, String>{}; // shapeId → filter id
    final clipPathMap = <String, String>{}; // maskShapeId → clipPath id

    void collectDefs(List<VecShape> shapes) {
      for (final shape in shapes) {
        // Collect filter defs from effects
        final effects = shape.data.effects.where((e) => e.enabled).toList();
        if (effects.isNotEmpty) {
          final fid = 'fx$filterId';
          filterId++;
          filterMap[shape.id] = fid;
          defs.write(_buildSvgFilter(fid, effects, ind, nl));
        }
        // Collect gradient and pattern defs from fills
        for (final fill in shape.fills) {
          if (fill.gradient != null && !_gradientMap.containsKey(fill.gradient)) {
            final g = fill.gradient!;
            final gid = g.type == VecGradientType.linear ? 'lg$_gradId' : 'rg$_gradId';
            _gradId++;
            _gradientMap[g] = gid;
            defs.write(_buildGradientDef(gid, g, ind, nl));
          }
          if (fill.pattern != null) {
            final patKey = '${fill.pattern.hashCode}:${_hexColor(fill.color)}';
            if (!_patternMap.containsKey(patKey)) {
              final pid = 'pat$_patId';
              _patId++;
              _patternMap[patKey] = pid;
              defs.write(_buildPatternDef(pid, fill.pattern!, fill.color, ind, nl));
            }
          }
        }
        shape.maybeMap(
          group: (g) => collectDefs(g.children),
          orElse: () {},
        );
      }
    }

    for (final layer in scene.layers) {
      collectDefs(layer.shapes);
    }

    // Build <clipPath> definitions for mask shapes.
    for (final maskId in maskShapeIds) {
      final maskShape = allShapes.cast<VecShape?>().firstWhere(
        (s) => s!.id == maskId,
        orElse: () => null,
      );
      if (maskShape != null) {
        final cpId = 'cp-${maskId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}';
        clipPathMap[maskId] = cpId;
        defs.write('$ind$ind<clipPath id="$cpId">$nl');
        defs.write(_shapeToSvg(maskShape, symbols, indent: '$ind$ind$ind', nl: nl));
        defs.write('$ind$ind</clipPath>$nl');
      }
    }

    buf.write(
      '<?xml version="1.0" encoding="UTF-8"?>$nl'
      '<svg xmlns="http://www.w3.org/2000/svg"'
      ' width="${_f(w)}" height="${_f(h)}"'
      ' viewBox="0 0 ${_f(w)} ${_f(h)}">$nl',
    );

    // Emit <defs> with filter and clipPath definitions
    if (defs.isNotEmpty) {
      buf.write('$ind<defs>$nl');
      buf.write(defs);
      buf.write('$ind</defs>$nl');
    }

    // Background rect
    if (bg.a > 0) {
      buf.write(
        '$ind<rect width="${_f(w)}" height="${_f(h)}"'
        ' fill="${_hexColor(bg)}"'
        '${bg.a < 255 ? ' fill-opacity="${_f(bg.a / 255)}"' : ''}/>$nl',
      );
    }

    // Sort layers bottom → top
    final layers = List<VecLayer>.from(scene.layers)..sort((a, b) => a.order.compareTo(b.order));

    for (final layer in layers) {
      if (!layer.visible) continue;
      if (layer.type == VecLayerType.guide) continue;

      for (final shape in layer.shapes) {
        buf.write(_shapeToSvg(shape, symbols, indent: ind, nl: nl, filterMap: filterMap, clipPathMap: clipPathMap, maskShapeIds: maskShapeIds));
      }
    }

    buf.write('</svg>');
    final result = buf.toString();
    _clearExportState();
    return result;
  }

  // ---------------------------------------------------------------------------
  // Shape dispatch
  // ---------------------------------------------------------------------------

  String _shapeToSvg(
    VecShape shape,
    List<VecSymbol> symbols, {
    String indent = '  ',
    String nl = '\n',
    Map<String, String> filterMap = const {},
    Map<String, String> clipPathMap = const {},
    Set<String> maskShapeIds = const {},
  }) {
    final opacity = shape.opacity.clamp(0.0, 1.0);
    if (opacity <= 0) return '';

    // Skip shapes that serve as clip masks — they're in <defs> only.
    if (maskShapeIds.contains(shape.id)) return '';

    var result = shape.map(
      path: (s) => _pathShapeToSvg(s, indent, nl),
      rectangle: (s) => _rectToSvg(s, indent, nl),
      ellipse: (s) => _ellipseToSvg(s, indent, nl),
      polygon: (s) => _polygonToSvg(s, indent, nl),
      text: (s) => _textToSvg(s, indent, nl),
      group: (s) => _groupToSvg(s, symbols, indent, nl, filterMap: filterMap, clipPathMap: clipPathMap, maskShapeIds: maskShapeIds),
      compound: (s) => _compoundToSvg(s, indent, nl),
      symbolInstance: (s) => _symbolInstanceToSvg(s, symbols, indent, nl),
      image: (s) => _imageToSvg(s, indent, nl),
    );

    // Wrap with clip-path and/or filter references
    final clipId = shape.clipMaskId;
    final cpId = clipId != null ? clipPathMap[clipId] : null;
    final fid = filterMap[shape.id];

    if (cpId != null || fid != null) {
      final clipAttr = cpId != null ? ' clip-path="url(#$cpId)"' : '';
      final filterAttr = fid != null ? ' filter="url(#$fid)"' : '';
      result = '$indent<g$clipAttr$filterAttr>$nl$result$indent</g>$nl';
    }

    return result;
  }

  // ---------------------------------------------------------------------------
  // Rectangle
  // ---------------------------------------------------------------------------

  String _rectToSvg(VecRectangleShape s, String ind, String nl) {
    final t = s.transform;
    final radii = s.cornerRadii;
    final rx = radii.isNotEmpty ? radii[0] : 0.0;
    final transform = _transformAttr(t);

    final buf = StringBuffer();
    final wrapInGroup = s.fills.length + s.strokes.length > 1 || s.transform.rotation != 0 || s.opacity < 1;

    if (wrapInGroup) {
      buf.write('$ind<g$transform${_opacityAttr(s.opacity)}${_blendModeAttr(s.blendMode)}>$nl');
    }

    final shape =
        '<rect x="0" y="0"'
        ' width="${_f(t.width)}" height="${_f(t.height)}"'
        '${rx > 0 ? ' rx="${_f(rx)}" ry="${_f(rx)}"' : ''}'
        '${wrapInGroup ? '' : '$transform${_opacityAttr(s.opacity)}${_blendModeAttr(s.blendMode)}'}';

    for (final fill in s.fills) {
      buf.write('$ind${wrapInGroup ? '$ind' : ''}$shape${_fillAttrs(fill)} stroke="none"/>$nl');
    }
    if (s.fills.isEmpty) {
      buf.write('$ind${wrapInGroup ? '$ind' : ''}$shape fill="none" stroke="none"/>$nl');
    }
    for (final stroke in s.strokes) {
      buf.write('$ind${wrapInGroup ? '$ind' : ''}$shape fill="none"${_strokeAttrs(stroke)}/>$nl');
    }

    if (wrapInGroup) buf.write('$ind</g>$nl');
    return buf.toString();
  }

  // ---------------------------------------------------------------------------
  // Ellipse
  // ---------------------------------------------------------------------------

  String _ellipseToSvg(VecEllipseShape s, String ind, String nl) {
    final t = s.transform;
    final cx = t.width / 2;
    final cy = t.height / 2;
    final transform = _transformAttr(t);

    final buf = StringBuffer();
    final wrapInGroup = s.fills.length + s.strokes.length > 1 || s.transform.rotation != 0 || s.opacity < 1;

    if (wrapInGroup) {
      buf.write('$ind<g$transform${_opacityAttr(s.opacity)}${_blendModeAttr(s.blendMode)}>$nl');
    }

    final shape =
        '<ellipse cx="${_f(cx)}" cy="${_f(cy)}"'
        ' rx="${_f(cx)}" ry="${_f(cy)}"'
        '${wrapInGroup ? '' : '$transform${_opacityAttr(s.opacity)}${_blendModeAttr(s.blendMode)}'}';

    for (final fill in s.fills) {
      buf.write('$ind${wrapInGroup ? '$ind' : ''}$shape${_fillAttrs(fill)} stroke="none"/>$nl');
    }
    if (s.fills.isEmpty) {
      buf.write('$ind${wrapInGroup ? '$ind' : ''}$shape fill="none" stroke="none"/>$nl');
    }
    for (final stroke in s.strokes) {
      buf.write('$ind${wrapInGroup ? '$ind' : ''}$shape fill="none"${_strokeAttrs(stroke)}/>$nl');
    }

    if (wrapInGroup) buf.write('$ind</g>$nl');
    return buf.toString();
  }

  // ---------------------------------------------------------------------------
  // Polygon / Star
  // ---------------------------------------------------------------------------

  String _polygonToSvg(VecPolygonShape s, String ind, String nl) {
    final t = s.transform;
    final cx = t.width / 2;
    final cy = t.height / 2;
    final rx = cx;
    final ry = cy;
    final sides = s.sideCount;
    final starDepth = s.starDepth;
    final transform = _transformAttr(t);

    final points = <String>[];
    if (starDepth != null && starDepth < 1.0) {
      // Star polygon
      final innerRx = rx * starDepth;
      final innerRy = ry * starDepth;
      for (var i = 0; i < sides; i++) {
        final outerAngle = (i * 2 * math.pi / sides) - math.pi / 2;
        final innerAngle = outerAngle + math.pi / sides;
        points.add('${_f(cx + rx * math.cos(outerAngle))},${_f(cy + ry * math.sin(outerAngle))}');
        points.add('${_f(cx + innerRx * math.cos(innerAngle))},${_f(cy + innerRy * math.sin(innerAngle))}');
      }
    } else {
      for (var i = 0; i < sides; i++) {
        final angle = (i * 2 * math.pi / sides) - math.pi / 2;
        points.add('${_f(cx + rx * math.cos(angle))},${_f(cy + ry * math.sin(angle))}');
      }
    }

    final pointsStr = points.join(' ');
    final buf = StringBuffer();
    final wrapInGroup = s.fills.length + s.strokes.length > 1 || s.transform.rotation != 0 || s.opacity < 1;

    if (wrapInGroup) {
      buf.write('$ind<g$transform${_opacityAttr(s.opacity)}${_blendModeAttr(s.blendMode)}>$nl');
    }

    final shape =
        '<polygon points="$pointsStr"'
        '${wrapInGroup ? '' : '$transform${_opacityAttr(s.opacity)}${_blendModeAttr(s.blendMode)}'}';

    for (final fill in s.fills) {
      buf.write('$ind${wrapInGroup ? '$ind' : ''}$shape${_fillAttrs(fill)} stroke="none"/>$nl');
    }
    if (s.fills.isEmpty) {
      buf.write('$ind${wrapInGroup ? '$ind' : ''}$shape fill="none" stroke="none"/>$nl');
    }
    for (final stroke in s.strokes) {
      buf.write('$ind${wrapInGroup ? '$ind' : ''}$shape fill="none"${_strokeAttrs(stroke)}/>$nl');
    }

    if (wrapInGroup) buf.write('$ind</g>$nl');
    return buf.toString();
  }

  // ---------------------------------------------------------------------------
  // Path
  // ---------------------------------------------------------------------------

  String _pathShapeToSvg(VecPathShape s, String ind, String nl) {
    final d = _buildPathData(s.nodes, s.isClosed);
    final transform = _transformAttr(s.transform);

    final buf = StringBuffer();
    final wrapInGroup = s.fills.length + s.strokes.length > 1 || s.transform.rotation != 0 || s.opacity < 1;

    if (wrapInGroup) {
      buf.write('$ind<g$transform${_opacityAttr(s.opacity)}${_blendModeAttr(s.blendMode)}>$nl');
    }

    final shape =
        '<path d="$d"'
        '${wrapInGroup ? '' : '$transform${_opacityAttr(s.opacity)}${_blendModeAttr(s.blendMode)}'}';

    for (final fill in s.fills) {
      buf.write('$ind${wrapInGroup ? '$ind' : ''}$shape${_fillAttrs(fill)} stroke="none"/>$nl');
    }
    if (s.fills.isEmpty) {
      buf.write('$ind${wrapInGroup ? '$ind' : ''}$shape fill="none" stroke="none"/>$nl');
    }
    for (final stroke in s.strokes) {
      buf.write('$ind${wrapInGroup ? '$ind' : ''}$shape fill="none"${_strokeAttrs(stroke)}/>$nl');
    }

    if (wrapInGroup) buf.write('$ind</g>$nl');
    return buf.toString();
  }

  String _buildPathData(List<VecPathNode> nodes, bool closed) {
    if (nodes.isEmpty) return '';
    final buf = StringBuffer();

    buf.write('M ${_f(nodes[0].position.x)},${_f(nodes[0].position.y)}');

    for (var i = 1; i < nodes.length; i++) {
      final from = nodes[i - 1];
      final to = nodes[i];
      _appendSegment(buf, from, to);
    }

    // Close the path back to first node
    if (closed && nodes.length > 2) {
      _appendSegment(buf, nodes.last, nodes.first);
      buf.write(' Z');
    }

    return buf.toString();
  }

  void _appendSegment(StringBuffer buf, VecPathNode from, VecPathNode to) {
    final hasHOut = from.handleOut != null;
    final hasHIn = to.handleIn != null;

    if (hasHOut || hasHIn) {
      final cp1x = hasHOut ? from.handleOut!.x : from.position.x;
      final cp1y = hasHOut ? from.handleOut!.y : from.position.y;
      final cp2x = hasHIn ? to.handleIn!.x : to.position.x;
      final cp2y = hasHIn ? to.handleIn!.y : to.position.y;
      buf.write(' C ${_f(cp1x)},${_f(cp1y)} ${_f(cp2x)},${_f(cp2y)} ${_f(to.position.x)},${_f(to.position.y)}');
    } else {
      buf.write(' L ${_f(to.position.x)},${_f(to.position.y)}');
    }
  }

  // ---------------------------------------------------------------------------
  // Text
  // ---------------------------------------------------------------------------

  String _textToSvg(VecTextShape s, String ind, String nl) {
    final t = s.transform;
    final transform = _transformAttr(t);

    final fill = s.fills.isNotEmpty ? _fillAttrs(s.fills.first) : ' fill="#000000"';
    final anchor = switch (s.alignment) {
      VecTextAlign.left => 'start',
      VecTextAlign.center => 'middle',
      VecTextAlign.right => 'end',
      VecTextAlign.justify => 'start',
    };

    final weight = s.fontWeight >= 700 ? 'bold' : (s.fontWeight >= 500 ? '600' : 'normal');

    return '$ind<text$transform x="0" y="${_f(s.fontSize)}"'
        ' font-family="${_escape(s.fontFamily)}"'
        ' font-size="${_f(s.fontSize)}"'
        ' font-weight="$weight"'
        ' text-anchor="$anchor"'
        '${_opacityAttr(s.opacity)}'
        '$fill'
        '>${_escape(s.content)}</text>$nl';
  }

  // ---------------------------------------------------------------------------
  // Group
  // ---------------------------------------------------------------------------

  String _groupToSvg(
    VecGroupShape s,
    List<VecSymbol> symbols,
    String ind,
    String nl, {
    Map<String, String> filterMap = const {},
    Map<String, String> clipPathMap = const {},
    Set<String> maskShapeIds = const {},
  }) {
    final transform = _transformAttr(s.transform);
    final buf = StringBuffer();

    buf.write('$ind<g$transform${_opacityAttr(s.opacity)}${_blendModeAttr(s.blendMode)}>$nl');
    for (final child in s.children) {
      buf.write(_shapeToSvg(child, symbols, indent: '$ind  ', nl: nl, filterMap: filterMap, clipPathMap: clipPathMap, maskShapeIds: maskShapeIds));
    }
    buf.write('$ind</g>$nl');

    return buf.toString();
  }

  // ---------------------------------------------------------------------------
  // Symbol instance — render master layers inline as a <g>
  // ---------------------------------------------------------------------------

  String _symbolInstanceToSvg(VecSymbolInstanceShape s, List<VecSymbol> symbols, String ind, String nl) {
    final symbol = symbols.cast<VecSymbol?>().firstWhere(
      (sym) => sym!.id == s.symbolId,
      orElse: () => null,
    );
    if (symbol == null) return '';

    final transform = _transformAttr(s.transform);
    final opacity = s.opacity * s.alphaOverride;
    final buf = StringBuffer();
    buf.write('$ind<g$transform${_opacityAttr(opacity)}${_blendModeAttr(s.blendMode)}>$nl');

    // Render symbol layers bottom-to-top
    final sorted = List<VecLayer>.from(symbol.layers)
      ..sort((a, b) => a.order.compareTo(b.order));
    for (final layer in sorted) {
      if (!layer.visible) continue;
      for (final shape in layer.shapes) {
        buf.write(_shapeToSvg(shape, symbols, indent: '$ind  ', nl: nl));
      }
    }

    buf.write('$ind</g>$nl');
    return buf.toString();
  }

  // ---------------------------------------------------------------------------
  // Compound (pathfinder result)
  // ---------------------------------------------------------------------------

  String _compoundToSvg(VecCompoundShape s, String ind, String nl) {
    // Expand the compound (boolean pathfinder result) to a sampled VecPathShape
    // using the same pathfinder logic as the canvas renderer, then serialise to SVG.
    final expanded = PathfinderOps.expand(s);
    return expanded.maybeMap(
      path: (p) => _pathShapeToSvg(p, ind, nl),
      orElse: () {
        final transform = _transformAttr(s.transform);
        return '$ind<g$transform><!-- compound: empty --></g>$nl';
      },
    );
  }

  String _imageToSvg(VecImageShape s, String ind, String nl) {
    final t = s.transform;
    final transform = _transformAttr(t);
    final opacity = s.opacity < 1 ? ' opacity="${_f(s.opacity)}"' : '';

    // Look up the asset and embed as a base64 data URI when available.
    final asset = _assets.cast<VecAsset?>().firstWhere(
      (a) => a!.id == s.assetId,
      orElse: () => null,
    );
    String hrefAttr = '';
    if (asset != null && asset.dataBase64 != null && asset.dataBase64!.isNotEmpty) {
      final mime = asset.mimeType ?? 'image/png';
      hrefAttr = ' href="data:$mime;base64,${asset.dataBase64}"';
    } else if (asset != null && asset.path.isNotEmpty) {
      hrefAttr = ' href="${_escape(asset.path)}"';
    }

    return '$ind<image$transform x="0" y="0" width="${_f(t.width)}" height="${_f(t.height)}"'
        ' preserveAspectRatio="${_imagePreserveAspectRatio(s.fit)}"$hrefAttr$opacity/>$nl';
  }

  String _imagePreserveAspectRatio(VecImageFit fit) {
    switch (fit) {
      case VecImageFit.contain:
        return 'xMidYMid meet';
      case VecImageFit.cover:
        return 'xMidYMid slice';
      case VecImageFit.fill:
        return 'none';
      case VecImageFit.none:
        return 'xMinYMin meet';
    }
  }

  // ---------------------------------------------------------------------------
  // SVG filter generation
  // ---------------------------------------------------------------------------

  String _buildSvgFilter(String id, List<VecEffect> effects, String ind, String nl) {
    final buf = StringBuffer();
    buf.write('$ind$ind<filter id="$id" x="-50%" y="-50%" width="200%" height="200%">$nl');

    for (final fx in effects) {
      switch (fx.type) {
        case VecEffectType.blur:
          buf.write(
            '$ind$ind$ind<feGaussianBlur in="SourceGraphic" stdDeviation="${_f(fx.blur)}"'
            ' result="blur"/>$nl',
          );
          break;
        case VecEffectType.shadow:
          buf.write(
            '$ind$ind$ind<feDropShadow dx="${_f(fx.offsetX)}" dy="${_f(fx.offsetY)}"'
            ' stdDeviation="${_f(fx.blur)}"'
            ' flood-color="${_hexColor(fx.color)}"'
            ' flood-opacity="${_f(fx.opacity * (fx.color.a / 255.0))}"/>$nl',
          );
          break;
        case VecEffectType.glow:
          // Glow = no offset shadow with spread approximated by extra blur
          final glowBlur = fx.blur + fx.spread;
          buf.write(
            '$ind$ind$ind<feDropShadow dx="0" dy="0"'
            ' stdDeviation="${_f(glowBlur)}"'
            ' flood-color="${_hexColor(fx.color)}"'
            ' flood-opacity="${_f(fx.opacity * (fx.color.a / 255.0))}"/>$nl',
          );
          break;
      }
    }

    buf.write('$ind$ind</filter>$nl');
    return buf.toString();
  }

  // ---------------------------------------------------------------------------
  // Gradient definition
  // ---------------------------------------------------------------------------

  String _buildGradientDef(String id, VecGradient g, String ind, String nl) {
    final buf = StringBuffer();
    final stops = g.stops.map((s) {
      final hex = _hexColor(s.color);
      final stopOpacity = s.color.a / 255.0;
      final opacityAttr = stopOpacity < 1.0 ? ' stop-opacity="${_f(stopOpacity)}"' : '';
      return '$ind$ind$ind<stop offset="${_f(s.position)}" stop-color="$hex"$opacityAttr/>$nl';
    }).join('');

    if (g.type == VecGradientType.linear) {
      // Angle 0° = left→right, 90° = top→bottom
      final rad = g.angle * math.pi / 180.0;
      final x1 = 0.5 - 0.5 * math.cos(rad);
      final y1 = 0.5 - 0.5 * math.sin(rad);
      final x2 = 0.5 + 0.5 * math.cos(rad);
      final y2 = 0.5 + 0.5 * math.sin(rad);
      buf.write(
        '$ind$ind<linearGradient id="$id"'
        ' x1="${_f(x1)}" y1="${_f(y1)}"'
        ' x2="${_f(x2)}" y2="${_f(y2)}"'
        ' gradientUnits="objectBoundingBox">$nl'
        '$stops'
        '$ind$ind</linearGradient>$nl',
      );
    } else {
      // Radial (and angular, which SVG cannot represent as conic — falls back to radial)
      buf.write(
        '$ind$ind<radialGradient id="$id"'
        ' cx="${_f(g.centerX)}" cy="${_f(g.centerY)}"'
        ' r="${_f(g.radius)}"'
        ' gradientUnits="objectBoundingBox">$nl'
        '$stops'
        '$ind$ind</radialGradient>$nl',
      );
    }
    return buf.toString();
  }

  // ---------------------------------------------------------------------------
  // Pattern definition
  // ---------------------------------------------------------------------------

  String _buildPatternDef(String id, VecPattern pat, VecColor fgColor, String ind, String nl) {
    final scale = pat.scale;
    final thick = pat.thickness;
    final bg = pat.backgroundColor;
    final rot = pat.rotation;

    final fgHex = _hexColor(fgColor);
    final bgRect = bg != null
        ? '<rect width="${_f(scale)}" height="${_f(scale)}" fill="${_hexColor(bg)}"/>'
        : '';
    final transformAttr = rot != 0 ? ' patternTransform="rotate(${_f(rot)})"' : '';

    final content = switch (pat.type) {
      VecPatternType.dots => () {
          final r = (thick / 2).clamp(0.5, scale / 2);
          final c = scale / 2;
          return '$bgRect<circle cx="${_f(c)}" cy="${_f(c)}" r="${_f(r)}" fill="$fgHex"/>';
        }(),
      VecPatternType.stripes => () {
          return '$bgRect<rect x="0" y="0" width="${_f(scale)}" height="${_f(thick)}" fill="$fgHex"/>';
        }(),
      VecPatternType.crosshatch => () {
          final half = _f(thick / 2);
          return '$bgRect'
              '<line x1="0" y1="$half" x2="${_f(scale)}" y2="$half" stroke="$fgHex" stroke-width="${_f(thick)}"/>'
              '<line x1="$half" y1="0" x2="$half" y2="${_f(scale)}" stroke="$fgHex" stroke-width="${_f(thick)}"/>';
        }(),
      VecPatternType.checkerboard => () {
          final half = scale / 2;
          final c2Hex = bg != null ? _hexColor(bg) : '#ffffff';
          return '<rect width="${_f(half)}" height="${_f(half)}" fill="$fgHex"/>'
              '<rect x="${_f(half)}" y="${_f(half)}" width="${_f(half)}" height="${_f(half)}" fill="$fgHex"/>'
              '<rect x="${_f(half)}" y="0" width="${_f(half)}" height="${_f(half)}" fill="$c2Hex"/>'
              '<rect x="0" y="${_f(half)}" width="${_f(half)}" height="${_f(half)}" fill="$c2Hex"/>';
        }(),
      VecPatternType.customTile => () {
          // Fallback: render as dots (custom tile assets are not embeddable in SVG without full asset resolution)
          final r = (thick / 2).clamp(0.5, scale / 2);
          final c = scale / 2;
          return '$bgRect<circle cx="${_f(c)}" cy="${_f(c)}" r="${_f(r)}" fill="$fgHex"/>';
        }(),
    };

    return '$ind$ind<pattern id="$id" x="0" y="0"'
        ' width="${_f(scale)}" height="${_f(scale)}"'
        ' patternUnits="userSpaceOnUse"$transformAttr>$content</pattern>$nl';
  }

  // ---------------------------------------------------------------------------
  // Transform attribute
  // ---------------------------------------------------------------------------

  String _transformAttr(VecTransform t) {
    final parts = <String>[];

    if (t.x != 0 || t.y != 0) {
      parts.add('translate(${_f(t.x)},${_f(t.y)})');
    }

    final px = t.pivot?.x ?? (t.width / 2);
    final py = t.pivot?.y ?? (t.height / 2);

    if (t.rotation != 0 || t.scaleX != 1 || t.scaleY != 1 || t.skewX != 0 || t.skewY != 0) {
      parts.add('translate(${_f(px)},${_f(py)})');
      if (t.rotation != 0) parts.add('rotate(${_f(t.rotation)})');
      if (t.scaleX != 1 || t.scaleY != 1) parts.add('scale(${_f(t.scaleX)},${_f(t.scaleY)})');
      if (t.skewX != 0) parts.add('skewX(${_f(t.skewX)})');
      if (t.skewY != 0) parts.add('skewY(${_f(t.skewY)})');
      parts.add('translate(${_f(-px)},${_f(-py)})');
    }

    if (parts.isEmpty) return '';
    return ' transform="${parts.join(' ')}"';
  }

  // ---------------------------------------------------------------------------
  // Fill / Stroke attributes
  // ---------------------------------------------------------------------------

  String _fillAttrs(VecFill fill) {
    final opacity = fill.opacity.clamp(0.0, 1.0);
    final blendCss = _blendModeCss(fill.blendMode);
    final blendStyle = blendCss != null ? ' style="mix-blend-mode: $blendCss"' : '';

    // Gradient fill
    if (fill.gradient != null) {
      final gid = _gradientMap[fill.gradient!];
      if (gid != null) {
        var s = ' fill="url(#$gid)"';
        if (opacity < 1.0) s += ' fill-opacity="${_f(opacity)}"';
        return '$s$blendStyle';
      }
    }

    // Pattern fill
    if (fill.pattern != null) {
      final patKey = '${fill.pattern.hashCode}:${_hexColor(fill.color)}';
      final pid = _patternMap[patKey];
      if (pid != null) {
        var s = ' fill="url(#$pid)"';
        if (opacity < 1.0) s += ' fill-opacity="${_f(opacity)}"';
        return '$s$blendStyle';
      }
    }

    // Flat color fallback
    final hex = _hexColor(fill.color);
    final colorOpacity = fill.color.a / 255.0 * opacity;
    var s = ' fill="$hex"';
    if (colorOpacity < 1.0) s += ' fill-opacity="${_f(colorOpacity)}"';
    return '$s$blendStyle';
  }

  String _strokeAttrs(VecStroke stroke) {
    final opacity = stroke.opacity.clamp(0.0, 1.0);
    final hex = _hexColor(stroke.color);
    final colorOpacity = stroke.color.a / 255.0 * opacity;
    final cap = _strokeCapName(stroke.cap);
    final join = _strokeJoinName(stroke.join);

    var s = ' stroke="$hex" stroke-width="${_f(stroke.width)}"';
    if (colorOpacity < 1.0) s += ' stroke-opacity="${_f(colorOpacity)}"';
    if (cap != 'butt') s += ' stroke-linecap="$cap"';
    if (join != 'miter') s += ' stroke-linejoin="$join"';
    if (stroke.dashPattern.isNotEmpty) {
      s += ' stroke-dasharray="${stroke.dashPattern.map(_f).join(',')}"';
      if (stroke.dashOffset != 0) s += ' stroke-dashoffset="${_f(stroke.dashOffset)}"';
    }
    return s;
  }

  String _opacityAttr(double opacity) {
    if (opacity >= 1.0) return '';
    return ' opacity="${_f(opacity.clamp(0.0, 1.0))}"';
  }

  String _blendModeAttr(VecBlendMode mode) {
    final css = _blendModeCss(mode);
    if (css == null) return '';
    return ' style="mix-blend-mode: $css"';
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _hexColor(VecColor c) =>
      '#${c.r.toRadixString(16).padLeft(2, '0')}${c.g.toRadixString(16).padLeft(2, '0')}${c.b.toRadixString(16).padLeft(2, '0')}';

  String _f(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  String _escape(String s) =>
      s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;');

  String _strokeCapName(VecStrokeCap cap) => switch (cap) {
    VecStrokeCap.butt => 'butt',
    VecStrokeCap.round => 'round',
    VecStrokeCap.square => 'square',
  };

  String _strokeJoinName(VecStrokeJoin join) => switch (join) {
    VecStrokeJoin.miter => 'miter',
    VecStrokeJoin.round => 'round',
    VecStrokeJoin.bevel => 'bevel',
  };

  String? _blendModeCss(VecBlendMode mode) => switch (mode) {
    VecBlendMode.normal => null,
    VecBlendMode.multiply => 'multiply',
    VecBlendMode.screen => 'screen',
    VecBlendMode.overlay => 'overlay',
    VecBlendMode.darken => 'darken',
    VecBlendMode.lighten => 'lighten',
    VecBlendMode.colorDodge => 'color-dodge',
    VecBlendMode.colorBurn => 'color-burn',
    VecBlendMode.hardLight => 'hard-light',
    VecBlendMode.softLight => 'soft-light',
    VecBlendMode.difference => 'difference',
    VecBlendMode.exclusion => 'exclusion',
    VecBlendMode.hue => 'hue',
    VecBlendMode.saturation => 'saturation',
    VecBlendMode.color => 'color',
    VecBlendMode.luminosity => 'luminosity',
  };

  // ===========================================================================
  // Animated SVG export — CSS @keyframes
  // ===========================================================================

  /// Exports [scene] as an animated SVG using CSS animations derived from the
  /// timeline keyframes. Shapes without keyframes are emitted as static elements.
  String exportAnimated(VecDocument doc, VecScene scene, {bool minify = false}) {
    _assets = doc.assets;
    final symbols = doc.symbols;
    final w = doc.meta.stageWidth;
    final h = doc.meta.stageHeight;
    final bg = doc.meta.backgroundColor;
    final fps = doc.meta.fps;
    final timeline = scene.timeline;
    final duration = timeline.duration;
    final durationSec = duration / fps;

    final nl = minify ? '' : '\n';
    final ind = minify ? '' : '  ';

    // Build a map from shapeId → track for fast lookup
    final trackMap = <String, VecTrack>{};
    for (final t in timeline.tracks) {
      if (t.shapeId != null) trackMap[t.shapeId!] = t;
    }

    // Collect animated shapes so we can emit CSS
    final animDefs = <String>[];
    final animClasses = <String, String>{}; // shapeId → cssClass

    for (final layer in scene.layers) {
      if (!layer.visible || layer.type == VecLayerType.guide) continue;
      for (final shape in layer.shapes) {
        final track = trackMap[shape.id];
        if (track == null || track.keyframes.length < 2) continue;
        final cssId = 'kf-${shape.id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}';
        animClasses[shape.id] = cssId;
        animDefs.add(_buildCssKeyframes(cssId, track.keyframes, durationSec, duration));
      }
    }

    final loopStr = switch (timeline.loopType) {
      VecLoopType.loop => 'infinite',
      VecLoopType.playOnce => '1',
      VecLoopType.pingPong => 'infinite',
    };
    final dirStr = timeline.loopType == VecLoopType.pingPong ? 'alternate' : 'normal';

    // Collect gradient and pattern defs for the animated scene
    final animDefs2 = StringBuffer(); // gradient/pattern defs
    void collectAnimatedFillDefs(List<VecShape> shapes) {
      for (final shape in shapes) {
        for (final fill in shape.fills) {
          if (fill.gradient != null && !_gradientMap.containsKey(fill.gradient)) {
            final g = fill.gradient!;
            final gid = g.type == VecGradientType.linear ? 'lg$_gradId' : 'rg$_gradId';
            _gradId++;
            _gradientMap[g] = gid;
            animDefs2.write(_buildGradientDef(gid, g, ind, nl));
          }
          if (fill.pattern != null) {
            final patKey = '${fill.pattern.hashCode}:${_hexColor(fill.color)}';
            if (!_patternMap.containsKey(patKey)) {
              final pid = 'pat$_patId';
              _patId++;
              _patternMap[patKey] = pid;
              animDefs2.write(_buildPatternDef(pid, fill.pattern!, fill.color, ind, nl));
            }
          }
        }
        shape.maybeMap(
          group: (g) => collectAnimatedFillDefs(g.children),
          orElse: () {},
        );
      }
    }

    for (final layer in scene.layers) {
      collectAnimatedFillDefs(layer.shapes);
    }

    final buf = StringBuffer();
    buf.write(
      '<?xml version="1.0" encoding="UTF-8"?>$nl'
      '<svg xmlns="http://www.w3.org/2000/svg"'
      ' width="${_f(w)}" height="${_f(h)}"'
      ' viewBox="0 0 ${_f(w)} ${_f(h)}">$nl',
    );

    // Emit gradient/pattern defs
    if (animDefs2.isNotEmpty) {
      buf.write('$ind<defs>$nl');
      buf.write(animDefs2);
      buf.write('$ind</defs>$nl');
    }

    // Style block with keyframe definitions + per-shape animation rules
    if (animDefs.isNotEmpty) {
      buf.write('${ind}<style>$nl');
      for (final def in animDefs) {
        buf.write(def);
      }
      // Per-shape animation application
      for (final entry in animClasses.entries) {
        buf.write(
          '$ind.${entry.value} {$nl'
          '$ind${ind}animation: ${entry.value} ${_f(durationSec)}s linear $loopStr $dirStr;$nl'
          '$ind}$nl',
        );
      }
      buf.write('${ind}</style>$nl');
    }

    // Background rect
    if (bg.a > 0) {
      buf.write(
        '$ind<rect width="${_f(w)}" height="${_f(h)}"'
        ' fill="${_hexColor(bg)}"'
        '${bg.a < 255 ? ' fill-opacity="${_f(bg.a / 255)}"' : ''}/>$nl',
      );
    }

    // Sort layers bottom → top
    final layers = List<VecLayer>.from(scene.layers)..sort((a, b) => a.order.compareTo(b.order));

    for (final layer in layers) {
      if (!layer.visible) continue;
      if (layer.type == VecLayerType.guide) continue;

      for (final shape in layer.shapes) {
        final cssClass = animClasses[shape.id];
        final track = trackMap[shape.id];
        buf.write(_shapeToSvgAnimated(shape, symbols, cssClass, track: track, durationSec: durationSec, loopStr: loopStr, indent: ind, nl: nl));
      }
    }

    buf.write('</svg>');
    final result = buf.toString();
    _clearExportState();
    return result;
  }

  /// Like [_shapeToSvg] but injects a CSS class for animated shapes.
  /// When [track] is provided, SMIL `<animate>` elements are injected for
  /// fill/stroke color changes that CSS cannot target directly.
  String _shapeToSvgAnimated(
    VecShape shape,
    List<VecSymbol> symbols,
    String? cssClass, {
    VecTrack? track,
    double durationSec = 1,
    String loopStr = 'indefinite',
    String indent = '  ',
    String nl = '\n',
  }) {
    if (cssClass == null) return _shapeToSvg(shape, symbols, indent: indent, nl: nl);

    // Inject class attribute by wrapping in a <g>
    final inner = _shapeToSvg(shape, symbols, indent: '$indent  ', nl: nl);
    if (inner.isEmpty) return '';

    final t = shape.transform;
    final tx = t.x + t.width / 2;
    final ty = t.y + t.height / 2;

    // If the track has fill/stroke colour keyframes, inject SMIL <animate> inside the shapes.
    // We append them after the inner SVG element by wrapping in a group and inserting before </g>.
    final smil = track != null ? _buildSmilAnimations(track, durationSec, loopStr, indent: '$indent  ', nl: nl) : '';

    final smilWrapped = smil.isEmpty
        ? inner
        : '$inner$smil';

    return '$indent<g class="$cssClass" style="transform-origin: ${_f(tx)}px ${_f(ty)}px">$nl$smilWrapped$indent</g>$nl';
  }

  /// Builds SMIL `<animate>` elements for fill and stroke colour changes.
  String _buildSmilAnimations(VecTrack track, double durationSec, String loopStr, {String indent = '    ', String nl = '\n'}) {
    final sorted = [...track.keyframes]..sort((a, b) => a.frame.compareTo(b.frame));
    if (sorted.length < 2) return '';

    final totalFrames = sorted.last.frame.toDouble();
    if (totalFrames <= 0) return '';

    final hasFill = sorted.any((kf) => (kf.fills != null && kf.fills!.isNotEmpty) || kf.fillColor != null);
    final hasStroke = sorted.any((kf) => (kf.strokes != null && kf.strokes!.isNotEmpty) || kf.strokeColor != null);

    if (!hasFill && !hasStroke) return '';

    final buf = StringBuffer();
    final dur = '${_f(durationSec)}s';
    final repeat = loopStr == '1' ? '1' : 'indefinite';

    if (hasFill) {
      final keyTimes = sorted.map((kf) => _f((kf.frame / totalFrames).clamp(0.0, 1.0))).join(';');
      final values = sorted.map((kf) {
        final c = kf.fills != null && kf.fills!.isNotEmpty ? kf.fills!.first.color : kf.fillColor;
        return c != null ? _hexColor(c) : 'inherit';
      }).join(';');
      buf.write('$indent<animate attributeName="fill" values="$values" keyTimes="$keyTimes" dur="$dur" repeatCount="$repeat" fill="freeze"/>$nl');
    }

    if (hasStroke) {
      final keyTimes = sorted.map((kf) => _f((kf.frame / totalFrames).clamp(0.0, 1.0))).join(';');
      final values = sorted.map((kf) {
        final c = kf.strokes != null && kf.strokes!.isNotEmpty ? kf.strokes!.first.color : kf.strokeColor;
        return c != null ? _hexColor(c) : 'inherit';
      }).join(';');
      buf.write('$indent<animate attributeName="stroke" values="$values" keyTimes="$keyTimes" dur="$dur" repeatCount="$repeat" fill="freeze"/>$nl');
    }

    return buf.toString();
  }

  /// Emits a CSS @keyframes block for one shape track.
  /// Covers: transform (translate/rotate/scale), opacity.
  /// Fill/stroke colour are handled via SMIL to avoid SVG presentation-attribute
  /// specificity issues.
  String _buildCssKeyframes(
    String name,
    List<VecKeyframe> keyframes,
    double durationSec,
    int totalFrames,
  ) {
    final buf = StringBuffer();
    buf.write('  @keyframes $name {\n');

    final sorted = [...keyframes]..sort((a, b) => a.frame.compareTo(b.frame));

    for (final kf in sorted) {
      final pct = (kf.frame / totalFrames * 100).clamp(0.0, 100.0);
      final t = kf.transform;

      // Skip frames that carry no transform or opacity data.
      final hasTransform = t != null;
      final hasOpacity = kf.opacity != null;
      if (!hasTransform && !hasOpacity) continue;

      final parts = <String>[];
      if (hasTransform) {
        if (t.x != 0 || t.y != 0) parts.add('translate(${_f(t.x)}px, ${_f(t.y)}px)');
        if (t.rotation != 0) parts.add('rotate(${_f(t.rotation)}deg)');
        if (t.scaleX != 1 || t.scaleY != 1) parts.add('scale(${_f(t.scaleX)}, ${_f(t.scaleY)})');
      }

      final transformStr = hasTransform ? (parts.isEmpty ? 'none' : parts.join(' ')) : null;
      final opacityStr = hasOpacity ? '      opacity: ${_f(kf.opacity!)};\n' : '';

      buf.write('    ${_f(pct)}% {\n');
      if (transformStr != null) buf.write('      transform: $transformStr;\n');
      buf.write(opacityStr);
      buf.write('    }\n');
    }

    buf.write('  }\n');
    return buf.toString();
  }
}
