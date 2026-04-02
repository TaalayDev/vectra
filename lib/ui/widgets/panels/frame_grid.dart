import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../data/models/vec_keyframe.dart';
import '../../../data/models/vec_shape.dart';
import '../../../data/models/vec_timeline.dart';
import '../../../data/models/vec_track.dart';
import '../../../providers/document_provider.dart';
import '../../../providers/editor_state_provider.dart';
import 'easing_editor.dart';

// ---------------------------------------------------------------------------
// Row descriptor
// ---------------------------------------------------------------------------

class TrackRow {
  const TrackRow({required this.layerId, required this.shapeId, required this.name, required this.icon});

  final String layerId;
  final String shapeId;
  final String name;
  final IconData icon;
}

// ---------------------------------------------------------------------------
// Drag mode
// ---------------------------------------------------------------------------

enum _DragMode { none, seek, moveKeyframe, duration }

// ---------------------------------------------------------------------------
// FrameGrid widget
// ---------------------------------------------------------------------------

class FrameGrid extends ConsumerStatefulWidget {
  const FrameGrid({super.key, required this.timeline, required this.rows, required this.theme, this.scrollController});

  final VecTimeline timeline;
  final List<TrackRow> rows;
  final AppTheme theme;
  final ScrollController? scrollController;

  static const frameWidth = 10.0;
  static const trackHeight = 24.0;
  static const rulerHeight = 18.0;
  // Width of the duration drag handle zone at the right edge of the ruler
  static const _durationHandleWidth = 8.0;

  @override
  ConsumerState<FrameGrid> createState() => _FrameGridState();
}

class _FrameGridState extends ConsumerState<FrameGrid> with SingleTickerProviderStateMixin {
  int _hoverFrame = -1;
  int _hoverRow = -1;

  // Drag state
  _DragMode _dragMode = _DragMode.none;
  // moveKeyframe
  String? _dragShapeId;
  String? _dragLayerId;
  int _dragFromFrame = -1;
  int _dragPreviewFrame = -1;
  // duration
  int _previewDuration = -1;

  // Auto-scroll during duration drag
  double _viewportWidth = 400;
  Offset _lastDurationDragPos = Offset.zero;
  Ticker? _autoScrollTicker;
  Duration? _autoScrollPrevTime;

  /// Independent canvas-X accumulator so duration grows even when
  /// maxScrollExtent is 0 (content not yet expanded).
  double _targetCanvasX = 0;
  static const _autoScrollZone = 48.0; // px from right edge to trigger
  static const _autoScrollSpeed = 240.0; // canvas px per second

  @override
  void dispose() {
    _stopAutoScroll();
    super.dispose();
  }

  void _startAutoScroll() {
    if (_autoScrollTicker?.isActive == true) return;
    _autoScrollTicker?.dispose();
    _autoScrollPrevTime = null;
    // Seed the accumulator at current canvas position so duration doesn't jump
    _targetCanvasX = _lastDurationDragPos.dx + _scrollOffset;
    _autoScrollTicker = createTicker(_onAutoScrollTick)..start();
  }

  void _stopAutoScroll() {
    _autoScrollTicker?.dispose();
    _autoScrollTicker = null;
    _autoScrollPrevTime = null;
  }

  void _onAutoScrollTick(Duration elapsed) {
    if (_dragMode != _DragMode.duration || !mounted) {
      _stopAutoScroll();
      return;
    }

    // Compute delta time
    final prev = _autoScrollPrevTime;
    _autoScrollPrevTime = elapsed;
    if (prev == null) return; // skip first tick (no dt yet)
    final dt = (elapsed - prev).inMicroseconds / 1e6;

    // Grow the independent canvas-X accumulator.  This drives the preview
    // duration regardless of whether the scroll controller has caught up yet.
    _targetCanvasX += _autoScrollSpeed * dt;

    final newDuration = (_targetCanvasX / FrameGrid.frameWidth).round().clamp(1, 9999);

    if (newDuration != _previewDuration) {
      setState(() => _previewDuration = newDuration);
    }

    // After the frame is rebuilt (content is now wider), scroll to follow.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sc = widget.scrollController;
      if (sc == null || !sc.hasClients) return;
      // Target: keep the duration handle roughly 80 % from the left edge.
      final targetOffset = _targetCanvasX - _viewportWidth * 0.8;
      if (targetOffset > sc.offset) {
        sc.jumpTo(targetOffset.clamp(0.0, sc.position.maxScrollExtent));
      }
    });
  }

  double get _scrollOffset => widget.scrollController?.hasClients == true ? widget.scrollController!.offset : 0.0;

  /// Converts a screen-local x position to a canvas frame index.
  int _toFrame(double screenX, int duration) {
    final canvasX = screenX + _scrollOffset;
    return (canvasX / FrameGrid.frameWidth).floor().clamp(0, duration - 1);
  }

  /// Returns (rowIndex, shapeId, layerId, fromFrame) if [screenPos] is near
  /// an existing keyframe diamond, otherwise null.
  ({int row, String shapeId, String layerId, int frame})? _hitTestKeyframe(
    Offset screenPos,
    Map<String, VecTrack> trackMap,
  ) {
    final dy = screenPos.dy;
    final canvasX = screenPos.dx + _scrollOffset;
    if (dy < FrameGrid.rulerHeight) return null;

    final rowIndex = ((dy - FrameGrid.rulerHeight) / FrameGrid.trackHeight).floor();
    if (rowIndex < 0 || rowIndex >= widget.rows.length) return null;

    final row = widget.rows[rowIndex];
    final track = trackMap[row.shapeId];
    if (track == null) return null;

    for (final kf in track.keyframes) {
      final kfX = kf.frame * FrameGrid.frameWidth + FrameGrid.frameWidth / 2;
      if ((canvasX - kfX).abs() <= 6) {
        return (row: rowIndex, shapeId: row.shapeId, layerId: row.layerId, frame: kf.frame);
      }
    }
    return null;
  }

  /// Returns true if [screenPos] is near the duration drag handle.
  bool _hitTestDurationHandle(Offset screenPos) {
    final canvasX = screenPos.dx + _scrollOffset;
    final handleX = widget.timeline.duration * FrameGrid.frameWidth;
    return screenPos.dy < FrameGrid.rulerHeight && (canvasX - handleX).abs() <= FrameGrid._durationHandleWidth;
  }

  @override
  Widget build(BuildContext context) {
    final playhead = ref.watch(playheadFrameProvider);
    final selectedKf = ref.watch(selectedKeyframeFrameProvider);
    final effectiveDuration = _previewDuration > 0 ? _previewDuration : widget.timeline.duration;
    final totalWidth = effectiveDuration * FrameGrid.frameWidth;

    // Build shapeId → track map for keyframe lookup
    final trackMap = <String, VecTrack>{};
    for (final t in widget.timeline.tracks) {
      if (t.shapeId != null) trackMap[t.shapeId!] = t;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        _viewportWidth = constraints.maxWidth;
        return _buildContent(trackMap, playhead, selectedKf, effectiveDuration, totalWidth);
      },
    );
  }

  Widget _buildContent(
    Map<String, VecTrack> trackMap,
    int playhead,
    int selectedKf,
    int effectiveDuration,
    double totalWidth,
  ) {
    return MouseRegion(
      onHover: (e) {
        final canvasX = e.localPosition.dx + _scrollOffset;
        final dy = e.localPosition.dy;
        final row = ((dy - FrameGrid.rulerHeight) / FrameGrid.trackHeight).floor();
        final frame = (canvasX / FrameGrid.frameWidth).floor().clamp(0, widget.timeline.duration - 1);
        setState(() {
          _hoverRow = row;
          _hoverFrame = frame;
        });
      },
      onExit: (_) => setState(() {
        _hoverRow = -1;
        _hoverFrame = -1;
      }),
      child: GestureDetector(
        onTapDown: (d) => _handleTap(d.localPosition, trackMap),
        onSecondaryTapDown: (d) => _handleSecondaryTap(d.localPosition, trackMap, context),
        onHorizontalDragStart: (d) => _handleDragStart(d.localPosition, trackMap),
        onHorizontalDragUpdate: (d) => _handleDragUpdate(d.localPosition, trackMap),
        onHorizontalDragEnd: (_) => _handleDragEnd(),
        child: SingleChildScrollView(
          controller: widget.scrollController,
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: totalWidth + FrameGrid.frameWidth * 2, // extra space for handle
            child: CustomPaint(
              painter: _FrameGridPainter(
                timeline: widget.timeline.copyWith(duration: effectiveDuration),
                rows: widget.rows,
                trackMap: trackMap,
                playheadFrame: playhead,
                selectedKeyframeFrame: selectedKf,
                hoverRow: _hoverRow,
                hoverFrame: _hoverFrame,
                dragShapeId: _dragShapeId,
                dragFromFrame: _dragFromFrame,
                dragPreviewFrame: _dragPreviewFrame,
                isDurationDrag: _dragMode == _DragMode.duration,
                gridLineColor: widget.theme.gridLine.withAlpha(40),
                dividerColor: widget.theme.divider.withAlpha(40),
                accentColor: widget.theme.accentColor,
                primaryColor: widget.theme.primaryColor,
                textColor: widget.theme.textDisabled,
                hoverColor: widget.theme.primaryColor.withAlpha(30),
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }

  void _handleDragStart(Offset localPos, Map<String, VecTrack> trackMap) {
    if (_hitTestDurationHandle(localPos)) {
      setState(() {
        _dragMode = _DragMode.duration;
        _previewDuration = widget.timeline.duration;
      });
      return;
    }

    final hit = _hitTestKeyframe(localPos, trackMap);
    if (hit != null) {
      setState(() {
        _dragMode = _DragMode.moveKeyframe;
        _dragShapeId = hit.shapeId;
        _dragLayerId = hit.layerId;
        _dragFromFrame = hit.frame;
        _dragPreviewFrame = hit.frame;
      });
      return;
    }

    setState(() => _dragMode = _DragMode.seek);
  }

  void _handleDragUpdate(Offset localPos, Map<String, VecTrack> trackMap) {
    switch (_dragMode) {
      case _DragMode.seek:
        final frame = _toFrame(localPos.dx, widget.timeline.duration);
        ref.read(playheadFrameProvider.notifier).set(frame);
      case _DragMode.moveKeyframe:
        final frame = _toFrame(localPos.dx, widget.timeline.duration);
        setState(() => _dragPreviewFrame = frame);
        ref.read(playheadFrameProvider.notifier).set(frame);
      case _DragMode.duration:
        _lastDurationDragPos = localPos;
        // Auto-scroll when pointer is near the right edge of the viewport
        if (localPos.dx >= _viewportWidth - _autoScrollZone) {
          _startAutoScroll();
        } else {
          _stopAutoScroll();
          // Pointer is not in auto-scroll zone — drive duration directly from
          // the pointer and keep _targetCanvasX in sync so re-entering the
          // zone doesn't jump.
          final canvasX = localPos.dx + _scrollOffset;
          _targetCanvasX = canvasX;
          final newDuration = (canvasX / FrameGrid.frameWidth).round().clamp(1, 9999);
          setState(() => _previewDuration = newDuration);
        }
      case _DragMode.none:
        break;
    }
  }

  void _handleDragEnd() {
    switch (_dragMode) {
      case _DragMode.moveKeyframe:
        if (_dragShapeId != null && _dragLayerId != null && _dragPreviewFrame != _dragFromFrame) {
          final scene = ref.read(activeSceneProvider);
          if (scene != null) {
            ref
                .read(vecDocumentStateProvider.notifier)
                .moveKeyframeForShape(scene.id, _dragLayerId!, _dragShapeId!, _dragFromFrame, _dragPreviewFrame);
            // Update selected keyframe to the new position
            ref.read(selectedKeyframeFrameProvider.notifier).state = _dragPreviewFrame;
          }
        }
        setState(() {
          _dragMode = _DragMode.none;
          _dragShapeId = null;
          _dragLayerId = null;
          _dragFromFrame = -1;
          _dragPreviewFrame = -1;
        });
      case _DragMode.duration:
        _stopAutoScroll();
        if (_previewDuration > 0) {
          final scene = ref.read(activeSceneProvider);
          if (scene != null) {
            ref.read(vecDocumentStateProvider.notifier).setTimelineDuration(scene.id, _previewDuration);
          }
        }
        setState(() {
          _dragMode = _DragMode.none;
          _previewDuration = -1;
        });
      case _DragMode.seek:
      case _DragMode.none:
        setState(() => _dragMode = _DragMode.none);
    }
  }

  void _handleTap(Offset localPos, Map<String, VecTrack> trackMap) {
    final dy = localPos.dy;
    final canvasX = localPos.dx + _scrollOffset;
    final frame = (canvasX / FrameGrid.frameWidth).floor().clamp(0, widget.timeline.duration - 1);

    if (dy < FrameGrid.rulerHeight) {
      ref.read(playheadFrameProvider.notifier).set(frame);
      return;
    }

    final rowIndex = ((dy - FrameGrid.rulerHeight) / FrameGrid.trackHeight).floor();
    if (rowIndex < 0 || rowIndex >= widget.rows.length) {
      ref.read(playheadFrameProvider.notifier).set(frame);
      return;
    }

    final row = widget.rows[rowIndex];
    final track = trackMap[row.shapeId];
    final hasKf = track?.keyframes.any((k) => k.frame == frame) ?? false;

    final scene = ref.read(activeSceneProvider);
    if (scene == null) return;

    if (hasKf) {
      if (HardwareKeyboard.instance.isMetaPressed) {
        ref.read(vecDocumentStateProvider.notifier).removeKeyframeForShape(scene.id, row.layerId, row.shapeId, frame);
      } else {
        // Select this keyframe and seek to it
        ref.read(selectedKeyframeFrameProvider.notifier).state = frame;
        ref.read(playheadFrameProvider.notifier).set(frame);
      }
    } else {
      // Add keyframe: snapshot shape state
      VecShape? shape;
      for (final layer in scene.layers) {
        if (layer.id != row.layerId) continue;
        shape = layer.shapes.where((s) => s.id == row.shapeId).firstOrNull;
        if (shape != null) break;
      }
      if (shape == null) return;

      final kf = VecKeyframe(
        frame: frame,
        tweenType: VecTweenType.classic,
        transform: shape.data.transform,
        opacity: shape.data.opacity,
        fills: List.unmodifiable(shape.data.fills),
        strokes: List.unmodifiable(shape.data.strokes),
      );
      ref.read(vecDocumentStateProvider.notifier).addKeyframeForShape(scene.id, row.layerId, row.shapeId, kf);

      // New keyframe becomes the selected frame
      ref.read(selectedKeyframeFrameProvider.notifier).state = frame;
      ref.read(playheadFrameProvider.notifier).set(frame);
    }
  }

  /// Right-click: open the easing editor for an existing keyframe.
  void _handleSecondaryTap(Offset localPos, Map<String, VecTrack> trackMap, BuildContext ctx) {
    final dy = localPos.dy;
    final canvasX = localPos.dx + _scrollOffset;
    if (dy < FrameGrid.rulerHeight) return;

    final rowIndex = ((dy - FrameGrid.rulerHeight) / FrameGrid.trackHeight).floor();
    if (rowIndex < 0 || rowIndex >= widget.rows.length) return;

    final frame = (canvasX / FrameGrid.frameWidth).floor().clamp(0, widget.timeline.duration - 1);

    final row = widget.rows[rowIndex];
    final track = trackMap[row.shapeId];
    final kf = track?.keyframes.where((k) => k.frame == frame).firstOrNull;
    if (kf == null) return;

    final scene = ref.read(activeSceneProvider);
    if (scene == null) return;

    showKeyframeEasingEditor(
      context: ctx,
      theme: widget.theme,
      keyframe: kf,
      onChanged: (updatedKf) {
        ref
            .read(vecDocumentStateProvider.notifier)
            .updateKeyframeForShape(scene.id, row.layerId, row.shapeId, frame, (_) => updatedKf);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Painter
// ---------------------------------------------------------------------------

class _FrameGridPainter extends CustomPainter {
  _FrameGridPainter({
    required this.timeline,
    required this.rows,
    required this.trackMap,
    required this.playheadFrame,
    required this.selectedKeyframeFrame,
    required this.hoverRow,
    required this.hoverFrame,
    required this.dragShapeId,
    required this.dragFromFrame,
    required this.dragPreviewFrame,
    required this.isDurationDrag,
    required this.gridLineColor,
    required this.dividerColor,
    required this.accentColor,
    required this.primaryColor,
    required this.textColor,
    required this.hoverColor,
  });

  final VecTimeline timeline;
  final List<TrackRow> rows;
  final Map<String, VecTrack> trackMap;
  final int playheadFrame;
  final int selectedKeyframeFrame;
  final int hoverRow;
  final int hoverFrame;
  final String? dragShapeId;
  final int dragFromFrame;
  final int dragPreviewFrame;
  final bool isDurationDrag;
  final Color gridLineColor;
  final Color dividerColor;
  final Color accentColor;
  final Color primaryColor;
  final Color textColor;
  final Color hoverColor;

  static const _fw = FrameGrid.frameWidth;
  static const _th = FrameGrid.trackHeight;
  static const _rh = FrameGrid.rulerHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridLineColor
      ..strokeWidth = 0.5;
    final majorGridPaint = Paint()
      ..color = gridLineColor.withAlpha(100)
      ..strokeWidth = 0.5;
    final dividerPaint = Paint()
      ..color = dividerColor
      ..strokeWidth = 0.5;

    // Ruler background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, _rh), Paint()..color = dividerColor.withAlpha(20));

    // Hover row highlight
    if (hoverRow >= 0 && hoverRow < rows.length) {
      canvas.drawRect(Rect.fromLTWH(0, _rh + hoverRow * _th, size.width, _th), Paint()..color = hoverColor);
    }

    // Selected keyframe column tint (behind everything)
    if (selectedKeyframeFrame >= 0 && selectedKeyframeFrame < timeline.duration) {
      final sx = selectedKeyframeFrame * _fw;
      canvas.drawRect(Rect.fromLTWH(sx, _rh, _fw, size.height - _rh), Paint()..color = primaryColor.withAlpha(12));
    }

    // Vertical frame lines + ruler numbers
    for (var f = 0; f <= timeline.duration; f++) {
      final x = f * _fw;
      final isMajor = f % 12 == 0;
      canvas.drawLine(Offset(x, _rh), Offset(x, size.height), isMajor ? majorGridPaint : gridPaint);
      if (isMajor && f < timeline.duration) {
        final tp = TextPainter(
          text: TextSpan(
            text: '${f + 1}',
            style: TextStyle(fontSize: 8, color: textColor),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x + 2, 3));
      }
    }

    // Hover frame column highlight (in ruler only)
    if (hoverFrame >= 0) {
      final hx = hoverFrame * _fw;
      canvas.drawRect(Rect.fromLTWH(hx, 0, _fw, _rh), Paint()..color = primaryColor.withAlpha(25));
    }

    // Horizontal track dividers
    for (var i = 0; i <= rows.length; i++) {
      final y = _rh + i * _th;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), dividerPaint);
    }

    // Keyframe diamonds per row
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final track = trackMap[row.shapeId];
      if (track == null) continue;

      final cy = _rh + i * _th + _th / 2;
      final isDragRow = row.shapeId == dragShapeId;

      for (final kf in track.keyframes) {
        // During drag: don't draw the original position, draw preview instead
        if (isDragRow && kf.frame == dragFromFrame && dragFromFrame >= 0) {
          if (dragPreviewFrame >= 0) {
            final cx = dragPreviewFrame * _fw + _fw / 2;
            final isSelected = dragPreviewFrame == selectedKeyframeFrame;
            _drawDiamond(canvas, Offset(cx, cy), 5.5, Paint()..color = primaryColor, selected: isSelected);
          }
          continue;
        }

        final cx = kf.frame * _fw + _fw / 2;
        final isHovered = i == hoverRow && kf.frame == hoverFrame;
        final isSelected = kf.frame == selectedKeyframeFrame;

        _drawDiamond(
          canvas,
          Offset(cx, cy),
          isHovered || isSelected ? 5.5 : 4.5,
          Paint()
            ..color = isSelected
                ? primaryColor
                : isHovered
                ? primaryColor.withAlpha(200)
                : accentColor,
          selected: isSelected,
        );
      }
    }

    // Duration end line
    final endX = timeline.duration * _fw;
    canvas.drawLine(
      Offset(endX, 0),
      Offset(endX, size.height),
      Paint()
        ..color = isDurationDrag ? primaryColor : dividerColor.withAlpha(180)
        ..strokeWidth = isDurationDrag ? 2.0 : 1.5,
    );

    // Duration handle on the ruler
    _drawDurationHandle(canvas, endX);

    // Playhead line
    final phX = playheadFrame * _fw + _fw / 2;
    canvas.drawLine(
      Offset(phX, 0),
      Offset(phX, size.height),
      Paint()
        ..color = primaryColor
        ..strokeWidth = 1.5,
    );
    // Playhead triangle at top
    final tri = Path()
      ..moveTo(phX - 5, 0)
      ..lineTo(phX + 5, 0)
      ..lineTo(phX, 7)
      ..close();
    canvas.drawPath(tri, Paint()..color = primaryColor);
  }

  void _drawDurationHandle(Canvas canvas, double endX) {
    // Small pill/tab on the ruler at the end
    const h = _rh - 4;
    const w = 10.0;
    final rect = RRect.fromRectAndRadius(Rect.fromLTWH(endX - w / 2, 2, w, h), const Radius.circular(3));
    canvas.drawRRect(rect, Paint()..color = isDurationDrag ? primaryColor : dividerColor.withAlpha(200));
    // Small double-arrow hint
    const midY = 2 + h / 2;
    final arrowPaint = Paint()
      ..color = isDurationDrag ? Colors.white : textColor
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    // Left arrow
    canvas.drawLine(Offset(endX - 3, midY - 2), Offset(endX - 5, midY), arrowPaint);
    canvas.drawLine(Offset(endX - 3, midY + 2), Offset(endX - 5, midY), arrowPaint);
    // Right arrow
    canvas.drawLine(Offset(endX + 3, midY - 2), Offset(endX + 5, midY), arrowPaint);
    canvas.drawLine(Offset(endX + 3, midY + 2), Offset(endX + 5, midY), arrowPaint);
  }

  void _drawDiamond(Canvas canvas, Offset c, double r, Paint paint, {bool selected = false}) {
    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..lineTo(c.dx + r, c.dy)
      ..lineTo(c.dx, c.dy + r)
      ..lineTo(c.dx - r, c.dy)
      ..close();
    canvas.drawPath(path, paint);
    // Outline – thicker and brighter for selected
    canvas.drawPath(
      path,
      Paint()
        ..color = selected ? Colors.white.withAlpha(200) : paint.color.withAlpha(180)
        ..style = PaintingStyle.stroke
        ..strokeWidth = selected ? 1.5 : 0.8,
    );
  }

  @override
  bool shouldRepaint(covariant _FrameGridPainter old) =>
      old.playheadFrame != playheadFrame ||
      old.selectedKeyframeFrame != selectedKeyframeFrame ||
      old.timeline != timeline ||
      old.rows != rows ||
      old.trackMap != trackMap ||
      old.hoverRow != hoverRow ||
      old.hoverFrame != hoverFrame ||
      old.dragShapeId != dragShapeId ||
      old.dragFromFrame != dragFromFrame ||
      old.dragPreviewFrame != dragPreviewFrame ||
      old.isDurationDrag != isDurationDrag ||
      old.primaryColor != primaryColor;
}
