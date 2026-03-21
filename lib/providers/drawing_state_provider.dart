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

/// A single node in a pen-tool path being drawn.
/// [handleOut] is an absolute canvas position; [handleIn] is its mirror.
class PenNode {
  final Offset position;
  final Offset? handleOut;

  const PenNode({required this.position, this.handleOut});

  bool get isCurve => handleOut != null;

  Offset? get handleIn =>
      handleOut != null ? position * 2.0 - handleOut! : null;

  PenNode withHandle(Offset out) =>
      PenNode(position: position, handleOut: out);

  PenNode withPosition(Offset pos) => PenNode(
        position: pos,
        handleOut: handleOut != null ? pos + (handleOut! - position) : null,
      );
}

/// Tracks pen tool nodes being placed.
class PenDrawingState {
  final List<PenNode> nodes;

  const PenDrawingState({required this.nodes});

  /// Backward-compat: plain positions of all nodes.
  List<Offset> get points => nodes.map((n) => n.position).toList();

  PenDrawingState addNode(Offset position) =>
      PenDrawingState(nodes: [...nodes, PenNode(position: position)]);

  /// Updates the [handleOut] (and derived [handleIn]) of the last node.
  PenDrawingState updateLastHandle(Offset handleOut) {
    if (nodes.isEmpty) return this;
    final updated = List<PenNode>.from(nodes);
    updated[updated.length - 1] = updated.last.withHandle(handleOut);
    return PenDrawingState(nodes: updated);
  }
}

@riverpod
class ActivePenDrawing extends _$ActivePenDrawing {
  @override
  PenDrawingState? build() => null;

  void start(Offset point) {
    state = PenDrawingState(nodes: [PenNode(position: point)]);
  }

  void addPoint(Offset point) {
    if (state != null) state = state!.addNode(point);
  }

  void updateLastHandle(Offset handleOut) {
    if (state != null) state = state!.updateLastHandle(handleOut);
  }

  void cancel() => state = null;

  PenDrawingState? finish() {
    final result = state;
    state = null;
    return result;
  }
}
