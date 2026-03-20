import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../data/models/vec_timeline.dart';
import '../../../providers/document_provider.dart';

class FrameGrid extends ConsumerWidget {
  const FrameGrid({
    super.key,
    required this.timeline,
    required this.theme,
    this.scrollController,
  });

  final VecTimeline timeline;
  final AppTheme theme;
  final ScrollController? scrollController;

  static const frameWidth = 10.0;
  static const trackHeight = 24.0;
  static const rulerHeight = 18.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playhead = ref.watch(playheadFrameProvider);
    final totalWidth = timeline.duration * frameWidth;

    return GestureDetector(
      onTapDown: (details) {
        final frame = ((details.localPosition.dx) / frameWidth).floor();
        ref.read(playheadFrameProvider.notifier).set(
              frame.clamp(0, timeline.duration - 1),
            );
      },
      onHorizontalDragUpdate: (details) {
        final frame = ((details.localPosition.dx) / frameWidth).floor();
        ref.read(playheadFrameProvider.notifier).set(
              frame.clamp(0, timeline.duration - 1),
            );
      },
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: totalWidth,
          child: CustomPaint(
            painter: _FrameGridPainter(
              timeline: timeline,
              playheadFrame: playhead,
              gridLineColor: theme.gridLine.withAlpha(40),
              dividerColor: theme.divider.withAlpha(40),
              accentColor: theme.accentColor,
              primaryColor: theme.primaryColor,
              textColor: theme.textDisabled,
              trackCount: timeline.tracks.length,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class _FrameGridPainter extends CustomPainter {
  _FrameGridPainter({
    required this.timeline,
    required this.playheadFrame,
    required this.gridLineColor,
    required this.dividerColor,
    required this.accentColor,
    required this.primaryColor,
    required this.textColor,
    required this.trackCount,
  });

  final VecTimeline timeline;
  final int playheadFrame;
  final Color gridLineColor;
  final Color dividerColor;
  final Color accentColor;
  final Color primaryColor;
  final Color textColor;
  final int trackCount;

  static const _frameWidth = FrameGrid.frameWidth;
  static const _trackHeight = FrameGrid.trackHeight;
  static const _rulerHeight = FrameGrid.rulerHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridLineColor
      ..strokeWidth = 0.5;
    final majorGridPaint = Paint()
      ..color = gridLineColor.withAlpha(80)
      ..strokeWidth = 0.5;
    final dividerPaint = Paint()
      ..color = dividerColor
      ..strokeWidth = 0.5;

    // Draw ruler background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, _rulerHeight),
      Paint()..color = dividerColor.withAlpha(20),
    );

    // Draw vertical frame lines
    for (var f = 0; f <= timeline.duration; f++) {
      final x = f * _frameWidth;
      final isMajor = f % 12 == 0;
      canvas.drawLine(
        Offset(x, _rulerHeight),
        Offset(x, size.height),
        isMajor ? majorGridPaint : gridPaint,
      );

      // Frame numbers at ruler
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

    // Draw horizontal track lines
    for (var t = 0; t <= trackCount; t++) {
      final y = _rulerHeight + t * _trackHeight;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        dividerPaint,
      );
    }

    // Draw keyframe diamonds
    final keyframePaint = Paint()..color = accentColor;
    for (var i = 0; i < timeline.tracks.length; i++) {
      final track = timeline.tracks[i];
      final cy = _rulerHeight + i * _trackHeight + _trackHeight / 2;
      for (final kf in track.keyframes) {
        final cx = kf.frame * _frameWidth + _frameWidth / 2;
        _drawDiamond(canvas, Offset(cx, cy), 4, keyframePaint);
      }
    }

    // Draw playhead
    final phX = playheadFrame * _frameWidth + _frameWidth / 2;
    final playheadPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(phX, 0),
      Offset(phX, size.height),
      playheadPaint,
    );

    // Playhead triangle at top
    final path = Path()
      ..moveTo(phX - 5, 0)
      ..lineTo(phX + 5, 0)
      ..lineTo(phX, 6)
      ..close();
    canvas.drawPath(path, Paint()..color = primaryColor);
  }

  void _drawDiamond(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..lineTo(center.dx + radius, center.dy)
      ..lineTo(center.dx, center.dy + radius)
      ..lineTo(center.dx - radius, center.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FrameGridPainter old) =>
      old.playheadFrame != playheadFrame ||
      old.timeline != timeline ||
      old.primaryColor != primaryColor;
}
