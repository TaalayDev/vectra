import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../data/models/vec_keyframe.dart';
import '../../data/models/vec_layer.dart';
import '../../data/models/vec_scene.dart';
import '../../data/models/vec_shape.dart';
import '../../data/models/vec_symbol.dart';
import '../rendering/scene_painter.dart';
import '../utils/keyframe_interpolator.dart';
import '../../providers/editor_state_provider.dart';

// ---------------------------------------------------------------------------
// Onion skin frame painter
// ---------------------------------------------------------------------------

/// Renders ghost frames (onion skinning) before and after the current playhead.
///
/// Before-frames are drawn in blue-tinted overlay, after-frames in orange-tinted
/// overlay. Opacity falls off linearly with distance from the playhead.
class OnionPainter extends CustomPainter {
  const OnionPainter({
    required this.scene,
    required this.currentFrame,
    required this.settings,
    required this.symbols,
    this.imageCache = const {},
  });

  final VecScene scene;
  final int currentFrame;
  final OnionSettings settings;
  final List<VecSymbol> symbols;
  final Map<String, ui.Image> imageCache;

  @override
  void paint(Canvas canvas, Size size) {
    if (!settings.enabled) return;

    final shapeKeyframes = <String, List<VecKeyframe>>{};
    for (final track in scene.timeline.tracks) {
      if (track.shapeId != null && track.keyframes.isNotEmpty) {
        shapeKeyframes[track.shapeId!] = track.keyframes;
      }
    }

    if (shapeKeyframes.isEmpty) return;

    // Draw before frames (blue tint)
    for (var i = settings.beforeFrames; i >= 1; i--) {
      final frame = currentFrame - i;
      if (frame < 0) continue;
      final alpha = (settings.opacity * (1 - (i - 1) / settings.beforeFrames.toDouble())).clamp(0.0, 1.0);
      _paintFrame(canvas, size, frame, shapeKeyframes, const Color(0xFF3399FF), alpha);
    }

    // Draw after frames (orange tint)
    for (var i = 1; i <= settings.afterFrames; i++) {
      final frame = currentFrame + i;
      if (frame >= scene.timeline.duration) continue;
      final alpha = (settings.opacity * (1 - (i - 1) / settings.afterFrames.toDouble())).clamp(0.0, 1.0);
      _paintFrame(canvas, size, frame, shapeKeyframes, const Color(0xFFFF8833), alpha);
    }
  }

  void _paintFrame(
    Canvas canvas,
    Size size,
    int frame,
    Map<String, List<VecKeyframe>> shapeKeyframes,
    Color tint,
    double alpha,
  ) {
    final interpolatedScene = scene.copyWith(
      layers: [
        for (final layer in scene.layers)
          layer.copyWith(
            shapes: [
              for (final shape in layer.shapes)
                () {
                  final kfs = shapeKeyframes[shape.id];
                  return kfs != null ? KeyframeInterpolator.applyAtFrame(shape, kfs, frame) : shape;
                }(),
            ],
          ),
      ],
    );

    canvas.saveLayer(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..color = tint.withAlpha((alpha * 255).round())
        ..blendMode = BlendMode.srcATop,
    );

    if (settings.mode == OnionMode.outline) {
      _paintOutlines(canvas, interpolatedScene, tint, alpha);
    } else {
      final painter = ScenePainter(scene: interpolatedScene, symbols: symbols, imageCache: imageCache);
      painter.paint(canvas, size);
    }

    canvas.restore();
  }

  void _paintOutlines(Canvas canvas, VecScene scene, Color tint, double alpha) {
    final paint = Paint()
      ..color = tint.withAlpha((alpha * 255).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final sortedLayers = List<VecLayer>.from(scene.layers)..sort((a, b) => a.order.compareTo(b.order));

    for (final layer in sortedLayers) {
      if (!layer.visible) continue;
      for (final shape in layer.shapes) {
        _outlinesShape(canvas, shape, paint);
      }
    }
  }

  void _outlinesShape(Canvas canvas, VecShape shape, Paint paint) {
    shape.maybeMap(
      path: (s) {
        if (s.nodes.length < 2) return;
        final t = s.transform;
        canvas.save();
        canvas.translate(t.x, t.y);
        canvas.rotate(t.rotation * 3.14159265358979 / 180);
        canvas.scale(t.scaleX, t.scaleY);
        final path = Path();
        for (var i = 0; i < s.nodes.length; i++) {
          final n = s.nodes[i];
          if (i == 0) {
            path.moveTo(n.position.x, n.position.y);
          } else {
            path.lineTo(n.position.x, n.position.y);
          }
        }
        if (s.isClosed) path.close();
        canvas.drawPath(path, paint);
        canvas.restore();
      },
      rectangle: (s) {
        final t = s.transform;
        canvas.drawRect(Rect.fromCenter(center: Offset(t.x, t.y), width: t.width, height: t.height), paint);
      },
      ellipse: (s) {
        final t = s.transform;
        canvas.drawOval(Rect.fromCenter(center: Offset(t.x, t.y), width: t.width, height: t.height), paint);
      },
      orElse: () {},
    );
  }

  @override
  bool shouldRepaint(covariant OnionPainter old) =>
      old.scene != scene || old.currentFrame != currentFrame || old.settings != settings;
}
