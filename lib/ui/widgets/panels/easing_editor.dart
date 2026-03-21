import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/theme.dart';
import '../../../core/utils/easing_evaluator.dart';
import '../../../data/models/vec_easing.dart';

// ---------------------------------------------------------------------------
// Public entry-point
// ---------------------------------------------------------------------------

/// Opens the easing editor as a modal dialog.
/// Calls [onChanged] when the user commits a new easing (preset select or
/// bezier drag-end). Changes are immediate (no need to "confirm").
Future<void> showEasingEditor({
  required BuildContext context,
  required AppTheme theme,
  required VecEasing? currentEasing,
  required void Function(VecEasing?) onChanged,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black26,
    builder: (_) => _EasingEditorDialog(
      theme: theme,
      initialEasing: currentEasing,
      onChanged: onChanged,
    ),
  );
}

// ---------------------------------------------------------------------------
// Dialog shell
// ---------------------------------------------------------------------------

class _EasingEditorDialog extends StatefulWidget {
  const _EasingEditorDialog({
    required this.theme,
    required this.initialEasing,
    required this.onChanged,
  });

  final AppTheme theme;
  final VecEasing? initialEasing;
  final void Function(VecEasing?) onChanged;

  @override
  State<_EasingEditorDialog> createState() => _EasingEditorDialogState();
}

class _EasingEditorDialogState extends State<_EasingEditorDialog> {
  late VecEasing? _easing;

  // Cubic-bezier handle coords (always kept up-to-date from _easing or preset)
  double _x1 = 0.42, _y1 = 0.0, _x2 = 0.58, _y2 = 1.0;
  int? _dragHandle; // 0 = h1, 1 = h2

  // Canvas size for the curve widget (assigned in build)
  static const _cw = 220.0;
  static const _ch = 180.0;

  bool get _isCustom => _easing is VecCubicBezierEasing;

  @override
  void initState() {
    super.initState();
    _easing = widget.initialEasing;
    _syncHandlesFromEasing();
  }

  void _syncHandlesFromEasing() {
    if (_easing is VecCubicBezierEasing) {
      final cb = _easing as VecCubicBezierEasing;
      _x1 = cb.x1; _y1 = cb.y1; _x2 = cb.x2; _y2 = cb.y2;
    } else {
      final pts = EasingEvaluator.controlPoints(_easing);
      if (pts != null) {
        _x1 = pts.$1; _y1 = pts.$2; _x2 = pts.$3; _y2 = pts.$4;
      }
    }
  }

  void _selectPreset(VecEasing? easing) {
    setState(() {
      _easing = easing;
      _syncHandlesFromEasing();
    });
    widget.onChanged(_easing);
  }

  void _switchToCustom() {
    final newEasing = VecEasing.cubicBezier(
        x1: _x1, y1: _y1, x2: _x2, y2: _y2);
    setState(() => _easing = newEasing);
    widget.onChanged(newEasing);
  }

  // Bezier handle drag
  void _onPanStart(DragStartDetails d) {
    if (!_isCustom) return;
    final pos = d.localPosition;
    final h1 = Offset(_x1 * _cw, (1 - _y1.clamp(0.0, 1.0)) * _ch);
    final h2 = Offset(_x2 * _cw, (1 - _y2.clamp(0.0, 1.0)) * _ch);
    if ((pos - h1).distance < 14) {
      _dragHandle = 0;
    } else if ((pos - h2).distance < 14) {
      _dragHandle = 1;
    } else {
      _dragHandle = null;
    }
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (!_isCustom || _dragHandle == null) return;
    final pos = d.localPosition;
    final nx = (pos.dx / _cw).clamp(0.0, 1.0);
    final ny = 1.0 - pos.dy / _ch; // unclamped y allows overshoot
    setState(() {
      if (_dragHandle == 0) { _x1 = nx; _y1 = ny; }
      else                  { _x2 = nx; _y2 = ny; }
      _easing = VecEasing.cubicBezier(x1: _x1, y1: _y1, x2: _x2, y2: _y2);
    });
  }

  void _onPanEnd(DragEndDetails _) {
    if (_dragHandle != null) widget.onChanged(_easing);
    setState(() => _dragHandle = null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return Dialog(
      backgroundColor: theme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        width: 280,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title ──────────────────────────────────────────────
              Row(
                children: [
                  Text('Easing',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.textPrimary)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.close, size: 16, color: theme.textDisabled),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Curve canvas ───────────────────────────────────────
              Container(
                width: _cw,
                height: _ch,
                decoration: BoxDecoration(
                  color: theme.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: theme.divider.withAlpha(80), width: 0.5),
                ),
                clipBehavior: Clip.hardEdge,
                child: GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: CustomPaint(
                    size: const Size(_cw, _ch),
                    painter: _CurvePainter(
                      easing: _easing,
                      x1: _x1, y1: _y1, x2: _x2, y2: _y2,
                      isCustom: _isCustom,
                      curveColor: theme.accentColor,
                      handleColor: theme.primaryColor,
                      gridColor: theme.divider,
                      bgColor: theme.surfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Preset chips ───────────────────────────────────────
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _Chip('Linear',
                      _easing is VecPresetEasing &&
                          (_easing as VecPresetEasing).preset ==
                              VecEasingPreset.linear,
                      () => _selectPreset(const VecEasing.preset(
                          preset: VecEasingPreset.linear)),
                      theme),
                  _Chip('Ease In',
                      _easing is VecPresetEasing &&
                          (_easing as VecPresetEasing).preset ==
                              VecEasingPreset.easeIn,
                      () => _selectPreset(const VecEasing.preset(
                          preset: VecEasingPreset.easeIn)),
                      theme),
                  _Chip('Ease Out',
                      _easing is VecPresetEasing &&
                          (_easing as VecPresetEasing).preset ==
                              VecEasingPreset.easeOut,
                      () => _selectPreset(const VecEasing.preset(
                          preset: VecEasingPreset.easeOut)),
                      theme),
                  _Chip('Ease In/Out',
                      _easing is VecPresetEasing &&
                          (_easing as VecPresetEasing).preset ==
                              VecEasingPreset.easeInOut,
                      () => _selectPreset(const VecEasing.preset(
                          preset: VecEasingPreset.easeInOut)),
                      theme),
                  _Chip('Bounce',
                      _easing is VecPresetEasing &&
                          (_easing as VecPresetEasing).preset ==
                              VecEasingPreset.bounce,
                      () => _selectPreset(const VecEasing.preset(
                          preset: VecEasingPreset.bounce)),
                      theme),
                  _Chip('Elastic',
                      _easing is VecPresetEasing &&
                          (_easing as VecPresetEasing).preset ==
                              VecEasingPreset.elastic,
                      () => _selectPreset(const VecEasing.preset(
                          preset: VecEasingPreset.elastic)),
                      theme),
                  _Chip('Spring',
                      _easing is VecPresetEasing &&
                          (_easing as VecPresetEasing).preset ==
                              VecEasingPreset.spring,
                      () => _selectPreset(const VecEasing.preset(
                          preset: VecEasingPreset.spring)),
                      theme),
                  _Chip('Custom', _isCustom, _switchToCustom, theme,
                      icon: Icons.tune),
                ],
              ),

              // ── Custom bezier inputs ───────────────────────────────
              if (_isCustom) ...[
                const SizedBox(height: 12),
                _BezierFields(
                  x1: _x1, y1: _y1, x2: _x2, y2: _y2,
                  theme: theme,
                  onChanged: (x1, y1, x2, y2) {
                    setState(() {
                      _x1 = x1; _y1 = y1; _x2 = x2; _y2 = y2;
                      _easing = VecEasing.cubicBezier(
                          x1: _x1, y1: _y1, x2: _x2, y2: _y2);
                    });
                    widget.onChanged(_easing);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chip
// ---------------------------------------------------------------------------

class _Chip extends StatelessWidget {
  const _Chip(this.label, this.selected, this.onTap, this.theme,
      {this.icon});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final AppTheme theme;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? theme.accentColor.withAlpha(40)
              : theme.surfaceVariant,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected
                ? theme.accentColor.withAlpha(160)
                : theme.divider.withAlpha(80),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 10,
                  color: selected ? theme.accentColor : theme.textDisabled),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? theme.accentColor : theme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bezier numeric inputs
// ---------------------------------------------------------------------------

class _BezierFields extends StatefulWidget {
  const _BezierFields({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.theme,
    required this.onChanged,
  });

  final double x1, y1, x2, y2;
  final AppTheme theme;
  final void Function(double x1, double y1, double x2, double y2) onChanged;

  @override
  State<_BezierFields> createState() => _BezierFieldsState();
}

class _BezierFieldsState extends State<_BezierFields> {
  late final _c = [
    TextEditingController(text: _fmt(widget.x1)),
    TextEditingController(text: _fmt(widget.y1)),
    TextEditingController(text: _fmt(widget.x2)),
    TextEditingController(text: _fmt(widget.y2)),
  ];

  @override
  void didUpdateWidget(_BezierFields old) {
    super.didUpdateWidget(old);
    // Sync controllers only if the user isn't editing them
    final vals = [widget.x1, widget.y1, widget.x2, widget.y2];
    for (var i = 0; i < 4; i++) {
      if (!_c[i].selection.isValid || _c[i].selection.isCollapsed) {
        _c[i].text = _fmt(vals[i]);
      }
    }
  }

  @override
  void dispose() {
    for (final c in _c) c.dispose();
    super.dispose();
  }

  String _fmt(double v) => v.toStringAsFixed(2);

  void _commit() {
    final vals = _c.map((c) => double.tryParse(c.text) ?? 0.0).toList();
    widget.onChanged(
      vals[0].clamp(0.0, 1.0),
      vals[1], // y unclamped
      vals[2].clamp(0.0, 1.0),
      vals[3], // y unclamped
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return Column(
      children: [
        Row(children: [
          _field('X1', _c[0], theme),
          const SizedBox(width: 8),
          _field('Y1', _c[1], theme),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          _field('X2', _c[2], theme),
          const SizedBox(width: 8),
          _field('Y2', _c[3], theme),
        ]),
      ],
    );
  }

  Widget _field(String label, TextEditingController ctrl, AppTheme theme) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 9, color: theme.textDisabled)),
          const SizedBox(height: 2),
          SizedBox(
            height: 28,
            child: TextField(
              controller: ctrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true, signed: true),
              style: TextStyle(fontSize: 11, color: theme.textPrimary),
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                filled: true,
                fillColor: theme.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide:
                      BorderSide(color: theme.divider.withAlpha(80), width: 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide:
                      BorderSide(color: theme.divider.withAlpha(80), width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: theme.accentColor, width: 1),
                ),
              ),
              onSubmitted: (_) => _commit(),
              onEditingComplete: _commit,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Curve painter
// ---------------------------------------------------------------------------

class _CurvePainter extends CustomPainter {
  const _CurvePainter({
    required this.easing,
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.isCustom,
    required this.curveColor,
    required this.handleColor,
    required this.gridColor,
    required this.bgColor,
  });

  final VecEasing? easing;
  final double x1, y1, x2, y2;
  final bool isCustom;
  final Color curveColor, handleColor, gridColor, bgColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Determine y range (to accommodate overshoot)
    double yMin = 0, yMax = 1;
    const steps = 80;
    for (var i = 0; i <= steps; i++) {
      final v = EasingEvaluator.evaluate(easing, i / steps);
      if (v < yMin) yMin = v;
      if (v > yMax) yMax = v;
    }
    final yPad = (yMax - yMin) * 0.08;
    final yLo = yMin - yPad, yHi = yMax + yPad;
    final yRange = yHi - yLo;

    double toCanvasX(double t) => t * w;
    double toCanvasY(double v) => h - ((v - yLo) / yRange) * h;

    // Grid
    final gridPaint = Paint()
      ..color = gridColor.withAlpha(50)
      ..strokeWidth = 0.5;
    for (var i = 1; i < 4; i++) {
      canvas.drawLine(
          Offset(w * i / 4, 0), Offset(w * i / 4, h), gridPaint);
      canvas.drawLine(
          Offset(0, h * i / 4), Offset(w, h * i / 4), gridPaint);
    }

    // y=0 and y=1 reference lines
    final refPaint = Paint()
      ..color = gridColor.withAlpha(90)
      ..strokeWidth = 0.7;
    canvas.drawLine(Offset(0, toCanvasY(0)), Offset(w, toCanvasY(0)), refPaint);
    canvas.drawLine(Offset(0, toCanvasY(1)), Offset(w, toCanvasY(1)), refPaint);

    // Curve path
    final curvePath = Path();
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      final v = EasingEvaluator.evaluate(easing, t);
      final cx = toCanvasX(t);
      final cy = toCanvasY(v);
      if (i == 0) curvePath.moveTo(cx, cy); else curvePath.lineTo(cx, cy);
    }
    canvas.drawPath(
      curvePath,
      Paint()
        ..color = curveColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Handles — always show for bezier-representable easings
    final pts = EasingEvaluator.controlPoints(easing);
    if (pts != null || isCustom) {
      final hx1 = toCanvasX(x1);
      final hy1 = toCanvasY(y1.clamp(yLo, yHi));
      final hx2 = toCanvasX(x2);
      final hy2 = toCanvasY(y2.clamp(yLo, yHi));

      final p0 = Offset(toCanvasX(0), toCanvasY(0));
      final p3 = Offset(toCanvasX(1), toCanvasY(1));
      final h1 = Offset(hx1, hy1);
      final h2 = Offset(hx2, hy2);

      // Dashed handle lines
      _drawDashed(canvas, p0, h1,
          color: handleColor.withAlpha(isCustom ? 160 : 90));
      _drawDashed(canvas, p3, h2,
          color: handleColor.withAlpha(isCustom ? 160 : 90));

      // Handle circles
      final r = isCustom ? 5.5 : 4.0;
      canvas.drawCircle(h1, r, Paint()..color = handleColor);
      canvas.drawCircle(h1, r,
          Paint()
            ..color = Colors.white
            ..strokeWidth = 1.5
            ..style = PaintingStyle.stroke);

      canvas.drawCircle(h2, r, Paint()..color = handleColor);
      canvas.drawCircle(h2, r,
          Paint()
            ..color = Colors.white
            ..strokeWidth = 1.5
            ..style = PaintingStyle.stroke);
    }

    // Endpoints
    final epPaint = Paint()
      ..color = curveColor.withAlpha(200);
    canvas.drawCircle(Offset(toCanvasX(0), toCanvasY(0)), 3, epPaint);
    canvas.drawCircle(Offset(toCanvasX(1), toCanvasY(1)), 3, epPaint);
  }

  static void _drawDashed(Canvas canvas, Offset a, Offset b,
      {required Color color}) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dashLen = 4.0, gap = 3.0;
    final dx = b.dx - a.dx, dy = b.dy - a.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len < 1) return;
    final ux = dx / len, uy = dy / len;
    var dist = 0.0;
    var draw = true;
    while (dist < len) {
      final segEnd = math.min(dist + (draw ? dashLen : gap), len);
      if (draw) {
        canvas.drawLine(
          Offset(a.dx + ux * dist, a.dy + uy * dist),
          Offset(a.dx + ux * segEnd, a.dy + uy * segEnd),
          paint,
        );
      }
      dist = segEnd;
      draw = !draw;
    }
  }

  @override
  bool shouldRepaint(covariant _CurvePainter old) =>
      old.easing != easing ||
      old.x1 != x1 || old.y1 != y1 ||
      old.x2 != x2 || old.y2 != y2 ||
      old.isCustom != isCustom;
}
