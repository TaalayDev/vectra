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
          PanelHeader(
            title: 'Layers',
            theme: theme,
            trailing: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (scene != null) {
                    ref.read(vecDocumentStateProvider.notifier).addLayer(scene.id);
                  }
                },
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(Icons.add, size: 14, color: theme.textSecondary),
                ),
              ),
            ),
          ),
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
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    itemCount: layers.length,
                    itemBuilder: (_, index) {
                      // Show layers in reverse order (top layer first)
                      final layer = layers[layers.length - 1 - index];
                      return LayerRow(
                        layer: layer,
                        sceneId: scene!.id,
                        isActive: layer.id == activeLayerId,
                        theme: theme,
                      );
                    },
                  ),
          ),
          // Scene indicator
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
                  Icon(Icons.movie_outlined, size: 12, color: theme.textDisabled),
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
