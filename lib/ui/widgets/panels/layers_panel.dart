import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../data/models/vec_layer.dart';
import '../../../data/models/vec_shape.dart';
import '../../../providers/document_provider.dart';
import '../../../providers/editor_state_provider.dart';
import '../common/panel_header.dart';
import 'layer_row.dart';

String _shapeDisplayName(VecShape shape) => shape.map(
      path: (_) => 'Path',
      rectangle: (_) => 'Rectangle',
      ellipse: (_) => 'Ellipse',
      polygon: (_) => 'Polygon',
      text: (s) => s.content.trim().isEmpty ? 'Text' : s.content.trim(),
      group: (_) => 'Group',
      symbolInstance: (_) => 'Symbol',
      compound: (_) => 'Compound',
    );

bool _shapeMatchesQuery(VecShape shape, String query) {
  if ((shape.data.name ?? '').toLowerCase().contains(query)) return true;
  if (_shapeDisplayName(shape).toLowerCase().contains(query)) return true;
  return shape.maybeMap(
    group: (g) => g.children.any((c) => _shapeMatchesQuery(c, query)),
    compound: (c) => c.inputs.any((s) => _shapeMatchesQuery(s, query)),
    orElse: () => false,
  );
}

bool _layerMatchesQuery(VecLayer layer, String query) {
  if (query.isEmpty) return true;
  if (layer.name.toLowerCase().contains(query)) return true;
  return layer.shapes.any((s) => _shapeMatchesQuery(s, query));
}

class LayersPanel extends HookConsumerWidget {
  const LayersPanel({super.key, required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scene = ref.watch(activeSceneProvider);
    final activeLayerId = ref.watch(activeLayerIdProvider);
    final layers = scene?.layers ?? [];

    final searchCtrl = useTextEditingController();
    useListenable(searchCtrl);
    final query = searchCtrl.text.toLowerCase().trim();
    final filteredLayers = query.isEmpty
        ? layers
        : layers.where((l) => _layerMatchesQuery(l, query)).toList();

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
          // Search field
          // ----------------------------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: _SearchField(ctrl: searchCtrl, theme: theme),
          ),

          // ----------------------------------------------------------------
          // Layer list — reorderable (disabled when search is active)
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
                : query.isNotEmpty
                    // ---- Search results: non-reorderable flat list ----
                    ? filteredLayers.isEmpty
                        ? Center(
                            child: Text(
                              'No results',
                              style: TextStyle(
                                  fontSize: 11, color: theme.textDisabled),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            itemCount: filteredLayers.length,
                            itemBuilder: (_, i) {
                              final layer = filteredLayers[
                                  filteredLayers.length - 1 - i];
                              return LayerRow(
                                key: ValueKey(layer.id),
                                layer: layer,
                                sceneId: scene!.id,
                                isActive: layer.id == activeLayerId,
                                theme: theme,
                                index: i,
                              );
                            },
                          )
                    // ---- Normal reorderable list ----
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        buildDefaultDragHandles: false,
                        itemCount: layers.length,
                        onReorder: (oldDisplayIdx, newDisplayIdx) {
                          if (scene == null) return;
                          final n = layers.length;
                          final displayIds = List<String>.generate(
                              n, (i) => layers[n - 1 - i].id);
                          final id = displayIds.removeAt(oldDisplayIdx);
                          final insertAt = newDisplayIdx > oldDisplayIdx
                              ? newDisplayIdx - 1
                              : newDisplayIdx;
                          displayIds.insert(insertAt, id);
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
// Search field
// =============================================================================

class _SearchField extends StatelessWidget {
  const _SearchField({required this.ctrl, required this.theme});

  final TextEditingController ctrl;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      decoration: BoxDecoration(
        color: theme.surfaceVariant,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: theme.divider, width: 0.5),
      ),
      child: Row(
        children: [
          const SizedBox(width: 6),
          Icon(Icons.search, size: 12, color: theme.textDisabled),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: ctrl,
              style: TextStyle(fontSize: 11, color: theme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search layers and shapes…',
                hintStyle: TextStyle(fontSize: 11, color: theme.textDisabled),
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (ctrl.text.isNotEmpty) ...[
            GestureDetector(
              onTap: ctrl.clear,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.close, size: 11, color: theme.textDisabled),
              ),
            ),
          ],
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
