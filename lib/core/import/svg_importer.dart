import 'dart:math' as math;

import 'package:universal_html/parsing.dart' as html_parse;
import 'package:universal_html/html.dart' show Element;
import 'package:uuid/uuid.dart';

import '../../data/models/vec_color.dart';
import '../../data/models/vec_effect.dart';
import '../../data/models/vec_fill.dart';
import '../../data/models/vec_gradient.dart';
import '../../data/models/vec_path_node.dart';
import '../../data/models/vec_point.dart';
import '../../data/models/vec_shape.dart';
import '../../data/models/vec_stroke.dart';
import '../../data/models/vec_transform.dart';

class _SvgContext {
  final Map<String, VecGradient> gradients = {};
  final Map<String, List<VecEffect>> filters = {};
  final Map<String, String> clipPathShapes = {};
  final List<VecShape> extraShapes = [];
}

/// Parses SVG markup and converts elements to [VecShape] objects.
///
/// Supported elements: rect, circle, ellipse, line, polyline, polygon, path, g.
/// Supported attributes: fill, stroke, stroke-width, opacity, fill-opacity,
/// stroke-opacity, transform (translate/rotate/scale), d (path data).
class SvgImporter {
  const SvgImporter();

  static const _uuid = Uuid();

  // ---------------------------------------------------------------------------
  // Entry point
  // ---------------------------------------------------------------------------

  /// Parse [svgContent] and return a flat list of [VecShape]s.
  List<VecShape> import(String svgContent) {
    try {
      final doc = html_parse.parseXmlDocument(svgContent);
      final svgEl = doc.documentElement;
      if (svgEl == null) return const [];
      final ctx = _SvgContext();
      _parseDefs(svgEl, ctx);
      final inheritedStyle = _ParsedStyle.none();
      final shapes = _parseChildren(svgEl, inheritedStyle, ctx);
      return [...ctx.extraShapes, ...shapes];
    } catch (_) {
      return const [];
    }
  }

  // ---------------------------------------------------------------------------
  // Recursive children parser
  // ---------------------------------------------------------------------------

  List<VecShape> _parseChildren(Element parent, _ParsedStyle inherited, _SvgContext ctx) {
    final shapes = <VecShape>[];
    for (final node in parent.childNodes) {
      if (node is! Element) continue;
      final child = node;
      final tag = child.localName.toLowerCase();
      if (tag == 'defs' || tag == 'clippath' || tag == 'filter' || tag == 'lineargradient' || tag == 'radialgradient') {
        continue;
      }
      
      final style = _ParsedStyle.from(child, inherited, ctx);

      switch (tag) {
        case 'rect':
          final s = _parseRect(child, style);
          if (s != null) shapes.add(s);
        case 'circle':
          final s = _parseCircle(child, style);
          if (s != null) shapes.add(s);
        case 'ellipse':
          final s = _parseEllipse(child, style);
          if (s != null) shapes.add(s);
        case 'line':
          final s = _parseLine(child, style);
          if (s != null) shapes.add(s);
        case 'polyline':
        case 'polygon':
          final s = _parsePolyShape(child, tag, style);
          if (s != null) shapes.add(s);
        case 'path':
          shapes.addAll(_parsePath(child, style));
        case 'text':
          final s = _parseText(child, style);
          if (s != null) shapes.add(s);
        case 'g':
          final children = _parseChildren(child, style, ctx);
          if (children.isNotEmpty) {
            final groupT = _parseTransform(child.getAttribute('transform'));
            shapes.add(
              VecShape.group(
                data: VecShapeData(
                  id: _uuid.v4(),
                  transform: groupT ?? const VecTransform(width: 100, height: 100),
                  opacity: style.opacity,
                  effects: style.effects,
                  clipMaskId: style.clipMaskId,
                ),
                children: children,
              ),
            );
          }
        case 'svg':
          shapes.addAll(_parseChildren(child, style, ctx));
        default:
          break;
      }
    }
    return shapes;
  }

  void _parseDefs(Element root, _SvgContext ctx) {
    void visit(Element parent) {
      for (final node in parent.childNodes) {
        if (node is! Element) continue;
        final el = node;
        final tag = el.localName.toLowerCase();

        if (tag == 'lineargradient') {
          final id = el.getAttribute('id');
          if (id != null && id.isNotEmpty) {
            final gradient = _parseLinearGradient(el);
            if (gradient != null) ctx.gradients[id] = gradient;
          }
        } else if (tag == 'radialgradient') {
          final id = el.getAttribute('id');
          if (id != null && id.isNotEmpty) {
            final gradient = _parseRadialGradient(el);
            if (gradient != null) ctx.gradients[id] = gradient;
          }
        } else if (tag == 'filter') {
          final id = el.getAttribute('id');
          if (id != null && id.isNotEmpty) {
            final effects = _parseFilter(el);
            if (effects.isNotEmpty) ctx.filters[id] = effects;
          }
        } else if (tag == 'clippath') {
          final id = el.getAttribute('id');
          if (id != null && id.isNotEmpty) {
            final clipChildren = _parseChildren(el, _ParsedStyle.none(), ctx);
            if (clipChildren.isNotEmpty) {
              if (clipChildren.length == 1) {
                ctx.clipPathShapes[id] = clipChildren.first.data.id;
              } else {
                final groupId = _uuid.v4();
                ctx.clipPathShapes[id] = groupId;
                clipChildren.insert(0, VecShape.group(
                  data: VecShapeData(id: groupId, transform: const VecTransform(width: 100, height: 100)),
                  children: List.from(clipChildren),
                ));
              }
              // Hide clip mask source geometries by zeroing out opacity or strokes/fills to not render on canvas unless selected as mask.
              final hiddenChildren = clipChildren.map((s) => s.map(
                path: (p) => p.copyWith(data: p.data.copyWith(opacity: 0, strokes: [], fills: [])),
                rectangle: (p) => p.copyWith(data: p.data.copyWith(opacity: 0, strokes: [], fills: [])),
                ellipse: (p) => p.copyWith(data: p.data.copyWith(opacity: 0, strokes: [], fills: [])),
                polygon: (p) => p.copyWith(data: p.data.copyWith(opacity: 0, strokes: [], fills: [])),
                text: (p) => p.copyWith(data: p.data.copyWith(opacity: 0, strokes: [], fills: [])),
                group: (p) => p.copyWith(data: p.data.copyWith(opacity: 0)),
                symbolInstance: (p) => p.copyWith(data: p.data.copyWith(opacity: 0)),
                compound: (p) => p.copyWith(data: p.data.copyWith(opacity: 0)),
                image: (p) => p.copyWith(data: p.data.copyWith(opacity: 0)),
              )).toList();
              ctx.extraShapes.addAll(hiddenChildren);
            }
          }
        }

        visit(el);
      }
    }
    visit(root);
  }

  List<VecEffect> _parseFilter(Element el) {
    final effects = <VecEffect>[];
    for (final node in el.childNodes) {
      if (node is! Element) continue;
      final tag = node.localName.toLowerCase();
      if (tag == 'fedropshadow') {
        final dx = _d(node, 'dx');
        final dy = _d(node, 'dy');
        final stdDev = _d(node, 'stdDeviation', fallback: 2.0);
        final color = _ParsedStyle.parseColor(node.getAttribute('flood-color') ?? 'black') ?? const VecColor(a: 255, r: 0, g: 0, b: 0);
        final opacity = _d(node, 'flood-opacity', fallback: 1.0);
        effects.add(VecEffect(
          type: VecEffectType.shadow,
          offsetX: dx,
          offsetY: dy,
          blur: stdDev * 2,
          color: color.copyWith(a: (opacity * 255).round().clamp(0, 255)),
        ));
      } else if (tag == 'fegaussianblur') {
        final stdDev = _d(node, 'stdDeviation', fallback: 2.0);
        effects.add(VecEffect(
          type: VecEffectType.blur,
          blur: stdDev * 2,
        ));
      }
    }
    return effects;
  }

  VecGradient? _parseLinearGradient(Element el) {
    final stops = _parseGradientStops(el);
    if (stops.isEmpty) return null;

    final x1 = _parseUnit(el.getAttribute('x1'), fallback: 0.0);
    final y1 = _parseUnit(el.getAttribute('y1'), fallback: 0.0);
    final x2 = _parseUnit(el.getAttribute('x2'), fallback: 1.0);
    final y2 = _parseUnit(el.getAttribute('y2'), fallback: 0.0);
    final angle = math.atan2(y2 - y1, x2 - x1) * 180 / math.pi;

    return VecGradient(type: VecGradientType.linear, stops: stops, angle: angle);
  }

  VecGradient? _parseRadialGradient(Element el) {
    final stops = _parseGradientStops(el);
    if (stops.isEmpty) return null;

    return VecGradient(
      type: VecGradientType.radial,
      stops: stops,
      centerX: _parseUnit(el.getAttribute('cx'), fallback: 0.5).clamp(0.0, 1.0),
      centerY: _parseUnit(el.getAttribute('cy'), fallback: 0.5).clamp(0.0, 1.0),
      radius: _parseUnit(el.getAttribute('r'), fallback: 0.5).clamp(0.0, 1.5),
    );
  }

  List<VecGradientStop> _parseGradientStops(Element gradientEl) {
    final stops = <VecGradientStop>[];
    for (final node in gradientEl.childNodes) {
      if (node is! Element) continue;
      final stopEl = node;
      if (stopEl.localName.toLowerCase() != 'stop') continue;

      final styleMap = _ParsedStyle.parseInlineStyle(stopEl.getAttribute('style') ?? '');
      String? attr(String name) => styleMap[name] ?? stopEl.getAttribute(name);

      final color = _ParsedStyle.parseColor(attr('stop-color') ?? '');
      if (color == null) continue;

      final offset = _parseUnit(attr('offset'), fallback: 0.0).clamp(0.0, 1.0);
      final stopOpacity = (double.tryParse(attr('stop-opacity') ?? '') ?? 1.0).clamp(0.0, 1.0);
      final alpha = (255 * stopOpacity).round().clamp(0, 255);

      stops.add(
        VecGradientStop(
          color: color.copyWith(a: alpha),
          position: offset,
        ),
      );
    }

    if (stops.isEmpty) return const [];
    if (stops.length == 1) {
      return [stops.first, stops.first.copyWith(position: 1.0)];
    }
    stops.sort((a, b) => a.position.compareTo(b.position));
    return stops;
  }

  double _parseUnit(String? raw, {required double fallback}) {
    if (raw == null) return fallback;
    final s = raw.trim();
    if (s.isEmpty) return fallback;
    if (s.endsWith('%')) {
      final v = double.tryParse(s.substring(0, s.length - 1));
      return v == null ? fallback : v / 100.0;
    }
    return double.tryParse(s) ?? fallback;
  }

  // ---------------------------------------------------------------------------
  // Element parsers
  // ---------------------------------------------------------------------------

  VecShape? _parseText(Element el, _ParsedStyle style) {
    final x = _d(el, 'x');
    final y = _d(el, 'y');
    final text = el.text ?? '';
    if (text.isEmpty) return null;

    final fontSize = _d(el, 'font-size', fallback: 16);
    final fontFamily = el.getAttribute('font-family') ?? 'Inter';
    final fontWeightStr = el.getAttribute('font-weight') ?? '400';
    final int fontWeight;
    if (fontWeightStr == 'bold') {
      fontWeight = 700;
    } else if (fontWeightStr == 'normal') {
      fontWeight = 400;
    } else {
      fontWeight = int.tryParse(fontWeightStr) ?? 400;
    }

    final t = _applyTransform(el, x, y - fontSize, fontSize * text.length * 0.6, fontSize);
    
    return VecShape.text(
      data: _makeData(t, style),
      content: text,
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  VecShape? _parseRect(Element el, _ParsedStyle style) {
    final x = _d(el, 'x');
    final y = _d(el, 'y');
    final w = _d(el, 'width');
    final h = _d(el, 'height');
    if (w <= 0 || h <= 0) return null;
    final rx = _d(el, 'rx', fallback: _d(el, 'ry'));
    final t = _applyTransform(el, x, y, w, h);
    return VecShape.rectangle(data: _makeData(t, style), cornerRadii: [rx, rx, rx, rx]);
  }

  VecShape? _parseCircle(Element el, _ParsedStyle style) {
    final cx = _d(el, 'cx');
    final cy = _d(el, 'cy');
    final r = _d(el, 'r');
    if (r <= 0) return null;
    final t = _applyTransform(el, cx - r, cy - r, r * 2, r * 2);
    return VecShape.ellipse(data: _makeData(t, style));
  }

  VecShape? _parseEllipse(Element el, _ParsedStyle style) {
    final cx = _d(el, 'cx');
    final cy = _d(el, 'cy');
    final rx = _d(el, 'rx');
    final ry = _d(el, 'ry');
    if (rx <= 0 || ry <= 0) return null;
    final t = _applyTransform(el, cx - rx, cy - ry, rx * 2, ry * 2);
    return VecShape.ellipse(data: _makeData(t, style));
  }

  VecShape? _parseLine(Element el, _ParsedStyle style) {
    final x1 = _d(el, 'x1');
    final y1 = _d(el, 'y1');
    final x2 = _d(el, 'x2');
    final y2 = _d(el, 'y2');
    final nodes = [
      VecPathNode(
        position: VecPoint(x: x1, y: y1),
      ),
      VecPathNode(
        position: VecPoint(x: x2, y: y2),
      ),
    ];
    final bbox = _nodesBBox(nodes);
    final t = _applyTransform(el, bbox.$1, bbox.$2, bbox.$3, bbox.$4);
    return VecShape.path(data: _makeData(t, style), nodes: _localiseNodes(nodes, bbox.$1, bbox.$2), isClosed: false);
  }

  VecShape? _parsePolyShape(Element el, String tag, _ParsedStyle style) {
    final pts = _parsePointsList(el.getAttribute('points') ?? '');
    if (pts.length < 2) return null;
    final nodes = pts
        .map(
          (p) => VecPathNode(
            position: VecPoint(x: p.x, y: p.y),
          ),
        )
        .toList();
    final closed = tag == 'polygon';
    final bbox = _nodesBBox(nodes);
    final t = _applyTransform(el, bbox.$1, bbox.$2, bbox.$3, bbox.$4);
    return VecShape.path(data: _makeData(t, style), nodes: _localiseNodes(nodes, bbox.$1, bbox.$2), isClosed: closed);
  }

  List<VecShape> _parsePath(Element el, _ParsedStyle style) {
    final d = el.getAttribute('d') ?? '';
    if (d.isEmpty) return const [];
    final subpaths = _parsePathData(d);
    if (subpaths.isEmpty) return const [];
    if (subpaths.length == 1) {
      final sp = subpaths.first;
      if (sp.nodes.isEmpty) return const [];
      final bbox = _nodesBBox(sp.nodes);
      final t = _applyTransform(el, bbox.$1, bbox.$2, bbox.$3, bbox.$4);
      return [
        VecShape.path(
          data: _makeData(t, style),
          nodes: _localiseNodes(sp.nodes, bbox.$1, bbox.$2),
          isClosed: sp.closed,
        ),
      ];
    }
    // Multiple subpaths → group
    final children = <VecShape>[];
    for (final sp in subpaths) {
      if (sp.nodes.isEmpty) continue;
      final bbox = _nodesBBox(sp.nodes);
      final t = VecTransform(x: bbox.$1, y: bbox.$2, width: bbox.$3, height: bbox.$4);
      children.add(
        VecShape.path(
          data: _makeData(t, style),
          nodes: _localiseNodes(sp.nodes, bbox.$1, bbox.$2),
          isClosed: sp.closed,
        ),
      );
    }
    if (children.isEmpty) return const [];
    final groupT = _applyTransform(el, 0, 0, 100, 100);
    return [
      VecShape.group(
        data: VecShapeData(id: _uuid.v4(), transform: groupT, opacity: style.opacity),
        children: children,
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Path data parser (SVG `d` attribute)
  // ---------------------------------------------------------------------------

  List<_Subpath> _parsePathData(String d) {
    final subpaths = <_Subpath>[];
    final nodes = <VecPathNode>[];
    bool closed = false;
    double cx = 0, cy = 0; // current point
    double startX = 0, startY = 0; // last moveto

    final tokens = _tokenizePathData(d);
    int i = 0;

    void finishSubpath() {
      if (nodes.isNotEmpty) {
        subpaths.add(_Subpath(List.from(nodes), closed));
        nodes.clear();
        closed = false;
      }
    }

    while (i < tokens.length) {
      final cmd = tokens[i++];
      if (cmd.isEmpty) continue;
      final rel = cmd == cmd.toLowerCase() && cmd != 'Z' && cmd != 'z';

      List<double> nums() {
        final result = <double>[];
        while (i < tokens.length && double.tryParse(tokens[i]) != null) {
          result.add(double.parse(tokens[i++]));
        }
        return result;
      }

      switch (cmd.toUpperCase()) {
        case 'M':
          final args = nums();
          for (var k = 0; k < args.length - 1; k += 2) {
            if (k > 0) {
              // implicit lineto after first moveto
            }
            finishSubpath();
            final px = rel ? cx + args[k] : args[k];
            final py = rel ? cy + args[k + 1] : args[k + 1];
            cx = px;
            cy = py;
            startX = px;
            startY = py;
            nodes.add(
              VecPathNode(
                position: VecPoint(x: cx, y: cy),
              ),
            );
          }
        case 'L':
          final args = nums();
          for (var k = 0; k < args.length - 1; k += 2) {
            cx = rel ? cx + args[k] : args[k];
            cy = rel ? cy + args[k + 1] : args[k + 1];
            nodes.add(
              VecPathNode(
                position: VecPoint(x: cx, y: cy),
              ),
            );
          }
        case 'H':
          final args = nums();
          for (final v in args) {
            cx = rel ? cx + v : v;
            nodes.add(
              VecPathNode(
                position: VecPoint(x: cx, y: cy),
              ),
            );
          }
        case 'V':
          final args = nums();
          for (final v in args) {
            cy = rel ? cy + v : v;
            nodes.add(
              VecPathNode(
                position: VecPoint(x: cx, y: cy),
              ),
            );
          }
        case 'C':
          final args = nums();
          for (var k = 0; k < args.length - 5; k += 6) {
            final x1 = rel ? cx + args[k] : args[k];
            final y1 = rel ? cy + args[k + 1] : args[k + 1];
            final x2 = rel ? cx + args[k + 2] : args[k + 2];
            final y2 = rel ? cy + args[k + 3] : args[k + 3];
            final x = rel ? cx + args[k + 4] : args[k + 4];
            final y = rel ? cy + args[k + 5] : args[k + 5];
            // Update handleOut on previous node
            if (nodes.isNotEmpty) {
              final prev = nodes.last;
              nodes[nodes.length - 1] = prev.copyWith(
                handleOut: VecPoint(x: x1, y: y1),
              );
            }
            cx = x;
            cy = y;
            nodes.add(
              VecPathNode(
                position: VecPoint(x: cx, y: cy),
                handleIn: VecPoint(x: x2, y: y2),
              ),
            );
          }
        case 'Q':
          final args = nums();
          for (var k = 0; k < args.length - 3; k += 4) {
            // Convert quadratic to cubic
            final qx1 = rel ? cx + args[k] : args[k];
            final qy1 = rel ? cy + args[k + 1] : args[k + 1];
            final ex = rel ? cx + args[k + 2] : args[k + 2];
            final ey = rel ? cy + args[k + 3] : args[k + 3];
            final cx1 = cx + 2.0 / 3.0 * (qx1 - cx);
            final cy1 = cy + 2.0 / 3.0 * (qy1 - cy);
            final cx2 = ex + 2.0 / 3.0 * (qx1 - ex);
            final cy2 = ey + 2.0 / 3.0 * (qy1 - ey);
            if (nodes.isNotEmpty) {
              final prev = nodes.last;
              nodes[nodes.length - 1] = prev.copyWith(
                handleOut: VecPoint(x: cx1, y: cy1),
              );
            }
            cx = ex;
            cy = ey;
            nodes.add(
              VecPathNode(
                position: VecPoint(x: cx, y: cy),
                handleIn: VecPoint(x: cx2, y: cy2),
              ),
            );
          }
        case 'Z':
          closed = true;
          cx = startX;
          cy = startY;
          finishSubpath();
      }
    }
    finishSubpath();
    return subpaths;
  }

  List<String> _tokenizePathData(String d) {
    // Split on command letters and whitespace/comma separators
    return d
        .replaceAllMapped(RegExp(r'([MmLlHhVvCcQqSsTtAaZz])'), (m) => ' ${m[0]} ')
        .split(RegExp(r'[\s,]+'))
        .where((s) => s.isNotEmpty)
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Transform parser
  // ---------------------------------------------------------------------------

  VecTransform _applyTransform(Element el, double x, double y, double w, double h) {
    final parsed = _parseTransform(el.getAttribute('transform'));
    return VecTransform(
      x: x + (parsed?.x ?? 0),
      y: y + (parsed?.y ?? 0),
      width: w,
      height: h,
      rotation: parsed?.rotation ?? 0,
      scaleX: parsed?.scaleX ?? 1,
      scaleY: parsed?.scaleY ?? 1,
    );
  }

  VecTransform? _parseTransform(String? attr) {
    if (attr == null || attr.isEmpty) return null;
    double tx = 0, ty = 0, rotation = 0, scaleX = 1, scaleY = 1;

    final translateMatch = RegExp(r'translate\(([-\d.]+)(?:[,\s]+([-\d.]+))?\)').firstMatch(attr);
    if (translateMatch != null) {
      tx = double.tryParse(translateMatch[1] ?? '') ?? 0;
      ty = double.tryParse(translateMatch[2] ?? '') ?? 0;
    }

    final rotateMatch = RegExp(r'rotate\(([-\d.]+)').firstMatch(attr);
    if (rotateMatch != null) {
      rotation = double.tryParse(rotateMatch[1] ?? '') ?? 0;
    }

    final scaleMatch = RegExp(r'scale\(([-\d.]+)(?:[,\s]+([-\d.]+))?\)').firstMatch(attr);
    if (scaleMatch != null) {
      scaleX = double.tryParse(scaleMatch[1] ?? '') ?? 1;
      scaleY = double.tryParse(scaleMatch[2] ?? '') ?? scaleX;
    }

    return VecTransform(x: tx, y: ty, rotation: rotation, scaleX: scaleX, scaleY: scaleY);
  }

  // ---------------------------------------------------------------------------
  // Style helpers
  // ---------------------------------------------------------------------------

  VecShapeData _makeData(VecTransform t, _ParsedStyle style) {
    return VecShapeData(
      id: _uuid.v4(),
      transform: t,
      fills: style.fill != null ? [style.fill!] : const [],
      strokes: style.stroke != null ? [style.stroke!] : const [],
      opacity: style.opacity,
      effects: style.effects,
      clipMaskId: style.clipMaskId,
    );
  }

  // ---------------------------------------------------------------------------
  // Geometry helpers
  // ---------------------------------------------------------------------------

  /// (minX, minY, width, height) bounding box of a node list.
  (double, double, double, double) _nodesBBox(List<VecPathNode> nodes) {
    if (nodes.isEmpty) return (0, 0, 1, 1);
    double minX = nodes.first.position.x;
    double maxX = minX;
    double minY = nodes.first.position.y;
    double maxY = minY;
    for (final n in nodes) {
      minX = math.min(minX, n.position.x);
      maxX = math.max(maxX, n.position.x);
      minY = math.min(minY, n.position.y);
      maxY = math.max(maxY, n.position.y);
    }
    return (minX, minY, math.max(maxX - minX, 1.0), math.max(maxY - minY, 1.0));
  }

  /// Translate nodes so origin becomes (0, 0).
  List<VecPathNode> _localiseNodes(List<VecPathNode> nodes, double ox, double oy) {
    return [
      for (final n in nodes)
        VecPathNode(
          position: VecPoint(x: n.position.x - ox, y: n.position.y - oy),
          handleIn: n.handleIn != null ? VecPoint(x: n.handleIn!.x - ox, y: n.handleIn!.y - oy) : null,
          handleOut: n.handleOut != null ? VecPoint(x: n.handleOut!.x - ox, y: n.handleOut!.y - oy) : null,
        ),
    ];
  }

  List<math.Point<double>> _parsePointsList(String pts) {
    final nums = pts.trim().split(RegExp(r'[\s,]+')).map(double.tryParse).whereType<double>().toList();
    final result = <math.Point<double>>[];
    for (var i = 0; i + 1 < nums.length; i += 2) {
      result.add(math.Point(nums[i], nums[i + 1]));
    }
    return result;
  }

  double _d(Element el, String attr, {double fallback = 0.0}) =>
      double.tryParse(el.getAttribute(attr) ?? '') ?? fallback;
}

// ---------------------------------------------------------------------------
// Internal models
// ---------------------------------------------------------------------------

class _Subpath {
  const _Subpath(this.nodes, this.closed);
  final List<VecPathNode> nodes;
  final bool closed;
}

class _ParsedStyle {
  const _ParsedStyle({
    required this.fill,
    required this.stroke,
    required this.opacity,
    required this.effects,
    this.clipMaskId,
  });

  factory _ParsedStyle.none() => const _ParsedStyle(
    fill: null, 
    stroke: null, 
    opacity: 1.0, 
    effects: [],
  );

  factory _ParsedStyle.from(Element el, _ParsedStyle parent, _SvgContext ctx) {
    // Parse style="" inline first, then individual attributes
    final styleMap = parseInlineStyle(el.getAttribute('style') ?? '');
    String? attr(String name) => styleMap[name] ?? el.getAttribute(name);

    final fillStr = attr('fill');
    VecFill? fill = parent.fill;
    if (fillStr != null) {
      if (fillStr == 'none') {
        fill = null;
      } else if (_isUrlRef(fillStr)) {
        final id = _extractUrlRefId(fillStr);
        final gradient = id == null ? null : ctx.gradients[id];
        if (gradient != null) {
          final fo = double.tryParse(attr('fill-opacity') ?? '') ?? 1.0;
          fill = VecFill(color: gradient.stops.first.color, opacity: fo, gradient: gradient);
        } else {
          fill = null;
        }
      } else {
        final c = parseColor(fillStr);
        if (c != null) {
          final fo = double.tryParse(attr('fill-opacity') ?? '') ?? 1.0;
          fill = VecFill(color: c, opacity: fo);
        }
      }
    }

    final strokeStr = attr('stroke');
    VecStroke? stroke = parent.stroke;
    if (strokeStr != null) {
      if (strokeStr == 'none') {
        stroke = null;
      } else {
        final c = parseColor(strokeStr);
        if (c != null) {
          final sw = double.tryParse(attr('stroke-width') ?? '') ?? 1.0;
          final so = double.tryParse(attr('stroke-opacity') ?? '') ?? 1.0;
          stroke = VecStroke(color: c, width: sw, opacity: so);
        }
      }
    }

    final opStr = attr('opacity');
    final opacity = (double.tryParse(opStr ?? '') ?? 1.0) * parent.opacity;

    List<VecEffect> effects = parent.effects;
    final filterStr = attr('filter');
    if (filterStr != null && _isUrlRef(filterStr)) {
      final id = _extractUrlRefId(filterStr);
      if (id != null && ctx.filters.containsKey(id)) {
        effects = [...effects, ...ctx.filters[id]!];
      }
    }

    String? clipMaskId = parent.clipMaskId;
    final clipPathStr = attr('clip-path');
    if (clipPathStr != null && _isUrlRef(clipPathStr)) {
      final id = _extractUrlRefId(clipPathStr);
      if (id != null && ctx.clipPathShapes.containsKey(id)) {
        clipMaskId = ctx.clipPathShapes[id];
      }
    }

    return _ParsedStyle(
      fill: fill, 
      stroke: stroke, 
      opacity: opacity.clamp(0.0, 1.0),
      effects: effects,
      clipMaskId: clipMaskId,
    );
  }

  final VecFill? fill;
  final VecStroke? stroke;
  final double opacity;
  final List<VecEffect> effects;
  final String? clipMaskId;

  static Map<String, String> parseInlineStyle(String style) {
    final map = <String, String>{};
    for (final part in style.split(';')) {
      final kv = part.split(':');
      if (kv.length == 2) map[kv[0].trim()] = kv[1].trim();
    }
    return map;
  }

  static bool _isUrlRef(String value) => value.trim().startsWith('url(');

  static String? _extractUrlRefId(String value) {
    final m = RegExp(r'url\(\s*#([^)\s]+)\s*\)').firstMatch(value.trim());
    return m?.group(1);
  }

  static VecColor? parseColor(String s) {
    s = s.trim().toLowerCase();
    if (s.startsWith('#')) {
      final hex = s.substring(1);
      if (hex.length == 3) {
        final r = int.parse(hex[0] * 2, radix: 16);
        final g = int.parse(hex[1] * 2, radix: 16);
        final b = int.parse(hex[2] * 2, radix: 16);
        return VecColor(r: r, g: g, b: b, a: 255);
      }
      if (hex.length == 6) {
        final r = int.parse(hex.substring(0, 2), radix: 16);
        final g = int.parse(hex.substring(2, 4), radix: 16);
        final b = int.parse(hex.substring(4, 6), radix: 16);
        return VecColor(r: r, g: g, b: b, a: 255);
      }
    }
    if (s.startsWith('rgb')) {
      final nums = RegExp(r'[\d.]+').allMatches(s).map((m) => double.parse(m[0]!)).toList();
      if (nums.length >= 3) {
        return VecColor(r: nums[0].round(), g: nums[1].round(), b: nums[2].round(), a: 255);
      }
    }
    // Named colors (minimal set)
    const named = {
      'black': VecColor(r: 0, g: 0, b: 0, a: 255),
      'white': VecColor(r: 255, g: 255, b: 255, a: 255),
      'red': VecColor(r: 255, g: 0, b: 0, a: 255),
      'green': VecColor(r: 0, g: 128, b: 0, a: 255),
      'blue': VecColor(r: 0, g: 0, b: 255, a: 255),
      'yellow': VecColor(r: 255, g: 255, b: 0, a: 255),
      'orange': VecColor(r: 255, g: 165, b: 0, a: 255),
      'purple': VecColor(r: 128, g: 0, b: 128, a: 255),
      'gray': VecColor(r: 128, g: 128, b: 128, a: 255),
      'grey': VecColor(r: 128, g: 128, b: 128, a: 255),
      'pink': VecColor(r: 255, g: 192, b: 203, a: 255),
      'cyan': VecColor(r: 0, g: 255, b: 255, a: 255),
      'magenta': VecColor(r: 255, g: 0, b: 255, a: 255),
    };
    return named[s];
  }
}
