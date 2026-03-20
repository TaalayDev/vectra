import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../providers/document_provider.dart';
import '../../../providers/editor_state_provider.dart';

class StatusBar extends ConsumerWidget {
  const StatusBar({super.key, required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tool = ref.watch(activeToolProvider);
    final cursor = ref.watch(cursorPositionProvider);
    final zoom = ref.watch(zoomLevelProvider);
    final playhead = ref.watch(playheadFrameProvider);
    final scene = ref.watch(activeSceneProvider);
    final duration = scene?.timeline.duration ?? 72;

    return Container(
      height: 24,
      decoration: BoxDecoration(
        color: theme.toolbarColor,
        border: Border(
          top: BorderSide(color: theme.divider, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DefaultTextStyle(
        style: TextStyle(
          fontSize: 10,
          color: theme.textDisabled,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        child: Row(
          children: [
            // Tool name
            Text(
              tool.name[0].toUpperCase() + tool.name.substring(1),
              style: TextStyle(color: theme.textSecondary),
            ),
            const Spacer(),
            // Cursor position
            Text('X: ${cursor.dx.toInt()}  Y: ${cursor.dy.toInt()}'),
            const Spacer(),
            // Zoom
            Text(
              '${(zoom * 100).round()}%',
              style: TextStyle(color: theme.textSecondary),
            ),
            const SizedBox(width: 16),
            // Frame
            Text('${playhead + 1} / $duration'),
          ],
        ),
      ),
    );
  }
}
