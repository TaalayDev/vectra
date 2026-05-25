import 'package:flutter/material.dart';

import '../../../app/theme/theme.dart';

class PanelSlider extends StatelessWidget {
  const PanelSlider({
    super.key,
    required this.value,
    required this.theme,
    required this.onChanged,
    this.onChangeEnd,
  });

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
