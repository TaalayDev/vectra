import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../data/models/vec_color.dart';
import '../../../data/models/vec_stroke.dart';
import '../../../providers/freedraw_state_provider.dart';
import '../common/collapsible_section.dart';
import '../common/color_swatch_button.dart';
import '../common/color_picker.dart';
import 'properties_sections.dart' show PanelSlider;

class FreeDrawOptionsPanel extends HookConsumerWidget {
  const FreeDrawOptionsPanel({super.key, required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(freeDrawSettingsProvider);
    final notifier = ref.read(freeDrawSettingsProvider.notifier);

    return CollapsibleSection(
      title: 'Free Draw',
      theme: theme,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Color + Opacity ──────────────────────────────────────────────
          Row(
            children: [
              Text('Color', style: TextStyle(fontSize: 11, color: theme.textSecondary)),
              const SizedBox(width: 8),
              ColorSwatchButton(
                color: settings.color,
                theme: theme,
                onTap: () async {
                  final picked = await showColorPicker(
                    context: context,
                    initialColor: settings.color,
                    theme: theme,
                  );
                  if (picked != null) notifier.setColor(picked);
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PanelSlider(
                  value: settings.opacity,
                  theme: theme,
                  onChanged: notifier.setOpacity,
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 30,
                child: Text(
                  '${(settings.opacity * 100).round()}%',
                  style: TextStyle(fontSize: 10, color: theme.textDisabled),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Width ────────────────────────────────────────────────────────
          Row(
            children: [
              Text('Width', style: TextStyle(fontSize: 11, color: theme.textSecondary)),
              const SizedBox(width: 8),
              Expanded(
                child: _WidthSlider(
                  value: settings.width,
                  theme: theme,
                  onChanged: notifier.setWidth,
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 34,
                child: Text(
                  '${settings.width.toStringAsFixed(settings.width < 10 ? 1 : 0)}px',
                  style: TextStyle(fontSize: 10, color: theme.textDisabled),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Cap ──────────────────────────────────────────────────────────
          Row(
            children: [
              Text('Cap', style: TextStyle(fontSize: 11, color: theme.textSecondary)),
              const SizedBox(width: 8),
              _CapToggle(
                value: settings.cap,
                theme: theme,
                onChanged: notifier.setCap,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Close + Fill toggles ─────────────────────────────────────────
          Row(
            children: [
              _ToggleChip(
                label: 'Close',
                active: settings.close,
                theme: theme,
                onTap: () => notifier.setClose(!settings.close),
              ),
              const SizedBox(width: 6),
              _ToggleChip(
                label: 'Fill',
                active: settings.fill,
                theme: theme,
                onTap: () => notifier.setFill(!settings.fill),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Width slider — maps 0.5–64 on a logarithmic-ish scale via sqrt
// ---------------------------------------------------------------------------

class _WidthSlider extends StatelessWidget {
  const _WidthSlider({
    required this.value,
    required this.theme,
    required this.onChanged,
  });

  final double value;
  final AppTheme theme;
  final ValueChanged<double> onChanged;

  static const _min = 0.5;
  static const _max = 64.0;

  // Map real width → slider [0,1] via sqrt for better low-end precision
  double get _sliderValue => ((value - _min) / (_max - _min)).clamp(0.0, 1.0);

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
      child: Slider(
        value: _sliderValue,
        onChanged: (v) {
          final real = _min + v * (_max - _min);
          onChanged(double.parse(real.toStringAsFixed(1)));
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Cap toggle (Butt / Round / Square)
// ---------------------------------------------------------------------------

class _CapToggle extends StatelessWidget {
  const _CapToggle({
    required this.value,
    required this.theme,
    required this.onChanged,
  });

  final VecStrokeCap value;
  final AppTheme theme;
  final ValueChanged<VecStrokeCap> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _capBtn(VecStrokeCap.butt, 'Butt'),
        const SizedBox(width: 4),
        _capBtn(VecStrokeCap.round, 'Round'),
        const SizedBox(width: 4),
        _capBtn(VecStrokeCap.square, 'Square'),
      ],
    );
  }

  Widget _capBtn(VecStrokeCap cap, String label) {
    final active = value == cap;
    return GestureDetector(
      onTap: () => onChanged(cap),
      child: Container(
        height: 22,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: active
              ? theme.primaryColor.withAlpha(20)
              : theme.surfaceVariant,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: active ? theme.primaryColor : theme.divider,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: active ? theme.primaryColor : theme.textSecondary,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Toggle chip (Close / Fill)
// ---------------------------------------------------------------------------

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
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
      child: Container(
        height: 24,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: active
              ? theme.primaryColor.withAlpha(18)
              : theme.surfaceVariant,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: active ? theme.primaryColor : theme.divider,
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (active)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(Icons.check, size: 10, color: theme.primaryColor),
              ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: active ? theme.primaryColor : theme.textSecondary,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
