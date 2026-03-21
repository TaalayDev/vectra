import 'dart:convert';

import '../../data/models/vec_document.dart';
import '../../data/models/vec_fill.dart';
import '../../data/models/vec_layer.dart';
import '../../data/models/vec_scene.dart';
import '../../data/models/vec_path_node.dart';
import '../../data/models/vec_shape.dart';
import '../../data/models/vec_stroke.dart';

/// Generates a Lottie-compatible JSON from a [VecScene].
///
/// Supported: static shapes (rectangles, ellipses, paths), fills, strokes.
/// Named markers from the timeline's frame labels are preserved.
/// Animations (keyframes) are stubbed — the scene is exported at frame 0.
class LottieExporter {
  const LottieExporter();

  Map<String, dynamic> export(VecDocument doc, VecScene scene) {
    final w = doc.meta.stageWidth;
    final h = doc.meta.stageHeight;
    final fps = doc.meta.fps;
    final totalFrames = scene.timeline.duration;

    final layers = <Map<String, dynamic>>[];

    // Sort layers bottom to top; in Lottie, index 0 = topmost
    final sortedLayers = List<VecLayer>.from(scene.layers)..sort((a, b) => b.order.compareTo(a.order));

    var layerIndex = 0;
    for (final layer in sortedLayers) {
      if (!layer.visible) continue;
      if (layer.type == VecLayerType.guide) continue;
      for (final shape in layer.shapes) {
        final lottieLayer = _shapeToLayer(shape, layerIndex, totalFrames, fps);
        if (lottieLayer != null) {
          layers.add(lottieLayer);
          layerIndex++;
        }
      }
    }

    // Build markers from frame labels
    final markers = <Map<String, dynamic>>[];
    final frameLabels = scene.timeline.frameLabels;
    for (final label in frameLabels) {
      markers.add({'tm': label.frame, 'cm': label.label, 'dr': 0});
    }

    return {
      'v': '5.9.6',
      'fr': fps,
      'ip': 0,
      'op': totalFrames,
      'w': w.toInt(),
      'h': h.toInt(),
      'nm': doc.meta.name,
      'ddd': 0,
      'assets': [],
      'layers': layers,
      'markers': markers,
      'meta': {'g': 'Vectra', 'a': '', 'k': '', 'd': '', 'tc': ''},
    };
  }

  Map<String, dynamic>? _shapeToLayer(VecShape shape, int index, int totalFrames, int fps) {
    final t = shape.transform;
    final name = shape.name ?? 'Shape $index';

    // Shape layer (ty: 4)
    final shapeItems = <Map<String, dynamic>>[];

    // Geometry
    final geometry = _shapeGeometry(shape);
    if (geometry != null) shapeItems.add(geometry);

    // Fills
    for (final fill in shape.fills) {
      shapeItems.add(_lottieFill(fill));
    }

    // Strokes
    for (final stroke in shape.strokes) {
      shapeItems.add(_lottieStroke(stroke));
    }

    if (shapeItems.isEmpty) return null;

    // Transform
    final cx = t.x + t.width / 2;
    final cy = t.y + t.height / 2;

    return {
      'ty': 4, // shape layer
      'nm': name,
      'ind': index,
      'ip': 0,
      'op': totalFrames,
      'st': 0,
      'sr': 1,
      'ks': {
        'o': _staticValue(shape.opacity * 100),
        'r': _staticValue(t.rotation),
        'p': _staticValue2D(cx, cy),
        'a': _staticValue2D(t.width / 2, t.height / 2),
        's': _staticValue2D(t.scaleX * 100, t.scaleY * 100),
      },
      'shapes': [
        {
          'ty': 'gr',
          'nm': 'Shape group',
          'it': [...shapeItems, _transformShape()],
        },
      ],
    };
  }

  Map<String, dynamic>? _shapeGeometry(VecShape shape) {
    return shape.map(
      rectangle: (s) => {
        'ty': 'rc',
        'nm': 'Rectangle',
        'p': _staticValue2D(s.transform.width / 2, s.transform.height / 2),
        's': _staticValue2D(s.transform.width, s.transform.height),
        'r': _staticValue(s.cornerRadii.isNotEmpty ? s.cornerRadii[0] : 0.0),
      },
      ellipse: (s) => {
        'ty': 'el',
        'nm': 'Ellipse',
        'p': _staticValue2D(s.transform.width / 2, s.transform.height / 2),
        's': _staticValue2D(s.transform.width, s.transform.height),
      },
      path: (s) => {
        'ty': 'sh',
        'nm': 'Path',
        'ks': {'a': 0, 'k': _buildLottieShape(s.nodes, s.isClosed)},
      },
      group: (_) => null,
      text: (_) => null,
      polygon: (s) => _lottiePolygon(s),
      compound: (_) => null,
      symbolInstance: (_) => null,
    );
  }

  Map<String, dynamic> _buildLottieShape(List<VecPathNode> nodes, bool closed) {
    final vertices = nodes.map((n) => [n.position.x, n.position.y]).toList();
    final inTangents = nodes.map((n) {
      if (n.handleIn == null) return [0.0, 0.0];
      return [n.handleIn!.x - n.position.x, n.handleIn!.y - n.position.y];
    }).toList();
    final outTangents = nodes.map((n) {
      if (n.handleOut == null) return [0.0, 0.0];
      return [n.handleOut!.x - n.position.x, n.handleOut!.y - n.position.y];
    }).toList();

    return {'i': inTangents, 'o': outTangents, 'v': vertices, 'c': closed};
  }

  Map<String, dynamic> _lottiePolygon(VecPolygonShape s) {
    return {
      'ty': 'sr',
      'nm': 'Polygon',
      'sy': s.starDepth != null ? 1 : 2, // 1 = star, 2 = polygon
      'p': _staticValue2D(s.transform.width / 2, s.transform.height / 2),
      'r': _staticValue(0),
      'ir': _staticValue(s.transform.width / 2 * (s.starDepth ?? 0.5)),
      'or': _staticValue(s.transform.width / 2),
      'pt': _staticValue(s.sideCount.toDouble()),
      'os': _staticValue(0),
      'is': _staticValue(0),
    };
  }

  Map<String, dynamic> _lottieFill(VecFill fill) {
    final c = fill.color;
    return {
      'ty': 'fl',
      'nm': 'Fill',
      'o': _staticValue(fill.opacity * (c.a / 255.0) * 100),
      'c': _staticValueColor(c.r / 255.0, c.g / 255.0, c.b / 255.0),
      'r': 1,
    };
  }

  Map<String, dynamic> _lottieStroke(VecStroke stroke) {
    final c = stroke.color;
    return {
      'ty': 'st',
      'nm': 'Stroke',
      'o': _staticValue(stroke.opacity * (c.a / 255.0) * 100),
      'c': _staticValueColor(c.r / 255.0, c.g / 255.0, c.b / 255.0),
      'w': _staticValue(stroke.width),
      'lc': 2, // round cap
      'lj': 2, // round join
      'd': [],
    };
  }

  Map<String, dynamic> _transformShape() => {
    'ty': 'tr',
    'nm': 'Transform',
    'p': _staticValue2D(0, 0),
    'a': _staticValue2D(0, 0),
    's': _staticValue2D(100, 100),
    'r': _staticValue(0),
    'o': _staticValue(100),
    'sk': _staticValue(0),
    'sa': _staticValue(0),
  };

  // ---------------------------------------------------------------------------
  // Static value helpers (no animation)
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _staticValue(double v) => {'a': 0, 'k': v};

  Map<String, dynamic> _staticValue2D(double x, double y) => {
    'a': 0,
    'k': [x, y, 0],
  };

  Map<String, dynamic> _staticValueColor(double r, double g, double b) => {
    'a': 0,
    'k': [r, g, b, 1],
  };

  String toJsonString(Map<String, dynamic> lottie) => const JsonEncoder.withIndent('  ').convert(lottie);

  String toJsonStringMinified(Map<String, dynamic> lottie) => json.encode(lottie);
}
