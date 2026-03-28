import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../providers/editor_state_provider.dart';
import '../canvas/editor_canvas.dart';
import '../panels/layers_panel.dart';
import '../panels/properties_panel.dart';
import '../panels/symbols_panel.dart';
import '../panels/timeline_panel.dart';
import '../toolbar/editor_toolbar.dart';
import 'scene_tabs_bar.dart';
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
              // Left: Layers/Symbols tabbed panel or collapse strip
              if (panels.layers)
                SizedBox(width: 240, child: _LeftPanel(theme: theme))
              else
                _PanelCollapseStrip(
                  label: 'Layers',
                  theme: theme,
                  onTap: () => ref.read(panelVisibilityProvider.notifier).toggleLayers(),
                ),

              // Center: Canvas
              Expanded(child: EditorCanvas(theme: theme)),

              // Right: Properties panel or collapse strip
              if (panels.properties)
                SizedBox(width: 280, child: PropertiesPanel(theme: theme))
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

        // Scene tabs bar
        SceneTabsBar(theme: theme),

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

// ---------------------------------------------------------------------------
// Left panel — Layers / Symbols tab switcher
// ---------------------------------------------------------------------------

class _LeftPanel extends ConsumerStatefulWidget {
  const _LeftPanel({required this.theme});
  final AppTheme theme;

  @override
  ConsumerState<_LeftPanel> createState() => _LeftPanelState();
}

class _LeftPanelState extends ConsumerState<_LeftPanel> {
  int _tab = 0; // 0=Layers, 1=Symbols

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(right: BorderSide(color: theme.divider, width: 0.5)),
      ),
      child: Column(
        children: [
          // Tab bar
          Container(
            height: 28,
            decoration: BoxDecoration(
              color: theme.surfaceVariant,
              border: Border(bottom: BorderSide(color: theme.divider, width: 0.5)),
            ),
            child: Row(
              children: [
                _Tab(label: 'Layers', selected: _tab == 0, theme: theme, onTap: () => setState(() => _tab = 0)),
                _Tab(label: 'Symbols', selected: _tab == 1, theme: theme, onTap: () => setState(() => _tab = 1)),
              ],
            ),
          ),
          Expanded(
            child: _tab == 0
                ? LayersPanel(theme: theme)
                : SymbolsPanel(theme: theme),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.selected, required this.theme, required this.onTap});

  final String label;
  final bool selected;
  final AppTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? theme.accentColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: selected ? theme.accentColor : theme.textDisabled,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Vertical collapse strip for side panels (24px wide).
class _PanelCollapseStrip extends StatelessWidget {
  const _PanelCollapseStrip({required this.label, required this.theme, required this.onTap, this.alignRight = false});

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
              left: alignRight ? BorderSide(color: theme.divider, width: 0.5) : BorderSide.none,
              right: !alignRight ? BorderSide(color: theme.divider, width: 0.5) : BorderSide.none,
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
                    Icon(alignRight ? Icons.chevron_left : Icons.chevron_right, size: 10, color: theme.textDisabled),
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
  const _HorizontalCollapseStrip({required this.label, required this.theme, required this.onTap});

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
            border: Border(top: BorderSide(color: theme.divider, width: 0.5)),
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
