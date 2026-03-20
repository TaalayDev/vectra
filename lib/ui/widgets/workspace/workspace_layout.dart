import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../providers/editor_state_provider.dart';
import '../canvas/editor_canvas.dart';
import '../panels/layers_panel.dart';
import '../panels/properties_panel.dart';
import '../panels/timeline_panel.dart';
import '../toolbar/editor_toolbar.dart';
import 'status_bar.dart';

class WorkspaceLayout extends ConsumerWidget {
  const WorkspaceLayout({super.key, required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final panels = ref.watch(panelVisibilityProvider);
    final timelineHeight = ref.watch(timelineHeightProvider);

    return Column(
      children: [
        // Toolbar
        EditorToolbar(theme: theme),

        // Main content area
        Expanded(
          child: Row(
            children: [
              // Left: Layers panel or collapse strip
              if (panels.layers)
                SizedBox(
                  width: 240,
                  child: LayersPanel(theme: theme),
                )
              else
                _PanelCollapseStrip(
                  label: 'Layers',
                  theme: theme,
                  onTap: () => ref.read(panelVisibilityProvider.notifier).toggleLayers(),
                ),

              // Center: Canvas
              Expanded(
                child: EditorCanvas(theme: theme),
              ),

              // Right: Properties panel or collapse strip
              if (panels.properties)
                SizedBox(
                  width: 280,
                  child: PropertiesPanel(theme: theme),
                )
              else
                _PanelCollapseStrip(
                  label: 'Properties',
                  theme: theme,
                  onTap: () => ref.read(panelVisibilityProvider.notifier).toggleProperties(),
                  alignRight: true,
                ),
            ],
          ),
        ),

        // Bottom: Timeline or collapse strip
        if (panels.timeline)
          SizedBox(
            height: timelineHeight,
            child: TimelinePanel(
              theme: theme,
              onResizeDrag: (delta) {
                ref.read(timelineHeightProvider.notifier).set(timelineHeight - delta);
              },
            ),
          )
        else
          _HorizontalCollapseStrip(
            label: 'Timeline',
            theme: theme,
            onTap: () => ref.read(panelVisibilityProvider.notifier).toggleTimeline(),
          ),

        // Status bar
        StatusBar(theme: theme),
      ],
    );
  }
}

/// Vertical collapse strip for side panels (24px wide).
class _PanelCollapseStrip extends StatelessWidget {
  const _PanelCollapseStrip({
    required this.label,
    required this.theme,
    required this.onTap,
    this.alignRight = false,
  });

  final String label;
  final AppTheme theme;
  final VoidCallback onTap;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: 24,
          decoration: BoxDecoration(
            color: theme.surfaceVariant,
            border: Border(
              left: alignRight
                  ? BorderSide(color: theme.divider, width: 0.5)
                  : BorderSide.none,
              right: !alignRight
                  ? BorderSide(color: theme.divider, width: 0.5)
                  : BorderSide.none,
            ),
          ),
          child: Center(
            child: RotatedBox(
              quarterTurns: alignRight ? 1 : 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      alignRight ? Icons.chevron_left : Icons.chevron_right,
                      size: 10,
                      color: theme.textDisabled,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: theme.textDisabled,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontal collapse strip for the timeline (24px tall).
class _HorizontalCollapseStrip extends StatelessWidget {
  const _HorizontalCollapseStrip({
    required this.label,
    required this.theme,
    required this.onTap,
  });

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
          height: 24,
          decoration: BoxDecoration(
            color: theme.surfaceVariant,
            border: Border(
              top: BorderSide(color: theme.divider, width: 0.5),
            ),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.expand_less, size: 12, color: theme.textDisabled),
                const SizedBox(width: 4),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: theme.textDisabled,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
