import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/document_provider.dart';
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
        onUndo: () {},
        onRedo: () {},
        onSave: () => ref.read(vecDocumentStateProvider.notifier).save(),
        onZoomIn: () => ref.read(zoomLevelProvider.notifier).zoomIn(),
        onZoomOut: () => ref.read(zoomLevelProvider.notifier).zoomOut(),
        onZoomFit: () => ref.read(zoomLevelProvider.notifier).zoomFit(),
        onZoom100: () => ref.read(zoomLevelProvider.notifier).zoom100(),
        onToggleUI: () => ref.read(panelVisibilityProvider.notifier).toggleAll(),
        onNewLayer: () {
          final scene = ref.read(activeSceneProvider);
          if (scene != null) {
            ref.read(vecDocumentStateProvider.notifier).addLayer(scene.id);
          }
        },
        onDeleteLayer: () {
          final scene = ref.read(activeSceneProvider);
          final layerId = ref.read(activeLayerIdProvider);
          if (scene != null && layerId != null) {
            ref.read(vecDocumentStateProvider.notifier).removeLayer(scene.id, layerId);
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
