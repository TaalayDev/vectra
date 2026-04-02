import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../core/utils/easing_evaluator.dart';
import '../../../data/models/vec_easing.dart';
import '../../../data/models/vec_keyframe.dart';
import '../../../data/models/vec_timeline.dart';
import '../../../data/models/vec_track.dart';
import '../../../providers/document_provider.dart';
import '../../../providers/editor_state_provider.dart';
import 'frame_grid.dart';

// ---------------------------------------------------------------------------
// Graph editor panel
// ---------------------------------------------------------------------------

class GraphEditorPanel extends ConsumerStatefulWidget {
  const GraphEditorPanel({
    super.key,
    required this.theme,
    required this.timeline,
    required this.rows,
    required this.scrollController,
  });

  final AppTheme theme;
  final VecTimeline timeline;
  final List<TrackRow> rows;
  final ScrollController scrollController;

  @override
  ConsumerState<GraphEditorPanel> createState() => _GraphEditorPanelState();
}

class _GraphEditorPanelState extends ConsumerState<GraphEditorPanel> {
  bool _showSpeedGraph = false;

  @override
  Widget build(BuildContext context) {
    final scene = ref.watch(activeSceneProvider);
    final selectedShapeId = ref.watch(selectedShapeIdProvider);
    if (scene == null) return const SizedBox.shrink();

    final trackMap = <String, VecTrack>{};
    for (final t in scene.timeline.tracks) {
      if (t.shapeId != null) trackMap[t.shapeId!] = t;
    }

    final track = selectedShapeId != null ? trackMap[selectedShapeId] : null;
    final theme = widget.theme;

    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: theme.surfaceVariant,
        border: Border(top: BorderSide(color: theme.divider, width: 0.5)),
      ),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────
          Container(
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: theme.surface,
            child: Row(
              children: [
                Text(
                  'Graph Editor',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: theme.textSecondary),
                ),
                const SizedBox(width: 8),
                _ToggleChip(
                  label: 'Value',
                  selected: !_showSpeedGraph,
                  theme: theme,
                  onTap: () => setState(() => _showSpeedGraph = false),
                ),
                const SizedBox(width: 4),
                _ToggleChip(
                  label: 'Speed',
                  selected: _showSpeedGraph,
                  theme: theme,
                  onTap: () => setState(() => _showSpeedGraph = true),
                ),
                const Spacer(),
                Text(
                  track != null
                      ? '${track.keyframes.length} keyframe${track.keyframes.length == 1 ? '' : 's'}'
                      : 'Select a shape',
                  style: TextStyle(fontSize: 9, color: theme.textDisabled),
                ),
              ],
            ),
          ),

          // ── Graph area ──────────────────────────────────────────
          Expanded(
            child: track == null || track.keyframes.isEmpty
                ? Center(
                    child: Text('No keyframes', style: TextStyle(fontSize: 10, color: theme.textDisabled)),
                  )
                : _GraphArea(
                    theme: theme,
                    timeline: widget.timeline,
                    track: track,
                    showSpeed: _showSpeedGraph,
                    scrollController: widget.scrollController,
                    onKeyframeEasingChanged: (frame, updatedKf) {
                      final row = widget.rows.firstWhere(
                        (r) => r.shapeId == selectedShapeId,
                        orElse: () => widget.rows.first,
                      );
                      ref
                          .read(vecDocumentStateProvider.notifier)
                          .updateKeyframeForShape(scene.id, row.layerId, row.shapeId, frame, (_) => updatedKf);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Graph area (custom painter + interaction)
// ---------------------------------------------------------------------------

class _GraphArea extends StatefulWidget {
  const _GraphArea({
    required this.theme,
    required this.timeline,
    required this.track,
    required this.showSpeed,
    required this.scrollController,
    required this.onKeyframeEasingChanged,
  });

  final AppTheme theme;
  final VecTimeline timeline;
  final VecTrack track;
  final bool showSpeed;
  final ScrollController scrollController;
  final void Function(int frame, VecKeyframe updatedKf) onKeyframeEasingChanged;

  @override
  State<_GraphArea> createState() => _GraphAreaState();
}

class _GraphAreaState extends State<_GraphArea> {
  static const _frameWidth = 10.0;
  int? _draggingHandleIndex; // index into sorted keyframes
  bool _draggingIsOut = false; // true = out-handle, false = in-handle

  List<VecKeyframe> get _sorted {
    final s = List<VecKeyframe>.from(widget.track.keyframes)..sort((a, b) => a.frame.compareTo(b.frame));
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        return GestureDetector(
          onPanStart: (d) => _onPanStart(d, h),
          onPanUpdate: (d) => _onPanUpdate(d, h),
          onPanEnd: (_) => setState(() => _draggingHandleIndex = null),
          child: CustomPaint(
            painter: _GraphPainter(
              timeline: widget.timeline,
              track: widget.track,
              showSpeed: widget.showSpeed,
              scrollOffset: widget.scrollController.hasClients ? widget.scrollController.offset : 0.0,
              frameWidth: _frameWidth,
              curveColor: widget.theme.accentColor,
              keyframeColor: widget.theme.primaryColor,
              gridColor: widget.theme.divider,
            ),
            size: Size(constraints.maxWidth, h),
          ),
        );
      },
    );
  }

  void _onPanStart(DragStartDetails d, double h) {
    if (widget.showSpeed) return;
    final sorted = _sorted;
    final scrollOffset = widget.scrollController.hasClients ? widget.scrollController.offset : 0.0;

    for (var i = 0; i < sorted.length; i++) {
      final kf = sorted[i];
      final cx = kf.frame * _frameWidth - scrollOffset;
      final pts = EasingEvaluator.controlPoints(kf.easing);
      if (pts != null) {
        final outX = kf.frame * _frameWidth + pts.$1 * _frameWidth * 2 - scrollOffset;
        final outY = h - pts.$2.clamp(0.0, 1.0) * h;
        if ((d.localPosition - Offset(outX, outY)).distance < 10) {
          setState(() {
            _draggingHandleIndex = i;
            _draggingIsOut = true;
          });
          return;
        }
      }
      if (i > 0) {
        final prevPts = EasingEvaluator.controlPoints(sorted[i - 1].easing);
        if (prevPts != null) {
          final inX = cx - prevPts.$3 * _frameWidth * 2;
          final inY = h - prevPts.$4.clamp(0.0, 1.0) * h;
          if ((d.localPosition - Offset(inX, inY)).distance < 10) {
            setState(() {
              _draggingHandleIndex = i - 1;
              _draggingIsOut = false;
            });
            return;
          }
        }
      }
    }
  }

  void _onPanUpdate(DragUpdateDetails d, double h) {
    if (_draggingHandleIndex == null) return;
    final sorted = _sorted;
    final kf = sorted[_draggingHandleIndex!];
    final scrollOffset = widget.scrollController.hasClients ? widget.scrollController.offset : 0.0;
    final xRel = (d.localPosition.dx + scrollOffset - kf.frame * _frameWidth) / (_frameWidth * 2);
    final yRel = 1.0 - d.localPosition.dy / h;
    final nx = xRel.clamp(0.0, 1.0);

    VecEasing newEasing;
    final current = kf.easing;
    if (current is VecCubicBezierEasing) {
      if (_draggingIsOut) {
        newEasing = VecEasing.cubicBezier(x1: nx, y1: yRel, x2: current.x2, y2: current.y2);
      } else {
        newEasing = VecEasing.cubicBezier(x1: current.x1, y1: current.y1, x2: nx, y2: yRel);
      }
    } else {
      final pts = EasingEvaluator.controlPoints(current) ?? (0.42, 0.0, 0.58, 1.0);
      if (_draggingIsOut) {
        newEasing = VecEasing.cubicBezier(x1: nx, y1: yRel, x2: pts.$3, y2: pts.$4);
      } else {
        newEasing = VecEasing.cubicBezier(x1: pts.$1, y1: pts.$2, x2: nx, y2: yRel);
      }
    }

    final updatedKf = kf.copyWith(easing: newEasing);
    widget.onKeyframeEasingChanged(kf.frame, updatedKf);
    setState(() {});
  }
}

// ---------------------------------------------------------------------------

class _GraphPainter extends CustomPainter {
  _GraphPainter({
    required this.timeline,
    required this.track,
    required this.showSpeed,
    required this.scrollOffset,
    required this.frameWidth,
    required this.curveColor,
    required this.keyframeColor,
    required this.gridColor,
  });

  final VecTimeline timeline;
  final VecTrack track;
  final bool showSpeed;
  final double scrollOffset;
  final double frameWidth;
  final Color curveColor;
  final Color keyframeColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    _drawGrid(canvas, w, h);

    final sorted = List<VecKeyframe>.from(track.keyframes)..sort((a, b) => a.frame.compareTo(b.frame));

    if (sorted.length < 2) {
      _drawKeyframeDots(canvas, sorted, h);
      return;
    }

    final curvePaint = Paint()
      ..color = curveColor.withAlpha(200)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < sorted.length - 1; i++) {
      final a = sorted[i];
      final b = sorted[i + 1];
      _drawSegment(canvas, a, b, h, curvePaint);
    }

    _drawKeyframeDots(canvas, sorted, h);
    _drawHandles(canvas, sorted, h);
  }

  void _drawGrid(Canvas canvas, double w, double h) {
    final paint = Paint()
      ..color = gridColor.withAlpha(50)
      ..strokeWidth = 0.5;

    for (var f = 0; f <= timeline.duration; f += 5) {
      final x = f * frameWidth - scrollOffset;
      if (x < 0 || x > w) continue;
      canvas.drawLine(Offset(x, 0), Offset(x, h), paint);
    }

    // 0% and 100% lines
    canvas.drawLine(Offset(0, h), Offset(w, h), paint);
    canvas.drawLine(const Offset(0, 0), Offset(w, 0), paint..color = gridColor.withAlpha(80));
    canvas.drawLine(Offset(0, h * 0.5), Offset(w, h * 0.5), paint..color = gridColor.withAlpha(30));
  }

  void _drawSegment(Canvas canvas, VecKeyframe a, VecKeyframe b, double h, Paint paint) {
    final x0 = a.frame * frameWidth - scrollOffset;
    final x1 = b.frame * frameWidth - scrollOffset;
    if (x1 < 0 || x0 > canvas.getSaveCount().toDouble() + 2000) return;

    if (showSpeed) {
      _drawSpeedSegment(canvas, a, b, h, paint, x0, x1);
    } else {
      _drawValueSegment(canvas, a, b, h, paint, x0, x1);
    }
  }

  void _drawValueSegment(Canvas canvas, VecKeyframe a, VecKeyframe b, double h, Paint paint, double x0, double x1) {
    final easing = a.easing;
    final pts = EasingEvaluator.controlPoints(easing);

    final path = Path()..moveTo(x0, h); // start at bottom-left (t=0, value=0)

    if (pts != null) {
      final cx1 = x0 + pts.$1 * (x1 - x0);
      final cy1 = h - pts.$2 * h;
      final cx2 = x0 + pts.$3 * (x1 - x0);
      final cy2 = h - pts.$4 * h;
      path.cubicTo(cx1, cy1, cx2, cy2, x1, 0);
    } else {
      const steps = 32;
      for (var s = 1; s <= steps; s++) {
        final t = s / steps;
        final ev = EasingEvaluator.evaluate(easing, t);
        path.lineTo(x0 + t * (x1 - x0), h - ev * h);
      }
    }

    canvas.drawPath(path, paint);
  }

  void _drawSpeedSegment(Canvas canvas, VecKeyframe a, VecKeyframe b, double h, Paint paint, double x0, double x1) {
    const steps = 32;
    double? prevX, prevSpeed;

    for (var s = 0; s <= steps; s++) {
      final t = s / steps;
      final ev = EasingEvaluator.evaluate(a.easing, t);
      final speed = s == 0 ? 0.0 : (ev - EasingEvaluator.evaluate(a.easing, (s - 1) / steps)) * steps;
      final x = x0 + t * (x1 - x0);
      final y = h - speed.abs().clamp(0.0, 1.0) * h;

      if (prevX != null) {
        canvas.drawLine(Offset(prevX, prevSpeed!), Offset(x, y), paint);
      }
      prevX = x;
      prevSpeed = y;
    }
  }

  void _drawKeyframeDots(Canvas canvas, List<VecKeyframe> sorted, double h) {
    final dotPaint = Paint()..color = keyframeColor;
    for (final kf in sorted) {
      final x = kf.frame * frameWidth - scrollOffset;
      canvas.drawCircle(Offset(x, h * 0.5), 4, dotPaint);
    }
  }

  void _drawHandles(Canvas canvas, List<VecKeyframe> sorted, double h) {
    if (showSpeed) return;
    final handlePaint = Paint()
      ..color = curveColor.withAlpha(140)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    final dotPaint = Paint()..color = curveColor.withAlpha(200);

    for (var i = 0; i < sorted.length; i++) {
      final kf = sorted[i];
      final cx = kf.frame * frameWidth - scrollOffset;
      final pts = EasingEvaluator.controlPoints(kf.easing);
      if (pts != null) {
        final outX = cx + pts.$1 * frameWidth * 2;
        final outY = h - pts.$2.clamp(0.0, 1.0) * h;
        canvas.drawLine(Offset(cx, h * 0.5), Offset(outX, outY), handlePaint);
        canvas.drawCircle(Offset(outX, outY), 3, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GraphPainter old) =>
      old.track != track || old.scrollOffset != scrollOffset || old.showSpeed != showSpeed;
}

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({required this.label, required this.selected, required this.theme, required this.onTap});

  final String label;
  final bool selected;
  final AppTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: selected ? theme.accentColor.withAlpha(40) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: selected ? theme.accentColor.withAlpha(160) : theme.divider.withAlpha(80)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
            color: selected ? theme.accentColor : theme.textSecondary,
          ),
        ),
      ),
    );
  }
}
