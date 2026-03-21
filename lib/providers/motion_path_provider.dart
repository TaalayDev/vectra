import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/models/vec_motion_path.dart';
import '../data/models/vec_path_node.dart';
import 'document_provider.dart';
import 'editor_state_provider.dart';

part 'motion_path_provider.g.dart';

// ---------------------------------------------------------------------------
// Drawing mode — "draw motion path for shape X"
// ---------------------------------------------------------------------------

/// When non-null, the user is in motion-path drawing mode for this shapeId.
@riverpod
class MotionPathDrawTarget extends _$MotionPathDrawTarget {
  @override
  String? build() => null;

  void start(String shapeId) => state = shapeId;
  void cancel() => state = null;
}

/// Live preview nodes accumulated while the user clicks during drawing mode.
@riverpod
class MotionPathPreviewNodes extends _$MotionPathPreviewNodes {
  @override
  List<VecPathNode> build() => const [];

  void addNode(VecPathNode node) => state = [...state, node];
  void updateLastHandle(VecPathNode node) {
    if (state.isEmpty) return;
    state = [...state.sublist(0, state.length - 1), node];
  }
  void clear() => state = const [];
}

// ---------------------------------------------------------------------------
// Derived — motion paths for the current scene
// ---------------------------------------------------------------------------

@riverpod
List<VecMotionPath> activeSceneMotionPaths(ActiveSceneMotionPathsRef ref) {
  final scene = ref.watch(activeSceneProvider);
  return scene?.motionPaths ?? const [];
}

/// Returns the motion path for the currently selected shape, or null.
@riverpod
VecMotionPath? selectedShapeMotionPath(SelectedShapeMotionPathRef ref) {
  final paths = ref.watch(activeSceneMotionPathsProvider);
  final shapeId = ref.watch(selectedShapeIdProvider);
  if (shapeId == null) return null;
  for (final mp in paths) {
    if (mp.shapeId == shapeId) return mp;
  }
  return null;
}
