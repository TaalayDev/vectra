import 'package:flutter/material.dart';
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
  const TrackRow({
    required this.layerId,
    required this.shapeId,
    required this.name,
    required this.icon,
  });

  final String layerId;
  final String shapeId;
  final String name;
  final IconData icon;
}

// ---------------------------------------------------------------------------
// FrameGrid widget
// ---------------------------------------------------------------------------

class FrameGrid extends ConsumerStatefulWidget {
  const FrameGrid({
    super.key,
    required this.timeline,
    required this.rows,
    required this.theme,
    this.scrollController,
  });

  final VecTimeline timeline;
  final List<TrackRow> rows;
  final AppTheme theme;
  final ScrollController? scrollController;

  static const frameWidth = 10.0;
  static const trackHeight = 24.0;
  static const rulerHeight = 18.0;

  @override
  ConsumerState<FrameGrid> createState() => _FrameGridState();
}

class _FrameGridState extends ConsumerState<FrameGrid> {
  int _hoverFrame = -1;
  int _hoverRow = -1;

  @override
  Widget build(BuildContext context) {
    final playhead = ref.watch(playheadFrameProvider);
    final totalWidth = widget.timeline.duration * FrameGrid.frameWidth;

    // Build shapeId → track map for keyframe lookup
    final trackMap = <String, VecTrack>{};
    for (final t in widget.timeline.tracks) {
      if (t.shapeId != null) trackMap[t.shapeId!] = t;
    }

    return MouseRegion(
      onHover: (e) {
        final dx = e.localPosition.dx;
        final dy = e.localPosition.dy;
        final row = ((dy - FrameGrid.rulerHeight) / FrameGrid.trackHeight).floor();
        final frame = (dx / FrameGrid.frameWidth).floor();
        setState(() {
          _hoverRow = row;
          _hoverFrame = frame.clamp(0, widget.timeline.duration - 1);
        });
      },
      onExit: (_) => setState(() {
        _hoverRow = -1;
        _hoverFrame = -1;
      }),
      child: GestureDetector(
        // Tap on ruler → seek; tap on track row → add/remove keyframe
        onTapDown: (d) => _handleTap(d.localPosition, trackMap),
        // Right-click on a keyframe diamond → easing editor
        onSecondaryTapDown: (d) =>
            _handleSecondaryTap(d.localPosition, trackMap, context),
        // Drag always seeks
        onHorizontalDragUpdate: (d) {
          final frame = (d.localPosition.dx / FrameGrid.frameWidth)
              .floor()
              .clamp(0, widget.timeline.duration - 1);
          ref.read(playheadFrameProvider.notifier).set(frame);
        },
        child: SingleChildScrollView(
          controller: widget.scrollController,
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: totalWidth,
            child: CustomPaint(
              painter: _FrameGridPainter(
                timeline: widget.timeline,
                rows: widget.rows,
                trackMap: trackMap,
                playheadFrame: playhead,
                hoverRow: _hoverRow,
                hoverFrame: _hoverFrame,
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

  void _handleTap(Offset localPos, Map<String, VecTrack> trackMap) {
    final dy = localPos.dy;
    final dx = localPos.dx;
    final frame = (dx / FrameGrid.frameWidth)
        .floor()
        .clamp(0, widget.timeline.duration - 1);

    if (dy < FrameGrid.rulerHeight) {
      // Ruler → seek
      ref.read(playheadFrameProvider.notifier).set(frame);
      return;
    }

    final rowIndex =
        ((dy - FrameGrid.rulerHeight) / FrameGrid.trackHeight).floor();
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
      // Cmd+click or plain click on existing → remove
      if (HardwareKeyboard.instance.isMetaPressed) {
        ref.read(vecDocumentStateProvider.notifier).removeKeyframeForShape(
              scene.id, row.layerId, row.shapeId, frame);
      } else {
        // Plain click on diamond → just seek
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
      ref.read(vecDocumentStateProvider.notifier).addKeyframeForShape(
            scene.id, row.layerId, row.shapeId, kf);

      // Seek to the added keyframe
      ref.read(playheadFrameProvider.notifier).set(frame);
    }
  }

  /// Right-click: open the easing editor for an existing keyframe.
  void _handleSecondaryTap(
    Offset localPos,
    Map<String, VecTrack> trackMap,
    BuildContext ctx,
  ) {
    final dy = localPos.dy;
    final dx = localPos.dx;
    if (dy < FrameGrid.rulerHeight) return;

    final rowIndex =
        ((dy - FrameGrid.rulerHeight) / FrameGrid.trackHeight).floor();
    if (rowIndex < 0 || rowIndex >= widget.rows.length) return;

    final frame = (dx / FrameGrid.frameWidth)
        .floor()
        .clamp(0, widget.timeline.duration - 1);

    final row = widget.rows[rowIndex];
    final track = trackMap[row.shapeId];
    final kf = track?.keyframes.where((k) => k.frame == frame).firstOrNull;
    if (kf == null) return; // only on existing keyframes

    final scene = ref.read(activeSceneProvider);
    if (scene == null) return;

    showEasingEditor(
      context: ctx,
      theme: widget.theme,
      currentEasing: kf.easing,
      onChanged: (newEasing) {
        ref.read(vecDocumentStateProvider.notifier).updateKeyframeForShape(
              scene.id, row.layerId, row.shapeId, frame,
              (k) => k.copyWith(easing: newEasing));
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
    required this.hoverRow,
    required this.hoverFrame,
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
  final int hoverRow;
  final int hoverFrame;
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
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, _rh),
      Paint()..color = dividerColor.withAlpha(20),
    );

    // Hover row highlight
    if (hoverRow >= 0 && hoverRow < rows.length) {
      canvas.drawRect(
        Rect.fromLTWH(0, _rh + hoverRow * _th, size.width, _th),
        Paint()..color = hoverColor,
      );
    }

    // Vertical frame lines + ruler numbers
    for (var f = 0; f <= timeline.duration; f++) {
      final x = f * _fw;
      final isMajor = f % 12 == 0;
      canvas.drawLine(
        Offset(x, _rh),
        Offset(x, size.height),
        isMajor ? majorGridPaint : gridPaint,
      );
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
      canvas.drawRect(
        Rect.fromLTWH(hx, 0, _fw, _rh),
        Paint()..color = primaryColor.withAlpha(25),
      );
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
      for (final kf in track.keyframes) {
        final cx = kf.frame * _fw + _fw / 2;
        final isHovered = i == hoverRow && kf.frame == hoverFrame;
        _drawDiamond(
          canvas,
          Offset(cx, cy),
          isHovered ? 5.5 : 4.5,
          Paint()..color = isHovered ? primaryColor : accentColor,
        );
      }
    }

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

  void _drawDiamond(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..lineTo(c.dx + r, c.dy)
      ..lineTo(c.dx, c.dy + r)
      ..lineTo(c.dx - r, c.dy)
      ..close();
    canvas.drawPath(path, paint);
    // Outline
    canvas.drawPath(
      path,
      Paint()
        ..color = paint.color.withAlpha(180)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  @override
  bool shouldRepaint(covariant _FrameGridPainter old) =>
      old.playheadFrame != playheadFrame ||
      old.timeline != timeline ||
      old.rows != rows ||
      old.trackMap != trackMap ||
      old.hoverRow != hoverRow ||
      old.hoverFrame != hoverFrame ||
      old.primaryColor != primaryColor;
}
