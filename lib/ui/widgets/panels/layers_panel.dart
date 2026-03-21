import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../providers/document_provider.dart';
import '../../../providers/editor_state_provider.dart';
import '../common/panel_header.dart';
import 'layer_row.dart';

class LayersPanel extends ConsumerWidget {
  const LayersPanel({super.key, required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scene = ref.watch(activeSceneProvider);
    final activeLayerId = ref.watch(activeLayerIdProvider);
    final layers = scene?.layers ?? [];

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(
          right: BorderSide(color: theme.divider, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          // ----------------------------------------------------------------
          // Header: title + add + delete buttons
          // ----------------------------------------------------------------
          PanelHeader(
            title: 'Layers',
            theme: theme,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Delete active layer (disabled when only one layer left)
                if (activeLayerId != null && layers.length > 1)
                  _HeaderButton(
                    icon: Icons.delete_outline,
                    color: theme.error,
                    tooltip: 'Delete layer',
                    onTap: () {
                      ref
                          .read(vecDocumentStateProvider.notifier)
                          .removeLayer(scene!.id, activeLayerId);
                      // Switch to first remaining layer
                      final remaining =
                          layers.where((l) => l.id != activeLayerId).toList();
                      if (remaining.isNotEmpty) {
                        ref
                            .read(activeLayerIdProvider.notifier)
                            .set(remaining.last.id);
                      }
                    },
                  ),

                // Add layer
                _HeaderButton(
                  icon: Icons.add,
                  color: theme.textSecondary,
                  tooltip: 'Add layer',
                  onTap: () {
                    if (scene != null) {
                      ref
                          .read(vecDocumentStateProvider.notifier)
                          .addLayer(scene.id);
                    }
                  },
                ),
              ],
            ),
          ),

          // ----------------------------------------------------------------
          // Layer list — reorderable
          // ----------------------------------------------------------------
          Expanded(
            child: layers.isEmpty
                ? Center(
                    child: Text(
                      'No layers',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textDisabled,
                      ),
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    buildDefaultDragHandles: false,
                    itemCount: layers.length,
                    onReorder: (oldDisplayIdx, newDisplayIdx) {
                      if (scene == null) return;
                      // Layers are displayed in reverse order: display[i] = actual[n-1-i]
                      // Build the new display-order ID list, perform the move, then reverse.
                      final n = layers.length;
                      final displayIds = List<String>.generate(
                          n, (i) => layers[n - 1 - i].id);
                      final id = displayIds.removeAt(oldDisplayIdx);
                      final insertAt = newDisplayIdx > oldDisplayIdx
                          ? newDisplayIdx - 1
                          : newDisplayIdx;
                      displayIds.insert(insertAt, id);
                      // Reverse back to actual order for the provider
                      final actualIds = displayIds.reversed.toList();
                      ref
                          .read(vecDocumentStateProvider.notifier)
                          .reorderLayers(scene.id, actualIds);
                    },
                    itemBuilder: (_, displayIdx) {
                      final n = layers.length;
                      final layer = layers[n - 1 - displayIdx];
                      return LayerRow(
                        key: ValueKey(layer.id),
                        layer: layer,
                        sceneId: scene!.id,
                        isActive: layer.id == activeLayerId,
                        theme: theme,
                        index: displayIdx,
                      );
                    },
                  ),
          ),

          // ----------------------------------------------------------------
          // Scene indicator
          // ----------------------------------------------------------------
          if (scene != null)
            Container(
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: theme.surfaceVariant,
                border: Border(
                  top: BorderSide(color: theme.divider, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.movie_outlined,
                      size: 12, color: theme.textDisabled),
                  const SizedBox(width: 6),
                  Text(
                    scene.name,
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.textDisabled,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// Small header button
// =============================================================================

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 600),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Icon(icon, size: 14, color: color),
          ),
        ),
      ),
    );
  }
}
