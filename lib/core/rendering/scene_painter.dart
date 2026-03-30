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
    final renderer = ShapeRenderer(symbols: symbols, imageCache: imageCache);

    // Sort layers by order ascending (bottom first)
    final sortedLayers = List<VecLayer>.from(scene.layers)
      ..sort((a, b) => a.order.compareTo(b.order));

    for (final layer in sortedLayers) {
      if (!layer.visible) continue;
      if (layer.type == VecLayerType.guide && !showGuides) continue;

      for (final shape in layer.shapes) {
        renderer.render(canvas, shape);
      }
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
