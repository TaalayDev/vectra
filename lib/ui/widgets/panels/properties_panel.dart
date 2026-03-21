import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../data/models/vec_shape.dart';
import '../../../providers/document_provider.dart';
import '../../../providers/editor_state_provider.dart';
import '../../../providers/motion_path_provider.dart';
import '../common/panel_header.dart';
import 'pathfinder_panel.dart';
import 'properties_sections.dart';

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
          PanelHeader(title: shape != null ? _shapeTypeName(shape) : 'Properties', theme: theme),
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

    // When only multi-selection (no single shape), show pathfinder only
    if (shape == null) {
      return ListView(
        padding: const EdgeInsets.symmetric(vertical: 4),
        children: [PathfinderPanel(theme: theme)],
      );
    }

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
        PathfinderPanel(theme: theme),
        Divider(height: 1, color: theme.divider.withAlpha(60)),
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
