import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../data/models/vec_color.dart';
import '../../../providers/document_provider.dart';
import '../../../providers/editor_state_provider.dart';
import '../common/color_picker.dart';

/// Horizontal tool strip shown at the bottom of the editor on mobile screens.
/// Contains undo/redo, scrollable tool buttons, and fill/stroke color swatches.
class BottomToolPanel extends ConsumerWidget {
  const BottomToolPanel({super.key, required this.theme});

  final AppTheme theme;

  static const _tools = [
    (VecTool.select, Icons.near_me_outlined, 'Select'),
    (VecTool.pen, Icons.mode_edit_outline, 'Pen'),
    (VecTool.line, Icons.horizontal_rule, 'Line'),
    (VecTool.rectangle, Icons.rectangle_outlined, 'Rectangle'),
    (VecTool.ellipse, Icons.circle_outlined, 'Ellipse'),
    (VecTool.text, Icons.text_fields, 'Text'),
    (VecTool.bend, Icons.architecture, 'Bend'),
    (VecTool.knife, Icons.content_cut_outlined, 'Knife'),
    (VecTool.freedraw, Icons.brush_outlined, 'Free Draw'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTool = ref.watch(activeToolProvider);
    final availability = ref.watch(undoAvailabilityProvider);

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: theme.toolbarColor,
        border: Border(top: BorderSide(color: theme.divider, width: 0.5)),
      ),
      child: Row(
        children: [
          _ActionBtn(
            icon: Icons.undo,
            enabled: availability.canUndo,
            onTap: () => ref.read(vecDocumentStateProvider.notifier).undo(),
            theme: theme,
          ),
          _ActionBtn(
            icon: Icons.redo,
            enabled: availability.canRedo,
            onTap: () => ref.read(vecDocumentStateProvider.notifier).redo(),
            theme: theme,
          ),
          Container(width: 0.5, height: 32, color: theme.divider),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  for (final (tool, icon, label) in _tools)
                    _ToolToggleBtn(
                      icon: icon,
                      tooltip: label,
                      isActive: activeTool == tool,
                      onTap: () => ref.read(activeToolProvider.notifier).set(tool),
                      theme: theme,
                    ),
                ],
              ),
            ),
          ),
          Container(width: 0.5, height: 32, color: theme.divider),
          _ColorSection(theme: theme),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({required this.icon, required this.onTap, required this.theme, this.enabled = true});

  final IconData icon;
  final VoidCallback onTap;
  final AppTheme theme;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: SizedBox(
        width: 44,
        height: 56,
        child: Icon(icon, size: 20, color: enabled ? theme.textSecondary : theme.textDisabled.withAlpha(80)),
      ),
    );
  }
}

class _ToolToggleBtn extends StatelessWidget {
  const _ToolToggleBtn({
    required this.icon,
    required this.tooltip,
    required this.isActive,
    required this.onTap,
    required this.theme,
  });

  final IconData icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback onTap;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 600),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 56,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isActive ? theme.primaryColor.withAlpha(25) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: isActive ? theme.primaryColor : theme.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Overlapping fill / stroke swatches for the mobile bottom panel
// ---------------------------------------------------------------------------

class _ColorSection extends ConsumerWidget {
  const _ColorSection({required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baseColor = ref.watch(baseColorProvider);
    final fillColor = baseColor.fillColor.toFlutterColor();
    final strokeColor = baseColor.strokeColor.toFlutterColor();

    return SizedBox(
      width: 48,
      height: 56,
      child: Center(
        child: SizedBox(
          width: 36,
          height: 36,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Stroke swatch (back, bottom-right)
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () async {
                    final picked = await showColorPicker(
                      context: context,
                      initialColor: strokeColor,
                      theme: theme,
                    );
                    if (picked != null) {
                      ref.read(baseColorProvider.notifier).setStroke(VecColor.fromFlutterColor(picked));
                    }
                  },
                  child: _ColorSwatch(color: strokeColor, size: 22, isStroke: true, theme: theme),
                ),
              ),
              // Fill swatch (front, top-left)
              Positioned(
                left: 0,
                top: 0,
                child: GestureDetector(
                  onTap: () async {
                    final picked = await showColorPicker(
                      context: context,
                      initialColor: fillColor,
                      theme: theme,
                    );
                    if (picked != null) {
                      ref.read(baseColorProvider.notifier).setFill(VecColor.fromFlutterColor(picked));
                    }
                  },
                  child: _ColorSwatch(color: fillColor, size: 22, isStroke: false, theme: theme),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.color, required this.size, required this.isStroke, required this.theme});

  final Color color;
  final double size;
  final bool isStroke;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: theme.divider, width: isStroke ? 2.0 : 0.5),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 3, offset: const Offset(0, 1))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2.5),
        child: ColoredBox(color: color),
      ),
    );
  }
}
