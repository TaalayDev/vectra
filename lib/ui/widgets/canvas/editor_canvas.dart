import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/theme.dart';
import '../../../core/rendering/bend_handle_overlay.dart';
import '../../../core/rendering/corner_radius_overlay.dart';
import '../../../core/rendering/drawing_preview_painter.dart';
import '../../../core/rendering/motion_path_overlay.dart';
import '../../../core/rendering/path_edit_overlay.dart';
import '../../../core/rendering/scene_painter.dart';
import '../../../core/rendering/selection_overlay.dart';
import '../../../core/tools/drawing_tool_handler.dart';
import '../../../core/tools/select_tool_handler.dart';
import '../../../data/models/vec_document.dart';
import '../../../data/models/vec_motion_path.dart';
import '../../../data/models/vec_path_node.dart';
import '../../../data/models/vec_point.dart';
import '../../../providers/animation_provider.dart';
import '../../../providers/document_provider.dart';
import '../../../providers/drawing_state_provider.dart';
import '../../../providers/editor_state_provider.dart';
import '../../../providers/motion_path_provider.dart';

// Describes what kind of select-tool drag is active.
enum _SelectDragMode { none, move, resizeHandle, rotate, cornerRadius, bend, motionPathNode }

class EditorCanvas extends ConsumerStatefulWidget {
  const EditorCanvas({super.key, required this.theme});

  final AppTheme theme;

  @override
  ConsumerState<EditorCanvas> createState() => _EditorCanvasState();
}

class _EditorCanvasState extends ConsumerState<EditorCanvas> {
  // General canvas state
  bool _isPanning = false;
  bool _didInitialFit = false;
  int _lastFitRequest = 0;

  // Select-tool drag state
  _SelectDragMode _selectDragMode = _SelectDragMode.none;
  int _resizeHandleIndex = -1;
  dynamic _dragStartTransform; // VecTransform for single-shape drag (canvas-space)
  Map<String, dynamic> _dragStartTransforms = {}; // shapeId → VecTransform for multi-shape drag
  Offset _dragStartCanvasPoint = Offset.zero;
  double _rotationStartAngle = 0.0; // direction from center to drag-start point
  // When dragging a group child, store the group transform so we can convert back
  dynamic _dragGroupTransform; // group's VecTransform when in group-edit mode

  // Marquee (rubber-band) selection drag
  bool _isMarqueeDrag = false;
  Offset _marqueeStartCanvas = Offset.zero;
  Offset _marqueeCurrentCanvas = Offset.zero;

  // Hover hit index for cursor
  int _hoverHandleIndex = -1; // -2=rotate, 0-7=resize, -1=none, -3=body

  // Pen tool — handle drag (click+drag to pull bezier handle from last node)
  bool _isPenHandleDrag = false;

  // Pen tool — node editing (drag an existing node on a selected path)
  int _editNodeIndex = -1; // index of node being dragged, or -1
  int _hoverNodeIndex = -1; // index of node under cursor, or -1
  Offset _editDragStartCanvas = Offset.zero;
  dynamic _editDragStartTransform; // VecTransform captured at drag start

  // Corner-radius editing (rectangle only, single selection)
  Set<int> _selectedCorners = {0, 1, 2, 3}; // 0=TL,1=TR,2=BR,3=BL
  int _hoverCornerIndex = -1;
  List<double> _cornerRadiiAtDragStart = const [];
  Set<int> _cornersBeingDragged = const {};
  String? _cornerEditShapeId; // shape ID last used to set _selectedCorners

  // Bend handle editing (2-node line shape, single selection)
  bool _hoverBendHandle = false;
  Offset _bendHandleAtDragStart = Offset.zero;
  Offset _bendStartLocalPos = Offset.zero; // node[0] position at drag start
  Offset _bendEndLocalPos = Offset.zero; // node[1] position at drag start

  // Motion path node drag
  String? _mpDragPathId;
  int _mpDragNodeIndex = -1;

  AppTheme get theme => widget.theme;

  // ===========================================================================
  // Coordinate conversion — screen point → canvas point
  // ===========================================================================

  Offset _toCanvasPoint(Offset screenLocal) {
    final zoom = ref.read(zoomLevelProvider);
    final panOffset = ref.read(canvasOffsetProvider);
    final size = context.size ?? Size.zero;
    final meta = ref.read(currentMetaProvider);

    final cx = size.width / 2 + panOffset.dx;
    final cy = size.height / 2 + panOffset.dy;
    final stageOriginX = cx - (meta.stageWidth * zoom) / 2;
    final stageOriginY = cy - (meta.stageHeight * zoom) / 2;

    return Offset((screenLocal.dx - stageOriginX) / zoom, (screenLocal.dy - stageOriginY) / zoom);
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
    // Start/stop the playback timer automatically
    ref.watch(playbackTickerProvider);
    // Use the animation-interpolated scene for rendering
    final scene = ref.watch(animatedSceneProvider);
    final selectedShapeId = ref.watch(selectedShapeIdProvider);
    final selectedShapeIds = ref.watch(selectedShapeIdsProvider);
    final selectedShape = ref.watch(selectedShapeProvider);
    final activeGroupId = ref.watch(activeGroupIdProvider);
    final activeTool = ref.watch(activeToolProvider);
    final drawing = ref.watch(activeDrawingProvider);
    final penDrawing = ref.watch(activePenDrawingProvider);
    final motionPaths = ref.watch(activeSceneMotionPathsProvider);
    final mpDrawTargetNullable = ref.watch(motionPathDrawTargetProvider);
    final mpPreviewNodes = ref.watch(motionPathPreviewNodesProvider);
    final isMotionPathDrawing = mpDrawTargetNullable != null;
    final mpDrawTarget = mpDrawTargetNullable ?? '';

    final isDrawingTool =
        activeTool == VecTool.rectangle ||
        activeTool == VecTool.ellipse ||
        activeTool == VecTool.text ||
        activeTool == VecTool.line;
    final isPenTool = activeTool == VecTool.pen;
    final isSelectTool = activeTool == VecTool.select;

    // For display purposes (selection overlay, handles, cursor hit-testing)
    // use the animated scene so the selection box tracks animated positions.
    // `selectedShape` (raw) is still used for editing operations.
    dynamic activeGroup;
    dynamic displaySelectedShape = selectedShape; // fallback to raw
    if (scene != null) {
      if (activeGroupId != null) {
        // Group-edit mode: find the group in the animated scene.
        for (final layer in scene.layers) {
          for (final shape in layer.shapes) {
            if (shape.id == activeGroupId) {
              activeGroup = shape;
              break;
            }
          }
          if (activeGroup != null) break;
        }
        if (activeGroup != null && selectedShape != null) {
          // Children are group-local; offset by the animated group's position.
          final gt = activeGroup.data.transform;
          final ct = selectedShape.data.transform;
          displaySelectedShape = selectedShape.copyWith(
            data: selectedShape.data.copyWith(
              transform: ct.copyWith(x: gt.x + ct.x, y: gt.y + ct.y),
            ),
          );
        }
      } else if (selectedShapeId != null) {
        // Normal mode: find the selected shape in the animated scene so the
        // selection overlay moves with the shape during animation playback.
        var found = false;
        for (final layer in scene.layers) {
          if (found) break;
          for (final shape in layer.shapes) {
            if (shape.id == selectedShapeId) {
              displaySelectedShape = shape;
              found = true;
              break;
            }
          }
        }
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportSize = Size(constraints.maxWidth, constraints.maxHeight);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleViewportChange(viewportSize, meta, fitRequest);
        });

        final stageScreenW = meta.stageWidth * zoom;
        final stageScreenH = meta.stageHeight * zoom;
        final stageLeft = (viewportSize.width - stageScreenW) / 2 + panOffset.dx;
        final stageTop = (viewportSize.height - stageScreenH) / 2 + panOffset.dy;

        return Listener(
          onPointerHover: (event) {
            ref.read(cursorPositionProvider.notifier).set(event.localPosition);
            if (isSelectTool && displaySelectedShape != null) {
              _updateHoverCursor(displaySelectedShape.transform, zoom, event.localPosition);
            }
            if (isSelectTool && selectedShapeIds.length == 1) {
              _updateHoverCorner(displaySelectedShape, zoom, event.localPosition);
              _updateHoverBend(displaySelectedShape, zoom, event.localPosition);
            }
            if (isPenTool && penDrawing == null && selectedShape != null) {
              _updateHoverNode(selectedShape, event.localPosition, zoom);
            }
          },
          onPointerSignal: (event) {
            if (event is PointerScrollEvent) {
              _handleScrollZoom(event, viewportSize);
            }
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,

            onPanStart: (details) {
              if (_isPanning) return;
              if (isDrawingTool) {
                final local = _toCanvasPoint(details.localPosition);
                ref.read(activeDrawingProvider.notifier).start(local);
                return;
              }
              if (isPenTool) {
                _handlePenPanStart(details, selectedShape, zoom);
                return;
              }
              if (isSelectTool) {
                _handleSelectPanStart(details, scene, selectedShape, displaySelectedShape, zoom, activeGroup);
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
                return;
              }
              if (isPenTool && (_isPenHandleDrag || _editNodeIndex >= 0)) {
                _handlePenPanUpdate(details, scene, selectedShape);
                return;
              }
              if (_selectDragMode == _SelectDragMode.motionPathNode) {
                _handleMpNodeDrag(details);
                return;
              }
              if (isSelectTool && _isMarqueeDrag) {
                setState(() => _marqueeCurrentCanvas = _toCanvasPoint(details.localPosition));
                return;
              }
              if (isSelectTool && _selectDragMode != _SelectDragMode.none) {
                _handleSelectPanUpdate(details, scene, selectedShape, zoom, activeGroup);
              }
            },

            onPanEnd: (details) {
              if (_isPanning) return;
              if (isDrawingTool) {
                _finishDragDrawing(activeTool);
                return;
              }
              if (isPenTool && (_isPenHandleDrag || _editNodeIndex >= 0)) {
                _handlePenPanEnd(scene, selectedShape);
                return;
              }
              if (_selectDragMode == _SelectDragMode.motionPathNode) {
                ref.read(vecDocumentStateProvider.notifier).commitCurrentState();
                setState(() {
                  _selectDragMode = _SelectDragMode.none;
                  _mpDragPathId = null;
                  _mpDragNodeIndex = -1;
                });
                return;
              }
              if (isSelectTool && _isMarqueeDrag) {
                _finishMarqueeSelection(scene, activeGroupId);
                setState(() => _isMarqueeDrag = false);
                return;
              }
              if (isSelectTool && _selectDragMode != _SelectDragMode.none) {
                _handleSelectPanEnd(scene, selectedShape, activeGroup);
              }
            },

            onTapDown: isMotionPathDrawing
                ? (details) {
                    final local = _toCanvasPoint(details.localPosition);
                    _handleMotionPathTap(local, mpDrawTarget, zoom);
                  }
                : isPenTool
                ? (details) {
                    final local = _toCanvasPoint(details.localPosition);
                    final pen = ref.read(activePenDrawingProvider);
                    // If no active drawing and clicked near an existing node,
                    // let onPanStart handle the drag instead.
                    if (pen == null && selectedShape != null) {
                      final pathShape = selectedShape.maybeMap(path: (s) => s, orElse: () => null);
                      if (pathShape != null) {
                        final nodeIdx = PathEditOverlayPainter.hitTestNode(pathShape, local, zoom);
                        if (nodeIdx != -1) return;
                      }
                    }
                    if (pen == null) {
                      ref.read(activePenDrawingProvider.notifier).start(local);
                    } else {
                      ref.read(activePenDrawingProvider.notifier).addPoint(local);
                    }
                  }
                : isSelectTool
                ? (details) {
                    final local = _toCanvasPoint(details.localPosition);
                    final cmdHeld =
                        HardwareKeyboard.instance.isControlPressed || HardwareKeyboard.instance.isMetaPressed;
                    _handleSelectTap(scene, selectedShape, displaySelectedShape, local, zoom, cmdHeld, activeGroupId);
                  }
                : null,

            onDoubleTap: isMotionPathDrawing
                ? () => _finishMotionPathDrawing(mpDrawTarget)
                : isPenTool
                ? () => _finishPenDrawing(closed: true)
                : isSelectTool
                ? () {
                    if (selectedShape == null) return;
                    // If the selected shape is a group and we're not already inside it,
                    // enter group-edit mode.
                    final isGroup = selectedShape.maybeMap(group: (_) => true, orElse: () => false);
                    if (isGroup && activeGroupId == null) {
                      ref.read(activeGroupIdProvider.notifier).set(selectedShape.id);
                      ref.read(selectedShapeIdProvider.notifier).clear();
                      ref.read(selectedShapeIdsProvider.notifier).clear();
                    }
                  }
                : null,

            child: MouseRegion(
              cursor: _isPanning ? SystemMouseCursors.grab : _currentCursor(activeTool, selectedShape),
              child: SizedBox(
                width: viewportSize.width,
                height: viewportSize.height,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _CanvasBackgroundPainter(
                          bgColor: theme.canvasBackground,
                          dotColor: theme.gridLine.withAlpha(60),
                        ),
                      ),
                    ),

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
                            selectedShapeIds: selectedShapeIds,
                            selectedShape: selectedShape,
                            displaySelectedShape: displaySelectedShape,
                            activeGroup: activeGroup,
                            activeTool: activeTool,
                            drawing: drawing,
                            penDrawing: penDrawing,
                            motionPaths: motionPaths,
                            mpPreviewNodes: mpPreviewNodes,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      left: stageLeft,
                      top: stageTop,
                      width: stageScreenW,
                      height: stageScreenH,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(border: Border.all(color: theme.divider.withAlpha(100), width: 1)),
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
    required List<String> selectedShapeIds,
    required dynamic selectedShape,
    required dynamic displaySelectedShape,
    required dynamic activeGroup,
    required VecTool activeTool,
    required dynamic drawing,
    required dynamic penDrawing,
    required List<dynamic> motionPaths,
    required List<dynamic> mpPreviewNodes,
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
            Positioned.fill(
              child: CustomPaint(
                painter: _CheckerboardPainter(color1: theme.gridBackground, color2: theme.gridLine.withAlpha(30)),
                child: ColoredBox(color: meta.backgroundColor.toFlutterColor()),
              ),
            ),

            if (scene != null)
              Positioned.fill(
                child: ClipRect(
                  child: CustomPaint(
                    painter: ScenePainter(scene: scene, selectedShapeId: selectedShapeId),
                  ),
                ),
              ),

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

            // Group outline — dashed rect around the active group bounds
            if (activeGroup != null)
              Positioned.fill(
                child: CustomPaint(
                  painter: _GroupOutlinePainter(
                    groupTransform: activeGroup.data.transform,
                    color: theme.selectionOutline.withAlpha(120),
                    zoom: zoom,
                  ),
                ),
              ),

            // Multi-selection bounding rect (no handles) — shown when >1 selected
            if (selectedShapeIds.length > 1 && scene != null)
              Positioned.fill(
                child: CustomPaint(
                  painter: _MultiSelectionPainter(
                    scene: scene,
                    selectedIds: selectedShapeIds,
                    color: theme.selectionOutline,
                    zoom: zoom,
                  ),
                ),
              ),

            // Single-selection overlay with handles
            if (selectedShapeIds.length <= 1 && displaySelectedShape != null)
              Positioned.fill(
                child: CustomPaint(
                  painter: SelectionOverlayPainter(
                    shape: displaySelectedShape,
                    selectionColor: theme.selectionOutline,
                    handleColor: theme.onPrimary,
                    zoom: zoom,
                  ),
                ),
              ),

            // Corner-radius handles — rectangle, single selection only
            if (selectedShapeIds.length == 1 && displaySelectedShape != null)
              Builder(
                builder: (ctx) {
                  final rectShape = displaySelectedShape.maybeMap(rectangle: (r) => r, orElse: () => null);
                  if (rectShape == null) return const SizedBox.shrink();
                  return Positioned.fill(
                    child: CustomPaint(
                      painter: CornerRadiusOverlayPainter(
                        shape: rectShape,
                        zoom: zoom,
                        selectedCorners: _selectedCorners,
                        hoverCornerIndex: _hoverCornerIndex,
                        color: theme.selectionOutline,
                      ),
                    ),
                  );
                },
              ),

            // Bend handle — 2-node open path (line), single selection, select tool
            if (selectedShapeIds.length == 1 && displaySelectedShape != null && activeTool == VecTool.select)
              Builder(
                builder: (ctx) {
                  final lineShape = displaySelectedShape.maybeMap(
                    path: (p) => p.nodes.length == 2 && !p.isClosed ? p : null,
                    orElse: () => null,
                  );
                  if (lineShape == null) return const SizedBox.shrink();
                  return Positioned.fill(
                    child: CustomPaint(
                      painter: BendHandleOverlayPainter(
                        shape: lineShape,
                        zoom: zoom,
                        isHovered: _hoverBendHandle,
                        color: theme.selectionOutline,
                      ),
                    ),
                  );
                },
              ),

            // Marquee (rubber-band) selection rect
            if (_isMarqueeDrag)
              Positioned.fill(
                child: CustomPaint(
                  painter: _MarqueePainter(
                    start: _marqueeStartCanvas,
                    end: _marqueeCurrentCanvas,
                    color: theme.selectionOutline,
                    zoom: zoom,
                  ),
                ),
              ),

            // Path node editing overlay (pen tool + path selected + not drawing)
            if (activeTool == VecTool.pen && penDrawing == null && selectedShape != null)
              Builder(
                builder: (context) {
                  final pathShape = selectedShape.maybeMap(path: (s) => s, orElse: () => null);
                  if (pathShape == null) return const SizedBox.shrink();
                  return Positioned.fill(
                    child: CustomPaint(
                      painter: PathEditOverlayPainter(
                        shape: pathShape,
                        nodeColor: theme.selectionOutline,
                        zoom: zoom,
                        hoveredNodeIndex: _hoverNodeIndex,
                        draggedNodeIndex: _editNodeIndex,
                      ),
                    ),
                  );
                },
              ),

            // Motion path overlay — dashed paths + node handles
            if (motionPaths.isNotEmpty || mpPreviewNodes.isNotEmpty)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: MotionPathOverlayPainter(
                      motionPaths: motionPaths.cast(),
                      previewNodes: mpPreviewNodes.cast(),
                      zoom: zoom,
                      pathColor: theme.accentColor,
                      nodeColor: theme.primaryColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Select tool — tap (click to select)
  // ===========================================================================

  void _handleSelectTap(
    dynamic scene,
    dynamic selectedShape,
    dynamic displaySelectedShape,
    Offset canvasPoint,
    double zoom,
    bool cmdHeld,
    String? activeGroupId,
  ) {
    // Corner-radius handle tap (rectangle, single selection, no group-edit)
    if (displaySelectedShape != null && activeGroupId == null && ref.read(selectedShapeIdsProvider).length == 1) {
      final rectShape = displaySelectedShape.maybeMap(rectangle: (r) => r, orElse: () => null);
      if (rectShape != null) {
        final cornerIdx = CornerRadiusOverlayPainter.hitTestHandle(rectShape, zoom, canvasPoint);
        if (cornerIdx != -1) {
          setState(() {
            if (cmdHeld) {
              final updated = Set<int>.from(_selectedCorners);
              if (updated.contains(cornerIdx) && updated.length > 1) {
                updated.remove(cornerIdx);
              } else {
                updated.add(cornerIdx);
              }
              _selectedCorners = updated;
            } else {
              // If all selected, switch to individual; else select only this one
              _selectedCorners = _selectedCorners.length == 4 && _selectedCorners.contains(cornerIdx)
                  ? {cornerIdx}
                  : {cornerIdx};
            }
          });
          return;
        }
      }
    }

    // Bend handle tap (2-node line, single selection, no group-edit)
    if (displaySelectedShape != null && activeGroupId == null && ref.read(selectedShapeIdsProvider).length == 1) {
      final lineShape = displaySelectedShape.maybeMap(
        path: (p) => p.nodes.length == 2 && !p.isClosed ? p : null,
        orElse: () => null,
      );
      if (lineShape != null && BendHandleOverlayPainter.hitTestHandle(lineShape, zoom, canvasPoint) == 0) {
        return; // panStart will handle the drag
      }
    }

    // If a shape is selected, ignore taps that land on handles (pan will handle those)
    if (displaySelectedShape != null) {
      final hitIndex = SelectToolHandler.hitTestHandles(displaySelectedShape.transform, zoom, canvasPoint);
      if (hitIndex != -1) return; // Let panStart handle it
      // Also ignore taps inside the body when it's already selected (unless cmd adds to selection)
      if (!cmdHeld && SelectToolHandler.hitTestBody(displaySelectedShape.transform, canvasPoint)) {
        return;
      }
    }

    _hitTestAndSelect(scene, canvasPoint, cmdHeld, activeGroupId: activeGroupId);
  }

  void _hitTestAndSelect(dynamic scene, Offset canvasPoint, bool cmdHeld, {String? activeGroupId}) {
    if (scene == null) {
      ref.read(selectedShapeIdProvider.notifier).clear();
      ref.read(selectedShapeIdsProvider.notifier).clear();
      return;
    }

    // --- Group-edit mode: hit-test only the active group's children ---
    if (activeGroupId != null) {
      for (final layer in scene.layers) {
        for (final shape in layer.shapes) {
          if (shape.id != activeGroupId) continue;
          final group = shape.maybeMap(group: (g) => g, orElse: () => null);
          if (group == null) return;
          final gt = group.data.transform;
          for (var i = group.children.length - 1; i >= 0; i--) {
            final child = group.children[i];
            final ct = child.data.transform;
            final et = ct.copyWith(x: gt.x + ct.x, y: gt.y + ct.y);
            final hit = et.rotation == 0
                ? Rect.fromLTWH(et.x, et.y, et.width, et.height).contains(canvasPoint)
                : SelectToolHandler.hitTestBody(et, canvasPoint);
            if (hit) {
              ref.read(selectedShapeIdProvider.notifier).set(child.id);
              ref.read(selectedShapeIdsProvider.notifier).setSingle(child.id);
              return;
            }
          }
          // Missed all children — deselect child
          ref.read(selectedShapeIdProvider.notifier).clear();
          ref.read(selectedShapeIdsProvider.notifier).clear();
          return;
        }
      }
      return;
    }

    // --- Normal mode ---
    final layers = List.from(scene.layers)..sort((a, b) => b.order.compareTo(a.order));

    for (final layer in layers) {
      if (!layer.visible || layer.locked) continue;
      for (var i = layer.shapes.length - 1; i >= 0; i--) {
        final shape = layer.shapes[i];
        final t = shape.transform;
        final hit = t.rotation == 0
            ? Rect.fromLTWH(t.x, t.y, t.width, t.height).contains(canvasPoint)
            : SelectToolHandler.hitTestBody(t, canvasPoint);

        if (hit) {
          if (cmdHeld) {
            // Cmd/Ctrl held → toggle in multi-select
            final ids = ref.read(selectedShapeIdsProvider);
            if (ids.contains(shape.id)) {
              ref.read(selectedShapeIdsProvider.notifier).remove(shape.id);
              final remaining = ref.read(selectedShapeIdsProvider);
              ref.read(selectedShapeIdProvider.notifier).set(remaining.isEmpty ? null : remaining.last);
            } else {
              ref.read(selectedShapeIdsProvider.notifier).add(shape.id);
              ref.read(selectedShapeIdProvider.notifier).set(shape.id);
            }
          } else {
            // Plain click → select only this shape
            ref.read(selectedShapeIdProvider.notifier).set(shape.id);
            ref.read(selectedShapeIdsProvider.notifier).setSingle(shape.id);
          }
          // Reset corner selection when switching shapes
          if (shape.id != _cornerEditShapeId) {
            _selectedCorners = {0, 1, 2, 3};
            _cornerEditShapeId = shape.id;
          }
          ref.read(activeLayerIdProvider.notifier).set(layer.id);
          return;
        }
      }
    }

    // Tapped empty area — deselect (only if not adding to selection)
    if (!cmdHeld) {
      ref.read(selectedShapeIdProvider.notifier).clear();
      ref.read(selectedShapeIdsProvider.notifier).clear();
    }
  }

  // ===========================================================================
  // Select tool — pan (drag to move/resize/rotate)
  // ===========================================================================

  void _handleSelectPanStart(
    DragStartDetails details,
    dynamic scene,
    dynamic selectedShape,
    dynamic displaySelectedShape,
    double zoom,
    dynamic activeGroup,
  ) {
    final canvasPoint = _toCanvasPoint(details.localPosition);
    final selectedIds = ref.read(selectedShapeIdsProvider);

    // --- Motion path node drag ---
    final motionPaths = ref.read(activeSceneMotionPathsProvider);
    final mpHit = MotionPathHitTest.hitTestNode(motionPaths, canvasPoint, zoom);
    if (mpHit != null) {
      setState(() {
        _selectDragMode = _SelectDragMode.motionPathNode;
        _mpDragPathId = mpHit.pathId;
        _mpDragNodeIndex = mpHit.nodeIndex;
      });
      return;
    }

    // --- Multi-select drag: move all selected shapes together ---
    if (selectedIds.length > 1 && activeGroup == null && scene != null) {
      // Check if the drag started on any selected shape
      bool hitAny = false;
      for (final layer in scene.layers) {
        for (final shape in layer.shapes) {
          if (!selectedIds.contains(shape.id)) continue;
          final t = shape.data.transform;
          if (SelectToolHandler.hitTestBody(t, canvasPoint)) {
            hitAny = true;
            break;
          }
        }
        if (hitAny) break;
      }

      if (hitAny) {
        // Capture start transforms for every selected shape
        final transforms = <String, dynamic>{};
        for (final layer in scene.layers) {
          for (final shape in layer.shapes) {
            if (selectedIds.contains(shape.id)) {
              transforms[shape.id] = shape.data.transform;
            }
          }
        }
        setState(() {
          _selectDragMode = _SelectDragMode.move;
          _dragStartTransforms = transforms;
          _dragStartCanvasPoint = canvasPoint;
        });
        return;
      }

      // Missed all selected shapes → start marquee
      setState(() {
        _isMarqueeDrag = true;
        _marqueeStartCanvas = canvasPoint;
        _marqueeCurrentCanvas = canvasPoint;
      });
      return;
    }

    // --- Single-select: handle/body/rotate/resize ---
    if (displaySelectedShape == null) return;
    // Use effective canvas-space transform for handle/body testing
    final t = displaySelectedShape.transform;

    // Corner-radius drag (rectangle only, no group-edit)
    if (activeGroup == null) {
      final rectShape = displaySelectedShape.maybeMap(rectangle: (r) => r, orElse: () => null);
      if (rectShape != null) {
        final cornerIdx = CornerRadiusOverlayPainter.hitTestHandle(rectShape, zoom, canvasPoint);
        if (cornerIdx != -1) {
          // If the tapped corner isn't in the current selection, use only it
          final cornersToChange = _selectedCorners.contains(cornerIdx) ? Set<int>.from(_selectedCorners) : {cornerIdx};
          final radii = rectShape.cornerRadii.length == 4 ? rectShape.cornerRadii : [0.0, 0.0, 0.0, 0.0];
          setState(() {
            _selectDragMode = _SelectDragMode.cornerRadius;
            _cornersBeingDragged = cornersToChange;
            _cornerRadiiAtDragStart = List<double>.from(radii);
            _dragStartCanvasPoint = canvasPoint;
            _dragStartTransform = t;
          });
          return;
        }
      }
    }

    // Bend handle drag (2-node open path, no group-edit)
    if (activeGroup == null) {
      final lineShape = displaySelectedShape.maybeMap(
        path: (p) => p.nodes.length == 2 && !p.isClosed ? p : null,
        orElse: () => null,
      );
      if (lineShape != null) {
        final hit = BendHandleOverlayPainter.hitTestHandle(lineShape, zoom, canvasPoint);
        if (hit == 0) {
          final n0 = lineShape.nodes[0];
          final n1 = lineShape.nodes[1];
          final canvasBendPos = BendHandleOverlayPainter.bendHandleCanvasPos(lineShape)!;
          setState(() {
            _selectDragMode = _SelectDragMode.bend;
            _dragStartCanvasPoint = canvasPoint;
            _dragStartTransform = t;
            _bendHandleAtDragStart = canvasBendPos;
            _bendStartLocalPos = Offset(n0.position.x, n0.position.y);
            _bendEndLocalPos = Offset(n1.position.x, n1.position.y);
          });
          return;
        }
      }
    }

    final hitIndex = SelectToolHandler.hitTestHandles(t, zoom, canvasPoint);

    if (hitIndex == -2) {
      // Rotation handle
      final center = SelectToolHandler.localToCanvas(t, Offset(t.width / 2, t.height / 2));
      setState(() {
        _selectDragMode = _SelectDragMode.rotate;
        _dragStartTransform = t;
        _dragStartCanvasPoint = canvasPoint;
        _rotationStartAngle = (canvasPoint - center).direction;
        _dragGroupTransform = activeGroup?.data.transform;
      });
    } else if (hitIndex >= 0) {
      // Resize handle
      setState(() {
        _selectDragMode = _SelectDragMode.resizeHandle;
        _resizeHandleIndex = hitIndex;
        _dragStartTransform = t;
        _dragStartCanvasPoint = canvasPoint;
        _dragGroupTransform = activeGroup?.data.transform;
      });
    } else if (SelectToolHandler.hitTestBody(t, canvasPoint)) {
      // Move single shape
      setState(() {
        _selectDragMode = _SelectDragMode.move;
        _dragStartTransform = t;
        _dragStartCanvasPoint = canvasPoint;
        _dragGroupTransform = activeGroup?.data.transform;
      });
    } else {
      // Started on empty space → begin marquee selection
      setState(() {
        _isMarqueeDrag = true;
        _marqueeStartCanvas = canvasPoint;
        _marqueeCurrentCanvas = canvasPoint;
      });
    }
  }

  void _handleSelectPanUpdate(
    DragUpdateDetails details,
    dynamic scene,
    dynamic selectedShape,
    double zoom,
    dynamic activeGroup,
  ) {
    if (scene == null) return;
    final layerId = ref.read(activeLayerIdProvider);
    if (layerId == null) return;

    final canvasPoint = _toCanvasPoint(details.localPosition);
    final delta = canvasPoint - _dragStartCanvasPoint;

    // --- Multi-shape move ---
    if (_dragStartTransforms.length > 1 && _selectDragMode == _SelectDragMode.move) {
      for (final entry in _dragStartTransforms.entries) {
        final start = entry.value;
        final newT = start.copyWith(x: start.x + delta.dx, y: start.y + delta.dy);
        ref
            .read(vecDocumentStateProvider.notifier)
            .updateShapeNoHistory(
              scene.id,
              layerId,
              entry.key,
              (s) => s.copyWith(data: s.data.copyWith(transform: newT)),
            );
      }
      return;
    }

    if (selectedShape == null) return;
    // _dragStartTransform is in canvas space (effective transform)
    final start = _dragStartTransform!;

    dynamic newCanvasTransform;

    switch (_selectDragMode) {
      case _SelectDragMode.move:
        newCanvasTransform = start.copyWith(x: start.x + delta.dx, y: start.y + delta.dy);

      case _SelectDragMode.resizeHandle:
        newCanvasTransform = SelectToolHandler.applyResizeHandle(start, _resizeHandleIndex, delta);

      case _SelectDragMode.rotate:
        final center = SelectToolHandler.localToCanvas(start, Offset(start.width / 2, start.height / 2));
        final currentAngle = (canvasPoint - center).direction;
        final angleDeltaDeg = (currentAngle - _rotationStartAngle) * 180 / math.pi;
        newCanvasTransform = start.copyWith(rotation: start.rotation + angleDeltaDeg);

      case _SelectDragMode.cornerRadius:
        // Un-rotate the canvas delta into shape-local space
        final angle = start.rotation * math.pi / 180;
        final cosA = math.cos(angle);
        final sinA = math.sin(angle);
        final localDx = delta.dx * cosA + delta.dy * sinA;
        final localDy = -delta.dx * sinA + delta.dy * cosA;
        final maxR = math.min(start.width, start.height) / 2;
        const signs = [
          Offset(1, 1), // TL
          Offset(-1, 1), // TR
          Offset(-1, -1), // BR
          Offset(1, -1), // BL
        ];
        final newRadii = List<double>.from(_cornerRadiiAtDragStart);
        for (final ci in _cornersBeingDragged) {
          final s = signs[ci];
          final rd = (localDx * s.dx + localDy * s.dy) / math.sqrt(2);
          newRadii[ci] = (_cornerRadiiAtDragStart[ci] + rd).clamp(0.0, maxR);
        }
        ref
            .read(vecDocumentStateProvider.notifier)
            .updateShapeNoHistory(
              scene.id,
              layerId,
              selectedShape.id,
              (s) => s.maybeMap(
                rectangle: (r) => r.copyWith(cornerRadii: newRadii),
                orElse: () => s,
              ),
            );
        return;

      case _SelectDragMode.bend:
        // New bend handle canvas position = original position + drag delta
        final newBendCanvas = _bendHandleAtDragStart + delta;
        // Convert to shape-local space
        final h = SelectToolHandler.canvasToLocal(start, newBendCanvas);
        // Symmetric quadratic-to-cubic: C1 = (4H - end) / 3, C2 = (4H - start) / 3
        final h4 = Offset(h.dx * 4, h.dy * 4);
        final c1 = (h4 - _bendEndLocalPos) / 3.0;
        final c2 = (h4 - _bendStartLocalPos) / 3.0;
        ref
            .read(vecDocumentStateProvider.notifier)
            .updateShapeNoHistory(
              scene.id,
              layerId,
              selectedShape.id,
              (s) => s.maybeMap(
                path: (pathS) {
                  final n0 = pathS.nodes[0];
                  final n1 = pathS.nodes[1];
                  return pathS.copyWith(
                    nodes: [
                      n0.copyWith(
                        handleOut: VecPoint(x: c1.dx, y: c1.dy),
                        type: VecNodeType.smooth,
                      ),
                      n1.copyWith(
                        handleIn: VecPoint(x: c2.dx, y: c2.dy),
                        type: VecNodeType.smooth,
                      ),
                    ],
                  );
                },
                orElse: () => s,
              ),
            );
        return;

      case _SelectDragMode.none:
        return;

      case _SelectDragMode.motionPathNode:
        // Handled before this switch in onPanUpdate
        return;
    }

    if (_dragGroupTransform != null) {
      // Group-edit mode: convert canvas-space transform back to group-local
      final gt = _dragGroupTransform!;
      final localTransform = newCanvasTransform.copyWith(
        x: newCanvasTransform.x - gt.x,
        y: newCanvasTransform.y - gt.y,
      );
      final groupId = ref.read(activeGroupIdProvider)!;
      ref
          .read(vecDocumentStateProvider.notifier)
          .updateGroupChildNoHistory(
            scene.id,
            layerId,
            groupId,
            selectedShape.id,
            (c) => c.copyWith(data: c.data.copyWith(transform: localTransform)),
          );
    } else {
      ref.read(vecDocumentStateProvider.notifier).updateShapeNoHistory(scene.id, layerId, selectedShape.id, (s) {
        // For path shapes during resize: scale node positions proportionally
        if (_selectDragMode == _SelectDragMode.resizeHandle) {
          return s.maybeMap(
            path: (pathS) {
              final scX = start.width > 0 ? newCanvasTransform.width / start.width : 1.0;
              final scY = start.height > 0 ? newCanvasTransform.height / start.height : 1.0;
              final scaledNodes = pathS.nodes.map((n) {
                return n.copyWith(
                  position: VecPoint(x: n.position.x * scX, y: n.position.y * scY),
                  handleOut: n.handleOut == null ? null : VecPoint(x: n.handleOut!.x * scX, y: n.handleOut!.y * scY),
                  handleIn: n.handleIn == null ? null : VecPoint(x: n.handleIn!.x * scX, y: n.handleIn!.y * scY),
                );
              }).toList();
              return pathS.copyWith(
                data: pathS.data.copyWith(transform: newCanvasTransform),
                nodes: scaledNodes,
              );
            },
            orElse: () => s.copyWith(data: s.data.copyWith(transform: newCanvasTransform)),
          );
        }
        return s.copyWith(data: s.data.copyWith(transform: newCanvasTransform));
      });
    }
  }

  void _handleSelectPanEnd(dynamic scene, dynamic selectedShape, dynamic activeGroup) {
    if (selectedShape != null && scene != null) {
      final layerId = ref.read(activeLayerIdProvider);
      if (layerId != null) {
        // Commit final state as one undo-able entry
        ref.read(vecDocumentStateProvider.notifier).commitCurrentState();
      }
    }
    setState(() {
      _selectDragMode = _SelectDragMode.none;
      _dragGroupTransform = null;
      _dragStartTransforms = {};
    });
  }

  void _finishMarqueeSelection(dynamic scene, String? activeGroupId) {
    if (scene == null) return;
    final marqueeRect = Rect.fromPoints(_marqueeStartCanvas, _marqueeCurrentCanvas);
    // Ignore tiny accidental drags
    if (marqueeRect.width < 2 && marqueeRect.height < 2) return;

    final selectedIds = <String>[];

    if (activeGroupId != null) {
      // In group-edit mode: select children whose effective bounds overlap the marquee
      for (final layer in scene.layers) {
        for (final shape in layer.shapes) {
          if (shape.id != activeGroupId) continue;
          final group = shape.maybeMap(group: (g) => g, orElse: () => null);
          if (group == null) return;
          final gt = group.data.transform;
          for (final child in group.children) {
            final ct = child.data.transform;
            final effectiveRect = Rect.fromLTWH(gt.x + ct.x, gt.y + ct.y, ct.width, ct.height);
            if (marqueeRect.overlaps(effectiveRect)) selectedIds.add(child.id);
          }
        }
      }
    } else {
      // Normal mode: select shapes whose bounds overlap the marquee
      for (final layer in scene.layers) {
        if (!layer.visible || layer.locked) continue;
        for (final shape in layer.shapes) {
          final t = shape.transform;
          final shapeRect = Rect.fromLTWH(t.x, t.y, t.width, t.height);
          if (marqueeRect.overlaps(shapeRect)) selectedIds.add(shape.id);
        }
      }
    }

    if (selectedIds.isNotEmpty) {
      ref.read(selectedShapeIdsProvider.notifier).setAll(selectedIds);
      ref.read(selectedShapeIdProvider.notifier).set(selectedIds.last);
    }
  }

  // ===========================================================================
  // Pen tool — handle drag + node editing
  // ===========================================================================

  void _handlePenPanStart(DragStartDetails details, dynamic selectedShape, double zoom) {
    final pen = ref.read(activePenDrawingProvider);

    // Case 1: currently drawing → pull handle from the last placed node
    if (pen != null && pen.nodes.isNotEmpty) {
      setState(() => _isPenHandleDrag = true);
      return;
    }

    // Case 2: no active drawing + path selected → try to drag an existing node
    if (pen == null && selectedShape != null) {
      final pathShape = selectedShape.maybeMap(path: (s) => s, orElse: () => null);
      if (pathShape != null) {
        final canvasPoint = _toCanvasPoint(details.localPosition);
        final nodeIdx = PathEditOverlayPainter.hitTestNode(pathShape, canvasPoint, zoom);
        if (nodeIdx != -1) {
          setState(() {
            _editNodeIndex = nodeIdx;
            _editDragStartCanvas = canvasPoint;
            _editDragStartTransform = pathShape.data.transform;
          });
        }
      }
    }
  }

  void _handlePenPanUpdate(DragUpdateDetails details, dynamic scene, dynamic selectedShape) {
    final canvasPoint = _toCanvasPoint(details.localPosition);

    if (_isPenHandleDrag) {
      ref.read(activePenDrawingProvider.notifier).updateLastHandle(canvasPoint);
      return;
    }

    if (_editNodeIndex >= 0 && scene != null && selectedShape != null) {
      final layerId = ref.read(activeLayerIdProvider);
      if (layerId == null) return;

      final t = _editDragStartTransform!;
      final delta = canvasPoint - _editDragStartCanvas;

      ref
          .read(vecDocumentStateProvider.notifier)
          .updateShapeNoHistory(
            scene.id,
            layerId,
            selectedShape.id,
            (s) => s.maybeMap(
              path: (pathS) {
                final oldNode = pathS.nodes[_editNodeIndex];
                final oldCanvas = SelectToolHandler.localToCanvas(t, Offset(oldNode.position.x, oldNode.position.y));
                final newCanvas = oldCanvas + delta;
                final newLocal = SelectToolHandler.canvasToLocal(t, newCanvas);
                final updatedNodes = List<VecPathNode>.from(pathS.nodes);
                updatedNodes[_editNodeIndex] = oldNode.copyWith(
                  position: VecPoint(x: newLocal.dx, y: newLocal.dy),
                );
                return pathS.copyWith(nodes: updatedNodes);
              },
              orElse: () => s,
            ),
          );
    }
  }

  void _handlePenPanEnd(dynamic scene, dynamic selectedShape) {
    if (_editNodeIndex >= 0 && scene != null && selectedShape != null) {
      ref.read(vecDocumentStateProvider.notifier).commitCurrentState();
    }
    setState(() {
      _isPenHandleDrag = false;
      _editNodeIndex = -1;
    });
  }

  void _updateHoverNode(dynamic selectedShape, Offset screenPos, double zoom) {
    final pathShape = selectedShape?.maybeMap(path: (s) => s, orElse: () => null);
    if (pathShape == null) {
      if (_hoverNodeIndex != -1) setState(() => _hoverNodeIndex = -1);
      return;
    }
    final canvasPoint = _toCanvasPoint(screenPos);
    final nodeIdx = PathEditOverlayPainter.hitTestNode(pathShape, canvasPoint, zoom);
    if (nodeIdx != _hoverNodeIndex) {
      setState(() => _hoverNodeIndex = nodeIdx);
    }
  }

  void _updateHoverCorner(dynamic displaySelectedShape, double zoom, Offset screenPos) {
    final rectShape = displaySelectedShape?.maybeMap(rectangle: (r) => r, orElse: () => null);
    if (rectShape == null) {
      if (_hoverCornerIndex != -1) setState(() => _hoverCornerIndex = -1);
      return;
    }
    final canvasPoint = _toCanvasPoint(screenPos);
    final idx = CornerRadiusOverlayPainter.hitTestHandle(rectShape, zoom, canvasPoint);
    if (idx != _hoverCornerIndex) setState(() => _hoverCornerIndex = idx);
  }

  void _updateHoverBend(dynamic displaySelectedShape, double zoom, Offset screenPos) {
    final lineShape = displaySelectedShape?.maybeMap(
      path: (p) => p.nodes.length == 2 && !p.isClosed ? p : null,
      orElse: () => null,
    );
    if (lineShape == null) {
      if (_hoverBendHandle) setState(() => _hoverBendHandle = false);
      return;
    }
    final canvasPoint = _toCanvasPoint(screenPos);
    final hit = BendHandleOverlayPainter.hitTestHandle(lineShape, zoom, canvasPoint) == 0;
    if (hit != _hoverBendHandle) setState(() => _hoverBendHandle = hit);
  }

  // ===========================================================================
  // Hover cursor update
  // ===========================================================================

  void _updateHoverCursor(dynamic transform, double zoom, Offset screenPos) {
    if (transform == null) return;
    final canvasPoint = _toCanvasPoint(screenPos);
    final hitIndex = SelectToolHandler.hitTestHandles(transform, zoom, canvasPoint);
    final bodyHit = hitIndex == -1 ? SelectToolHandler.hitTestBody(transform, canvasPoint) : false;
    final newIndex = bodyHit ? -3 : hitIndex;
    if (newIndex != _hoverHandleIndex) {
      setState(() => _hoverHandleIndex = newIndex);
    }
  }

  MouseCursor _currentCursor(VecTool activeTool, dynamic selectedShape) {
    if (activeTool == VecTool.select) {
      if (selectedShape != null) {
        // Bend handle drag/hover
        if (_selectDragMode == _SelectDragMode.bend || _hoverBendHandle) {
          return SystemMouseCursors.precise;
        }
        // Corner-radius drag/hover
        if (_selectDragMode == _SelectDragMode.cornerRadius || _hoverCornerIndex >= 0) {
          return SystemMouseCursors.precise;
        }
        if (_selectDragMode == _SelectDragMode.move || _hoverHandleIndex == -3) {
          return SystemMouseCursors.move;
        }
        if (_selectDragMode == _SelectDragMode.rotate || _hoverHandleIndex == -2) {
          return SystemMouseCursors.grab;
        }
        final handleIdx = _selectDragMode == _SelectDragMode.resizeHandle ? _resizeHandleIndex : _hoverHandleIndex;
        if (handleIdx >= 0) {
          return SelectToolHandler.cursorForHandle(handleIdx);
        }
      }
      return SystemMouseCursors.basic;
    }
    return _cursorForTool(activeTool);
  }

  // ===========================================================================
  // Viewport change → auto zoom-to-fit
  // ===========================================================================

  void _handleViewportChange(Size viewportSize, VecMeta meta, int fitRequest) {
    if (viewportSize.width <= 0 || viewportSize.height <= 0) return;

    if (!_didInitialFit) {
      _didInitialFit = true;
      _lastFitRequest = fitRequest;
      _fitToViewport(viewportSize, meta);
      return;
    }

    if (fitRequest != _lastFitRequest) {
      _lastFitRequest = fitRequest;
      _fitToViewport(viewportSize, meta);
    }
  }

  void _fitToViewport(Size viewportSize, VecMeta meta) {
    ref
        .read(zoomLevelProvider.notifier)
        .zoomToFit(viewportSize.width, viewportSize.height, meta.stageWidth, meta.stageHeight);
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

    final pointerLocal = event.localPosition;
    final delta = -event.scrollDelta.dy;
    final zoomFactor = delta > 0 ? 1.1 : 1 / 1.1;
    final newZoom = (oldZoom * zoomFactor).clamp(0.01, 64.0);
    zoomNotifier.set(newZoom);

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
      case VecTool.line:
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
    if (drawingState == null) return;

    const handler = DrawingToolHandler();

    // Line only needs length in any axis ≥ 2px; auto-switches to select tool
    if (tool == VecTool.line) {
      if (drawingState.width < 2 && drawingState.height < 2) return;
      final shape = handler.createLine(drawingState);
      _addShapeToActiveLayer(shape);
      ref.read(activeToolProvider.notifier).set(VecTool.select);
      return;
    }

    if (drawingState.width < 2 || drawingState.height < 2) return;

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
    ref.read(selectedShapeIdsProvider.notifier).setSingle(shape.id);
  }

  // ===========================================================================
  // Motion path — drawing mode
  // ===========================================================================

  /// Called on each tap while in motion-path drawing mode.
  void _handleMotionPathTap(Offset canvasPoint, String shapeId, double zoom) {
    final node = VecPathNode(
      position: VecPoint(x: canvasPoint.dx, y: canvasPoint.dy),
    );
    ref.read(motionPathPreviewNodesProvider.notifier).addNode(node);
  }

  /// Called on double-tap (or Esc→finish) to commit the drawn path.
  void _finishMotionPathDrawing(String shapeId) {
    final nodes = ref.read(motionPathPreviewNodesProvider);
    if (nodes.length < 2) {
      // Not enough nodes — cancel silently
      ref.read(motionPathDrawTargetProvider.notifier).cancel();
      ref.read(motionPathPreviewNodesProvider.notifier).clear();
      return;
    }

    final scene = ref.read(activeSceneProvider);
    if (scene == null) return;

    const uuid = Uuid();
    final mp = VecMotionPath(id: uuid.v4(), shapeId: shapeId, nodes: List.unmodifiable(nodes));

    ref.read(vecDocumentStateProvider.notifier).addMotionPath(scene.id, mp);
    ref.read(motionPathDrawTargetProvider.notifier).cancel();
    ref.read(motionPathPreviewNodesProvider.notifier).clear();
  }

  // ===========================================================================
  // Motion path — node drag
  // ===========================================================================

  void _handleMpNodeDrag(DragUpdateDetails details) {
    final pathId = _mpDragPathId;
    final nodeIdx = _mpDragNodeIndex;
    if (pathId == null || nodeIdx < 0) return;

    final scene = ref.read(activeSceneProvider);
    if (scene == null) return;

    final canvasPoint = _toCanvasPoint(details.localPosition);
    final mp = scene.motionPaths.where((p) => p.id == pathId).firstOrNull;
    if (mp == null || nodeIdx >= mp.nodes.length) return;

    final updatedNodes = [
      for (var i = 0; i < mp.nodes.length; i++)
        if (i == nodeIdx)
          mp.nodes[i].copyWith(
            position: VecPoint(x: canvasPoint.dx, y: canvasPoint.dy),
          )
        else
          mp.nodes[i],
    ];

    ref.read(vecDocumentStateProvider.notifier).updateMotionPathNodesNoHistory(scene.id, pathId, updatedNodes);
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
  bool shouldRepaint(covariant _CanvasBackgroundPainter old) => old.bgColor != bgColor || old.dotColor != dotColor;
}

// =============================================================================
// Marquee (rubber-band) selection rect
// =============================================================================

class _MarqueePainter extends CustomPainter {
  const _MarqueePainter({required this.start, required this.end, required this.color, required this.zoom});

  final Offset start;
  final Offset end;
  final Color color;
  final double zoom;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromPoints(start, end);
    final strokeW = 1.0 / zoom;
    final fillPaint = Paint()
      ..color = color.withAlpha(30)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW;

    canvas.drawRect(rect, fillPaint);

    // Dashed outline
    final path = Path()..addRect(rect);
    final dashed = Path();
    const dash = 6.0;
    const gap = 4.0;
    for (final m in path.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        final end = (d + dash / zoom).clamp(0.0, m.length);
        dashed.addPath(m.extractPath(d, end), Offset.zero);
        d += (dash + gap) / zoom;
      }
    }
    canvas.drawPath(dashed, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _MarqueePainter old) => old.start != start || old.end != end;
}

// =============================================================================
// Multi-selection bounding box overlay (shown when >1 shapes selected)
// =============================================================================

class _MultiSelectionPainter extends CustomPainter {
  const _MultiSelectionPainter({
    required this.scene,
    required this.selectedIds,
    required this.color,
    required this.zoom,
  });

  final dynamic scene;
  final List<String> selectedIds;
  final Color color;
  final double zoom;

  @override
  void paint(Canvas canvas, Size size) {
    if (scene == null || selectedIds.isEmpty) return;

    double? minX, minY, maxX, maxY;

    for (final layer in scene.layers) {
      for (final shape in layer.shapes) {
        if (!selectedIds.contains(shape.id)) continue;
        final t = shape.data.transform;
        minX = minX == null ? t.x : math.min(minX, t.x);
        minY = minY == null ? t.y : math.min(minY, t.y);
        maxX = maxX == null ? t.x + t.width : math.max(maxX, t.x + t.width);
        maxY = maxY == null ? t.y + t.height : math.max(maxY, t.y + t.height);
      }
    }

    if (minX == null) return;

    final rect = Rect.fromLTRB(minX, minY!, maxX!, maxY!);
    final strokeW = 1.5 / zoom;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW;

    canvas.drawRect(rect, paint);

    // Corner ticks
    const tick = 6.0;
    final t = tick / zoom;
    final corners = [
      [rect.topLeft, Offset(t, 0), Offset(0, t)],
      [rect.topRight, Offset(-t, 0), Offset(0, t)],
      [rect.bottomLeft, Offset(t, 0), Offset(0, -t)],
      [rect.bottomRight, Offset(-t, 0), Offset(0, -t)],
    ];
    for (final c in corners) {
      final p = c[0] as Offset;
      canvas.drawLine(p, p + (c[1] as Offset), paint);
      canvas.drawLine(p, p + (c[2] as Offset), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MultiSelectionPainter old) => old.selectedIds != selectedIds || old.scene != scene;
}

// =============================================================================
// Group outline — dashed rect around the active group
// =============================================================================

class _GroupOutlinePainter extends CustomPainter {
  const _GroupOutlinePainter({required this.groupTransform, required this.color, required this.zoom});

  final dynamic groupTransform;
  final Color color;
  final double zoom;

  @override
  void paint(Canvas canvas, Size size) {
    final t = groupTransform;
    if (t == null) return;
    final rect = Rect.fromLTWH(t.x, t.y, t.width, t.height);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 / zoom;

    // Dashed path
    final path = Path()..addRect(rect);
    const dashLen = 6.0;
    const gapLen = 4.0;
    final metrics = path.computeMetrics();
    final dashed = Path();
    for (final metric in metrics) {
      var dist = 0.0;
      while (dist < metric.length) {
        final end = (dist + dashLen / zoom).clamp(0.0, metric.length);
        dashed.addPath(metric.extractPath(dist, end), Offset.zero);
        dist += (dashLen + gapLen) / zoom;
      }
    }
    canvas.drawPath(dashed, paint);
  }

  @override
  bool shouldRepaint(covariant _GroupOutlinePainter old) =>
      old.groupTransform != groupTransform || old.color != color || old.zoom != zoom;
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
  bool shouldRepaint(covariant _CheckerboardPainter old) => old.color1 != color1 || old.color2 != color2;
}
