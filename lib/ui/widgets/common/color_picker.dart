import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../providers/color_history_provider.dart';

// ===========================================================================
// Public API
// ===========================================================================

/// Opens the full HSV color picker dialog.
/// Returns the picked [Color] or null if cancelled.
Future<Color?> showColorPicker({
  required BuildContext context,
  required Color initialColor,
  required AppTheme theme,
}) {
  return showDialog<Color>(
    context: context,
    barrierColor: Colors.black26,
    builder: (_) => _ColorPickerDialog(
      initialColor: initialColor,
      theme: theme,
    ),
  );
}

// ===========================================================================
// Dialog
// ===========================================================================

class _ColorPickerDialog extends HookConsumerWidget {
  const _ColorPickerDialog({
    required this.initialColor,
    required this.theme,
  });

  final Color initialColor;
  final AppTheme theme;

  static const _squareW = 224.0;
  static const _squareH = 180.0;
  static const _stripH = 14.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(colorHistoryProvider);

    // -----------------------------------------------------------------------
    // HSV state
    // -----------------------------------------------------------------------
    final initHsv = HSVColor.fromColor(initialColor);
    final hue = useState(initHsv.hue);
    final sat = useState(initHsv.saturation);
    final val = useState(initHsv.value);
    final alpha = useState(
        (initialColor.a * 255).round().clamp(0, 255).toDouble() / 255.0);

    // Computed on every build — no getter, just a local function
    Color current() =>
        HSVColor.fromAHSV(alpha.value, hue.value, sat.value, val.value)
            .toColor();

    final hexCtrl =
        useTextEditingController(text: _toHex(current()));
    final hexFocus = useFocusNode();

    // Keep HEX field in sync whenever HSV changes (but not while typing)
    useEffect(() {
      if (!hexFocus.hasFocus) {
        hexCtrl.text = _toHex(current());
      }
      return null;
    }, [hue.value, sat.value, val.value, alpha.value]);

    // -----------------------------------------------------------------------
    // Helpers
    // -----------------------------------------------------------------------

    void applyHex(String raw) {
      final cleaned = raw.replaceAll('#', '').trim();
      final full = cleaned.length == 6
          ? 'FF$cleaned'
          : cleaned.length == 8
              ? cleaned
              : null;
      if (full == null) return;
      final parsed = int.tryParse(full, radix: 16);
      if (parsed == null) return;
      final c = Color(parsed);
      final hsv = HSVColor.fromColor(c);
      hue.value = hsv.hue;
      sat.value = hsv.saturation;
      val.value = hsv.value;
      alpha.value = (c.a * 255).round() / 255.0;
    }

    void updateSV(Offset local) {
      sat.value = (local.dx / _squareW).clamp(0.0, 1.0);
      val.value = (1.0 - local.dy / _squareH).clamp(0.0, 1.0);
    }

    void updateHue(Offset local) {
      hue.value = (local.dx / _squareW * 360.0).clamp(0.0, 360.0);
    }

    void updateAlpha(Offset local) {
      alpha.value = (local.dx / _squareW).clamp(0.0, 1.0);
    }

    void applyHistoryColor(Color c) {
      final hsv = HSVColor.fromColor(c);
      hue.value = hsv.hue;
      sat.value = hsv.saturation;
      val.value = hsv.value;
      hexCtrl.text = _toHex(c);
    }

    // -----------------------------------------------------------------------
    // Build
    // -----------------------------------------------------------------------

    return Dialog(
      backgroundColor: theme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.divider, width: 0.5),
      ),
      insetPadding: const EdgeInsets.all(32),
      child: SizedBox(
        width: _squareW + 36,
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

              // ── SV square ──────────────────────────────────────────────
              GestureDetector(
                onPanDown: (d) => updateSV(d.localPosition),
                onPanUpdate: (d) => updateSV(d.localPosition),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    width: _squareW,
                    height: _squareH,
                    child: CustomPaint(
                      painter: _SVPainter(
                        hue: hue.value,
                        sat: sat.value,
                        val: val.value,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ── Hue strip ───────────────────────────────────────────────
              GestureDetector(
                onPanDown: (d) => updateHue(d.localPosition),
                onPanUpdate: (d) => updateHue(d.localPosition),
                child: SizedBox(
                  width: _squareW,
                  height: _stripH,
                  child: CustomPaint(
                    painter: _HuePainter(hue: hue.value),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // ── Opacity strip ───────────────────────────────────────────
              GestureDetector(
                onPanDown: (d) => updateAlpha(d.localPosition),
                onPanUpdate: (d) => updateAlpha(d.localPosition),
                child: SizedBox(
                  width: _squareW,
                  height: _stripH,
                  child: CustomPaint(
                    painter: _AlphaPainter(
                      alpha: alpha.value,
                      color: HSVColor.fromAHSV(
                              1.0, hue.value, sat.value, val.value)
                          .toColor(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ── Preview + HEX ────────────────────────────────────────────
              Row(
                children: [
                  // Before / After preview
                  _ColorPreview(
                    before: initialColor,
                    after: current(),
                    theme: theme,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HEX
                        _FieldLabel('HEX', theme),
                        SizedBox(
                          height: 26,
                          child: Focus(
                            onFocusChange: (has) {
                              if (!has) applyHex(hexCtrl.text);
                            },
                            child: TextField(
                              controller: hexCtrl,
                              focusNode: hexFocus,
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.textPrimary,
                                fontFamily: 'monospace',
                              ),
                              decoration: _inputDeco(theme, prefix: '#'),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9a-fA-F]')),
                                LengthLimitingTextInputFormatter(8),
                              ],
                              onSubmitted: (v) {
                                applyHex(v);
                                hexCtrl.text = _toHex(current());
                              },
                              onChanged: (v) {
                                if (v.length == 6 || v.length == 8) {
                                  applyHex(v);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ── RGBA numeric inputs ─────────────────────────────────────
              Row(
                children: [
                  _ChanInput(
                    label: 'R',
                    value: (current().r * 255).round(),
                    theme: theme,
                    onChanged: (v) {
                      final c = Color.fromARGB(
                        (alpha.value * 255).round(),
                        v.clamp(0, 255),
                        (current().g * 255).round(),
                        (current().b * 255).round(),
                      );
                      final hsv = HSVColor.fromColor(c);
                      hue.value = hsv.hue;
                      sat.value = hsv.saturation;
                      val.value = hsv.value;
                    },
                  ),
                  const SizedBox(width: 4),
                  _ChanInput(
                    label: 'G',
                    value: (current().g * 255).round(),
                    theme: theme,
                    onChanged: (v) {
                      final c = Color.fromARGB(
                        (alpha.value * 255).round(),
                        (current().r * 255).round(),
                        v.clamp(0, 255),
                        (current().b * 255).round(),
                      );
                      final hsv = HSVColor.fromColor(c);
                      hue.value = hsv.hue;
                      sat.value = hsv.saturation;
                      val.value = hsv.value;
                    },
                  ),
                  const SizedBox(width: 4),
                  _ChanInput(
                    label: 'B',
                    value: (current().b * 255).round(),
                    theme: theme,
                    onChanged: (v) {
                      final c = Color.fromARGB(
                        (alpha.value * 255).round(),
                        (current().r * 255).round(),
                        (current().g * 255).round(),
                        v.clamp(0, 255),
                      );
                      final hsv = HSVColor.fromColor(c);
                      hue.value = hsv.hue;
                      sat.value = hsv.saturation;
                      val.value = hsv.value;
                    },
                  ),
                  const SizedBox(width: 4),
                  _ChanInput(
                    label: 'A',
                    value: (alpha.value * 255).round(),
                    theme: theme,
                    onChanged: (v) {
                      alpha.value = v.clamp(0, 255) / 255.0;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Color history ────────────────────────────────────────────
              if (history.isNotEmpty) ...[
                Text(
                  'Recent',
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.textDisabled,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (final c in history)
                      GestureDetector(
                        onTap: () => applyHistoryColor(c),
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: c,
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                              color: theme.divider,
                              width: 0.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
              ],

              // ── Buttons ──────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _Btn(
                    label: 'Cancel',
                    primary: false,
                    theme: theme,
                    onTap: () => Navigator.of(context).pop(null),
                  ),
                  const SizedBox(width: 8),
                  _Btn(
                    label: 'Apply',
                    primary: true,
                    theme: theme,
                    onTap: () {
                      final picked = current();
                      ref
                          .read(colorHistoryProvider.notifier)
                          .addColor(picked);
                      Navigator.of(context).pop(picked);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Static helpers
  // -----------------------------------------------------------------------

  static String _toHex(Color c) {
    final r = (c.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (c.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (c.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '$r$g$b'.toUpperCase();
  }

  static InputDecoration _inputDeco(AppTheme theme, {String? prefix}) {
    return InputDecoration(
      prefixText: prefix,
      prefixStyle: TextStyle(fontSize: 11, color: theme.textDisabled),
      filled: true,
      fillColor: theme.surfaceVariant,
      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
    );
  }
}

// ===========================================================================
// Painters
// ===========================================================================

/// Saturation–Value gradient square with a crosshair cursor.
class _SVPainter extends CustomPainter {
  const _SVPainter({
    required this.hue,
    required this.sat,
    required this.val,
  });

  final double hue, sat, val;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Base: pure hue colour
    final hueColor =
        HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor();

    // 2. Horizontal gradient white → hue (saturation axis)
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.white, hueColor],
        ).createShader(rect),
    );

    // 3. Vertical gradient transparent → black (value axis)
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black],
        ).createShader(rect),
    );

    // 4. Crosshair
    final cx = sat * size.width;
    final cy = (1.0 - val) * size.height;
    canvas.drawCircle(
      Offset(cx, cy),
      7,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      Offset(cx, cy),
      5,
      Paint()
        ..color = HSVColor.fromAHSV(1.0, hue, sat, val).toColor(),
    );
  }

  @override
  bool shouldRepaint(_SVPainter old) =>
      old.hue != hue || old.sat != sat || old.val != val;
}

/// Full-spectrum hue strip with a position cursor.
class _HuePainter extends CustomPainter {
  const _HuePainter({required this.hue});

  final double hue;

  static const _hueColors = [
    Color(0xFFFF0000),
    Color(0xFFFFFF00),
    Color(0xFF00FF00),
    Color(0xFF00FFFF),
    Color(0xFF0000FF),
    Color(0xFFFF00FF),
    Color(0xFFFF0000),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rRect =
        RRect.fromRectAndRadius(rect, const Radius.circular(3));

    canvas.drawRRect(
      rRect,
      Paint()
        ..shader =
            LinearGradient(colors: _hueColors).createShader(rect),
    );

    // Cursor
    final x = (hue / 360.0) * size.width;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(x, size.height / 2),
            width: 4,
            height: size.height + 4),
        const Radius.circular(2),
      ),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_HuePainter old) => old.hue != hue;
}

/// Opacity/alpha strip (checkerboard + transparent→color gradient).
class _AlphaPainter extends CustomPainter {
  const _AlphaPainter({required this.alpha, required this.color});

  final double alpha;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rRect =
        RRect.fromRectAndRadius(rect, const Radius.circular(3));

    // Clip to rounded rect
    canvas.save();
    canvas.clipRRect(rRect);

    // Checkerboard
    const cell = 4.0;
    for (var y = 0.0; y < size.height; y += cell) {
      for (var x = 0.0; x < size.width; x += cell) {
        final col = (x / cell).floor();
        final row = (y / cell).floor();
        canvas.drawRect(
          Rect.fromLTWH(x, y, cell, cell),
          Paint()
            ..color = (col + row) % 2 == 0
                ? const Color(0xFFCCCCCC)
                : Colors.white,
        );
      }
    }

    // Gradient: transparent → opaque
    final r = (color.r * 255).round();
    final g = (color.g * 255).round();
    final b = (color.b * 255).round();
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(colors: [
          Color.fromARGB(0, r, g, b),
          Color.fromARGB(255, r, g, b),
        ]).createShader(rect),
    );

    canvas.restore();

    // Cursor
    final x = alpha * size.width;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(x, size.height / 2),
            width: 4,
            height: size.height + 4),
        const Radius.circular(2),
      ),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_AlphaPainter old) =>
      old.alpha != alpha || old.color != old.color;
}

// ===========================================================================
// Small sub-widgets
// ===========================================================================

/// Before/after color preview swatch.
class _ColorPreview extends StatelessWidget {
  const _ColorPreview({
    required this.before,
    required this.after,
    required this.theme,
  });

  final Color before, after;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.divider, width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3.5),
        child: Column(
          children: [
            Expanded(
              child: Container(color: before),
            ),
            Expanded(
              child: Container(color: after),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single RGB/A channel numeric input.
class _ChanInput extends HookWidget {
  const _ChanInput({
    required this.label,
    required this.value,
    required this.theme,
    required this.onChanged,
  });

  final String label;
  final int value;
  final AppTheme theme;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final ctrl = useTextEditingController(text: '$value');
    final focus = useFocusNode();

    useEffect(() {
      if (!focus.hasFocus) ctrl.text = '$value';
      return null;
    }, [value]);

    void submit(String text) {
      final parsed = int.tryParse(text);
      if (parsed != null) {
        onChanged(parsed.clamp(0, 255));
      } else {
        ctrl.text = '$value';
      }
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 9, color: theme.textDisabled),
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: 26,
            child: Focus(
              onFocusChange: (has) {
                if (!has) submit(ctrl.text);
              },
              child: TextField(
                controller: ctrl,
                focusNode: focus,
                style: TextStyle(fontSize: 11, color: theme.textPrimary),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: theme.surfaceVariant,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                onSubmitted: submit,
                onTapOutside: (_) => focus.unfocus(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, this.theme);

  final String text;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          color: theme.textDisabled,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({
    required this.label,
    required this.primary,
    required this.theme,
    required this.onTap,
  });

  final String label;
  final bool primary;
  final AppTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
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

