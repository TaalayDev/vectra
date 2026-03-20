import 'dart:ui' show Offset;

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'drawing_state_provider.g.dart';

/// Tracks the current pointer drag during shape creation.
/// `null` when not drawing.
class DrawingState {
  final Offset startPoint;
  final Offset currentPoint;

  const DrawingState({
    required this.startPoint,
    required this.currentPoint,
  });

  double get left => startPoint.dx < currentPoint.dx ? startPoint.dx : currentPoint.dx;
  double get top => startPoint.dy < currentPoint.dy ? startPoint.dy : currentPoint.dy;
  double get width => (currentPoint.dx - startPoint.dx).abs();
  double get height => (currentPoint.dy - startPoint.dy).abs();

  DrawingState copyWith({Offset? startPoint, Offset? currentPoint}) {
    return DrawingState(
      startPoint: startPoint ?? this.startPoint,
      currentPoint: currentPoint ?? this.currentPoint,
    );
  }
}

@riverpod
class ActiveDrawing extends _$ActiveDrawing {
  @override
  DrawingState? build() => null;

  void start(Offset point) {
    state = DrawingState(startPoint: point, currentPoint: point);
  }

  void update(Offset point) {
    if (state != null) {
      state = state!.copyWith(currentPoint: point);
    }
  }

  void cancel() => state = null;

  DrawingState? finish() {
    final result = state;
    state = null;
    return result;
  }
}

/// Tracks pen tool nodes being placed (list of offsets).
class PenDrawingState {
  final List<Offset> points;

  const PenDrawingState({required this.points});

  PenDrawingState addPoint(Offset point) {
    return PenDrawingState(points: [...points, point]);
  }
}

@riverpod
class ActivePenDrawing extends _$ActivePenDrawing {
  @override
  PenDrawingState? build() => null;

  void start(Offset point) {
    state = PenDrawingState(points: [point]);
  }

  void addPoint(Offset point) {
    if (state != null) {
      state = state!.addPoint(point);
    }
  }

  void cancel() => state = null;

  PenDrawingState? finish() {
    final result = state;
    state = null;
    return result;
  }
}
