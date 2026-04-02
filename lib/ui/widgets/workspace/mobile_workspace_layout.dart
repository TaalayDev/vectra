import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../providers/document_provider.dart';
import '../../../providers/editor_state_provider.dart';
import '../../contents/dialogs/export_dialog.dart';
import '../canvas/editor_canvas.dart';
import '../common/toast_overlay.dart';
import '../panels/layers_panel.dart';
import '../panels/properties_panel.dart';
import '../toolbar/bottom_tool_panel.dart';

/// Full-screen editor layout for narrow mobile screens (width < 600).
///
/// Canvas occupies the space between the compact top bar and the bottom tool
/// strip.  Layers and Properties panels open as draggable bottom sheets.
class MobileWorkspaceLayout extends ConsumerWidget {
  const MobileWorkspaceLayout({super.key, required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Column(
          children: [
            _MobileTopBar(theme: theme),
            Expanded(child: EditorCanvas(theme: theme)),
            BottomToolPanel(theme: theme),
          ],
        ),
        const ToastOverlay(),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Compact top bar
// ---------------------------------------------------------------------------

class _MobileTopBar extends ConsumerWidget {
  const _MobileTopBar({required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = ref.watch(currentMetaProvider);
    final availability = ref.watch(undoAvailabilityProvider);

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: theme.toolbarColor,
        border: Border(bottom: BorderSide(color: theme.divider, width: 0.5)),
      ),
      child: Row(
        children: [
          _TopBarBtn(icon: Icons.arrow_back, theme: theme, onTap: () => Navigator.maybePop(context)),
          Expanded(
            child: Text(
              meta.name,
              style: TextStyle(fontSize: 13, color: theme.textPrimary, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          _TopBarBtn(
            icon: Icons.undo,
            theme: theme,
            onTap: availability.canUndo ? () => ref.read(vecDocumentStateProvider.notifier).undo() : null,
          ),
          _TopBarBtn(
            icon: Icons.redo,
            theme: theme,
            onTap: availability.canRedo ? () => ref.read(vecDocumentStateProvider.notifier).redo() : null,
          ),
          _TopBarBtn(
            icon: Icons.layers_outlined,
            theme: theme,
            onTap: () => _showSheet(context, 'Layers', 0.55, LayersPanel(theme: theme)),
          ),
          _TopBarBtn(
            icon: Icons.tune_outlined,
            theme: theme,
            onTap: () => _showSheet(context, 'Properties', 0.7, PropertiesPanel(theme: theme)),
          ),
          _TopBarBtn(icon: Icons.upload_rounded, theme: theme, onTap: () => ExportDialog.show(context)),
        ],
      ),
    );
  }

  void _showSheet(BuildContext context, String title, double initialSize, Widget content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PanelSheet(title: title, initialSize: initialSize, theme: theme, child: content),
    );
  }
}

class _TopBarBtn extends StatelessWidget {
  const _TopBarBtn({required this.icon, required this.theme, this.onTap});

  final IconData icon;
  final AppTheme theme;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 40,
        height: 44,
        child: Icon(icon, size: 20, color: onTap != null ? theme.textSecondary : theme.textDisabled.withAlpha(80)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Draggable bottom sheet container used for Layers and Properties panels
// ---------------------------------------------------------------------------

class _PanelSheet extends StatelessWidget {
  const _PanelSheet({required this.title, required this.initialSize, required this.theme, required this.child});

  final String title;
  final double initialSize;
  final AppTheme theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: initialSize,
      minChildSize: 0.3,
      maxChildSize: 0.92,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(60), blurRadius: 20, offset: const Offset(0, -4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SheetHandle(theme: theme),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
              child: Text(
                title,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: theme.textPrimary),
              ),
            ),
            Divider(color: theme.divider, height: 1),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle({required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(color: theme.divider, borderRadius: BorderRadius.circular(2)),
        ),
      ),
    );
  }
}
