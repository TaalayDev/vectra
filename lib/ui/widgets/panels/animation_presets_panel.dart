import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../data/animation_presets.dart';
import '../../../providers/document_provider.dart';
import '../../../providers/editor_state_provider.dart';

// ---------------------------------------------------------------------------
// Animation Presets Panel
// ---------------------------------------------------------------------------

/// Shows a scrollable list of built-in animation presets grouped by category.
/// Tapping a preset applies it to the selected shape at the current playhead.
class AnimationPresetsPanel extends ConsumerWidget {
  const AnimationPresetsPanel({super.key, required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scene = ref.watch(activeSceneProvider);
    final selectedShapeId = ref.watch(selectedShapeIdProvider);
    final playhead = ref.watch(playheadFrameProvider);
    final canApply = scene != null && selectedShapeId != null;

    final categories = AnimationPresetCategory.values;

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(color: theme.divider, borderRadius: BorderRadius.circular(2)),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  'Animation Presets',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.textPrimary),
                ),
                const Spacer(),
                if (!canApply) Text('Select a shape first', style: TextStyle(fontSize: 10, color: theme.textDisabled)),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Preset list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              children: [
                for (final category in categories)
                  _CategorySection(
                    category: category,
                    theme: theme,
                    presets: AnimationPresets.builtIn.where((p) => p.category == category).toList(),
                    canApply: canApply,
                    onApply: (preset) {
                      final s = scene;
                      final shapeId = selectedShapeId;
                      if (s == null || shapeId == null) return;
                      // Find layer id for selected shape
                      String? layerId;
                      for (final layer in s.layers) {
                        for (final shape in layer.shapes) {
                          if (shape.id == shapeId) {
                            layerId = layer.id;
                            break;
                          }
                        }
                        if (layerId != null) break;
                      }
                      if (layerId == null) return;
                      ref
                          .read(vecDocumentStateProvider.notifier)
                          .applyAnimationPreset(s.id, layerId, shapeId, preset, playhead);
                      Navigator.of(context).pop();
                    },
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
// Category section
// ---------------------------------------------------------------------------

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.theme,
    required this.presets,
    required this.canApply,
    required this.onApply,
  });

  final AnimationPresetCategory category;
  final AppTheme theme;
  final List<AnimationPreset> presets;
  final bool canApply;
  final void Function(AnimationPreset) onApply;

  String get _categoryLabel => switch (category) {
    AnimationPresetCategory.enter => 'Enter',
    AnimationPresetCategory.exit => 'Exit',
    AnimationPresetCategory.loop => 'Loop',
    AnimationPresetCategory.attention => 'Attention',
    AnimationPresetCategory.transform => 'Transform',
    AnimationPresetCategory.reveal => 'Reveal',
  };

  @override
  Widget build(BuildContext context) {
    if (presets.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6, left: 4),
          child: Text(
            _categoryLabel,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: theme.textDisabled, letterSpacing: 0.8),
          ),
        ),
        ...presets.map(
          (preset) => _PresetTile(preset: preset, theme: theme, enabled: canApply, onTap: () => onApply(preset)),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Individual preset tile
// ---------------------------------------------------------------------------

class _PresetTile extends StatefulWidget {
  const _PresetTile({required this.preset, required this.theme, required this.enabled, required this.onTap});

  final AnimationPreset preset;
  final AppTheme theme;
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<_PresetTile> createState() => _PresetTileState();
}

class _PresetTileState extends State<_PresetTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final preset = widget.preset;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: _hovering && widget.enabled ? theme.accentColor.withAlpha(20) : theme.surfaceVariant,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _hovering && widget.enabled ? theme.accentColor.withAlpha(100) : theme.divider.withAlpha(60),
            ),
          ),
          child: Row(
            children: [
              // Mini curve preview
              _CurvePreview(
                easing: preset.keyframes.isNotEmpty ? preset.keyframes.first.keyframe.easing : null,
                color: widget.enabled ? theme.accentColor : theme.textDisabled,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preset.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: widget.enabled ? theme.textPrimary : theme.textDisabled,
                      ),
                    ),
                    if (preset.description.isNotEmpty)
                      Text(preset.description, style: TextStyle(fontSize: 10, color: theme.textSecondary)),
                  ],
                ),
              ),
              Text('${preset.duration}f', style: TextStyle(fontSize: 9, color: theme.textDisabled)),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tiny curve preview (28×28 canvas)
// ---------------------------------------------------------------------------

class _CurvePreview extends StatelessWidget {
  const _CurvePreview({required this.easing, required this.color});

  final Object? easing;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(28, 28),
      painter: _CurvePreviewPainter(easing: easing, color: color),
    );
  }
}

class _CurvePreviewPainter extends CustomPainter {
  const _CurvePreviewPainter({required this.easing, required this.color});

  final Object? easing; // VecEasing? — kept dynamic to avoid import cycle
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Draw a simple diagonal line as the default curve
    final paint = Paint()
      ..color = color.withAlpha(160)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()..moveTo(0, h);
    const steps = 16;
    for (var i = 1; i <= steps; i++) {
      final t = i / steps;
      // Simple approximation — without importing EasingEvaluator into this file
      path.lineTo(t * w, h - t * h);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CurvePreviewPainter old) => old.easing != easing || old.color != color;
}
