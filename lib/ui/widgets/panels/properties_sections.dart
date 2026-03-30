import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../app/theme/theme.dart';
import '../../../data/models/vec_color.dart';
import '../../../data/models/vec_fill.dart';
import '../../../data/models/vec_gradient.dart';
import '../../../data/models/vec_motion_path.dart';
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
                          child: PanelSlider(
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
          const SizedBox(height: 6),
          // Row 3: Skew X / Skew Y
          Row(
            children: [
              NumericInput(
                label: 'SkewX°',
                value: transform.skewX,
                theme: theme,
                width: 76,
                onChanged: (v) => onUpdate(
                  (s) => s.copyWith(
                    data: s.data.copyWith(transform: s.transform.copyWith(skewX: v)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              NumericInput(
                label: 'SkewY°',
                value: transform.skewY,
                theme: theme,
                width: 76,
                onChanged: (v) => onUpdate(
                  (s) => s.copyWith(
                    data: s.data.copyWith(transform: s.transform.copyWith(skewY: v)),
                  ),
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
    final isGradient = fill.gradient != null;
    final gradType = fill.gradient?.type ?? VecGradientType.linear;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type toggle: Solid | Linear | Radial
        Row(
          children: [
            _FillTypeButton(
              label: 'Solid',
              active: !isGradient,
              theme: theme,
              onTap: () => onUpdate((s) => _updateFill(s, i, s.fills[i].copyWith(gradient: null))),
            ),
            const SizedBox(width: 4),
            _FillTypeButton(
              label: 'Linear',
              active: isGradient && gradType == VecGradientType.linear,
              theme: theme,
              onTap: () {
                final g = fill.gradient?.copyWith(type: VecGradientType.linear) ??
                    VecGradient.defaultLinear;
                onUpdate((s) => _updateFill(s, i, s.fills[i].copyWith(gradient: g)));
              },
            ),
            const SizedBox(width: 4),
            _FillTypeButton(
              label: 'Radial',
              active: isGradient && gradType == VecGradientType.radial,
              theme: theme,
              onTap: () {
                final g = (fill.gradient?.copyWith(type: VecGradientType.radial)) ??
                    VecGradient.defaultLinear.copyWith(type: VecGradientType.radial);
                onUpdate((s) => _updateFill(s, i, s.fills[i].copyWith(gradient: g)));
              },
            ),
            const Spacer(),
            // Remove fill
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
        const SizedBox(height: 6),

        if (!isGradient) ...[
          // Solid fill: color + opacity
          Row(
            children: [
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
              Expanded(
                child: PanelSlider(
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
            ],
          ),
        ] else ...[
          // Gradient: stop list + angle/opacity
          _GradientEditor(
            gradient: fill.gradient!,
            opacity: fill.opacity,
            theme: theme,
            onUpdateGradient: (g) => onUpdate((s) => _updateFill(s, i, s.fills[i].copyWith(gradient: g))),
            onUpdateOpacity: (v) => onLiveUpdate((s) => _updateFill(s, i, s.fills[i].copyWith(opacity: v))),
            onCommit: onCommit,
          ),
        ],

        const SizedBox(height: 4),
        // Blend mode
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

class _FillTypeButton extends StatelessWidget {
  const _FillTypeButton({
    required this.label,
    required this.active,
    required this.theme,
    required this.onTap,
  });

  final String label;
  final bool active;
  final AppTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: active ? theme.primaryColor.withAlpha(30) : theme.surfaceVariant,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: active ? theme.primaryColor.withAlpha(100) : theme.divider,
              width: 0.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: active ? theme.primaryColor : theme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientEditor extends HookWidget {
  const _GradientEditor({
    required this.gradient,
    required this.opacity,
    required this.theme,
    required this.onUpdateGradient,
    required this.onUpdateOpacity,
    required this.onCommit,
  });

  final VecGradient gradient;
  final double opacity;
  final AppTheme theme;
  final void Function(VecGradient) onUpdateGradient;
  final void Function(double) onUpdateOpacity;
  final VoidCallback onCommit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gradient preview bar
        Container(
          height: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              colors: gradient.stops
                  .map((s) => s.color.toFlutterColor())
                  .toList(),
              stops: gradient.stops.map((s) => s.position.toDouble()).toList(),
            ),
            border: Border.all(color: theme.divider, width: 0.5),
          ),
        ),
        const SizedBox(height: 6),

        // Stops
        for (var si = 0; si < gradient.stops.length; si++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                ColorSwatchButton(
                  color: gradient.stops[si].color.toFlutterColor(),
                  theme: theme,
                  onTap: () async {
                    final picked = await showColorPicker(
                      context: context,
                      initialColor: gradient.stops[si].color.toFlutterColor(),
                      theme: theme,
                    );
                    if (picked != null) {
                      final newStops = List<VecGradientStop>.from(gradient.stops);
                      newStops[si] = newStops[si].copyWith(color: VecColor.fromFlutterColor(picked));
                      onUpdateGradient(gradient.copyWith(stops: newStops));
                    }
                  },
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: PanelSlider(
                    value: gradient.stops[si].position,
                    theme: theme,
                    onChanged: (v) {
                      final newStops = List<VecGradientStop>.from(gradient.stops);
                      newStops[si] = newStops[si].copyWith(position: v);
                      onUpdateGradient(gradient.copyWith(stops: newStops));
                    },
                    onChangeEnd: (_) => onCommit(),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${(gradient.stops[si].position * 100).round()}%',
                  style: TextStyle(fontSize: 10, color: theme.textDisabled),
                ),
                const SizedBox(width: 4),
                if (gradient.stops.length > 2)
                  GestureDetector(
                    onTap: () {
                      final newStops = List<VecGradientStop>.from(gradient.stops)..removeAt(si);
                      onUpdateGradient(gradient.copyWith(stops: newStops));
                    },
                    child: Icon(Icons.close, size: 12, color: theme.textDisabled),
                  ),
              ],
            ),
          ),

        // Add stop button
        GestureDetector(
          onTap: () {
            final newStops = List<VecGradientStop>.from(gradient.stops)
              ..add(const VecGradientStop(
                color: VecColor(r: 128, g: 128, b: 128),
                position: 0.5,
              ));
            onUpdateGradient(gradient.copyWith(stops: newStops));
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 12, color: theme.textDisabled),
                const SizedBox(width: 2),
                Text('Add stop', style: TextStyle(fontSize: 10, color: theme.textDisabled)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),

        // Angle (linear) or Center X/Y (radial) + opacity
        if (gradient.type == VecGradientType.linear)
          Row(
            children: [
              Icon(Icons.rotate_right_outlined, size: 12, color: theme.textDisabled),
              const SizedBox(width: 4),
              SizedBox(
                width: 64,
                child: NumericInput(
                  label: '°',
                  value: gradient.angle,
                  theme: theme,
                  min: -360,
                  max: 360,
                  onChanged: (v) => onUpdateGradient(gradient.copyWith(angle: v)),
                ),
              ),
              const Spacer(),
              PanelSlider(
                value: opacity,
                theme: theme,
                onChanged: onUpdateOpacity,
                onChangeEnd: (_) => onCommit(),
              ),
              const SizedBox(width: 4),
              Text(
                '${(opacity * 100).round()}%',
                style: TextStyle(fontSize: 10, color: theme.textDisabled),
              ),
            ],
          )
        else
          Row(
            children: [
              Text('CX', style: TextStyle(fontSize: 10, color: theme.textDisabled)),
              const SizedBox(width: 4),
              SizedBox(
                width: 48,
                child: NumericInput(
                  label: '',
                  value: gradient.centerX,
                  theme: theme,
                  min: 0,
                  max: 1,
                  onChanged: (v) => onUpdateGradient(gradient.copyWith(centerX: v)),
                ),
              ),
              const SizedBox(width: 6),
              Text('CY', style: TextStyle(fontSize: 10, color: theme.textDisabled)),
              const SizedBox(width: 4),
              SizedBox(
                width: 48,
                child: NumericInput(
                  label: '',
                  value: gradient.centerY,
                  theme: theme,
                  min: 0,
                  max: 1,
                  onChanged: (v) => onUpdateGradient(gradient.copyWith(centerY: v)),
                ),
              ),
            ],
          ),
      ],
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
              child: PanelSlider(
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
        const SizedBox(height: 4),
        // Dash pattern
        _DashPatternRow(
          stroke: stroke,
          index: i,
          theme: theme,
          onUpdate: onUpdate,
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
// Dash Pattern row (used inside _StrokeRow)
// ---------------------------------------------------------------------------

class _DashPatternRow extends HookWidget {
  const _DashPatternRow({
    required this.stroke,
    required this.index,
    required this.theme,
    required this.onUpdate,
  });

  final VecStroke stroke;
  final int index;
  final AppTheme theme;
  final ShapeCommit onUpdate;

  String _patternToText(List<double> pattern) =>
      pattern.map((v) => v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1)).join(', ');

  List<double> _parsePattern(String text) {
    final parts = text.split(RegExp(r'[,\s]+'));
    final result = <double>[];
    for (final p in parts) {
      final v = double.tryParse(p.trim());
      if (v != null && v >= 0) result.add(v);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final i = index;
    final hasDash = stroke.dashPattern.isNotEmpty;
    final ctrl = useTextEditingController(text: _patternToText(stroke.dashPattern));

    useEffect(() {
      final updated = _patternToText(stroke.dashPattern);
      if (ctrl.text != updated) ctrl.text = updated;
      return null;
    }, [stroke.dashPattern]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle dash on/off
        Row(
          children: [
            Text('Dash', style: TextStyle(fontSize: 10, color: theme.textDisabled, fontWeight: FontWeight.w500)),
            const Spacer(),
            GestureDetector(
              onTap: () {
                final newPattern = hasDash ? <double>[] : [4.0, 2.0];
                onUpdate((s) => _StrokeRow._updateStroke(
                    s, i, s.strokes[i].copyWith(dashPattern: newPattern)));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: 28,
                height: 14,
                decoration: BoxDecoration(
                  color: hasDash ? theme.primaryColor : theme.divider,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 120),
                  alignment: hasDash ? Alignment.centerRight : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Container(
                      width: 10, height: 10,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (hasDash) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              // Pattern text field
              Expanded(
                child: Container(
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: theme.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: theme.divider, width: 0.5),
                  ),
                  child: TextField(
                    controller: ctrl,
                    style: TextStyle(fontSize: 10, color: theme.textPrimary),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintText: '4, 2, 1, 2',
                    ),
                    onSubmitted: (v) {
                      final pattern = _parsePattern(v);
                      onUpdate((s) => _StrokeRow._updateStroke(
                          s, i, s.strokes[i].copyWith(dashPattern: pattern)));
                    },
                    onTapOutside: (_) {
                      final pattern = _parsePattern(ctrl.text);
                      onUpdate((s) => _StrokeRow._updateStroke(
                          s, i, s.strokes[i].copyWith(dashPattern: pattern)));
                    },
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Dash offset
              NumericInput(
                label: 'Off',
                value: stroke.dashOffset,
                theme: theme,
                width: 52,
                min: 0,
                onChanged: (v) => onUpdate(
                    (s) => _StrokeRow._updateStroke(s, i, s.strokes[i].copyWith(dashOffset: v))),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 4. Text Section (text shapes only)
// ---------------------------------------------------------------------------

class TextSection extends StatelessWidget {
  const TextSection({
    super.key,
    required this.shape,
    required this.theme,
    required this.onUpdate,
  });

  final VecTextShape shape;
  final AppTheme theme;
  final ShapeCommit onUpdate;

  @override
  Widget build(BuildContext context) {
    return CollapsibleSection(
      title: 'Text',
      theme: theme,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Font family + size
          Row(
            children: [
              Expanded(child: _FontFamilyField(shape: shape, theme: theme, onUpdate: onUpdate)),
              const SizedBox(width: 8),
              NumericInput(
                label: 'Size',
                value: shape.fontSize,
                min: 1,
                width: 60,
                theme: theme,
                onChanged: (v) => onUpdate(
                  (s) => s.maybeMap(text: (t) => t.copyWith(fontSize: v), orElse: () => s),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Font weight + alignment
          Row(
            children: [
              Expanded(child: _FontWeightDropdown(shape: shape, theme: theme, onUpdate: onUpdate)),
              const SizedBox(width: 8),
              _AlignmentButtons(shape: shape, theme: theme, onUpdate: onUpdate),
            ],
          ),
          const SizedBox(height: 8),
          // Tracking + Leading
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              NumericInput(
                label: 'Tracking',
                value: shape.tracking,
                width: 76,
                theme: theme,
                onChanged: (v) => onUpdate(
                  (s) => s.maybeMap(text: (t) => t.copyWith(tracking: v), orElse: () => s),
                ),
              ),
              NumericInput(
                label: 'Leading',
                value: shape.leading,
                min: 0.1,
                width: 76,
                theme: theme,
                onChanged: (v) => onUpdate(
                  (s) => s.maybeMap(text: (t) => t.copyWith(leading: v), orElse: () => s),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FontFamilyField extends HookWidget {
  const _FontFamilyField({required this.shape, required this.theme, required this.onUpdate});

  final VecTextShape shape;
  final AppTheme theme;
  final ShapeCommit onUpdate;

  static const _commonFonts = [
    'Inter', 'Roboto', 'Arial', 'Helvetica', 'Georgia',
    'Times New Roman', 'Courier New', 'Verdana', 'Trebuchet MS',
  ];

  @override
  Widget build(BuildContext context) {
    final ctrl = useTextEditingController(text: shape.fontFamily);
    final focus = useFocusNode();

    useEffect(() {
      // Sync controller when shape updates externally
      if (ctrl.text != shape.fontFamily) ctrl.text = shape.fontFamily;
      return null;
    }, [shape.fontFamily]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Font', style: TextStyle(fontSize: 10, color: theme.textDisabled, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Container(
          height: 26,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: theme.surfaceVariant,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: focus.hasFocus ? theme.primaryColor : theme.divider,
              width: focus.hasFocus ? 1.0 : 0.5,
            ),
          ),
          child: TextField(
            controller: ctrl,
            focusNode: focus,
            style: TextStyle(fontSize: 11, color: theme.textPrimary),
            decoration: const InputDecoration(isDense: true, border: InputBorder.none, contentPadding: EdgeInsets.zero),
            onSubmitted: (v) {
              final font = v.trim().isEmpty ? 'Inter' : v.trim();
              onUpdate((s) => s.maybeMap(text: (t) => t.copyWith(fontFamily: font), orElse: () => s));
            },
            onEditingComplete: () {
              final font = ctrl.text.trim().isEmpty ? 'Inter' : ctrl.text.trim();
              onUpdate((s) => s.maybeMap(text: (t) => t.copyWith(fontFamily: font), orElse: () => s));
              focus.unfocus();
            },
          ),
        ),
        // Quick-select chips for common fonts
        const SizedBox(height: 4),
        Wrap(
          spacing: 3,
          runSpacing: 3,
          children: _commonFonts.map((f) {
            final active = shape.fontFamily == f;
            return GestureDetector(
              onTap: () {
                ctrl.text = f;
                onUpdate((s) => s.maybeMap(text: (t) => t.copyWith(fontFamily: f), orElse: () => s));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: active ? theme.primaryColor : theme.surfaceVariant,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: active ? theme.primaryColor : theme.divider, width: 0.5),
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    fontSize: 9,
                    color: active ? theme.onPrimary : theme.textDisabled,
                    fontFamily: f,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _FontWeightDropdown extends StatelessWidget {
  const _FontWeightDropdown({required this.shape, required this.theme, required this.onUpdate});

  final VecTextShape shape;
  final AppTheme theme;
  final ShapeCommit onUpdate;

  static const _weights = [
    (100, 'Thin'),
    (200, 'ExtraLight'),
    (300, 'Light'),
    (400, 'Regular'),
    (500, 'Medium'),
    (600, 'SemiBold'),
    (700, 'Bold'),
    (800, 'ExtraBold'),
    (900, 'Black'),
  ];

  @override
  Widget build(BuildContext context) {
    // Snap to nearest weight step
    final current = (shape.fontWeight ~/ 100) * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Weight', style: TextStyle(fontSize: 10, color: theme.textDisabled, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Container(
          height: 26,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: theme.surfaceVariant,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: theme.divider, width: 0.5),
          ),
          child: DropdownButton<int>(
            value: _weights.any((w) => w.$1 == current) ? current : 400,
            onChanged: (v) {
              if (v != null) {
                onUpdate((s) => s.maybeMap(text: (t) => t.copyWith(fontWeight: v), orElse: () => s));
              }
            },
            isExpanded: true,
            underline: const SizedBox.shrink(),
            icon: Icon(Icons.expand_more, size: 12, color: theme.textDisabled),
            dropdownColor: theme.surface,
            style: TextStyle(fontSize: 11, color: theme.textPrimary),
            items: _weights.map((w) {
              return DropdownMenuItem<int>(
                value: w.$1,
                child: Text(
                  '${w.$2} ${w.$1}',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.textPrimary,
                    fontWeight: FontWeight.values[((w.$1 / 100).round() - 1).clamp(0, 8)],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _AlignmentButtons extends StatelessWidget {
  const _AlignmentButtons({required this.shape, required this.theme, required this.onUpdate});

  final VecTextShape shape;
  final AppTheme theme;
  final ShapeCommit onUpdate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('Align', style: TextStyle(fontSize: 10, color: theme.textDisabled, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AlignBtn(icon: Icons.format_align_left, active: shape.alignment == VecTextAlign.left, theme: theme,
                onTap: () => onUpdate((s) => s.maybeMap(text: (t) => t.copyWith(alignment: VecTextAlign.left), orElse: () => s))),
            _AlignBtn(icon: Icons.format_align_center, active: shape.alignment == VecTextAlign.center, theme: theme,
                onTap: () => onUpdate((s) => s.maybeMap(text: (t) => t.copyWith(alignment: VecTextAlign.center), orElse: () => s))),
            _AlignBtn(icon: Icons.format_align_right, active: shape.alignment == VecTextAlign.right, theme: theme,
                onTap: () => onUpdate((s) => s.maybeMap(text: (t) => t.copyWith(alignment: VecTextAlign.right), orElse: () => s))),
            _AlignBtn(icon: Icons.format_align_justify, active: shape.alignment == VecTextAlign.justify, theme: theme,
                onTap: () => onUpdate((s) => s.maybeMap(text: (t) => t.copyWith(alignment: VecTextAlign.justify), orElse: () => s))),
          ],
        ),
      ],
    );
  }
}

class _AlignBtn extends StatelessWidget {
  const _AlignBtn({required this.icon, required this.active, required this.theme, required this.onTap});

  final IconData icon;
  final bool active;
  final AppTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 26,
        margin: const EdgeInsets.only(left: 2),
        decoration: BoxDecoration(
          color: active ? theme.primaryColor : theme.surfaceVariant,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: active ? theme.primaryColor : theme.divider, width: 0.5),
        ),
        child: Icon(icon, size: 12, color: active ? theme.onPrimary : theme.textDisabled),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5a. Ellipse Section (arcs / donuts — ellipse shapes only)
// ---------------------------------------------------------------------------

class EllipseSection extends StatelessWidget {
  const EllipseSection({
    super.key,
    required this.shape,
    required this.theme,
    required this.onUpdate,
    required this.onLiveUpdate,
    required this.onCommit,
  });

  final VecEllipseShape shape;
  final AppTheme theme;
  final ShapeCommit onUpdate;
  final ShapeLiveUpdate onLiveUpdate;
  final VoidCallback onCommit;

  @override
  Widget build(BuildContext context) {
    return CollapsibleSection(
      title: 'Arc / Donut',
      theme: theme,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Start / End angles
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              NumericInput(
                label: 'Start°',
                value: shape.startAngle,
                min: 0,
                max: 360,
                theme: theme,
                width: 72,
                onChanged: (v) => onUpdate(
                  (s) => s.maybeMap(
                    ellipse: (e) => e.copyWith(startAngle: v.clamp(0, 360)),
                    orElse: () => s,
                  ),
                ),
              ),
              NumericInput(
                label: 'End°',
                value: shape.endAngle,
                min: 0,
                max: 360,
                theme: theme,
                width: 72,
                onChanged: (v) => onUpdate(
                  (s) => s.maybeMap(
                    ellipse: (e) => e.copyWith(endAngle: v.clamp(0, 360)),
                    orElse: () => s,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Inner radius (donut hole)
          Text('Inner Radius', style: TextStyle(fontSize: 10, color: theme.textDisabled, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: PanelSlider(
                  value: shape.innerRadius.clamp(0.0, 1.0),
                  theme: theme,
                  onChanged: (v) => onLiveUpdate(
                    (s) => s.maybeMap(
                      ellipse: (e) => e.copyWith(innerRadius: v),
                      orElse: () => s,
                    ),
                  ),
                  onChangeEnd: (_) => onCommit(),
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 36,
                child: Text(
                  '${(shape.innerRadius * 100).round()}%',
                  style: TextStyle(fontSize: 10, color: theme.textDisabled),
                  textAlign: TextAlign.right,
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
// 5b. Polygon Section (sides + star depth — polygon shapes only)
// ---------------------------------------------------------------------------

class PolygonSection extends StatelessWidget {
  const PolygonSection({
    super.key,
    required this.shape,
    required this.theme,
    required this.onUpdate,
    required this.onLiveUpdate,
    required this.onCommit,
  });

  final VecPolygonShape shape;
  final AppTheme theme;
  final ShapeCommit onUpdate;
  final ShapeLiveUpdate onLiveUpdate;
  final VoidCallback onCommit;

  @override
  Widget build(BuildContext context) {
    final isStar = shape.starDepth != null;
    return CollapsibleSection(
      title: 'Polygon',
      theme: theme,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Side count
          Row(
            children: [
              NumericInput(
                label: 'Sides',
                value: shape.sideCount.toDouble(),
                min: 3,
                max: 64,
                step: 1,
                theme: theme,
                width: 72,
                onChanged: (v) => onUpdate(
                  (s) => s.maybeMap(
                    polygon: (p) => p.copyWith(sideCount: v.round().clamp(3, 64)),
                    orElse: () => s,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Star toggle
              GestureDetector(
                onTap: () => onUpdate(
                  (s) => s.maybeMap(
                    polygon: (p) => p.copyWith(starDepth: isStar ? null : 0.5),
                    orElse: () => s,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      width: 28,
                      height: 14,
                      decoration: BoxDecoration(
                        color: isStar ? theme.primaryColor : theme.divider,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 120),
                        alignment: isStar ? Alignment.centerRight : Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Container(
                            width: 10, height: 10,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text('Star', style: TextStyle(fontSize: 10, color: theme.textDisabled)),
                  ],
                ),
              ),
            ],
          ),
          if (isStar) ...[
            const SizedBox(height: 8),
            Text('Star Depth', style: TextStyle(fontSize: 10, color: theme.textDisabled, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: PanelSlider(
                    value: (shape.starDepth ?? 0.5).clamp(0.0, 1.0),
                    theme: theme,
                    onChanged: (v) => onLiveUpdate(
                      (s) => s.maybeMap(
                        polygon: (p) => p.copyWith(starDepth: v),
                        orElse: () => s,
                      ),
                    ),
                    onChangeEnd: (_) => onCommit(),
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 36,
                  child: Text(
                    '${((shape.starDepth ?? 0.5) * 100).round()}%',
                    style: TextStyle(fontSize: 10, color: theme.textDisabled),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. Blend Mode Section (shape-level blendMode)
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
class PanelSlider extends StatelessWidget {
  const PanelSlider({super.key, required this.value, required this.theme, required this.onChanged, this.onChangeEnd});

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

// ---------------------------------------------------------------------------
// 6. Motion Path Section
// ---------------------------------------------------------------------------

class MotionPathSection extends StatelessWidget {
  const MotionPathSection({
    super.key,
    required this.shapeId,
    required this.motionPath,   // null = no path yet
    required this.isDrawing,    // currently in drawing mode for this shape
    required this.theme,
    required this.onStartDraw,
    required this.onRemove,
    required this.onToggleOrient,
    required this.onToggleEase,
  });

  final String shapeId;
  final VecMotionPath? motionPath;
  final bool isDrawing;
  final AppTheme theme;
  final VoidCallback onStartDraw;
  final VoidCallback onRemove;
  final VoidCallback onToggleOrient;
  final VoidCallback onToggleEase;

  @override
  Widget build(BuildContext context) {
    return CollapsibleSection(
      title: 'Motion Path',
      theme: theme,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (motionPath == null && !isDrawing) ...[
            // No path yet — show Draw button
            _MpButton(
              label: 'Draw Path',
              icon: Icons.timeline,
              active: false,
              theme: theme,
              onTap: onStartDraw,
            ),
            const SizedBox(height: 4),
            Text(
              'Click on the canvas to place nodes.\nDouble-click or press Esc to finish.',
              style: TextStyle(fontSize: 10, color: theme.textDisabled),
            ),
          ] else if (isDrawing) ...[
            // Currently drawing
            _MpButton(
              label: 'Drawing… (Esc to cancel)',
              icon: Icons.edit_road,
              active: true,
              theme: theme,
              onTap: () {}, // ESC handled globally
            ),
          ] else ...[
            // Path exists — show toggles + remove
            Row(
              children: [
                _MpToggle(
                  label: 'Orient',
                  icon: Icons.navigation,
                  active: motionPath!.orientToPath,
                  theme: theme,
                  onTap: onToggleOrient,
                ),
                const SizedBox(width: 6),
                _MpToggle(
                  label: 'Ease',
                  icon: Icons.show_chart,
                  active: motionPath!.easeAlongPath,
                  theme: theme,
                  onTap: onToggleEase,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onRemove,
                  child: Tooltip(
                    message: 'Remove motion path',
                    child: Icon(Icons.delete_outline,
                        size: 15, color: theme.textDisabled),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.check_circle_outline,
                    size: 11, color: theme.accentColor),
                const SizedBox(width: 4),
                Text(
                  '${motionPath!.nodes.length} node${motionPath!.nodes.length == 1 ? '' : 's'}',
                  style: TextStyle(fontSize: 10, color: theme.textDisabled),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _MpButton(
              label: 'Redraw Path',
              icon: Icons.redo,
              active: false,
              theme: theme,
              onTap: onStartDraw,
            ),
          ],
        ],
      ),
    );
  }
}

class _MpButton extends StatelessWidget {
  const _MpButton({
    required this.label,
    required this.icon,
    required this.active,
    required this.theme,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final AppTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: active
              ? theme.primaryColor.withAlpha(25)
              : theme.surfaceVariant,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: active ? theme.primaryColor : theme.divider,
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 12,
                color: active ? theme.primaryColor : theme.textDisabled),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: active ? theme.primaryColor : theme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MpToggle extends StatelessWidget {
  const _MpToggle({
    required this.label,
    required this.icon,
    required this.active,
    required this.theme,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final AppTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color:
              active ? theme.primaryColor.withAlpha(30) : theme.surfaceVariant,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: active ? theme.primaryColor : theme.divider,
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 11,
                color: active ? theme.primaryColor : theme.textDisabled),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: active ? theme.primaryColor : theme.textDisabled,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Align & Distribute Section (multi-selection)
// ---------------------------------------------------------------------------

typedef AlignAction = void Function(List<VecShape> shapes);

class AlignSection extends StatelessWidget {
  const AlignSection({
    super.key,
    required this.shapes,
    required this.theme,
    required this.onAlignApply,
  });

  final List<VecShape> shapes;
  final AppTheme theme;

  /// Called with the updated list of shapes after alignment.
  final void Function(List<VecShape> updated) onAlignApply;

  // ── helpers ─────────────────────────────────────────────────────────────

  double _left(VecShape s) => s.data.transform.x;
  double _top(VecShape s) => s.data.transform.y;
  double _right(VecShape s) => s.data.transform.x + s.data.transform.width;
  double _bottom(VecShape s) => s.data.transform.y + s.data.transform.height;
  double _cx(VecShape s) => s.data.transform.x + s.data.transform.width / 2;
  double _cy(VecShape s) => s.data.transform.y + s.data.transform.height / 2;

  VecShape _moveTo(VecShape s, double? x, double? y) => s.copyWith(
        data: s.data.copyWith(
          transform: s.data.transform.copyWith(
            x: x ?? s.data.transform.x,
            y: y ?? s.data.transform.y,
          ),
        ),
      );

  void _alignLeft() {
    final minX = shapes.map(_left).reduce((a, b) => a < b ? a : b);
    onAlignApply([for (final s in shapes) _moveTo(s, minX, null)]);
  }

  void _alignRight() {
    final maxX = shapes.map(_right).reduce((a, b) => a > b ? a : b);
    onAlignApply([for (final s in shapes) _moveTo(s, maxX - s.data.transform.width, null)]);
  }

  void _alignCenterH() {
    final avgCX = shapes.map(_cx).reduce((a, b) => a + b) / shapes.length;
    onAlignApply([for (final s in shapes) _moveTo(s, avgCX - s.data.transform.width / 2, null)]);
  }

  void _alignTop() {
    final minY = shapes.map(_top).reduce((a, b) => a < b ? a : b);
    onAlignApply([for (final s in shapes) _moveTo(s, null, minY)]);
  }

  void _alignBottom() {
    final maxY = shapes.map(_bottom).reduce((a, b) => a > b ? a : b);
    onAlignApply([for (final s in shapes) _moveTo(s, null, maxY - s.data.transform.height)]);
  }

  void _alignCenterV() {
    final avgCY = shapes.map(_cy).reduce((a, b) => a + b) / shapes.length;
    onAlignApply([for (final s in shapes) _moveTo(s, null, avgCY - s.data.transform.height / 2)]);
  }

  void _distributeH() {
    if (shapes.length < 3) return;
    final sorted = [...shapes]..sort((a, b) => _left(a).compareTo(_left(b)));
    final minX = _left(sorted.first);
    final maxX = _right(sorted.last);
    final totalW = sorted.fold<double>(0, (sum, s) => sum + s.data.transform.width);
    final gap = (maxX - minX - totalW) / (sorted.length - 1);
    double x = minX;
    final updated = <VecShape>[];
    for (final s in sorted) {
      updated.add(_moveTo(s, x, null));
      x += s.data.transform.width + gap;
    }
    onAlignApply(updated);
  }

  void _distributeV() {
    if (shapes.length < 3) return;
    final sorted = [...shapes]..sort((a, b) => _top(a).compareTo(_top(b)));
    final minY = _top(sorted.first);
    final maxY = _bottom(sorted.last);
    final totalH = sorted.fold<double>(0, (sum, s) => sum + s.data.transform.height);
    final gap = (maxY - minY - totalH) / (sorted.length - 1);
    double y = minY;
    final updated = <VecShape>[];
    for (final s in sorted) {
      updated.add(_moveTo(s, null, y));
      y += s.data.transform.height + gap;
    }
    onAlignApply(updated);
  }

  // ── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return CollapsibleSection(
      title: 'Align & Distribute',
      theme: t,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Align row
          Text('Align', style: TextStyle(fontSize: 9, color: t.textDisabled, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Row(
            children: [
              _DistributeBtn(icon: Icons.align_horizontal_left_outlined,   tooltip: 'Align left',      onTap: _alignLeft,    theme: t),
              const SizedBox(width: 4),
              _DistributeBtn(icon: Icons.align_horizontal_center_outlined, tooltip: 'Center horizontal', onTap: _alignCenterH, theme: t),
              const SizedBox(width: 4),
              _DistributeBtn(icon: Icons.align_horizontal_right_outlined,  tooltip: 'Align right',     onTap: _alignRight,   theme: t),
              const SizedBox(width: 12),
              _DistributeBtn(icon: Icons.align_vertical_top_outlined,      tooltip: 'Align top',       onTap: _alignTop,     theme: t),
              const SizedBox(width: 4),
              _DistributeBtn(icon: Icons.align_vertical_center_outlined,   tooltip: 'Center vertical',  onTap: _alignCenterV, theme: t),
              const SizedBox(width: 4),
              _DistributeBtn(icon: Icons.align_vertical_bottom_outlined,   tooltip: 'Align bottom',    onTap: _alignBottom,  theme: t),
            ],
          ),
          const SizedBox(height: 10),
          // Distribute row
          Text('Distribute', style: TextStyle(fontSize: 9, color: t.textDisabled, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Row(
            children: [
              _DistributeBtn(
                icon: Icons.horizontal_distribute,
                tooltip: 'Distribute horizontally',
                onTap: shapes.length >= 3 ? _distributeH : null,
                theme: t,
              ),
              const SizedBox(width: 4),
              _DistributeBtn(
                icon: Icons.vertical_distribute,
                tooltip: 'Distribute vertically',
                onTap: shapes.length >= 3 ? _distributeV : null,
                theme: t,
              ),
              if (shapes.length < 3) ...[
                const SizedBox(width: 8),
                Text('(need 3+)', style: TextStyle(fontSize: 9, color: t.textDisabled)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DistributeBtn extends StatelessWidget {
  const _DistributeBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.theme,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 400),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          hoverColor: enabled ? theme.primaryColor.withAlpha(20) : Colors.transparent,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: theme.divider.withAlpha(80)),
              color: theme.surfaceVariant,
            ),
            child: Icon(
              icon,
              size: 14,
              color: enabled ? theme.textSecondary : theme.textDisabled.withAlpha(80),
            ),
          ),
        ),
      ),
    );
  }
}
