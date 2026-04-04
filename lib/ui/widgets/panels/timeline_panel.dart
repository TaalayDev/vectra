import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../data/models/vec_shape.dart';
import '../../../providers/document_provider.dart';
import '../../../providers/editor_state_provider.dart';
import 'animation_presets_panel.dart';
import 'frame_grid.dart';
import 'graph_editor_panel.dart';
import 'playback_controls.dart';
import 'track_label_column.dart';

class TimelinePanel extends ConsumerStatefulWidget {
  const TimelinePanel({super.key, required this.theme, required this.onResizeDrag});

  final AppTheme theme;
  final void Function(double delta) onResizeDrag;

  @override
  ConsumerState<TimelinePanel> createState() => _TimelinePanelState();
}

class _TimelinePanelState extends ConsumerState<TimelinePanel> {
  final _labelScroll = ScrollController();
  final _gridHScroll = ScrollController();

  @override
  void dispose() {
    _labelScroll.dispose();
    _gridHScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scene = ref.watch(activeSceneProvider); // raw doc scene for editing
    final timeline = scene?.timeline;
    final layers = scene?.layers ?? [];
    final fps = ref.watch(currentMetaProvider).fps;
    final theme = widget.theme;
    final graphVisible = ref.watch(graphEditorVisibleProvider);

    // Build per-shape rows from all visible layers
    final rows = <TrackRow>[];
    for (final layer in layers) {
      if (!layer.visible) continue;
      for (final shape in layer.shapes) {
        rows.add(
          TrackRow(
            layerId: layer.id,
            shapeId: shape.id,
            name: shape.name ?? _shapeName(shape),
            icon: _shapeIcon(shape),
          ),
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(top: BorderSide(color: theme.divider, width: 0.5)),
      ),
      child: Column(
        children: [
          // Resize handle
          MouseRegion(
            cursor: SystemMouseCursors.resizeRow,
            child: GestureDetector(
              onVerticalDragUpdate: (d) => widget.onResizeDrag(d.delta.dy),
              child: Container(
                height: 5,
                color: theme.surfaceVariant,
                child: Center(
                  child: Container(
                    width: 32,
                    height: 3,
                    decoration: BoxDecoration(
                      color: theme.textDisabled.withAlpha(60),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Playback controls
          Row(
            children: [
              Expanded(
                child: PlaybackControls(theme: theme, fps: fps, duration: timeline?.duration ?? 72),
              ),
              // Graph editor toggle
              Tooltip(
                message: 'Graph Editor',
                child: InkWell(
                  onTap: () => ref.read(graphEditorVisibleProvider.notifier).toggle(),
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    color: graphVisible ? theme.accentColor.withAlpha(30) : Colors.transparent,
                    child: Icon(
                      Icons.show_chart,
                      size: 15,
                      color: graphVisible ? theme.accentColor : theme.textDisabled,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              // Animation presets
              Tooltip(
                message: 'Animation Presets',
                child: InkWell(
                  onTap: () => _openAnimationPresets(context, theme),
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    child: Icon(Icons.auto_awesome, size: 15, color: theme.textDisabled),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              // Collapse timeline
              Tooltip(
                message: 'Hide Timeline',
                child: InkWell(
                  onTap: () => ref.read(panelVisibilityProvider.notifier).toggleTimeline(),
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    child: Icon(Icons.keyboard_arrow_down, size: 16, color: theme.textDisabled),
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),

          // Timeline content
          Expanded(
            child: timeline == null
                ? Center(
                    child: Text('No timeline', style: TextStyle(fontSize: 11, color: theme.textDisabled)),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Label column
                            TrackLabelColumn(rows: rows, theme: theme, scrollController: _labelScroll),
                            VerticalDivider(width: 1, thickness: 0.5, color: theme.divider),
                            // Frame grid
                            Expanded(
                              child: FrameGrid(
                                timeline: timeline,
                                rows: rows,
                                theme: theme,
                                scrollController: _gridHScroll,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (graphVisible)
                        GraphEditorPanel(theme: theme, timeline: timeline, rows: rows, scrollController: _gridHScroll),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAnimationPresets(BuildContext context, AppTheme theme) async {
    final width = MediaQuery.sizeOf(context).width;
    final useBottomSheet = width < 900;

    if (useBottomSheet) {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.88,
          builder: (sheetCtx, scrollCtrl) => AnimationPresetsPanel(theme: theme),
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AnimationPresetsPanel(theme: theme),
          ),
        ),
      ),
    );
  }

  static String _shapeName(VecShape shape) => shape.map(
    path: (_) => 'Path',
    rectangle: (_) => 'Rectangle',
    ellipse: (_) => 'Ellipse',
    polygon: (_) => 'Polygon',
    text: (s) => s.content.isNotEmpty ? s.content.split('\n').first : 'Text',
    group: (_) => 'Group',
    symbolInstance: (_) => 'Symbol',
    compound: (_) => 'Compound',
    image: (_) => 'Image',
  );

  static IconData _shapeIcon(VecShape shape) => shape.map(
    path: (_) => Icons.gesture,
    rectangle: (_) => Icons.crop_square,
    ellipse: (_) => Icons.circle_outlined,
    polygon: (_) => Icons.change_history,
    text: (_) => Icons.text_fields,
    group: (_) => Icons.folder_outlined,
    symbolInstance: (_) => Icons.link,
    compound: (_) => Icons.join_inner,
    image: (_) => Icons.image_outlined,
  );
}
