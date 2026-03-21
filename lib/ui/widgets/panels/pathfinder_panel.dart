import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../data/models/vec_shape.dart';
import '../../../providers/document_provider.dart';
import '../../../providers/editor_state_provider.dart';

class PathfinderPanel extends ConsumerWidget {
  const PathfinderPanel({super.key, required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIds = ref.watch(selectedShapeIdsProvider);
    final selectedShape = ref.watch(selectedShapeProvider);
    final isCompound =
        selectedShape?.maybeMap(compound: (_) => true, orElse: () => false) ??
            false;

    // Show pathfinder ops when 2+ shapes selected; show Expand when compound selected
    final canApply = selectedIds.length >= 2;
    if (!canApply && !isCompound) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 1, color: theme.divider.withAlpha(60)),
        _SectionHeader(title: 'PATHFINDER', theme: theme),
        const SizedBox(height: 8),

        if (canApply) ...[
          // Row 1: main boolean ops
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _OpButton(
                  op: PathfinderOp.unite,
                  label: 'Unite',
                  theme: theme,
                  enabled: canApply,
                  onTap: () => _apply(ref, PathfinderOp.unite),
                ),
                const SizedBox(width: 6),
                _OpButton(
                  op: PathfinderOp.minusFront,
                  label: 'Minus Front',
                  theme: theme,
                  enabled: canApply,
                  onTap: () => _apply(ref, PathfinderOp.minusFront),
                ),
                const SizedBox(width: 6),
                _OpButton(
                  op: PathfinderOp.intersect,
                  label: 'Intersect',
                  theme: theme,
                  enabled: canApply,
                  onTap: () => _apply(ref, PathfinderOp.intersect),
                ),
                const SizedBox(width: 6),
                _OpButton(
                  op: PathfinderOp.exclude,
                  label: 'Exclude',
                  theme: theme,
                  enabled: canApply,
                  onTap: () => _apply(ref, PathfinderOp.exclude),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Row 2: structural ops
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _OpButton(
                  op: PathfinderOp.divide,
                  label: 'Divide',
                  theme: theme,
                  enabled: canApply,
                  onTap: () => _apply(ref, PathfinderOp.divide),
                ),
                const SizedBox(width: 6),
                _OpButton(
                  op: PathfinderOp.trim,
                  label: 'Trim',
                  theme: theme,
                  enabled: canApply,
                  onTap: () => _apply(ref, PathfinderOp.trim),
                ),
                const SizedBox(width: 6),
                _OpButton(
                  op: PathfinderOp.outline,
                  label: 'Outline',
                  theme: theme,
                  enabled: canApply,
                  onTap: () => _apply(ref, PathfinderOp.outline),
                ),
                const Spacer(),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Expand button — only when a compound is selected
        if (isCompound)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              width: double.infinity,
              child: _ExpandButton(
                theme: theme,
                onTap: () => _expand(ref),
              ),
            ),
          ),

        const SizedBox(height: 10),
      ],
    );
  }

  // ---------------------------------------------------------------------------

  void _apply(WidgetRef ref, PathfinderOp op) {
    final scene = ref.read(activeSceneProvider);
    final layerId = ref.read(activeLayerIdProvider);
    final ids = ref.read(selectedShapeIdsProvider).toList();
    if (scene == null || layerId == null || ids.length < 2) return;

    final resultIds = ref
        .read(vecDocumentStateProvider.notifier)
        .applyPathfinder(scene.id, layerId, ids, op);

    // Select the result(s)
    if (resultIds.isNotEmpty) {
      ref.read(selectedShapeIdsProvider.notifier).setAll(resultIds);
      ref.read(selectedShapeIdProvider.notifier).set(resultIds.last);
    }
  }

  void _expand(WidgetRef ref) {
    final scene = ref.read(activeSceneProvider);
    final layerId = ref.read(activeLayerIdProvider);
    final shapeId = ref.read(selectedShapeIdProvider);
    if (scene == null || layerId == null || shapeId == null) return;

    final newId = ref
        .read(vecDocumentStateProvider.notifier)
        .expandCompound(scene.id, layerId, shapeId);

    if (newId != null) {
      ref.read(selectedShapeIdProvider.notifier).set(newId);
      ref.read(selectedShapeIdsProvider.notifier).setSingle(newId);
    }
  }
}

// =============================================================================
// Section header
// =============================================================================

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.theme});

  final String title;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: theme.textDisabled,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// =============================================================================
// Operation button with custom icon
// =============================================================================

class _OpButton extends StatefulWidget {
  const _OpButton({
    required this.op,
    required this.label,
    required this.theme,
    required this.enabled,
    required this.onTap,
  });

  final PathfinderOp op;
  final String label;
  final AppTheme theme;
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<_OpButton> createState() => _OpButtonState();
}

class _OpButtonState extends State<_OpButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bg = _hovered
        ? widget.theme.surfaceVariant
        : widget.theme.surface;

    return Expanded(
      child: MouseRegion(
        cursor: widget.enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.forbidden,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.enabled ? widget.onTap : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            height: 52,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _hovered
                    ? widget.theme.primaryColor.withAlpha(180)
                    : widget.theme.divider,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CustomPaint(
                    painter: _PathfinderIconPainter(
                      op: widget.op,
                      color: widget.enabled
                          ? widget.theme.primaryColor
                          : widget.theme.textDisabled,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 8,
                    color: widget.enabled
                        ? widget.theme.textPrimary
                        : widget.theme.textDisabled,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Expand button
// =============================================================================

class _ExpandButton extends StatefulWidget {
  const _ExpandButton({required this.theme, required this.onTap});

  final AppTheme theme;
  final VoidCallback onTap;

  @override
  State<_ExpandButton> createState() => _ExpandButtonState();
}

class _ExpandButtonState extends State<_ExpandButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: 28,
          decoration: BoxDecoration(
            color: _hovered
                ? widget.theme.primaryColor.withAlpha(30)
                : widget.theme.surfaceVariant,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _hovered
                  ? widget.theme.primaryColor
                  : widget.theme.divider,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              'Expand',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _hovered
                    ? widget.theme.primaryColor
                    : widget.theme.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Custom icon painters for each operation
// =============================================================================

class _PathfinderIconPainter extends CustomPainter {
  const _PathfinderIconPainter({required this.op, required this.color});

  final PathfinderOp op;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Two overlapping rects: A (left), B (right)
    final aRect = Rect.fromLTWH(0, h * 0.15, w * 0.6, h * 0.7);
    final bRect = Rect.fromLTWH(w * 0.4, h * 0.15, w * 0.6, h * 0.7);

    final aPath = ui.Path()..addRect(aRect);
    final bPath = ui.Path()..addRect(bRect);

    final dimPaint = Paint()
      ..color = color.withAlpha(35)
      ..style = PaintingStyle.fill;
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    switch (op) {
      case PathfinderOp.unite:
        // Both shapes filled
        final united =
            ui.Path.combine(ui.PathOperation.union, aPath, bPath);
        canvas.drawPath(united, fillPaint);

      case PathfinderOp.minusFront:
        // A filled, B removes overlap
        canvas.drawPath(aPath, dimPaint);
        final result =
            ui.Path.combine(ui.PathOperation.difference, aPath, bPath);
        canvas.drawPath(result, fillPaint);
        canvas.drawPath(bPath, strokePaint);

      case PathfinderOp.intersect:
        // Only overlap filled
        canvas.drawPath(aPath, dimPaint);
        canvas.drawPath(bPath, dimPaint);
        final inter =
            ui.Path.combine(ui.PathOperation.intersect, aPath, bPath);
        canvas.drawPath(inter, fillPaint);

      case PathfinderOp.exclude:
        // Both minus overlap
        final xor = ui.Path.combine(ui.PathOperation.xor, aPath, bPath);
        canvas.drawPath(xor, fillPaint);
        final inter =
            ui.Path.combine(ui.PathOperation.intersect, aPath, bPath);
        canvas.drawPath(inter, dimPaint);

      case PathfinderOp.divide:
        // All regions filled with dividing lines
        canvas.drawPath(aPath, dimPaint);
        canvas.drawPath(bPath, dimPaint);
        final inter =
            ui.Path.combine(ui.PathOperation.intersect, aPath, bPath);
        canvas.drawPath(inter, fillPaint);
        // Dividing lines
        final strokeFill = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8;
        canvas.drawLine(
            Offset(aRect.right, aRect.top),
            Offset(aRect.right, aRect.bottom),
            strokeFill);
        canvas.drawRect(aRect, strokePaint);
        canvas.drawRect(bRect, strokePaint);

      case PathfinderOp.trim:
        // Lower shape trimmed: A minus overlap, B untouched
        final aOnly =
            ui.Path.combine(ui.PathOperation.difference, aPath, bPath);
        canvas.drawPath(aOnly, fillPaint);
        canvas.drawPath(bPath, fillPaint..color = color.withAlpha(160));
        canvas.drawPath(aPath, strokePaint..color = color.withAlpha(80));

      case PathfinderOp.outline:
        // Stroke outlines only
        final strokeOnly = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;
        canvas.drawRect(aRect, strokeOnly);
        canvas.drawRect(bRect, strokeOnly);
        canvas.drawRect(
            Rect.fromLTWH(w * 0.4, h * 0.15, w * 0.2, h * 0.7),
            Paint()
              ..color = color
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5);
    }
  }

  @override
  bool shouldRepaint(covariant _PathfinderIconPainter old) =>
      old.op != op || old.color != color;
}
