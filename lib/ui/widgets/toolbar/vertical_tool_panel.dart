import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../data/models/vec_color.dart';
import '../../../providers/editor_state_provider.dart';
import '../common/icon_toggle_button.dart';
import '../common/color_picker.dart';

class VerticalToolPanel extends ConsumerWidget {
  const VerticalToolPanel({super.key, required this.theme});

  final AppTheme theme;

  static const _tools = [
    (VecTool.select, Icons.near_me_outlined, 'Select (V)'),
    (VecTool.pen, Icons.mode_edit_outline, 'Pen (P)'),
    (VecTool.line, Icons.horizontal_rule, 'Line (L)'),
    (VecTool.rectangle, Icons.rectangle_outlined, 'Rectangle (R)'),
    (VecTool.ellipse, Icons.circle_outlined, 'Ellipse (E)'),
    (VecTool.text, Icons.text_fields, 'Text (T)'),
    (VecTool.width, Icons.line_weight, 'Width (W)'),
    (VecTool.bend, Icons.architecture, 'Bend (U)'),
    (VecTool.knife, Icons.content_cut_outlined, 'Knife (K)'),
    (VecTool.freedraw, Icons.brush_outlined, 'Free Draw (B)'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTool = ref.watch(activeToolProvider);

    return Container(
      width: 48,
      decoration: BoxDecoration(
        color: theme.toolbarColor,
        border: Border(right: BorderSide(color: theme.divider, width: 0.5)),
      ),
      child: Column(
        children: [
          // ── Tool buttons ─────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 6),
                  for (final (tool, icon, tooltip) in _tools)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: IconToggleButton(
                        icon: icon,
                        isActive: activeTool == tool,
                        onTap: () => ref.read(activeToolProvider.notifier).set(tool),
                        theme: theme,
                        tooltip: tooltip,
                        size: 40,
                      ),
                    ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),

          // ── Divider ──────────────────────────────────────────────────────
          Container(height: 0.5, color: theme.divider),

          // ── Base color picker ─────────────────────────────────────────────
          _BaseColorSection(theme: theme),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Base color section — fill + stroke swatches, Illustrator-style stacked
// ---------------------------------------------------------------------------

class _BaseColorSection extends ConsumerWidget {
  const _BaseColorSection({required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baseColor = ref.watch(baseColorProvider);
    final fillFlutter = baseColor.fillColor.toFlutterColor();
    final strokeFlutter = baseColor.strokeColor.toFlutterColor();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'COLOR',
            style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: theme.textDisabled, letterSpacing: 0.6),
          ),
          const SizedBox(height: 6),

          // Overlapping fill / stroke squares
          SizedBox(
            width: 36,
            height: 36,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Stroke swatch (back)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Tooltip(
                    message: 'Default stroke color',
                    waitDuration: const Duration(milliseconds: 500),
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showColorPicker(
                          context: context,
                          initialColor: strokeFlutter,
                          theme: theme,
                        );
                        if (picked != null) {
                          ref.read(baseColorProvider.notifier).setStroke(VecColor.fromFlutterColor(picked));
                        }
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: _ColorSwatch(color: strokeFlutter, size: 22, isStroke: true, theme: theme),
                      ),
                    ),
                  ),
                ),

                // Fill swatch (front)
                Positioned(
                  left: 0,
                  top: 0,
                  child: Tooltip(
                    message: 'Default fill color',
                    waitDuration: const Duration(milliseconds: 500),
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showColorPicker(context: context, initialColor: fillFlutter, theme: theme);
                        if (picked != null) {
                          ref.read(baseColorProvider.notifier).setFill(VecColor.fromFlutterColor(picked));
                        }
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: _ColorSwatch(color: fillFlutter, size: 22, isStroke: false, theme: theme),
                      ),
                    ),
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

// ---------------------------------------------------------------------------
// Individual color swatch
// ---------------------------------------------------------------------------

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
        child: CustomPaint(
          painter: _CheckerPainter(theme.gridLine.withAlpha(60)),
          child: ColoredBox(color: color),
        ),
      ),
    );
  }
}

class _CheckerPainter extends CustomPainter {
  _CheckerPainter(this.checkerColor);
  final Color checkerColor;

  @override
  void paint(Canvas canvas, Size size) {
    const cellSize = 3.0;
    final paint = Paint()..color = checkerColor;
    for (var y = 0.0; y < size.height; y += cellSize) {
      for (var x = 0.0; x < size.width; x += cellSize) {
        final col = (x / cellSize).floor();
        final row = (y / cellSize).floor();
        if ((col + row) % 2 == 0) {
          canvas.drawRect(Rect.fromLTWH(x, y, cellSize, cellSize), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CheckerPainter old) => old.checkerColor != checkerColor;
}
