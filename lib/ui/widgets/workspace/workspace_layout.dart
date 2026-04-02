import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../providers/editor_state_provider.dart';
import '../canvas/editor_canvas.dart';
import '../panels/layers_panel.dart';
import '../panels/properties_panel.dart';
import '../panels/symbols_panel.dart';
import '../panels/timeline_panel.dart';
import '../common/toast_overlay.dart';
import '../toolbar/editor_toolbar.dart';
import '../toolbar/vertical_tool_panel.dart';
import 'mobile_workspace_layout.dart';
import 'scene_tabs_bar.dart';
import 'status_bar.dart';

// Width thresholds for adaptive layout selection.
const _kMobileBreak = 600.0;
const _kTabletBreak = 960.0;

/// Top-level layout switcher.  Selects mobile, tablet, or desktop layout
/// based on the available width provided by [LayoutBuilder].
class WorkspaceLayout extends ConsumerWidget {
  const WorkspaceLayout({super.key, required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width < _kMobileBreak) return MobileWorkspaceLayout(theme: theme);
        if (width < _kTabletBreak) return _TabletWorkspaceLayout(theme: theme);
        return _DesktopWorkspaceLayout(theme: theme);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Desktop layout  (width >= 960)
// Side panels are inline in the row; they collapse to thin strips.
// ---------------------------------------------------------------------------

class _DesktopWorkspaceLayout extends ConsumerWidget {
  const _DesktopWorkspaceLayout({required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final panels = ref.watch(panelVisibilityProvider);
    final timelineHeight = ref.watch(timelineHeightProvider);

    return Stack(
      children: [
        Column(
          children: [
            EditorToolbar(theme: theme),
            Expanded(
              child: Row(
                children: [
                  VerticalToolPanel(theme: theme),
                  if (panels.layers)
                    SizedBox(width: 240, child: _LeftPanel(theme: theme))
                  else
                    _PanelCollapseStrip(
                      label: 'Layers',
                      theme: theme,
                      onTap: () => ref.read(panelVisibilityProvider.notifier).toggleLayers(),
                    ),
                  Expanded(child: EditorCanvas(theme: theme)),
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
            SceneTabsBar(theme: theme),
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
            StatusBar(theme: theme),
          ],
        ),
        const ToastOverlay(),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tablet layout  (600 <= width < 960)
// Canvas takes full width (minus the tool strip). Layers and Properties panels
// slide in as overlays from the edges. Floating toggle buttons follow the
// panel edges using AnimatedPositioned.
// ---------------------------------------------------------------------------

class _TabletWorkspaceLayout extends ConsumerWidget {
  const _TabletWorkspaceLayout({required this.theme});

  final AppTheme theme;

  static const _leftPanelWidth = 220.0;
  static const _rightPanelWidth = 240.0;
  static const _toolPanelWidth = 48.0;
  static const _slideDuration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final panels = ref.watch(panelVisibilityProvider);
    final timelineHeight = ref.watch(timelineHeightProvider);

    return Stack(
      children: [
        Column(
          children: [
            EditorToolbar(theme: theme),
            Expanded(
              child: Stack(
                children: [
                  Row(
                    children: [
                      VerticalToolPanel(theme: theme),
                      Expanded(child: EditorCanvas(theme: theme)),
                    ],
                  ),

                  // Left panel overlay (Layers / Symbols)
                  Positioned(
                    left: _toolPanelWidth,
                    top: 0,
                    bottom: 0,
                    child: SizedBox(
                      width: _leftPanelWidth,
                      child: AnimatedSlide(
                        offset: panels.layers ? Offset.zero : const Offset(-1.0, 0),
                        duration: _slideDuration,
                        curve: Curves.easeOut,
                        child: _ShadowedPanel(
                          side: _PanelSide.left,
                          theme: theme,
                          child: _LeftPanel(theme: theme),
                        ),
                      ),
                    ),
                  ),

                  // Right panel overlay (Properties)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: SizedBox(
                      width: _rightPanelWidth,
                      child: AnimatedSlide(
                        offset: panels.properties ? Offset.zero : const Offset(1.0, 0),
                        duration: _slideDuration,
                        curve: Curves.easeOut,
                        child: _ShadowedPanel(
                          side: _PanelSide.right,
                          theme: theme,
                          child: PropertiesPanel(theme: theme),
                        ),
                      ),
                    ),
                  ),

                  // Floating toggle — Layers
                  AnimatedPositioned(
                    duration: _slideDuration,
                    curve: Curves.easeOut,
                    top: 8,
                    left: panels.layers ? _toolPanelWidth + _leftPanelWidth + 4 : _toolPanelWidth + 4,
                    child: _TabletPanelToggle(
                      icon: panels.layers ? Icons.chevron_left : Icons.layers_outlined,
                      onTap: () => ref.read(panelVisibilityProvider.notifier).toggleLayers(),
                      theme: theme,
                    ),
                  ),

                  // Floating toggle — Properties
                  AnimatedPositioned(
                    duration: _slideDuration,
                    curve: Curves.easeOut,
                    top: 8,
                    right: panels.properties ? _rightPanelWidth + 4 : 4,
                    child: _TabletPanelToggle(
                      icon: panels.properties ? Icons.chevron_right : Icons.tune_outlined,
                      onTap: () => ref.read(panelVisibilityProvider.notifier).toggleProperties(),
                      theme: theme,
                    ),
                  ),
                ],
              ),
            ),
            SceneTabsBar(theme: theme),
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
            StatusBar(theme: theme),
          ],
        ),
        const ToastOverlay(),
      ],
    );
  }
}

// Which edge a panel is attached to — drives shadow direction.
enum _PanelSide { left, right }

/// Panel container with a directional drop shadow for the tablet overlay effect.
class _ShadowedPanel extends StatelessWidget {
  const _ShadowedPanel({required this.side, required this.theme, required this.child});

  final _PanelSide side;
  final AppTheme theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final shadowOffset = side == _PanelSide.left ? const Offset(6, 0) : const Offset(-6, 0);
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(60), blurRadius: 16, offset: shadowOffset)],
      ),
      child: child,
    );
  }
}

/// Small floating icon button used to toggle overlay panels on the tablet layout.
class _TabletPanelToggle extends StatelessWidget {
  const _TabletPanelToggle({required this.icon, required this.onTap, required this.theme});

  final IconData icon;
  final VoidCallback onTap;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.surface,
      borderRadius: BorderRadius.circular(6),
      elevation: 2,
      shadowColor: Colors.black.withAlpha(60),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        hoverColor: theme.primaryColor.withAlpha(18),
        child: SizedBox(width: 28, height: 28, child: Icon(icon, size: 14, color: theme.textSecondary)),
      ),
    );
  }
}

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
            child: _tab == 0 ? LayersPanel(theme: theme) : SymbolsPanel(theme: theme),
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
            border: Border(bottom: BorderSide(color: selected ? theme.accentColor : Colors.transparent, width: 2)),
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
