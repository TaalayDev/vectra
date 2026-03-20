import 'package:flutter/material.dart';

import '../../data/models/vec_layer.dart';
import '../../data/models/vec_scene.dart';
import '../../data/models/vec_shape.dart';
import 'shape_renderer.dart';

/// CustomPainter that renders all visible layers and shapes of a [VecScene].
///
/// Layers are painted bottom-to-top (by `order`). Guide layers are skipped
/// unless [showGuides] is true.
class ScenePainter extends CustomPainter {
  ScenePainter({
    required this.scene,
    this.selectedShapeId,
    this.showGuides = false,
  });

  final VecScene scene;
  final String? selectedShapeId;
  final bool showGuides;

  static const _renderer = ShapeRenderer();

  @override
  void paint(Canvas canvas, Size size) {
    // Sort layers by order ascending (bottom first)
    final sortedLayers = List<VecLayer>.from(scene.layers)
      ..sort((a, b) => a.order.compareTo(b.order));

    for (final layer in sortedLayers) {
      if (!layer.visible) continue;
      if (layer.type == VecLayerType.guide && !showGuides) continue;

      for (final shape in layer.shapes) {
        _renderer.render(canvas, shape);
      }
    }
  }

  @override
  bool shouldRepaint(covariant ScenePainter old) {
    return old.scene != scene ||
        old.selectedShapeId != selectedShapeId ||
        old.showGuides != showGuides;
  }
}
