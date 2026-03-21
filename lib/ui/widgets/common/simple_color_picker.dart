import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../app/theme/theme.dart';

/// Opens a compact color picker dialog.
/// Returns the picked [Color], or null if dismissed.
Future<Color?> showSimpleColorPicker({
  required BuildContext context,
  required Color initialColor,
  required AppTheme theme,
}) {
  return showDialog<Color>(
    context: context,
    barrierColor: Colors.black26,
    builder: (_) => _SimpleColorPickerDialog(
      initialColor: initialColor,
      theme: theme,
    ),
  );
}

// ---------------------------------------------------------------------------
// Preset palette (20 colors)
// ---------------------------------------------------------------------------

const _kPresets = <Color>[
  Color(0xFF000000), Color(0xFF323C50), Color(0xFF4A5568), Color(0xFF718096),
  Color(0xFF9CA3AF), Color(0xFFFFFFFF), Color(0xFFEF4444), Color(0xFFF97316),
  Color(0xFFF59E0B), Color(0xFFEAB308), Color(0xFF84CC16), Color(0xFF22C55E),
  Color(0xFF14B8A6), Color(0xFF06B6D4), Color(0xFF3B82F6), Color(0xFF6366F1),
  Color(0xFF8B5CF6), Color(0xFFEC4899), Color(0xFF78A0E6), Color(0xFFFF5722),
];

// ---------------------------------------------------------------------------
// Dialog widget
// ---------------------------------------------------------------------------

class _SimpleColorPickerDialog extends HookWidget {
  const _SimpleColorPickerDialog({
    required this.initialColor,
    required this.theme,
  });

  final Color initialColor;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    final current = useState(initialColor);
    final hexController = useTextEditingController(
      text: _colorToHex(initialColor),
    );
    final hexFocus = useFocusNode();

    void applyHex(String hex) {
      final cleaned = hex.replaceAll('#', '').trim();
      if (cleaned.length == 6 || cleaned.length == 8) {
        final parsed = int.tryParse(
          cleaned.length == 6 ? 'FF$cleaned' : cleaned,
          radix: 16,
        );
        if (parsed != null) {
          final c = Color(parsed);
          current.value = c;
        }
      }
    }

    return Dialog(
      backgroundColor: theme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.divider, width: 0.5),
      ),
      insetPadding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 220,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Color',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),

              // Preview bar
              Container(
                height: 32,
                decoration: BoxDecoration(
                  color: current.value,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: theme.divider, width: 0.5),
                ),
              ),
              const SizedBox(height: 8),

              // HEX input
              SizedBox(
                height: 30,
                child: Focus(
                  onFocusChange: (hasFocus) {
                    if (!hasFocus) applyHex(hexController.text);
                  },
                  child: TextField(
                    controller: hexController,
                    focusNode: hexFocus,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textPrimary,
                      fontFamily: 'monospace',
                    ),
                    decoration: InputDecoration(
                      prefixText: '#',
                      prefixStyle: TextStyle(
                          fontSize: 12, color: theme.textDisabled),
                      filled: true,
                      fillColor: theme.surfaceVariant,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide:
                            BorderSide(color: theme.divider, width: 0.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide:
                            BorderSide(color: theme.divider, width: 0.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide:
                            BorderSide(color: theme.primaryColor, width: 1),
                      ),
                      isDense: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9a-fA-F]')),
                      LengthLimitingTextInputFormatter(8),
                    ],
                    onSubmitted: (v) {
                      applyHex(v);
                      hexController.text = _colorToHex(current.value);
                    },
                    onChanged: (v) {
                      if (v.length == 6 || v.length == 8) {
                        applyHex(v);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // RGB sliders
              _RgbSlider(
                label: 'R',
                value: (current.value.r * 255).round(),
                color: Colors.red,
                theme: theme,
                onChanged: (v) {
                  current.value = current.value.withRed(v);
                  hexController.text = _colorToHex(current.value);
                },
              ),
              const SizedBox(height: 4),
              _RgbSlider(
                label: 'G',
                value: (current.value.g * 255).round(),
                color: Colors.green,
                theme: theme,
                onChanged: (v) {
                  current.value = current.value.withGreen(v);
                  hexController.text = _colorToHex(current.value);
                },
              ),
              const SizedBox(height: 4),
              _RgbSlider(
                label: 'B',
                value: (current.value.b * 255).round(),
                color: Colors.blue,
                theme: theme,
                onChanged: (v) {
                  current.value = current.value.withBlue(v);
                  hexController.text = _colorToHex(current.value);
                },
              ),
              const SizedBox(height: 10),

              // Preset palette
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  for (final preset in _kPresets)
                    GestureDetector(
                      onTap: () {
                        current.value = preset;
                        hexController.text = _colorToHex(preset);
                      },
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: preset,
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            color: current.value == preset
                                ? theme.primaryColor
                                : theme.divider,
                            width: current.value == preset ? 2 : 0.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _DialogButton(
                    label: 'Cancel',
                    onTap: () => Navigator.of(context).pop(null),
                    theme: theme,
                    primary: false,
                  ),
                  const SizedBox(width: 8),
                  _DialogButton(
                    label: 'Apply',
                    onTap: () => Navigator.of(context).pop(current.value),
                    theme: theme,
                    primary: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _colorToHex(Color c) {
    final r = (c.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (c.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (c.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '$r$g$b'.toUpperCase();
  }
}

class _RgbSlider extends StatelessWidget {
  const _RgbSlider({
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
    required this.onChanged,
  });

  final String label;
  final int value;
  final Color color;
  final AppTheme theme;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 12,
          child: Text(
            label,
            style: TextStyle(fontSize: 10, color: theme.textDisabled),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 5),
              activeTrackColor: color,
              inactiveTrackColor: theme.divider,
              thumbColor: color,
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 8),
            ),
            child: Slider(
              value: value.toDouble(),
              min: 0,
              max: 255,
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
        ),
        SizedBox(
          width: 28,
          child: Text(
            '$value',
            style: TextStyle(fontSize: 10, color: theme.textDisabled),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.onTap,
    required this.theme,
    required this.primary,
  });

  final String label;
  final VoidCallback onTap;
  final AppTheme theme;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: primary ? theme.primaryColor : theme.surfaceVariant,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: theme.divider, width: 0.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: primary ? theme.onPrimary : theme.textPrimary,
          ),
        ),
      ),
    );
  }
}
