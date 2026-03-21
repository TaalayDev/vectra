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

class EditorCanvas extends ConsumerStatefulWidget {
  const EditorCanvas({super.key, required this.theme});

  final AppTheme theme;

  @override
  ConsumerState<EditorCanvas> createState() => _EditorCanvasState();
}

class _EditorCanvasState extends ConsumerState<EditorCanvas> {
  bool _isPanning = false;
  bool _didInitialFit = false;
  int _lastFitRequest = 0;

  AppTheme get theme => widget.theme;

  // ===========================================================================
  // Coordinate conversion — screen point → canvas point
  // ===========================================================================

  Offset _toCanvasPoint(Offset screenLocal) {
    final zoom = ref.read(zoomLevelProvider);
    final panOffset = ref.read(canvasOffsetProvider);
    final size = context.size ?? Size.zero;
    final meta = ref.read(currentMetaProvider);

    // Stage center in screen space
    final cx = size.width / 2 + panOffset.dx;
    final cy = size.height / 2 + panOffset.dy;
    final stageOriginX = cx - (meta.stageWidth * zoom) / 2;
    final stageOriginY = cy - (meta.stageHeight * zoom) / 2;

    return Offset(
      (screenLocal.dx - stageOriginX) / zoom,
      (screenLocal.dy - stageOriginY) / zoom,
    );
  }

  // ===========================================================================
  // Build
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final meta = ref.watch(currentMetaProvider);
    final zoom = ref.watch(zoomLevelProvider);
    final panOffset = ref.watch(canvasOffsetProvider);
    final fitRequest = ref.watch(fitRequestProvider);
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportSize = Size(constraints.maxWidth, constraints.maxHeight);

        // Auto zoom-to-fit on first layout or on explicit fit request
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleViewportChange(viewportSize, meta, fitRequest);
        });

        // Compute stage position on screen
        final stageScreenW = meta.stageWidth * zoom;
        final stageScreenH = meta.stageHeight * zoom;
        final stageLeft = (viewportSize.width - stageScreenW) / 2 + panOffset.dx;
        final stageTop = (viewportSize.height - stageScreenH) / 2 + panOffset.dy;

        return Listener(
          onPointerHover: (event) {
            ref.read(cursorPositionProvider.notifier).set(event.localPosition);
          },
          onPointerSignal: (event) {
            if (event is PointerScrollEvent) {
              _handleScrollZoom(event, viewportSize);
            }
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,

            // --- Pan (middle-click drag or space+drag handled via _isPanning) ---
            onPanStart: (details) {
              if (_isPanning) return;
              if (isDrawingTool) {
                final local = _toCanvasPoint(details.localPosition);
                ref.read(activeDrawingProvider.notifier).start(local);
              }
            },
            onPanUpdate: (details) {
              if (_isPanning) {
                ref.read(canvasOffsetProvider.notifier).pan(details.delta);
                return;
              }
              if (isDrawingTool) {
                final local = _toCanvasPoint(details.localPosition);
                ref.read(activeDrawingProvider.notifier).update(local);
              }
            },
            onPanEnd: (details) {
              if (_isPanning) return;
              if (isDrawingTool) {
                _finishDragDrawing(activeTool);
              }
            },

            // --- Tap for pen tool (add point) or select tool ---
            onTapDown: isPenTool
                ? (details) {
                    final local = _toCanvasPoint(details.localPosition);
                    final pen = ref.read(activePenDrawingProvider);
                    if (pen == null) {
                      ref.read(activePenDrawingProvider.notifier).start(local);
                    } else {
                      ref.read(activePenDrawingProvider.notifier).addPoint(local);
                    }
                  }
                : activeTool == VecTool.select
                    ? (details) {
                        final local = _toCanvasPoint(details.localPosition);
                        _hitTestAndSelect(scene, local);
                      }
                    : null,

            // --- Double-tap to close pen path ---
            onDoubleTap: isPenTool
                ? () => _finishPenDrawing(closed: true)
                : null,

            child: MouseRegion(
              cursor: _isPanning
                  ? SystemMouseCursors.grab
                  : _cursorForTool(activeTool),
              child: SizedBox(
                width: viewportSize.width,
                height: viewportSize.height,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    // Background pattern
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _CanvasBackgroundPainter(
                          bgColor: theme.canvasBackground,
                          dotColor: theme.gridLine.withAlpha(60),
                        ),
                      ),
                    ),

                    // Stage (positioned, clips overflow)
                    Positioned(
                      left: stageLeft,
                      top: stageTop,
                      width: stageScreenW,
                      height: stageScreenH,
                      child: ClipRect(
                        child: OverflowBox(
                          alignment: Alignment.topLeft,
                          maxWidth: meta.stageWidth,
                          maxHeight: meta.stageHeight,
                          child: _buildStage(
                            meta: meta,
                            zoom: zoom,
                            scene: scene,
                            selectedShapeId: selectedShapeId,
                            selectedShape: selectedShape,
                            activeTool: activeTool,
                            drawing: drawing,
                            penDrawing: penDrawing,
                          ),
                        ),
                      ),
                    ),

                    // Stage border (drawn on top, not inside transform)
                    Positioned(
                      left: stageLeft,
                      top: stageTop,
                      width: stageScreenW,
                      height: stageScreenH,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.divider.withAlpha(100),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // Stage widget
  // ===========================================================================

  Widget _buildStage({
    required VecMeta meta,
    required double zoom,
    required dynamic scene,
    required String? selectedShapeId,
    required dynamic selectedShape,
    required VecTool activeTool,
    required dynamic drawing,
    required dynamic penDrawing,
  }) {
    return Transform.scale(
      scale: zoom,
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: meta.stageWidth,
        height: meta.stageHeight,
        child: Stack(
          clipBehavior: Clip.hardEdge,
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
    );
  }

  // ===========================================================================
  // Viewport change → auto zoom-to-fit
  // ===========================================================================

  void _handleViewportChange(Size viewportSize, VecMeta meta, int fitRequest) {
    if (viewportSize.width <= 0 || viewportSize.height <= 0) return;

    // Initial fit
    if (!_didInitialFit) {
      _didInitialFit = true;
      _lastFitRequest = fitRequest;
      _fitToViewport(viewportSize, meta);
      return;
    }

    // Explicit zoom-to-fit request (shortcut or button)
    if (fitRequest != _lastFitRequest) {
      _lastFitRequest = fitRequest;
      _fitToViewport(viewportSize, meta);
    }
  }

  void _fitToViewport(Size viewportSize, VecMeta meta) {
    ref.read(zoomLevelProvider.notifier).zoomToFit(
      viewportSize.width,
      viewportSize.height,
      meta.stageWidth,
      meta.stageHeight,
    );
    ref.read(canvasOffsetProvider.notifier).reset();
  }

  // ===========================================================================
  // Scroll-to-zoom
  // ===========================================================================

  void _handleScrollZoom(PointerScrollEvent event, Size viewportSize) {
    final zoomNotifier = ref.read(zoomLevelProvider.notifier);
    final panNotifier = ref.read(canvasOffsetProvider.notifier);
    final oldZoom = ref.read(zoomLevelProvider);
    final panOffset = ref.read(canvasOffsetProvider);

    // Zoom toward pointer position
    final pointerLocal = event.localPosition;

    // How much to zoom
    final delta = -event.scrollDelta.dy;
    final zoomFactor = delta > 0 ? 1.1 : 1 / 1.1;
    final newZoom = (oldZoom * zoomFactor).clamp(0.01, 64.0);
    zoomNotifier.set(newZoom);

    // Adjust pan so the point under cursor stays fixed
    final viewCenter = Offset(viewportSize.width / 2, viewportSize.height / 2);
    final pointerFromCenter = pointerLocal - viewCenter - panOffset;
    final scale = newZoom / oldZoom;
    final newPan = panOffset - pointerFromCenter * (scale - 1);
    panNotifier.set(newPan);
  }

  // ===========================================================================
  // Pan mode (called from ShortcutsWrapper space key)
  // ===========================================================================

  void startPan() => setState(() => _isPanning = true);
  void endPan() => setState(() => _isPanning = false);

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

  void _finishDragDrawing(VecTool tool) {
    final drawingState = ref.read(activeDrawingProvider.notifier).finish();
    if (drawingState == null || drawingState.width < 2 || drawingState.height < 2) return;

    const handler = DrawingToolHandler();
    late final dynamic shape;

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

    _addShapeToActiveLayer(shape);
  }

  void _finishPenDrawing({bool closed = false}) {
    final penState = ref.read(activePenDrawingProvider.notifier).finish();
    if (penState == null || penState.points.length < 2) return;

    const handler = DrawingToolHandler();
    final shape = handler.createPath(penState, closed: closed);
    _addShapeToActiveLayer(shape);
  }

  void _addShapeToActiveLayer(dynamic shape) {
    final scene = ref.read(activeSceneProvider);
    final layerId = ref.read(activeLayerIdProvider);
    if (scene == null || layerId == null) return;

    ref.read(vecDocumentStateProvider.notifier).addShape(scene.id, layerId, shape);
    ref.read(selectedShapeIdProvider.notifier).set(shape.id);
  }

  // ===========================================================================
  // Select tool hit testing
  // ===========================================================================

  void _hitTestAndSelect(dynamic scene, Offset canvasPoint) {
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
// Canvas background — dot grid
// =============================================================================

class _CanvasBackgroundPainter extends CustomPainter {
  _CanvasBackgroundPainter({required this.bgColor, required this.dotColor});

  final Color bgColor;
  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = bgColor);

    const spacing = 20.0;
    const dotRadius = 1.0;
    final dotPaint = Paint()..color = dotColor;

    for (var y = spacing; y < size.height; y += spacing) {
      for (var x = spacing; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CanvasBackgroundPainter old) =>
      old.bgColor != bgColor || old.dotColor != dotColor;
}

// =============================================================================
// Checkerboard (used inside stage for transparent bg)
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
