import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../app/theme/theme.dart';
import '../../../data/models/vec_color.dart';
import '../../../data/models/vec_fill.dart';
import '../../../data/models/vec_shape.dart';
import '../../../data/models/vec_stroke.dart';
import '../../../data/models/vec_transform.dart';
import '../common/collapsible_section.dart';
import '../common/color_swatch_button.dart';
import '../common/numeric_input.dart';
import '../common/color_picker.dart';

// ---------------------------------------------------------------------------
// Callback typedefs
// ---------------------------------------------------------------------------

/// Applies an update to the shape and commits it to undo history.
typedef ShapeCommit = void Function(VecShape Function(VecShape) updater);

/// Applies a live (no-history) update used during slider drag.
typedef ShapeLiveUpdate = void Function(VecShape Function(VecShape) updater);

// ---------------------------------------------------------------------------
// 1. Transform Section
// ---------------------------------------------------------------------------

class TransformSection extends StatelessWidget {
  const TransformSection({
    super.key,
    required this.transform,
    required this.opacity,
    required this.theme,
    required this.onUpdate,
    required this.onLiveUpdate,
    required this.onCommit,
  });

  final VecTransform transform;
  final double opacity;
  final AppTheme theme;
  final ShapeCommit onUpdate;
  final ShapeLiveUpdate onLiveUpdate;
  final VoidCallback onCommit;

  @override
  Widget build(BuildContext context) {
    return CollapsibleSection(
      title: 'Transform',
      theme: theme,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: X Y W H
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              NumericInput(
                label: 'X',
                value: transform.x,
                theme: theme,
                onChanged: (v) => onUpdate(
                  (s) => s.copyWith(
                    data: s.data.copyWith(transform: s.transform.copyWith(x: v)),
                  ),
                ),
              ),
              NumericInput(
                label: 'Y',
                value: transform.y,
                theme: theme,
                onChanged: (v) => onUpdate(
                  (s) => s.copyWith(
                    data: s.data.copyWith(transform: s.transform.copyWith(y: v)),
                  ),
                ),
              ),
              NumericInput(
                label: 'W',
                value: transform.width,
                theme: theme,
                min: 1,
                onChanged: (v) => onUpdate(
                  (s) => s.copyWith(
                    data: s.data.copyWith(transform: s.transform.copyWith(width: v)),
                  ),
                ),
              ),
              NumericInput(
                label: 'H',
                value: transform.height,
                theme: theme,
                min: 1,
                onChanged: (v) => onUpdate(
                  (s) => s.copyWith(
                    data: s.data.copyWith(transform: s.transform.copyWith(height: v)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Row 2: Rotation + Opacity
          Row(
            children: [
              NumericInput(
                label: 'Rotation°',
                value: transform.rotation,
                theme: theme,
                width: 76,
                onChanged: (v) => onUpdate(
                  (s) => s.copyWith(
                    data: s.data.copyWith(transform: s.transform.copyWith(rotation: v)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Opacity',
                      style: TextStyle(fontSize: 10, color: theme.textDisabled, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: _SliderCompact(
                            value: opacity,
                            theme: theme,
                            onChanged: (v) => onLiveUpdate((s) => s.copyWith(data: s.data.copyWith(opacity: v))),
                            onChangeEnd: (_) => onCommit(),
                          ),
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 30,
                          child: Text(
                            '${(opacity * 100).round()}%',
                            style: TextStyle(fontSize: 10, color: theme.textDisabled),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. Fill Section
// ---------------------------------------------------------------------------

class FillSection extends HookWidget {
  const FillSection({
    super.key,
    required this.fills,
    required this.theme,
    required this.onUpdate,
    required this.onLiveUpdate,
    required this.onCommit,
  });

  final List<VecFill> fills;
  final AppTheme theme;
  final ShapeCommit onUpdate;
  final ShapeLiveUpdate onLiveUpdate;
  final VoidCallback onCommit;

  @override
  Widget build(BuildContext context) {
    return CollapsibleSection(
      title: 'Fill',
      theme: theme,
      action: _AddRemoveButton(
        onAdd: () => onUpdate(
          (s) => s.copyWith(
            data: s.data.copyWith(
              fills: [
                ...s.fills,
                const VecFill(color: VecColor(r: 120, g: 160, b: 230)),
              ],
            ),
          ),
        ),
        theme: theme,
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (fills.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text('No fill — press + to add', style: TextStyle(fontSize: 11, color: theme.textDisabled)),
            )
          else
            for (var i = 0; i < fills.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _FillRow(
                  fill: fills[i],
                  index: i,
                  theme: theme,
                  onUpdate: onUpdate,
                  onLiveUpdate: onLiveUpdate,
                  onCommit: onCommit,
                ),
              ),
        ],
      ),
    );
  }
}

class _FillRow extends HookWidget {
  const _FillRow({
    required this.fill,
    required this.index,
    required this.theme,
    required this.onUpdate,
    required this.onLiveUpdate,
    required this.onCommit,
  });

  final VecFill fill;
  final int index;
  final AppTheme theme;
  final ShapeCommit onUpdate;
  final ShapeLiveUpdate onLiveUpdate;
  final VoidCallback onCommit;

  @override
  Widget build(BuildContext context) {
    final i = index;

    return Column(
      children: [
        Row(
          children: [
            // Color swatch
            ColorSwatchButton(
              color: fill.color.toFlutterColor(),
              theme: theme,
              onTap: () async {
                final picked = await showColorPicker(
                  context: context,
                  initialColor: fill.color.toFlutterColor(),
                  theme: theme,
                );
                if (picked != null) {
                  onUpdate((s) => _updateFill(s, i, s.fills[i].copyWith(color: VecColor.fromFlutterColor(picked))));
                }
              },
            ),
            const SizedBox(width: 8),
            // Opacity slider
            Expanded(
              child: _SliderCompact(
                value: fill.opacity,
                theme: theme,
                onChanged: (v) => onLiveUpdate((s) => _updateFill(s, i, s.fills[i].copyWith(opacity: v))),
                onChangeEnd: (_) => onCommit(),
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 30,
              child: Text(
                '${(fill.opacity * 100).round()}%',
                style: TextStyle(fontSize: 10, color: theme.textDisabled),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(width: 4),
            // Remove button
            GestureDetector(
              onTap: () => onUpdate(
                (s) => s.copyWith(
                  data: s.data.copyWith(
                    fills: [
                      for (var j = 0; j < s.fills.length; j++)
                        if (j != i) s.fills[j],
                    ],
                  ),
                ),
              ),
              child: Icon(Icons.close, size: 13, color: theme.textDisabled),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Blend mode row
        _BlendDropdown(
          value: fill.blendMode,
          theme: theme,
          onChanged: (mode) => onUpdate((s) => _updateFill(s, i, s.fills[i].copyWith(blendMode: mode))),
        ),
      ],
    );
  }

  static VecShape _updateFill(VecShape s, int i, VecFill updated) {
    return s.copyWith(
      data: s.data.copyWith(
        fills: [
          for (var j = 0; j < s.fills.length; j++)
            if (j == i) updated else s.fills[j],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Stroke Section
// ---------------------------------------------------------------------------

class StrokeSection extends HookWidget {
  const StrokeSection({
    super.key,
    required this.strokes,
    required this.theme,
    required this.onUpdate,
    required this.onLiveUpdate,
    required this.onCommit,
  });

  final List<VecStroke> strokes;
  final AppTheme theme;
  final ShapeCommit onUpdate;
  final ShapeLiveUpdate onLiveUpdate;
  final VoidCallback onCommit;

  @override
  Widget build(BuildContext context) {
    return CollapsibleSection(
      title: 'Stroke',
      theme: theme,
      action: _AddRemoveButton(
        onAdd: () => onUpdate(
          (s) => s.copyWith(
            data: s.data.copyWith(
              strokes: [
                ...s.strokes,
                const VecStroke(color: VecColor(r: 50, g: 60, b: 80)),
              ],
            ),
          ),
        ),
        theme: theme,
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (strokes.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text('No stroke — press + to add', style: TextStyle(fontSize: 11, color: theme.textDisabled)),
            )
          else
            for (var i = 0; i < strokes.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _StrokeRow(
                  stroke: strokes[i],
                  index: i,
                  theme: theme,
                  onUpdate: onUpdate,
                  onLiveUpdate: onLiveUpdate,
                  onCommit: onCommit,
                ),
              ),
        ],
      ),
    );
  }
}

class _StrokeRow extends HookWidget {
  const _StrokeRow({
    required this.stroke,
    required this.index,
    required this.theme,
    required this.onUpdate,
    required this.onLiveUpdate,
    required this.onCommit,
  });

  final VecStroke stroke;
  final int index;
  final AppTheme theme;
  final ShapeCommit onUpdate;
  final ShapeLiveUpdate onLiveUpdate;
  final VoidCallback onCommit;

  @override
  Widget build(BuildContext context) {
    final i = index;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Color + Width + Opacity + Remove
        Row(
          children: [
            ColorSwatchButton(
              color: stroke.color.toFlutterColor(),
              theme: theme,
              onTap: () async {
                final picked = await showColorPicker(
                  context: context,
                  initialColor: stroke.color.toFlutterColor(),
                  theme: theme,
                );
                if (picked != null) {
                  onUpdate((s) => _updateStroke(s, i, s.strokes[i].copyWith(color: VecColor.fromFlutterColor(picked))));
                }
              },
            ),
            const SizedBox(width: 8),
            NumericInput(
              label: 'W',
              value: stroke.width,
              theme: theme,
              min: 0,
              width: 52,
              onChanged: (v) => onUpdate((s) => _updateStroke(s, i, s.strokes[i].copyWith(width: v))),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SliderCompact(
                value: stroke.opacity,
                theme: theme,
                onChanged: (v) => onLiveUpdate((s) => _updateStroke(s, i, s.strokes[i].copyWith(opacity: v))),
                onChangeEnd: (_) => onCommit(),
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 30,
              child: Text(
                '${(stroke.opacity * 100).round()}%',
                style: TextStyle(fontSize: 10, color: theme.textDisabled),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => onUpdate(
                (s) => s.copyWith(
                  data: s.data.copyWith(
                    strokes: [
                      for (var j = 0; j < s.strokes.length; j++)
                        if (j != i) s.strokes[j],
                    ],
                  ),
                ),
              ),
              child: Icon(Icons.close, size: 13, color: theme.textDisabled),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Cap / Join / Align toggles
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            _EnumToggle<VecStrokeCap>(
              values: VecStrokeCap.values,
              current: stroke.cap,
              label: (v) => v.name[0].toUpperCase() + v.name.substring(1),
              theme: theme,
              onChanged: (v) => onUpdate((s) => _updateStroke(s, i, s.strokes[i].copyWith(cap: v))),
            ),
            const SizedBox(width: 4),
            _EnumToggle<VecStrokeJoin>(
              values: VecStrokeJoin.values,
              current: stroke.join,
              label: (v) => v.name[0].toUpperCase() + v.name.substring(1),
              theme: theme,
              onChanged: (v) => onUpdate((s) => _updateStroke(s, i, s.strokes[i].copyWith(join: v))),
            ),
            const SizedBox(width: 4),
            _EnumToggle<VecStrokeAlign>(
              values: VecStrokeAlign.values,
              current: stroke.align,
              label: (v) => v.name[0].toUpperCase() + v.name.substring(1),
              theme: theme,
              onChanged: (v) => onUpdate((s) => _updateStroke(s, i, s.strokes[i].copyWith(align: v))),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Blend mode
        _BlendDropdown(
          value: stroke.blendMode,
          theme: theme,
          onChanged: (mode) => onUpdate((s) => _updateStroke(s, i, s.strokes[i].copyWith(blendMode: mode))),
        ),
      ],
    );
  }

  static VecShape _updateStroke(VecShape s, int i, VecStroke updated) {
    return s.copyWith(
      data: s.data.copyWith(
        strokes: [
          for (var j = 0; j < s.strokes.length; j++)
            if (j == i) updated else s.strokes[j],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. Blend Mode Section (shape-level blendMode)
// ---------------------------------------------------------------------------

class BlendSection extends StatelessWidget {
  const BlendSection({super.key, required this.blendMode, required this.theme, required this.onUpdate});

  final VecBlendMode blendMode;
  final AppTheme theme;
  final ShapeCommit onUpdate;

  @override
  Widget build(BuildContext context) {
    return CollapsibleSection(
      title: 'Blend',
      theme: theme,
      content: _BlendDropdown(
        value: blendMode,
        theme: theme,
        onChanged: (mode) => onUpdate((s) => s.copyWith(data: s.data.copyWith(blendMode: mode))),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. Corner Radius Section (rectangles only)
// ---------------------------------------------------------------------------

class CornerSection extends StatefulWidget {
  const CornerSection({
    super.key,
    required this.shape,
    required this.theme,
    required this.onUpdate,
  });

  final VecRectangleShape shape;
  final AppTheme theme;
  final ShapeCommit onUpdate;

  @override
  State<CornerSection> createState() => _CornerSectionState();
}

class _CornerSectionState extends State<CornerSection> {
  bool _independent = false;

  List<double> get _radii {
    final r = widget.shape.cornerRadii;
    return r.length == 4 ? r : [0.0, 0.0, 0.0, 0.0];
  }

  double get _maxRadius {
    final t = widget.shape.data.transform;
    return (t.width < t.height ? t.width : t.height) / 2;
  }

  void _setAll(double v) {
    final clamped = v.clamp(0.0, _maxRadius);
    widget.onUpdate((s) => s.maybeMap(
          rectangle: (r) =>
              r.copyWith(cornerRadii: [clamped, clamped, clamped, clamped]),
          orElse: () => s,
        ));
  }

  void _setOne(int index, double v) {
    final clamped = v.clamp(0.0, _maxRadius);
    final newRadii = List<double>.from(_radii);
    newRadii[index] = clamped;
    widget.onUpdate((s) => s.maybeMap(
          rectangle: (r) => r.copyWith(cornerRadii: newRadii),
          orElse: () => s,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final r = _radii;

    return CollapsibleSection(
      title: 'Corner',
      theme: t,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_independent) ...[
            Row(
              children: [
                NumericInput(
                  label: 'Radius',
                  value: r[0],
                  min: 0,
                  max: _maxRadius,
                  theme: t,
                  width: 80,
                  onChanged: _setAll,
                ),
                const SizedBox(width: 8),
                _IndependentToggle(
                  independent: false,
                  theme: t,
                  onTap: () => setState(() => _independent = true),
                ),
              ],
            ),
          ] else ...[
            // Top row: TL, TR + toggle
            Row(
              children: [
                Expanded(
                  child: NumericInput(
                    label: 'TL',
                    value: r[0],
                    min: 0,
                    max: _maxRadius,
                    theme: t,
                    onChanged: (v) => _setOne(0, v),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: NumericInput(
                    label: 'TR',
                    value: r[1],
                    min: 0,
                    max: _maxRadius,
                    theme: t,
                    onChanged: (v) => _setOne(1, v),
                  ),
                ),
                const SizedBox(width: 8),
                _IndependentToggle(
                  independent: true,
                  theme: t,
                  onTap: () => setState(() => _independent = false),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Bottom row: BL, BR (aligned under TL, TR)
            Row(
              children: [
                Expanded(
                  child: NumericInput(
                    label: 'BL',
                    value: r[3],
                    min: 0,
                    max: _maxRadius,
                    theme: t,
                    onChanged: (v) => _setOne(3, v),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: NumericInput(
                    label: 'BR',
                    value: r[2],
                    min: 0,
                    max: _maxRadius,
                    theme: t,
                    onChanged: (v) => _setOne(2, v),
                  ),
                ),
                // Spacer matching toggle button width
                const SizedBox(width: 8 + 24),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _IndependentToggle extends StatelessWidget {
  const _IndependentToggle({
    required this.independent,
    required this.theme,
    required this.onTap,
  });

  final bool independent;
  final AppTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: independent ? 'Link corners' : 'Independent corners',
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: independent
                ? theme.primaryColor.withAlpha(30)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: independent ? theme.primaryColor : theme.divider,
              width: 1,
            ),
          ),
          child: Icon(
            independent ? Icons.link_off : Icons.link,
            size: 12,
            color: independent ? theme.primaryColor : theme.textDisabled,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared sub-widgets
// ---------------------------------------------------------------------------

/// Compact slider without the big Material height.
class _SliderCompact extends StatelessWidget {
  const _SliderCompact({required this.value, required this.theme, required this.onChanged, this.onChangeEnd});

  final double value;
  final AppTheme theme;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 2,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
        activeTrackColor: theme.primaryColor,
        inactiveTrackColor: theme.divider,
        thumbColor: theme.primaryColor,
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
      ),
      child: Slider(value: value.clamp(0.0, 1.0), onChanged: onChanged, onChangeEnd: onChangeEnd),
    );
  }
}

/// Blend mode dropdown.
class _BlendDropdown extends StatelessWidget {
  const _BlendDropdown({required this.value, required this.theme, required this.onChanged});

  final VecBlendMode value;
  final AppTheme theme;
  final ValueChanged<VecBlendMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: theme.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.divider, width: 0.5),
      ),
      child: DropdownButton<VecBlendMode>(
        value: value,
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
        isExpanded: true,
        underline: const SizedBox.shrink(),
        icon: Icon(Icons.expand_more, size: 12, color: theme.textDisabled),
        dropdownColor: theme.surface,
        style: TextStyle(fontSize: 11, color: theme.textPrimary),
        items: VecBlendMode.values.map((mode) {
          return DropdownMenuItem(value: mode, child: Text(_blendLabel(mode)));
        }).toList(),
      ),
    );
  }

  static String _blendLabel(VecBlendMode m) {
    switch (m) {
      case VecBlendMode.normal:
        return 'Normal';
      case VecBlendMode.multiply:
        return 'Multiply';
      case VecBlendMode.screen:
        return 'Screen';
      case VecBlendMode.overlay:
        return 'Overlay';
      case VecBlendMode.darken:
        return 'Darken';
      case VecBlendMode.lighten:
        return 'Lighten';
      case VecBlendMode.colorDodge:
        return 'Color Dodge';
      case VecBlendMode.colorBurn:
        return 'Color Burn';
      case VecBlendMode.hardLight:
        return 'Hard Light';
      case VecBlendMode.softLight:
        return 'Soft Light';
      case VecBlendMode.difference:
        return 'Difference';
      case VecBlendMode.exclusion:
        return 'Exclusion';
      case VecBlendMode.hue:
        return 'Hue';
      case VecBlendMode.saturation:
        return 'Saturation';
      case VecBlendMode.color:
        return 'Color';
      case VecBlendMode.luminosity:
        return 'Luminosity';
    }
  }
}

/// Row of tappable chips for enum toggle (cap, join, align).
class _EnumToggle<T extends Enum> extends StatelessWidget {
  const _EnumToggle({
    required this.values,
    required this.current,
    required this.label,
    required this.theme,
    required this.onChanged,
  });

  final List<T> values;
  final T current;
  final String Function(T) label;
  final AppTheme theme;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: values.map((v) {
        final active = v == current;
        return GestureDetector(
          onTap: () => onChanged(v),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            margin: const EdgeInsets.only(right: 2),
            decoration: BoxDecoration(
              color: active ? theme.primaryColor : theme.surfaceVariant,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: active ? theme.primaryColor : theme.divider, width: 0.5),
            ),
            child: Text(
              label(v),
              style: TextStyle(
                fontSize: 9,
                color: active ? theme.onPrimary : theme.textDisabled,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Small "+" icon button shown in section headers.
class _AddRemoveButton extends StatelessWidget {
  const _AddRemoveButton({required this.onAdd, required this.theme});

  final VoidCallback onAdd;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Icon(Icons.add, size: 14, color: theme.textDisabled),
      ),
    );
  }
}
