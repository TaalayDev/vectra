import 'dart:ui' show Offset;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/models/vec_layer.dart';
import '../data/models/vec_scene.dart';
import '../data/models/vec_shape.dart';
import 'document_provider.dart';

part 'editor_state_provider.g.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum VecTool { select, pen, rectangle, ellipse, text, width }

// ---------------------------------------------------------------------------
// UI state providers
// ---------------------------------------------------------------------------

@riverpod
class ActiveTool extends _$ActiveTool {
  @override
  VecTool build() => VecTool.select;

  void set(VecTool tool) => state = tool;
}

@riverpod
class ZoomLevel extends _$ZoomLevel {
  static const _min = 0.1;
  static const _max = 32.0;

  @override
  double build() => 1.0;

  void set(double value) => state = value.clamp(_min, _max);
  void zoomIn() => state = (state * 1.25).clamp(_min, _max);
  void zoomOut() => state = (state / 1.25).clamp(_min, _max);
  void zoomFit() => state = 1.0;
  void zoom100() => state = 1.0;
}

@riverpod
class CursorPosition extends _$CursorPosition {
  @override
  Offset build() => Offset.zero;

  void set(Offset pos) => state = pos;
}

@riverpod
class PanelVisibility extends _$PanelVisibility {
  @override
  ({bool layers, bool properties, bool timeline}) build() =>
      (layers: true, properties: true, timeline: true);

  void toggleLayers() =>
      state = (layers: !state.layers, properties: state.properties, timeline: state.timeline);
  void toggleProperties() =>
      state = (layers: state.layers, properties: !state.properties, timeline: state.timeline);
  void toggleTimeline() =>
      state = (layers: state.layers, properties: state.properties, timeline: !state.timeline);
  void toggleAll() {
    final allVisible = state.layers && state.properties && state.timeline;
    state = (layers: !allVisible, properties: !allVisible, timeline: !allVisible);
  }
}

@riverpod
class TimelineHeight extends _$TimelineHeight {
  @override
  double build() => 200.0;

  void set(double value) => state = value.clamp(100.0, 500.0);
}

@riverpod
class SelectedShapeId extends _$SelectedShapeId {
  @override
  String? build() => null;

  void set(String? id) => state = id;
  void clear() => state = null;
}

@riverpod
class IsPlaying extends _$IsPlaying {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void set(bool value) => state = value;
}

// ---------------------------------------------------------------------------
// Derived state providers
// ---------------------------------------------------------------------------

@riverpod
VecScene? activeScene(ActiveSceneRef ref) {
  final scenes = ref.watch(scenesProvider);
  final index = ref.watch(activeSceneIndexProvider);
  if (index >= 0 && index < scenes.length) return scenes[index];
  return null;
}

@riverpod
VecLayer? activeLayer(ActiveLayerRef ref) {
  final scene = ref.watch(activeSceneProvider);
  final layerId = ref.watch(activeLayerIdProvider);
  if (scene == null || layerId == null) return null;
  for (final layer in scene.layers) {
    if (layer.id == layerId) return layer;
  }
  return null;
}

@riverpod
VecShape? selectedShape(SelectedShapeRef ref) {
  final scene = ref.watch(activeSceneProvider);
  final shapeId = ref.watch(selectedShapeIdProvider);
  if (scene == null || shapeId == null) return null;
  for (final layer in scene.layers) {
    for (final shape in layer.shapes) {
      if (shape.id == shapeId) return shape;
    }
  }
  return null;
}
