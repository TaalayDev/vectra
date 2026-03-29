import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../data/models/vec_shape.dart';
import '../../../providers/document_provider.dart';
import '../../../providers/editor_state_provider.dart';
import '../../../providers/motion_path_provider.dart';
import '../../contents/dialogs/convert_to_symbol_dialog.dart';
import '../common/panel_header.dart';
import 'pathfinder_panel.dart';
import 'properties_sections.dart';
import 'symbol_instance_section.dart';

class PropertiesPanel extends ConsumerWidget {
  const PropertiesPanel({super.key, required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shape = ref.watch(selectedShapeProvider);
    final selectedIds = ref.watch(selectedShapeIdsProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(left: BorderSide(color: theme.divider, width: 0.5)),
      ),
      child: Column(
        children: [
          PanelHeader(
            title: selectedIds.length >= 2
                ? '${selectedIds.length} Selected'
                : shape != null
                    ? _shapeTypeName(shape)
                    : 'Properties',
            theme: theme,
          ),
          Expanded(
            child: shape == null && selectedIds.length < 2
                ? _buildEmptyState()
                : _buildSections(context, ref, shape, selectedIds),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Empty state
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.touch_app_outlined, size: 32, color: theme.textDisabled.withAlpha(80)),
          const SizedBox(height: 8),
          Text('No selection', style: TextStyle(fontSize: 12, color: theme.textDisabled)),
          const SizedBox(height: 4),
          Text(
            'Select a shape to see\nits properties',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: theme.textDisabled.withAlpha(120)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sections with real callbacks
  // ---------------------------------------------------------------------------

  Widget _buildSections(BuildContext context, WidgetRef ref, VecShape? shape, List<String> selectedIds) {
    final scene = ref.watch(activeSceneProvider);
    final layerId = ref.watch(activeLayerIdProvider);
    final docNotifier = ref.read(vecDocumentStateProvider.notifier);
    final motionPath = ref.watch(selectedShapeMotionPathProvider);
    final drawTarget = ref.watch(motionPathDrawTargetProvider);

    if (scene == null || layerId == null) return const SizedBox.shrink();
    final sceneId = scene.id;

    // Multi-selection: show dedicated multi-select panel
    if (selectedIds.length >= 2) {
      return _buildMultiSections(ref, scene, layerId, sceneId, docNotifier, selectedIds);
    }

    // Edge case: selectedIds >= 2 but shape == null already handled above
    if (shape == null) return const SizedBox.shrink();

    // Committed update — goes to undo history
    void onUpdate(VecShape Function(VecShape) updater) {
      docNotifier.updateShape(sceneId, layerId, shape.id, updater);
    }

    // Live update — no undo entry (used during slider drag)
    void onLiveUpdate(VecShape Function(VecShape) updater) {
      docNotifier.updateShapeNoHistory(sceneId, layerId, shape.id, updater);
    }

    // Commit current state after live drag ends
    void onCommit() {
      docNotifier.commitCurrentState();
    }

    final isSymbolInstance = shape.maybeMap(symbolInstance: (_) => true, orElse: () => false);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 4),
      children: [
        TransformSection(
          transform: shape.transform,
          opacity: shape.opacity,
          theme: theme,
          onUpdate: onUpdate,
          onLiveUpdate: onLiveUpdate,
          onCommit: onCommit,
        ),
        // Corner radius — rectangles only
        ...shape.maybeMap(
          rectangle: (r) => [
            Divider(height: 1, color: theme.divider.withAlpha(60)),
            CornerSection(shape: r, theme: theme, onUpdate: onUpdate),
          ],
          orElse: () => const <Widget>[],
        ),
        // Arc / Donut — ellipses only
        ...shape.maybeMap(
          ellipse: (e) => [
            Divider(height: 1, color: theme.divider.withAlpha(60)),
            EllipseSection(
              shape: e,
              theme: theme,
              onUpdate: onUpdate,
              onLiveUpdate: onLiveUpdate,
              onCommit: onCommit,
            ),
          ],
          orElse: () => const <Widget>[],
        ),
        // Polygon sides + star depth — polygons only
        ...shape.maybeMap(
          polygon: (p) => [
            Divider(height: 1, color: theme.divider.withAlpha(60)),
            PolygonSection(
              shape: p,
              theme: theme,
              onUpdate: onUpdate,
              onLiveUpdate: onLiveUpdate,
              onCommit: onCommit,
            ),
          ],
          orElse: () => const <Widget>[],
        ),
        // Text properties — text shapes only
        ...shape.maybeMap(
          text: (t) => [
            Divider(height: 1, color: theme.divider.withAlpha(60)),
            TextSection(shape: t, theme: theme, onUpdate: onUpdate),
          ],
          orElse: () => const <Widget>[],
        ),
        PathfinderPanel(theme: theme),
        Divider(height: 1, color: theme.divider.withAlpha(60)),

        // Symbol instance: show instance-specific controls instead of fills/strokes
        if (isSymbolInstance) ...[
          SymbolInstanceSection(
            shape: shape as VecSymbolInstanceShape,
            theme: theme,
            onUpdate: onUpdate,
            onLiveUpdate: onLiveUpdate,
            onCommit: onCommit,
          ),
        ] else ...[
          FillSection(
            fills: shape.fills,
            theme: theme,
            onUpdate: onUpdate,
            onLiveUpdate: onLiveUpdate,
            onCommit: onCommit,
          ),
          Divider(height: 1, color: theme.divider.withAlpha(60)),
          StrokeSection(
            strokes: shape.strokes,
            theme: theme,
            onUpdate: onUpdate,
            onLiveUpdate: onLiveUpdate,
            onCommit: onCommit,
          ),
          Divider(height: 1, color: theme.divider.withAlpha(60)),
          BlendSection(blendMode: shape.blendMode, theme: theme, onUpdate: onUpdate),
          Divider(height: 1, color: theme.divider.withAlpha(60)),
          MotionPathSection(
            shapeId: shape.id,
            motionPath: motionPath,
            isDrawing: drawTarget == shape.id,
            theme: theme,
            onStartDraw: () {
              ref.read(motionPathPreviewNodesProvider.notifier).clear();
              ref.read(motionPathDrawTargetProvider.notifier).start(shape.id);
            },
            onRemove: () {
              if (motionPath != null) {
                docNotifier.removeMotionPath(sceneId, motionPath.id);
              }
            },
            onToggleOrient: () {
              if (motionPath != null) {
                docNotifier.updateMotionPath(sceneId, motionPath.id,
                    (mp) => mp.copyWith(orientToPath: !mp.orientToPath));
              }
            },
            onToggleEase: () {
              if (motionPath != null) {
                docNotifier.updateMotionPath(sceneId, motionPath.id,
                    (mp) => mp.copyWith(easeAlongPath: !mp.easeAlongPath));
              }
            },
          ),
          Divider(height: 1, color: theme.divider.withAlpha(60)),
          _ConvertToSymbolButton(
            theme: theme,
            shape: shape,
            sceneId: sceneId,
            layerId: layerId,
            selectedIds: selectedIds,
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Multi-selection panel
  // ---------------------------------------------------------------------------

  Widget _buildMultiSections(
    WidgetRef ref,
    dynamic scene,
    String layerId,
    String sceneId,
    dynamic docNotifier,
    List<String> selectedIds,
  ) {
    // Gather the selected shapes from the scene
    final selectedShapes = <dynamic>[];
    for (final layer in scene.layers) {
      for (final shape in layer.shapes) {
        if (selectedIds.contains(shape.id)) selectedShapes.add(shape);
      }
    }

    // Compute average opacity across selected shapes
    final avgOpacity = selectedShapes.isEmpty
        ? 1.0
        : selectedShapes.fold<double>(0, (sum, s) => sum + (s.opacity as double)) /
            selectedShapes.length;

    void applyToAll(VecShape Function(VecShape) updater) {
      for (final id in selectedIds) {
        docNotifier.updateShapeNoHistory(sceneId, layerId, id, updater);
      }
      docNotifier.commitCurrentState();
    }

    void liveApplyToAll(VecShape Function(VecShape) updater) {
      for (final id in selectedIds) {
        docNotifier.updateShapeNoHistory(sceneId, layerId, id, updater);
      }
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // Info row
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
          child: Row(
            children: [
              Icon(Icons.select_all_outlined, size: 14, color: theme.textDisabled),
              const SizedBox(width: 6),
              Text(
                '${selectedIds.length} shapes selected',
                style: TextStyle(fontSize: 11, color: theme.textDisabled),
              ),
            ],
          ),
        ),

        Divider(height: 1, color: theme.divider.withAlpha(60)),

        // Opacity
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Opacity',
                style: TextStyle(
                    fontSize: 10,
                    color: theme.textDisabled,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: PanelSlider(
                      value: avgOpacity.clamp(0.0, 1.0),
                      theme: theme,
                      onChanged: (v) => liveApplyToAll(
                        (s) => s.copyWith(data: s.data.copyWith(opacity: v)),
                      ),
                      onChangeEnd: (_) => docNotifier.commitCurrentState(),
                    ),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '${(avgOpacity * 100).round()}%',
                      style: TextStyle(fontSize: 10, color: theme.textDisabled),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Divider(height: 1, color: theme.divider.withAlpha(60)),

        // Nudge position
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Move All',
                style: TextStyle(
                    fontSize: 10,
                    color: theme.textDisabled,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _NudgeButton(
                    label: '← −10',
                    theme: theme,
                    onTap: () => applyToAll((s) => s.copyWith(
                          data: s.data.copyWith(
                              transform: s.transform
                                  .copyWith(x: s.transform.x - 10)),
                        )),
                  ),
                  const SizedBox(width: 4),
                  _NudgeButton(
                    label: '→ +10',
                    theme: theme,
                    onTap: () => applyToAll((s) => s.copyWith(
                          data: s.data.copyWith(
                              transform: s.transform
                                  .copyWith(x: s.transform.x + 10)),
                        )),
                  ),
                  const SizedBox(width: 8),
                  _NudgeButton(
                    label: '↑ −10',
                    theme: theme,
                    onTap: () => applyToAll((s) => s.copyWith(
                          data: s.data.copyWith(
                              transform: s.transform
                                  .copyWith(y: s.transform.y - 10)),
                        )),
                  ),
                  const SizedBox(width: 4),
                  _NudgeButton(
                    label: '↓ +10',
                    theme: theme,
                    onTap: () => applyToAll((s) => s.copyWith(
                          data: s.data.copyWith(
                              transform: s.transform
                                  .copyWith(y: s.transform.y + 10)),
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),

        Divider(height: 1, color: theme.divider.withAlpha(60)),
        PathfinderPanel(theme: theme),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _shapeTypeName(VecShape shape) {
    return shape.map(
      path: (_) => 'Path',
      rectangle: (_) => 'Rectangle',
      ellipse: (_) => 'Ellipse',
      polygon: (_) => 'Polygon',
      text: (_) => 'Text',
      group: (_) => 'Group',
      symbolInstance: (_) => 'Symbol',
      compound: (s) => '${s.op.name[0].toUpperCase()}${s.op.name.substring(1)}',
    );
  }
}

// ---------------------------------------------------------------------------
// Convert to Symbol button
// ---------------------------------------------------------------------------

class _ConvertToSymbolButton extends ConsumerWidget {
  const _ConvertToSymbolButton({
    required this.theme,
    required this.shape,
    required this.sceneId,
    required this.layerId,
    required this.selectedIds,
  });

  final AppTheme theme;
  final VecShape shape;
  final String sceneId;
  final String layerId;
  final List<String> selectedIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          icon: Icon(Icons.widgets_outlined, size: 14, color: theme.accentColor),
          label: Text(
            'Convert to Symbol',
            style: TextStyle(fontSize: 11, color: theme.accentColor),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: theme.accentColor.withAlpha(100)),
            padding: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          onPressed: () async {
            // Determine which shapes to convert — if multi-selected use all,
            // otherwise just the single shape.
            final idsToConvert = selectedIds.length > 1 ? selectedIds : [shape.id];
            final defaultName = shape.name ?? 'Symbol ${DateTime.now().millisecondsSinceEpoch % 1000}';

            final result = await ConvertToSymbolDialog.show(
              context,
              theme,
              defaultName: defaultName,
            );
            if (result == null) return;

            ref.read(vecDocumentStateProvider.notifier).convertToSymbol(
              sceneId,
              layerId,
              idsToConvert,
              result.name,
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Nudge button for multi-select panel
// ---------------------------------------------------------------------------

class _NudgeButton extends StatelessWidget {
  const _NudgeButton({required this.label, required this.theme, required this.onTap});

  final String label;
  final AppTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            color: theme.surfaceVariant,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: theme.divider, width: 0.5),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 10, color: theme.textSecondary),
          ),
        ),
      ),
    );
  }
}
