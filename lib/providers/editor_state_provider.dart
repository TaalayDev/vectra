import 'dart:ui' show Offset;

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/models/vec_color.dart';
import '../data/models/vec_layer.dart';
import '../data/models/vec_scene.dart';
import '../data/models/vec_shape.dart';
import 'document_provider.dart';

part 'editor_state_provider.g.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum VecTool { select, pen, line, rectangle, ellipse, text, width, bend, knife, freedraw }

// ---------------------------------------------------------------------------
// Text editing — which shape is currently being inline-edited (null = none)
// ---------------------------------------------------------------------------

final textEditingShapeIdProvider = StateProvider<String?>((ref) => null);

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
  static const _min = 0.01;
  static const _max = 64.0;

  @override
  double build() => 1.0;

  void set(double value) => state = value.clamp(_min, _max);
  void zoomIn() => state = (state * 1.25).clamp(_min, _max);
  void zoomOut() => state = (state / 1.25).clamp(_min, _max);
  void zoom100() => state = 1.0;

  /// Compute zoom so that stage fits inside the given viewport with padding.
  void zoomToFit(double viewportWidth, double viewportHeight, double stageWidth, double stageHeight) {
    if (stageWidth <= 0 || stageHeight <= 0) return;
    const padding = 48.0;
    final scaleX = (viewportWidth - padding * 2) / stageWidth;
    final scaleY = (viewportHeight - padding * 2) / stageHeight;
    state = scaleX.clamp(_min, _max) < scaleY.clamp(_min, _max) ? scaleX.clamp(_min, _max) : scaleY.clamp(_min, _max);
  }
}

/// Undo / redo availability flags — updated by VecDocumentState after every commit.
@Riverpod(keepAlive: true)
class UndoAvailability extends _$UndoAvailability {
  @override
  ({bool canUndo, bool canRedo}) build() => (canUndo: false, canRedo: false);

  void update({required bool canUndo, required bool canRedo}) => state = (canUndo: canUndo, canRedo: canRedo);
}

/// Incremented to request a zoom-to-fit from the canvas.
@riverpod
class FitRequest extends _$FitRequest {
  @override
  int build() => 0;

  void request() => state++;
}

/// Incremented to request a zoom-to-selected-shapes from the canvas.
final fitSelectionRequestProvider = StateProvider<int>((ref) => 0);

@riverpod
class CanvasOffset extends _$CanvasOffset {
  @override
  Offset build() => Offset.zero;

  void set(Offset value) => state = value;
  void pan(Offset delta) => state = state + delta;
  void reset() => state = Offset.zero;
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
  ({bool layers, bool properties, bool timeline}) build() => (layers: true, properties: true, timeline: true);

  void toggleLayers() => state = (layers: !state.layers, properties: state.properties, timeline: state.timeline);
  void toggleProperties() => state = (layers: state.layers, properties: !state.properties, timeline: state.timeline);
  void toggleTimeline() => state = (layers: state.layers, properties: state.properties, timeline: !state.timeline);
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

/// Multi-selection: ordered list of selected shape IDs.
/// The last entry is considered the "primary" selected shape for the
/// Properties Panel. Kept in sync with [SelectedShapeId] by the canvas.
@riverpod
class SelectedShapeIds extends _$SelectedShapeIds {
  @override
  List<String> build() => const [];

  void setSingle(String id) => state = [id];
  void add(String id) {
    if (!state.contains(id)) state = [...state, id];
  }

  void remove(String id) => state = state.where((s) => s != id).toList(growable: false);
  void setAll(List<String> ids) => state = List.unmodifiable(ids);
  void clear() => state = const [];
}

/// The frame number of the currently selected keyframe.
/// Defaults to 0 (first frame). Updated when clicking a keyframe diamond
/// or adding a new keyframe.
final selectedKeyframeFrameProvider = StateProvider<int>((ref) => 0);

@riverpod
class IsPlaying extends _$IsPlaying {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void set(bool value) => state = value;
}

/// The ID of the shape whose name is currently being edited inline.
/// Set to a shape ID to enter rename mode; null to exit.
final renamingShapeIdProvider = StateProvider<String?>((ref) => null);

/// The ID of the group shape currently being edited in isolate mode.
/// Null when not in group-edit mode.
@riverpod
class ActiveGroupId extends _$ActiveGroupId {
  @override
  String? build() => null;

  void set(String? id) => state = id;
  void clear() => state = null;
}

/// The ID of the symbol currently being edited in Symbol Edit Mode.
/// Null when not editing a symbol master.
@riverpod
class EditingSymbolId extends _$EditingSymbolId {
  @override
  String? build() => null;

  void set(String symbolId) => state = symbolId;
  void clear() => state = null;
}

// ---------------------------------------------------------------------------
// Snap settings
// ---------------------------------------------------------------------------

class SnapSettings {
  const SnapSettings({
    this.toGrid = false,
    this.toObjects = true,
    this.showRulers = true,
    this.showGrid = false,
    this.gridSize = 8,
  });

  final bool toGrid;
  final bool toObjects;
  final bool showRulers;
  final bool showGrid;
  final int gridSize;

  SnapSettings copyWith({bool? toGrid, bool? toObjects, bool? showRulers, bool? showGrid, int? gridSize}) =>
      SnapSettings(
        toGrid: toGrid ?? this.toGrid,
        toObjects: toObjects ?? this.toObjects,
        showRulers: showRulers ?? this.showRulers,
        showGrid: showGrid ?? this.showGrid,
        gridSize: gridSize ?? this.gridSize,
      );
}

class SnapSettingsNotifier extends StateNotifier<SnapSettings> {
  SnapSettingsNotifier() : super(const SnapSettings());

  void toggleGrid() => state = state.copyWith(toGrid: !state.toGrid);
  void toggleObjects() => state = state.copyWith(toObjects: !state.toObjects);
  void toggleRulers() => state = state.copyWith(showRulers: !state.showRulers);
  void toggleShowGrid() => state = state.copyWith(showGrid: !state.showGrid);
  void setGridSize(int size) => state = state.copyWith(gridSize: size);
}

final snapSettingsProvider = StateNotifierProvider<SnapSettingsNotifier, SnapSettings>((ref) => SnapSettingsNotifier());

// ---------------------------------------------------------------------------
// Canvas guides (dragged from rulers)
// ---------------------------------------------------------------------------

class GuidesState {
  const GuidesState({this.horizontal = const [], this.vertical = const []});

  /// Canvas-coordinate Y positions of horizontal guides (y = constant lines).
  final List<double> horizontal;

  /// Canvas-coordinate X positions of vertical guides (x = constant lines).
  final List<double> vertical;

  GuidesState copyWith({List<double>? horizontal, List<double>? vertical}) =>
      GuidesState(horizontal: horizontal ?? this.horizontal, vertical: vertical ?? this.vertical);
}

class GuidesNotifier extends StateNotifier<GuidesState> {
  GuidesNotifier() : super(const GuidesState());

  void addHorizontal(double y) => state = state.copyWith(horizontal: [...state.horizontal, y]);
  void addVertical(double x) => state = state.copyWith(vertical: [...state.vertical, x]);

  void removeHorizontal(double y) =>
      state = state.copyWith(horizontal: state.horizontal.where((v) => (v - y).abs() > 0.01).toList());
  void removeVertical(double x) =>
      state = state.copyWith(vertical: state.vertical.where((v) => (v - x).abs() > 0.01).toList());

  void moveHorizontal(double oldY, double newY) =>
      state = state.copyWith(horizontal: [for (final y in state.horizontal) (y - oldY).abs() < 0.5 ? newY : y]);
  void moveVertical(double oldX, double newX) =>
      state = state.copyWith(vertical: [for (final x in state.vertical) (x - oldX).abs() < 0.5 ? newX : x]);

  void clear() => state = const GuidesState();
}

final guidesProvider = StateNotifierProvider<GuidesNotifier, GuidesState>((ref) => GuidesNotifier());

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
  final groupId = ref.watch(activeGroupIdProvider);
  if (scene == null || shapeId == null) return null;

  for (final layer in scene.layers) {
    for (final shape in layer.shapes) {
      // In group-edit mode, look inside the active group's children
      if (groupId != null && shape.id == groupId) {
        final g = shape.maybeMap(group: (g) => g, orElse: () => null);
        if (g != null) {
          for (final child in g.children) {
            if (child.id == shapeId) return child;
          }
        }
        continue;
      }
      if (shape.id == shapeId) return shape;
    }
  }
  return null;
}

// ---------------------------------------------------------------------------
// Base color — default fill / stroke for newly created shapes
// ---------------------------------------------------------------------------

class BaseColorState {
  final VecColor fillColor;
  final VecColor strokeColor;

  const BaseColorState({
    this.fillColor = const VecColor(a: 255, r: 120, g: 160, b: 230),
    this.strokeColor = const VecColor(a: 255, r: 50, g: 60, b: 80),
  });

  BaseColorState copyWith({VecColor? fillColor, VecColor? strokeColor}) =>
      BaseColorState(fillColor: fillColor ?? this.fillColor, strokeColor: strokeColor ?? this.strokeColor);
}

class BaseColorNotifier extends StateNotifier<BaseColorState> {
  BaseColorNotifier() : super(const BaseColorState());

  void setFill(VecColor color) => state = state.copyWith(fillColor: color);
  void setStroke(VecColor color) => state = state.copyWith(strokeColor: color);
}

final baseColorProvider = StateNotifierProvider<BaseColorNotifier, BaseColorState>((ref) => BaseColorNotifier());

// ---------------------------------------------------------------------------
// Graph editor
// ---------------------------------------------------------------------------

class GraphEditorVisibleNotifier extends StateNotifier<bool> {
  GraphEditorVisibleNotifier() : super(false);
  void toggle() => state = !state;
  void set(bool value) => state = value;
}

final graphEditorVisibleProvider = StateNotifierProvider<GraphEditorVisibleNotifier, bool>(
  (ref) => GraphEditorVisibleNotifier(),
);

// ---------------------------------------------------------------------------
// Onion skinning
// ---------------------------------------------------------------------------

enum OnionMode { outline, filled }

class OnionSettings {
  const OnionSettings({
    this.enabled = false,
    this.beforeFrames = 2,
    this.afterFrames = 2,
    this.opacity = 0.35,
    this.mode = OnionMode.outline,
  });

  final bool enabled;
  final int beforeFrames;
  final int afterFrames;
  final double opacity;
  final OnionMode mode;

  OnionSettings copyWith({bool? enabled, int? beforeFrames, int? afterFrames, double? opacity, OnionMode? mode}) =>
      OnionSettings(
        enabled: enabled ?? this.enabled,
        beforeFrames: beforeFrames ?? this.beforeFrames,
        afterFrames: afterFrames ?? this.afterFrames,
        opacity: opacity ?? this.opacity,
        mode: mode ?? this.mode,
      );
}

class OnionSettingsNotifier extends StateNotifier<OnionSettings> {
  OnionSettingsNotifier() : super(const OnionSettings());

  void toggleEnabled() => state = state.copyWith(enabled: !state.enabled);
  void setBeforeFrames(int n) => state = state.copyWith(beforeFrames: n.clamp(0, 10));
  void setAfterFrames(int n) => state = state.copyWith(afterFrames: n.clamp(0, 10));
  void setOpacity(double v) => state = state.copyWith(opacity: v.clamp(0.0, 1.0));
  void setMode(OnionMode mode) => state = state.copyWith(mode: mode);
}

final onionSettingsProvider = StateNotifierProvider<OnionSettingsNotifier, OnionSettings>(
  (ref) => OnionSettingsNotifier(),
);
