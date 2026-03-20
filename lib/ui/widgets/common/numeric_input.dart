import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../app/theme/theme.dart';

class NumericInput extends HookWidget {
  const NumericInput({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.theme,
    this.min,
    this.max,
    this.step = 1.0,
    this.width = 72,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final AppTheme theme;
  final double? min;
  final double? max;
  final double step;
  final double width;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: _format(value));
    final focusNode = useFocusNode();

    useEffect(() {
      if (!focusNode.hasFocus) {
        controller.text = _format(value);
      }
      return null;
    }, [value]);

    void submit(String text) {
      final parsed = double.tryParse(text);
      if (parsed != null) {
        var clamped = parsed;
        if (min != null) clamped = clamped.clamp(min!, double.infinity);
        if (max != null) clamped = clamped.clamp(double.negativeInfinity, max!);
        onChanged(clamped);
      } else {
        controller.text = _format(value);
      }
    }

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: theme.textDisabled,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: 28,
            child: Focus(
              onFocusChange: (hasFocus) {
                if (!hasFocus) submit(controller.text);
              },
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textPrimary,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: theme.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: theme.divider, width: 0.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: theme.divider, width: 0.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: theme.primaryColor, width: 1),
                  ),
                  isDense: true,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[-\d.]')),
                ],
                onSubmitted: submit,
                onTapOutside: (_) => focusNode.unfocus(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _format(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }
}
