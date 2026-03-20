import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../core/rendering/drawing_preview_painter.dart';
import '../../../data/models/vec_document.dart';
import '../../../core/rendering/scene_painter.dart';
import '../../../core/rendering/selection_overlay.dart';
import '../../../core/tools/drawing_tool_handler.dart';
import '../../../providers/document_provider.dart';
import '../../../providers/drawing_state_provider.dart';
import '../../../providers/editor_state_provider.dart';

class EditorCanvas extends ConsumerWidget {
  const EditorCanvas({super.key, required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = ref.watch(currentMetaProvider);
    final zoom = ref.watch(zoomLevelProvider);
    final scene = ref.watch(activeSceneProvider);
    final selectedShapeId = ref.watch(selectedShapeIdProvider);
    final selectedShape = ref.watch(selectedShapeProvider);
    final activeTool = ref.watch(activeToolProvider);
    final drawing = ref.watch(activeDrawingProvider);
    final penDrawing = ref.watch(activePenDrawingProvider);

    final isDrawingTool = activeTool == VecTool.rectangle ||
        activeTool == VecTool.ellipse ||
        activeTool == VecTool.text;
    final isPenTool = activeTool == VecTool.pen;

    return Listener(
      onPointerHover: (event) {
        ref.read(cursorPositionProvider.notifier).set(event.localPosition);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,

        // --- Drag for rectangle / ellipse / text tools ---
        onPanStart: isDrawingTool
            ? (details) {
                final local = _toCanvasPoint(details.localPosition, meta, zoom, context);
                ref.read(activeDrawingProvider.notifier).start(local);
              }
            : null,
        onPanUpdate: isDrawingTool
            ? (details) {
                final local = _toCanvasPoint(details.localPosition, meta, zoom, context);
                ref.read(activeDrawingProvider.notifier).update(local);
              }
            : null,
        onPanEnd: isDrawingTool
            ? (_) => _finishDragDrawing(ref, activeTool)
            : null,

        // --- Tap for pen tool (add point) or select tool ---
        onTapDown: isPenTool
            ? (details) {
                final local = _toCanvasPoint(details.localPosition, meta, zoom, context);
                final pen = ref.read(activePenDrawingProvider);
                if (pen == null) {
                  ref.read(activePenDrawingProvider.notifier).start(local);
                } else {
                  ref.read(activePenDrawingProvider.notifier).addPoint(local);
                }
              }
            : activeTool == VecTool.select
                ? (details) {
                    // Simple select: hit-test shapes under tap
                    final local = _toCanvasPoint(details.localPosition, meta, zoom, context);
                    _hitTestAndSelect(ref, scene, local);
                  }
                : null,

        // --- Double-tap to close pen path ---
        onDoubleTap: isPenTool
            ? () => _finishPenDrawing(ref, closed: true)
            : null,

        child: MouseRegion(
          cursor: _cursorForTool(activeTool),
          child: Container(
            color: theme.canvasBackground,
            child: Center(
              child: Transform.scale(
                scale: zoom,
                child: SizedBox(
                  width: meta.stageWidth,
                  height: meta.stageHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Checkerboard + bg
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _CheckerboardPainter(
                            color1: theme.gridBackground,
                            color2: theme.gridLine.withAlpha(30),
                          ),
                          child: ColoredBox(color: meta.backgroundColor.toFlutterColor()),
                        ),
                      ),

                      // Scene shapes
                      if (scene != null)
                        Positioned.fill(
                          child: ClipRect(
                            child: CustomPaint(
                              painter: ScenePainter(
                                scene: scene,
                                selectedShapeId: selectedShapeId,
                              ),
                            ),
                          ),
                        ),

                      // Drawing preview (live shape being drawn)
                      if (drawing != null || penDrawing != null)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: DrawingPreviewPainter(
                              tool: activeTool,
                              drawing: drawing,
                              penDrawing: penDrawing,
                              previewColor: theme.primaryColor,
                              strokeColor: theme.selectionOutline,
                            ),
                          ),
                        ),

                      // Selection overlay
                      if (selectedShape != null)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: SelectionOverlayPainter(
                              shape: selectedShape,
                              selectionColor: theme.selectionOutline,
                              handleColor: theme.onPrimary,
                              zoom: zoom,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Coordinate conversion — screen point → canvas point
  // ===========================================================================

  Offset _toCanvasPoint(Offset screenLocal, VecMeta meta, double zoom, BuildContext context) {
    final size = context.size ?? Size.zero;
    // Center of the canvas widget
    final cx = size.width / 2;
    final cy = size.height / 2;
    // Stage origin on screen
    final stageOriginX = cx - (meta.stageWidth * zoom) / 2;
    final stageOriginY = cy - (meta.stageHeight * zoom) / 2;
    // Convert to canvas coordinates
    return Offset(
      (screenLocal.dx - stageOriginX) / zoom,
      (screenLocal.dy - stageOriginY) / zoom,
    );
  }

  // ===========================================================================
  // Tool cursors
  // ===========================================================================

  MouseCursor _cursorForTool(VecTool tool) {
    switch (tool) {
      case VecTool.select:
        return SystemMouseCursors.basic;
      case VecTool.pen:
        return SystemMouseCursors.precise;
      case VecTool.rectangle:
      case VecTool.ellipse:
        return SystemMouseCursors.precise;
      case VecTool.text:
        return SystemMouseCursors.text;
      case VecTool.width:
        return SystemMouseCursors.precise;
    }
  }

  // ===========================================================================
  // Finish drawing
  // ===========================================================================

  void _finishDragDrawing(WidgetRef ref, VecTool tool) {
    final drawingState = ref.read(activeDrawingProvider.notifier).finish();
    if (drawingState == null || drawingState.width < 2 || drawingState.height < 2) return;

    const handler = DrawingToolHandler();
    late final shape;

    switch (tool) {
      case VecTool.rectangle:
        shape = handler.createRectangle(drawingState);
        break;
      case VecTool.ellipse:
        shape = handler.createEllipse(drawingState);
        break;
      case VecTool.text:
        shape = handler.createText(drawingState);
        break;
      default:
        return;
    }

    _addShapeToActiveLayer(ref, shape);
  }

  void _finishPenDrawing(WidgetRef ref, {bool closed = false}) {
    final penState = ref.read(activePenDrawingProvider.notifier).finish();
    if (penState == null || penState.points.length < 2) return;

    const handler = DrawingToolHandler();
    final shape = handler.createPath(penState, closed: closed);
    _addShapeToActiveLayer(ref, shape);
  }

  void _addShapeToActiveLayer(WidgetRef ref, dynamic shape) {
    final scene = ref.read(activeSceneProvider);
    final layerId = ref.read(activeLayerIdProvider);
    if (scene == null || layerId == null) return;

    ref.read(vecDocumentStateProvider.notifier).addShape(scene.id, layerId, shape);
    ref.read(selectedShapeIdProvider.notifier).set(shape.id);
  }

  // ===========================================================================
  // Select tool hit testing
  // ===========================================================================

  void _hitTestAndSelect(WidgetRef ref, dynamic scene, Offset canvasPoint) {
    if (scene == null) {
      ref.read(selectedShapeIdProvider.notifier).clear();
      return;
    }

    // Walk layers top-to-bottom, shapes last-to-first (topmost wins)
    final layers = List.from(scene.layers)..sort((a, b) => b.order.compareTo(a.order));
    for (final layer in layers) {
      if (!layer.visible || layer.locked) continue;
      for (var i = layer.shapes.length - 1; i >= 0; i--) {
        final shape = layer.shapes[i];
        final t = shape.transform;
        final rect = Rect.fromLTWH(t.x, t.y, t.width, t.height);
        if (rect.contains(canvasPoint)) {
          ref.read(selectedShapeIdProvider.notifier).set(shape.id);
          ref.read(activeLayerIdProvider.notifier).set(layer.id);
          return;
        }
      }
    }

    // Tapped empty area — deselect
    ref.read(selectedShapeIdProvider.notifier).clear();
  }
}

// =============================================================================
// Checkerboard
// =============================================================================

class _CheckerboardPainter extends CustomPainter {
  _CheckerboardPainter({required this.color1, required this.color2});

  final Color color1;
  final Color color2;

  @override
  void paint(Canvas canvas, Size size) {
    const cellSize = 8.0;
    final paint1 = Paint()..color = color1;
    final paint2 = Paint()..color = color2;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint1);

    for (var y = 0.0; y < size.height; y += cellSize) {
      for (var x = 0.0; x < size.width; x += cellSize) {
        final col = (x / cellSize).floor();
        final row = (y / cellSize).floor();
        if ((col + row) % 2 == 0) {
          canvas.drawRect(Rect.fromLTWH(x, y, cellSize, cellSize), paint2);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CheckerboardPainter old) =>
      old.color1 != color1 || old.color2 != color2;
}
