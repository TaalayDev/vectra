import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../providers/document_provider.dart';
import '../../../providers/editor_state_provider.dart';
import 'frame_grid.dart';
import 'playback_controls.dart';
import 'track_label_column.dart';

class TimelinePanel extends ConsumerWidget {
  const TimelinePanel({
    super.key,
    required this.theme,
    required this.onResizeDrag,
  });

  final AppTheme theme;
  final void Function(double delta) onResizeDrag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scene = ref.watch(activeSceneProvider);
    final timeline = scene?.timeline;
    final layers = scene?.layers ?? [];
    final fps = ref.watch(currentMetaProvider).fps;

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(
          top: BorderSide(color: theme.divider, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          // Resize handle
          MouseRegion(
            cursor: SystemMouseCursors.resizeRow,
            child: GestureDetector(
              onVerticalDragUpdate: (details) => onResizeDrag(details.delta.dy),
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
          PlaybackControls(
            theme: theme,
            fps: fps,
            duration: timeline?.duration ?? 72,
          ),
          // Timeline content
          Expanded(
            child: timeline == null
                ? Center(
                    child: Text(
                      'No timeline',
                      style: TextStyle(fontSize: 11, color: theme.textDisabled),
                    ),
                  )
                : Row(
                    children: [
                      TrackLabelColumn(
                        tracks: timeline.tracks,
                        layers: layers,
                        theme: theme,
                      ),
                      VerticalDivider(
                        width: 1,
                        thickness: 0.5,
                        color: theme.divider,
                      ),
                      Expanded(
                        child: FrameGrid(
                          timeline: timeline,
                          theme: theme,
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
