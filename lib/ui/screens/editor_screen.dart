import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/tools/drawing_tool_handler.dart';
import '../../data/models/vec_shape.dart';
import '../../providers/clipboard_provider.dart';
import '../../providers/document_provider.dart';
import '../../providers/drawing_state_provider.dart';
import '../../providers/editor_state_provider.dart';
import '../../ui/contents/theme_selector.dart';
import '../contents/shortcuts_wrapper.dart';
import '../widgets/workspace/workspace_layout.dart';

const _uuid = Uuid();
const _pasteOffset = 20.0;

/// Returns a deep copy of [shape] with a fresh ID and [offset] added to x/y.
VecShape _cloneShape(VecShape shape, {double offset = _pasteOffset}) {
  return shape.copyWith(
    data: shape.data.copyWith(
      id: _uuid.v4(),
      transform: shape.data.transform.copyWith(
        x: shape.data.transform.x + offset,
        y: shape.data.transform.y + offset,
      ),
    ),
  );
}

class EditorScreen extends HookConsumerWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider).theme;

    return Scaffold(
      backgroundColor: theme.background,
      body: ShortcutsWrapper(
        onUndo: () => ref.read(vecDocumentStateProvider.notifier).undo(),
        onRedo: () => ref.read(vecDocumentStateProvider.notifier).redo(),
        onSave: () => ref.read(vecDocumentStateProvider.notifier).save(),
        onZoomIn: () => ref.read(zoomLevelProvider.notifier).zoomIn(),
        onZoomOut: () => ref.read(zoomLevelProvider.notifier).zoomOut(),
        onZoomFit: () => ref.read(fitRequestProvider.notifier).request(),
        onZoom100: () => ref.read(zoomLevelProvider.notifier).zoom100(),
        onToggleUI: () => ref.read(panelVisibilityProvider.notifier).toggleAll(),
        onNewLayer: () {
          final scene = ref.read(activeSceneProvider);
          if (scene != null) {
            ref.read(vecDocumentStateProvider.notifier).addLayer(scene.id);
          }
        },
        onDeleteLayer: () {
          // If a shape is selected, delete the shape instead of the layer
          final selectedId = ref.read(selectedShapeIdProvider);
          if (selectedId != null) {
            final scene = ref.read(activeSceneProvider);
            final layerId = ref.read(activeLayerIdProvider);
            if (scene != null && layerId != null) {
              ref.read(vecDocumentStateProvider.notifier).removeShape(scene.id, layerId, selectedId);
              ref.read(selectedShapeIdProvider.notifier).clear();
            }
            return;
          }
          final scene = ref.read(activeSceneProvider);
          final layerId = ref.read(activeLayerIdProvider);
          if (scene != null && layerId != null) {
            ref.read(vecDocumentStateProvider.notifier).removeLayer(scene.id, layerId);
          }
        },
        onEscape: () {
          final tool = ref.read(activeToolProvider);
          // Cancel any in-progress drag drawing
          ref.read(activeDrawingProvider.notifier).finish();
          // Finish pen path as open (not closed)
          if (tool == VecTool.pen) {
            final penState = ref.read(activePenDrawingProvider.notifier).finish();
            if (penState != null && penState.points.length >= 2) {
              const handler = DrawingToolHandler();
              final shape = handler.createPath(penState, closed: false);
              final scene = ref.read(activeSceneProvider);
              final layerId = ref.read(activeLayerIdProvider);
              if (scene != null && layerId != null) {
                ref.read(vecDocumentStateProvider.notifier).addShape(scene.id, layerId, shape);
                ref.read(selectedShapeIdProvider.notifier).set(shape.id);
              }
            }
            ref.read(activeToolProvider.notifier).set(VecTool.select);
            return;
          }
          // Exit group-edit mode if active, otherwise deselect
          final groupId = ref.read(activeGroupIdProvider);
          if (groupId != null) {
            ref.read(activeGroupIdProvider.notifier).clear();
            ref.read(selectedShapeIdProvider.notifier).set(groupId);
            ref.read(selectedShapeIdsProvider.notifier).setSingle(groupId);
          } else {
            ref.read(selectedShapeIdProvider.notifier).clear();
            ref.read(selectedShapeIdsProvider.notifier).clear();
          }
          // Switch back to select tool
          ref.read(activeToolProvider.notifier).set(VecTool.select);
        },
        onEnter: () {
          final tool = ref.read(activeToolProvider);
          if (tool == VecTool.pen) {
            final penState = ref.read(activePenDrawingProvider.notifier).finish();
            if (penState != null && penState.points.length >= 2) {
              const handler = DrawingToolHandler();
              final shape = handler.createPath(penState, closed: true);
              final scene = ref.read(activeSceneProvider);
              final layerId = ref.read(activeLayerIdProvider);
              if (scene != null && layerId != null) {
                ref.read(vecDocumentStateProvider.notifier).addShape(scene.id, layerId, shape);
                ref.read(selectedShapeIdProvider.notifier).set(shape.id);
              }
            }
          }
        },
        onToolSwitch: (key) {
          final tool = switch (key) {
            'V' => VecTool.select,
            'P' => VecTool.pen,
            'R' => VecTool.rectangle,
            'E' => VecTool.ellipse,
            'T' => VecTool.text,
            _ => null,
          };
          if (tool != null) {
            ref.read(activeToolProvider.notifier).set(tool);
          }
        },
        onNudge: (dx, dy) {
          final selectedId = ref.read(selectedShapeIdProvider);
          if (selectedId == null) return;
          final scene = ref.read(activeSceneProvider);
          final layerId = ref.read(activeLayerIdProvider);
          if (scene == null || layerId == null) return;
          final groupId = ref.read(activeGroupIdProvider);
          if (groupId != null) {
            // Nudge a child inside the active group
            ref.read(vecDocumentStateProvider.notifier).updateGroupChildNoHistory(
                  scene.id,
                  layerId,
                  groupId,
                  selectedId,
                  (c) => c.copyWith(
                    data: c.data.copyWith(
                      transform: c.transform.copyWith(
                        x: c.transform.x + dx,
                        y: c.transform.y + dy,
                      ),
                    ),
                  ),
                );
            ref.read(vecDocumentStateProvider.notifier).commitCurrentState();
            return;
          }
          ref.read(vecDocumentStateProvider.notifier).updateShape(
                scene.id,
                layerId,
                selectedId,
                (shape) => shape.copyWith(
                  data: shape.data.copyWith(
                    transform: shape.transform.copyWith(
                      x: shape.transform.x + dx,
                      y: shape.transform.y + dy,
                    ),
                  ),
                ),
              );
        },
        onSelectAll: () {
          final scene = ref.read(activeSceneProvider);
          final layerId = ref.read(activeLayerIdProvider);
          if (scene == null || layerId == null) return;
          for (final layer in scene.layers) {
            if (layer.id != layerId) continue;
            final ids = layer.shapes.map((s) => s.id).toList();
            if (ids.isEmpty) return;
            ref.read(selectedShapeIdsProvider.notifier).setAll(ids);
            ref.read(selectedShapeIdProvider.notifier).set(ids.last);
            return;
          }
        },
        onDeselectAll: () {
          ref.read(selectedShapeIdProvider.notifier).clear();
          ref.read(selectedShapeIdsProvider.notifier).clear();
        },
        onCopy: () {
          final scene = ref.read(activeSceneProvider);
          final layerId = ref.read(activeLayerIdProvider);
          if (scene == null || layerId == null) return;
          final selectedIds = ref.read(selectedShapeIdsProvider);
          if (selectedIds.isEmpty) return;
          for (final layer in scene.layers) {
            if (layer.id != layerId) continue;
            final shapes = layer.shapes
                .where((s) => selectedIds.contains(s.id))
                .toList();
            if (shapes.isNotEmpty) {
              ref.read(clipboardProvider.notifier).set(shapes);
            }
            return;
          }
        },
        onPaste: () {
          final clipboard = ref.read(clipboardProvider);
          if (clipboard.isEmpty) return;
          final scene = ref.read(activeSceneProvider);
          final layerId = ref.read(activeLayerIdProvider);
          if (scene == null || layerId == null) return;
          final clones = clipboard.map(_cloneShape).toList();
          ref
              .read(vecDocumentStateProvider.notifier)
              .addShapes(scene.id, layerId, clones);
          ref
              .read(selectedShapeIdsProvider.notifier)
              .setAll(clones.map((s) => s.id).toList());
          ref.read(selectedShapeIdProvider.notifier).set(clones.last.id);
        },
        onCut: () {
          final scene = ref.read(activeSceneProvider);
          final layerId = ref.read(activeLayerIdProvider);
          if (scene == null || layerId == null) return;
          final selectedIds = ref.read(selectedShapeIdsProvider);
          if (selectedIds.isEmpty) return;
          // Copy first
          for (final layer in scene.layers) {
            if (layer.id != layerId) continue;
            final shapes = layer.shapes
                .where((s) => selectedIds.contains(s.id))
                .toList();
            if (shapes.isNotEmpty) {
              ref.read(clipboardProvider.notifier).set(shapes);
            }
            break;
          }
          // Remove in one undo step
          ref
              .read(vecDocumentStateProvider.notifier)
              .removeShapes(scene.id, layerId, selectedIds.toList());
          ref.read(selectedShapeIdProvider.notifier).clear();
          ref.read(selectedShapeIdsProvider.notifier).clear();
        },
        onDuplicate: () {
          final scene = ref.read(activeSceneProvider);
          final layerId = ref.read(activeLayerIdProvider);
          if (scene == null || layerId == null) return;
          final selectedIds = ref.read(selectedShapeIdsProvider);
          if (selectedIds.isEmpty) return;
          for (final layer in scene.layers) {
            if (layer.id != layerId) continue;
            final clones = layer.shapes
                .where((s) => selectedIds.contains(s.id))
                .map(_cloneShape)
                .toList();
            if (clones.isEmpty) return;
            ref
                .read(vecDocumentStateProvider.notifier)
                .addShapes(scene.id, layerId, clones);
            ref
                .read(selectedShapeIdsProvider.notifier)
                .setAll(clones.map((s) => s.id).toList());
            ref.read(selectedShapeIdProvider.notifier).set(clones.last.id);
            return;
          }
        },
        onGroup: () {
          final scene = ref.read(activeSceneProvider);
          final layerId = ref.read(activeLayerIdProvider);
          if (scene == null || layerId == null) return;
          final selectedIds = ref.read(selectedShapeIdsProvider);
          if (selectedIds.length < 2) return;
          final groupId = ref
              .read(vecDocumentStateProvider.notifier)
              .groupShapes(scene.id, layerId, selectedIds.toList());
          ref.read(selectedShapeIdProvider.notifier).set(groupId);
          ref.read(selectedShapeIdsProvider.notifier).setSingle(groupId);
        },
        onUngroup: () {
          final scene = ref.read(activeSceneProvider);
          final layerId = ref.read(activeLayerIdProvider);
          if (scene == null || layerId == null) return;
          final selectedId = ref.read(selectedShapeIdProvider);
          if (selectedId == null) return;
          final childIds = ref
              .read(vecDocumentStateProvider.notifier)
              .ungroupShape(scene.id, layerId, selectedId);
          if (childIds.isNotEmpty) {
            ref.read(selectedShapeIdsProvider.notifier).setAll(childIds);
            ref.read(selectedShapeIdProvider.notifier).set(childIds.last);
          } else {
            ref.read(selectedShapeIdProvider.notifier).clear();
            ref.read(selectedShapeIdsProvider.notifier).clear();
          }
        },
        onExport: () {},
        onImport: () {},
        child: WorkspaceLayout(theme: theme),
      ),
    );
  }
}
