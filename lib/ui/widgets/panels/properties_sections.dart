import 'package:flutter/material.dart';

import '../../../app/theme/theme.dart';
import '../../../data/models/vec_fill.dart';
import '../../../data/models/vec_stroke.dart';
import '../../../data/models/vec_transform.dart';
import '../common/collapsible_section.dart';
import '../common/color_swatch_button.dart';
import '../common/numeric_input.dart';

class TransformSection extends StatelessWidget {
  const TransformSection({
    super.key,
    required this.transform,
    required this.theme,
  });

  final VecTransform transform;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return CollapsibleSection(
      title: 'Transform',
      theme: theme,
      content: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          NumericInput(label: 'X', value: transform.x, onChanged: (_) {}, theme: theme),
          NumericInput(label: 'Y', value: transform.y, onChanged: (_) {}, theme: theme),
          NumericInput(label: 'W', value: transform.width, onChanged: (_) {}, theme: theme, min: 0),
          NumericInput(label: 'H', value: transform.height, onChanged: (_) {}, theme: theme, min: 0),
          NumericInput(label: 'R', value: transform.rotation, onChanged: (_) {}, theme: theme, width: 72),
        ],
      ),
    );
  }
}

class FillSection extends StatelessWidget {
  const FillSection({
    super.key,
    required this.fills,
    required this.theme,
  });

  final List<VecFill> fills;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return CollapsibleSection(
      title: 'Fill',
      theme: theme,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (fills.isEmpty)
            Text(
              'No fill',
              style: TextStyle(fontSize: 11, color: theme.textDisabled),
            )
          else
            for (final fill in fills)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    ColorSwatchButton(
                      color: fill.color.toFlutterColor(),
                      theme: theme,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 2,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                          activeTrackColor: theme.primaryColor,
                          inactiveTrackColor: theme.divider,
                          thumbColor: theme.primaryColor,
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                        ),
                        child: Slider(
                          value: fill.opacity,
                          onChanged: (_) {},
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 32,
                      child: Text(
                        '${(fill.opacity * 100).round()}%',
                        style: TextStyle(fontSize: 10, color: theme.textDisabled),
                        textAlign: TextAlign.right,
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

class StrokeSection extends StatelessWidget {
  const StrokeSection({
    super.key,
    required this.strokes,
    required this.theme,
  });

  final List<VecStroke> strokes;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return CollapsibleSection(
      title: 'Stroke',
      theme: theme,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (strokes.isEmpty)
            Text(
              'No stroke',
              style: TextStyle(fontSize: 11, color: theme.textDisabled),
            )
          else
            for (final stroke in strokes)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Column(
                  children: [
                    Row(
                      children: [
                        ColorSwatchButton(
                          color: stroke.color.toFlutterColor(),
                          theme: theme,
                        ),
                        const SizedBox(width: 8),
                        NumericInput(
                          label: 'Width',
                          value: stroke.width,
                          onChanged: (_) {},
                          theme: theme,
                          min: 0,
                          width: 56,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 2,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                              activeTrackColor: theme.primaryColor,
                              inactiveTrackColor: theme.divider,
                              thumbColor: theme.primaryColor,
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                            ),
                            child: Slider(
                              value: stroke.opacity,
                              onChanged: (_) {},
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Cap / Join indicators
                    Row(
                      children: [
                        _PropertyChip(
                          label: stroke.cap.name,
                          theme: theme,
                        ),
                        const SizedBox(width: 4),
                        _PropertyChip(
                          label: stroke.join.name,
                          theme: theme,
                        ),
                        const SizedBox(width: 4),
                        _PropertyChip(
                          label: stroke.align.name,
                          theme: theme,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class BlendSection extends StatelessWidget {
  const BlendSection({
    super.key,
    required this.opacity,
    required this.blendMode,
    required this.theme,
  });

  final double opacity;
  final VecBlendMode blendMode;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return CollapsibleSection(
      title: 'Blend',
      theme: theme,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Blend mode
          Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: theme.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: theme.divider, width: 0.5),
            ),
            child: DropdownButton<VecBlendMode>(
              value: blendMode,
              onChanged: (_) {},
              isExpanded: true,
              underline: const SizedBox.shrink(),
              icon: Icon(Icons.expand_more, size: 14, color: theme.textDisabled),
              dropdownColor: theme.surface,
              style: TextStyle(fontSize: 11, color: theme.textPrimary),
              items: VecBlendMode.values.map((mode) {
                return DropdownMenuItem(
                  value: mode,
                  child: Text(mode.name),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Opacity
          Row(
            children: [
              Text(
                'Opacity',
                style: TextStyle(fontSize: 10, color: theme.textDisabled),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                    activeTrackColor: theme.primaryColor,
                    inactiveTrackColor: theme.divider,
                    thumbColor: theme.primaryColor,
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                  ),
                  child: Slider(
                    value: opacity,
                    onChanged: (_) {},
                  ),
                ),
              ),
              SizedBox(
                width: 32,
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
    );
  }
}

class _PropertyChip extends StatelessWidget {
  const _PropertyChip({required this.label, required this.theme});

  final String label;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.surfaceVariant,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 9, color: theme.textDisabled),
      ),
    );
  }
}
