import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/tools/drawing_tool_handler.dart';
import '../../providers/document_provider.dart';
import '../../providers/drawing_state_provider.dart';
import '../../providers/editor_state_provider.dart';
import '../../ui/contents/theme_selector.dart';
import '../contents/shortcuts_wrapper.dart';
import '../widgets/workspace/workspace_layout.dart';

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
        onSelectAll: () {},
        onDeselectAll: () => ref.read(selectedShapeIdProvider.notifier).clear(),
        onCopy: () {},
        onPaste: () {},
        onCut: () {},
        onDuplicate: () {},
        onExport: () {},
        onImport: () {},
        child: WorkspaceLayout(theme: theme),
      ),
    );
  }
}
