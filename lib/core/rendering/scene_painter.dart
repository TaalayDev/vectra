import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../data/models/vec_layer.dart';
import '../../data/models/vec_scene.dart';
import '../../data/models/vec_shape.dart';
import '../../data/models/vec_symbol.dart';
import 'shape_renderer.dart';

/// CustomPainter that renders all visible layers and shapes of a [VecScene].
///
/// Layers are painted bottom-to-top (by `order`). Guide layers are skipped
/// unless [showGuides] is true.
class ScenePainter extends CustomPainter {
  ScenePainter({
    required this.scene,
    this.symbols = const [],
    this.selectedShapeId,
    this.showGuides = false,
    this.imageCache = const {},
  });

  final VecScene scene;
  final List<VecSymbol> symbols;
  final String? selectedShapeId;
  final bool showGuides;
  final Map<String, ui.Image> imageCache;

  @override
  void paint(Canvas canvas, Size size) {
    // Collect all shapes across visible layers for clip mask resolution.
    final sortedLayers = List<VecLayer>.from(scene.layers)..sort((a, b) => a.order.compareTo(b.order));

    final allShapes = <VecShape>[];
    for (final layer in sortedLayers) {
      if (!layer.visible) continue;
      if (layer.type == VecLayerType.guide && !showGuides) continue;
      allShapes.addAll(layer.shapes);
    }

    final renderer = ShapeRenderer(symbols: symbols, imageCache: imageCache, allShapes: allShapes);

    for (final layer in sortedLayers) {
      if (!layer.visible) continue;
      if (layer.type == VecLayerType.guide && !showGuides) continue;

      final needsOpacityLayer = layer.isReference && layer.referenceOpacity < 1.0;
      if (needsOpacityLayer) {
        final alpha = (layer.referenceOpacity.clamp(0.0, 1.0) * 255).round();
        canvas.saveLayer(null, ui.Paint()..color = ui.Color.fromARGB(alpha, 255, 255, 255));
      }

      for (final shape in layer.shapes) {
        renderer.render(canvas, shape);
      }

      if (needsOpacityLayer) canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ScenePainter old) {
    return old.scene != scene ||
        old.symbols != symbols ||
        old.selectedShapeId != selectedShapeId ||
        old.showGuides != showGuides ||
        old.imageCache != imageCache;
  }
}
