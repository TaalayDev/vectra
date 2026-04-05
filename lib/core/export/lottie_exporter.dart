import 'dart:convert';

import '../../data/models/vec_document.dart';
import '../../data/models/vec_effect.dart';
import '../../data/models/vec_fill.dart';
import '../../data/models/vec_keyframe.dart';
import '../../data/models/vec_layer.dart';
import '../../data/models/vec_scene.dart';
import '../../data/models/vec_path_node.dart';
import '../../data/models/vec_shape.dart';
import '../../data/models/vec_stroke.dart';
import '../../data/models/vec_track.dart';

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

    // Build shapeId → track map
    final trackMap = <String, VecTrack>{};
    for (final t in scene.timeline.tracks) {
      if (t.shapeId != null) trackMap[t.shapeId!] = t;
    }

    // Collect all shapes for clip mask tracking.
    final allShapes = <VecShape>[];
    final sortedLayers = List<VecLayer>.from(scene.layers)..sort((a, b) => b.order.compareTo(a.order));
    for (final layer in sortedLayers) {
      if (!layer.visible) continue;
      if (layer.type == VecLayerType.guide) continue;
      allShapes.addAll(layer.shapes);
    }

    // Track which shapes are used as clip masks.
    final maskShapeIds = <String>{};
    for (final s in allShapes) {
      if (s.clipMaskId != null && s.clipMaskId!.isNotEmpty) {
        maskShapeIds.add(s.clipMaskId!);
      }
    }

    final layers = <Map<String, dynamic>>[];
    var layerIndex = 0;

    for (final layer in sortedLayers) {
      if (!layer.visible) continue;
      if (layer.type == VecLayerType.guide) continue;
      for (final shape in layer.shapes) {
        // Skip shapes that are used as clip masks — they'll be emitted
        // inline as track matte layers just before the clipped shape.
        if (maskShapeIds.contains(shape.id)) continue;

        // If this shape has a clip mask, emit the mask as a track matte layer first.
        if (shape.clipMaskId != null && shape.clipMaskId!.isNotEmpty) {
          final maskShape = allShapes.cast<VecShape?>().firstWhere(
            (s) => s!.id == shape.clipMaskId,
            orElse: () => null,
          );
          if (maskShape != null) {
            final matteLayer = _shapeToLayer(maskShape, layerIndex, totalFrames, fps, track: trackMap[maskShape.id]);
            if (matteLayer != null) {
              matteLayer['td'] = 1; // This layer is a track matte
              layers.add(matteLayer);
              layerIndex++;
            }
          }
        }

        final lottieLayer = _shapeToLayer(shape, layerIndex, totalFrames, fps, track: trackMap[shape.id]);
        if (lottieLayer != null) {
          // If clipped, reference the track matte above
          if (shape.clipMaskId != null && shape.clipMaskId!.isNotEmpty && layers.isNotEmpty) {
            lottieLayer['tt'] = 1; // Alpha matte
          }
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

  Map<String, dynamic>? _shapeToLayer(VecShape shape, int index, int totalFrames, int fps, {VecTrack? track}) {
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

    // Build animated or static transform properties
    final cx = t.x + t.width / 2;
    final cy = t.y + t.height / 2;

    final Map<String, dynamic> ks;
    final keyframes = track?.keyframes ?? const [];
    final hasAnimation = keyframes.length >= 2;

    if (hasAnimation) {
      ks = {
        'o': _animatedOpacity(keyframes, shape.opacity),
        'r': _animatedRotation(keyframes, t.rotation),
        'p': _animatedPosition(keyframes, cx, cy),
        'a': _staticValue2D(t.width / 2, t.height / 2),
        's': _animatedScale(keyframes, t.scaleX, t.scaleY),
      };
    } else {
      ks = {
        'o': _staticValue(shape.opacity * 100),
        'r': _staticValue(t.rotation),
        'p': _staticValue2D(cx, cy),
        'a': _staticValue2D(t.width / 2, t.height / 2),
        's': _staticValue2D(t.scaleX * 100, t.scaleY * 100),
      };
    }

    final layer = <String, dynamic>{
      'ty': 4, // shape layer
      'nm': name,
      'ind': index,
      'ip': 0,
      'op': totalFrames,
      'st': 0,
      'sr': 1,
      'ks': ks,
      'shapes': [
        {
          'ty': 'gr',
          'nm': 'Shape group',
          'it': [...shapeItems, _transformShape()],
        },
      ],
    };

    // Add Lottie effects for blur/shadow/glow
    final effects = shape.data.effects.where((e) => e.enabled).toList();
    if (effects.isNotEmpty) {
      layer['ef'] = effects.map(_lottieEffect).toList();
    }

    return layer;
  }

  Map<String, dynamic> _lottieEffect(VecEffect fx) {
    switch (fx.type) {
      case VecEffectType.blur:
        // Lottie Gaussian Blur effect (ty: 29)
        return {
          'ty': 29,
          'nm': 'Gaussian Blur',
          'ef': [
            {'ty': 0, 'nm': 'Blurriness', 'v': _staticValue(fx.blur)},
            {'ty': 0, 'nm': 'Blur Dimensions', 'v': _staticValue(1)}, // 1 = H+V
            {'ty': 0, 'nm': 'Repeat Edge Pixels', 'v': _staticValue(0)},
          ],
        };
      case VecEffectType.shadow:
        // Lottie Drop Shadow effect (ty: 25)
        final c = fx.color;
        return {
          'ty': 25,
          'nm': 'Drop Shadow',
          'ef': [
            {'ty': 2, 'nm': 'Shadow Color', 'v': _staticValueColor(c.r / 255.0, c.g / 255.0, c.b / 255.0)},
            {'ty': 0, 'nm': 'Opacity', 'v': _staticValue(fx.opacity * (c.a / 255.0) * 255)},
            {'ty': 1, 'nm': 'Direction', 'v': _staticValue(0)},
            {'ty': 0, 'nm': 'Distance', 'v': _staticValue(fx.offsetX.abs() + fx.offsetY.abs())},
            {'ty': 0, 'nm': 'Softness', 'v': _staticValue(fx.blur)},
          ],
        };
      case VecEffectType.glow:
        // Approximate glow as a drop shadow with 0 offset
        final c = fx.color;
        return {
          'ty': 25,
          'nm': 'Glow',
          'ef': [
            {'ty': 2, 'nm': 'Shadow Color', 'v': _staticValueColor(c.r / 255.0, c.g / 255.0, c.b / 255.0)},
            {'ty': 0, 'nm': 'Opacity', 'v': _staticValue(fx.opacity * (c.a / 255.0) * 255)},
            {'ty': 1, 'nm': 'Direction', 'v': _staticValue(0)},
            {'ty': 0, 'nm': 'Distance', 'v': _staticValue(0)},
            {'ty': 0, 'nm': 'Softness', 'v': _staticValue(fx.blur + fx.spread)},
          ],
        };
    }
  }

  // ---------------------------------------------------------------------------
  // Animated property builders
  // ---------------------------------------------------------------------------

  static const _linearEase = {
    'i': {
      'x': [0.5],
      'y': [0.5],
    },
    'o': {
      'x': [0.5],
      'y': [0.5],
    },
  };

  Map<String, dynamic> _animatedPosition(List<VecKeyframe> keyframes, double defaultCx, double defaultCy) {
    final sorted = [...keyframes]..sort((a, b) => a.frame.compareTo(b.frame));
    final kfList = <Map<String, dynamic>>[];
    for (var i = 0; i < sorted.length; i++) {
      final kf = sorted[i];
      final tr = kf.transform;
      final cx = tr != null ? tr.x + tr.width / 2 : defaultCx;
      final cy = tr != null ? tr.y + tr.height / 2 : defaultCy;
      final entry = <String, dynamic>{
        't': kf.frame,
        's': [cx, cy, 0],
        ..._linearEase,
      };
      if (i < sorted.length - 1) {
        final next = sorted[i + 1];
        final ntr = next.transform;
        final ncx = ntr != null ? ntr.x + ntr.width / 2 : defaultCx;
        final ncy = ntr != null ? ntr.y + ntr.height / 2 : defaultCy;
        entry['e'] = [ncx, ncy, 0];
      }
      kfList.add(entry);
    }
    return {'a': 1, 'k': kfList};
  }

  Map<String, dynamic> _animatedRotation(List<VecKeyframe> keyframes, double defaultRot) {
    final sorted = [...keyframes]..sort((a, b) => a.frame.compareTo(b.frame));
    final kfList = <Map<String, dynamic>>[];
    for (var i = 0; i < sorted.length; i++) {
      final kf = sorted[i];
      final rot = kf.transform?.rotation ?? defaultRot;
      final entry = <String, dynamic>{
        't': kf.frame,
        's': [rot],
        ..._linearEase,
      };
      if (i < sorted.length - 1) {
        final next = sorted[i + 1];
        entry['e'] = [next.transform?.rotation ?? defaultRot];
      }
      kfList.add(entry);
    }
    return {'a': 1, 'k': kfList};
  }

  Map<String, dynamic> _animatedScale(List<VecKeyframe> keyframes, double defaultSX, double defaultSY) {
    final sorted = [...keyframes]..sort((a, b) => a.frame.compareTo(b.frame));
    final kfList = <Map<String, dynamic>>[];
    for (var i = 0; i < sorted.length; i++) {
      final kf = sorted[i];
      final sx = (kf.transform?.scaleX ?? defaultSX) * 100;
      final sy = (kf.transform?.scaleY ?? defaultSY) * 100;
      final entry = <String, dynamic>{
        't': kf.frame,
        's': [sx, sy, 100],
        ..._linearEase,
      };
      if (i < sorted.length - 1) {
        final next = sorted[i + 1];
        final nsx = (next.transform?.scaleX ?? defaultSX) * 100;
        final nsy = (next.transform?.scaleY ?? defaultSY) * 100;
        entry['e'] = [nsx, nsy, 100];
      }
      kfList.add(entry);
    }
    return {'a': 1, 'k': kfList};
  }

  Map<String, dynamic> _animatedOpacity(List<VecKeyframe> keyframes, double defaultOp) {
    final sorted = [...keyframes]..sort((a, b) => a.frame.compareTo(b.frame));
    final kfList = <Map<String, dynamic>>[];
    for (var i = 0; i < sorted.length; i++) {
      final kf = sorted[i];
      final op = (kf.opacity ?? defaultOp) * 100;
      final entry = <String, dynamic>{
        't': kf.frame,
        's': [op],
        ..._linearEase,
      };
      if (i < sorted.length - 1) {
        final next = sorted[i + 1];
        entry['e'] = [(next.opacity ?? defaultOp) * 100];
      }
      kfList.add(entry);
    }
    return {'a': 1, 'k': kfList};
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
      image: (_) => null,
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
