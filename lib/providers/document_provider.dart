import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../core/pathfinder/pathfinder.dart';
import '../data/models/vec_color.dart';
import '../data/models/vec_document.dart';
import '../data/models/vec_keyframe.dart';
import '../data/models/vec_layer.dart';
import '../data/models/vec_scene.dart';
import '../data/models/vec_shape.dart';
import '../data/models/vec_symbol.dart';
import '../data/models/vec_timeline.dart';
import '../data/models/vec_track.dart';
import '../data/models/vec_transform.dart';
import '../data/repositories/vec_file_repository.dart';
import '../data/services/vec_document_service.dart';
import 'editor_state_provider.dart';

part 'document_provider.g.dart';

const _uuid = Uuid();

// ---------------------------------------------------------------------------
// Infrastructure providers
// ---------------------------------------------------------------------------

final vecFileRepositoryProvider = Provider<VecFileRepository>((ref) {
  return VecFileRepository();
});

final vecDocumentServiceProvider = Provider<VecDocumentService>((ref) {
  final repo = ref.watch(vecFileRepositoryProvider);
  final service = VecDocumentService(repository: repo);
  ref.onDispose(() => service.dispose());
  return service;
});

// ---------------------------------------------------------------------------
// Document state with undo / redo
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
class VecDocumentState extends _$VecDocumentState {
  static const _maxHistory = 50;

  final List<VecDocument> _history = [];
  int _cursor = -1;

  bool get canUndo => _cursor > 0;
  bool get canRedo => _cursor < _history.length - 1;

  VecDocumentService get _service => ref.read(vecDocumentServiceProvider);

  @override
  VecDocument build() {
    final doc = VecDocument.blank();
    _history.clear();
    _history.add(doc);
    _cursor = 0;
    return doc;
  }

  // ===========================================================================
  // History management
  // ===========================================================================

  /// Commits a new document state to history and updates UI availability flags.
  void _commit(VecDocument newState) {
    // Drop any redo entries ahead of cursor
    if (_cursor < _history.length - 1) {
      _history.removeRange(_cursor + 1, _history.length);
    }
    _history.add(newState);
    if (_history.length > _maxHistory) {
      _history.removeAt(0);
    }
    _cursor = _history.length - 1;
    state = newState;
    _service.markDirty();
    _notifyAvailability();
  }

  /// Clears history and resets to a fresh state (used on open / new).
  void _resetHistory(VecDocument doc) {
    _history.clear();
    _history.add(doc);
    _cursor = 0;
    state = doc;
    _notifyAvailability();
  }

  void _notifyAvailability() {
    ref.read(undoAvailabilityProvider.notifier).update(
          canUndo: canUndo,
          canRedo: canRedo,
        );
  }

  void undo() {
    if (!canUndo) return;
    _cursor--;
    state = _history[_cursor];
    _service.markDirty();
    _notifyAvailability();
  }

  void redo() {
    if (!canRedo) return;
    _cursor++;
    state = _history[_cursor];
    _service.markDirty();
    _notifyAvailability();
  }

  // ===========================================================================
  // Private helpers — pure document transformations (no side effects)
  // ===========================================================================

  VecDocument _withScene(String sceneId, VecScene Function(VecScene) fn) {
    return state.copyWith(
      scenes: [
        for (final s in state.scenes)
          if (s.id == sceneId) fn(s) else s,
      ],
    );
  }

  VecDocument _withLayer(
    String sceneId,
    String layerId,
    VecLayer Function(VecLayer) fn,
  ) {
    return _withScene(sceneId, (scene) {
      return scene.copyWith(
        layers: [
          for (final l in scene.layers)
            if (l.id == layerId) fn(l) else l,
        ],
      );
    });
  }

  // ===========================================================================
  // File operations
  // ===========================================================================

  Future<void> openFile(String filePath) async {
    final doc = await _service.openFile(filePath);
    _resetHistory(doc);
  }

  Future<void> save() async {
    final now = DateTime.now();
    final saved = state.copyWith(
      meta: state.meta.copyWith(modifiedAt: now),
    );
    state = saved;
    // Update the history entry at cursor too so undo doesn't undo modifiedAt
    if (_cursor >= 0 && _cursor < _history.length) {
      _history[_cursor] = saved;
    }
    await _service.save(saved);
  }

  Future<void> saveAs(String filePath) async {
    final now = DateTime.now();
    final saved = state.copyWith(
      meta: state.meta.copyWith(modifiedAt: now),
    );
    state = saved;
    if (_cursor >= 0 && _cursor < _history.length) {
      _history[_cursor] = saved;
    }
    await _service.saveAs(saved, filePath);
  }

  void newDocument({
    String name = 'Untitled',
    double stageWidth = 1920,
    double stageHeight = 1080,
    int fps = 24,
    VecColor backgroundColor = VecColor.white,
  }) {
    final doc = _service.createNew(
      name: name,
      stageWidth: stageWidth,
      stageHeight: stageHeight,
      fps: fps,
      backgroundColor: backgroundColor,
    );
    _resetHistory(doc);
  }

  // ===========================================================================
  // Meta
  // ===========================================================================

  void updateMeta(VecMeta meta) {
    _commit(state.copyWith(meta: meta));
  }

  // ===========================================================================
  // Scenes
  // ===========================================================================

  void addScene(VecScene scene) {
    _commit(state.copyWith(scenes: [...state.scenes, scene]));
  }

  void updateScene(String sceneId, VecScene Function(VecScene) updater) {
    _commit(_withScene(sceneId, updater));
  }

  void removeScene(String sceneId) {
    _commit(state.copyWith(
      scenes: state.scenes.where((s) => s.id != sceneId).toList(),
    ));
  }

  /// Creates a fully initialised scene (1 layer + timeline) and appends it.
  void addNewScene({String? name}) {
    final sceneId = _uuid.v4();
    final layerId = _uuid.v4();
    final trackId = _uuid.v4();
    final fps = state.meta.fps;
    final scene = VecScene(
      id: sceneId,
      name: name ?? 'Scene ${state.scenes.length + 1}',
      layers: [VecLayer(id: layerId, name: 'Layer 1')],
      timeline: VecTimeline(
        duration: fps * 3, // 3 seconds default
        tracks: [VecTrack(id: trackId, layerId: layerId)],
      ),
    );
    _commit(state.copyWith(scenes: [...state.scenes, scene]));
  }

  // ===========================================================================
  // Layers
  // ===========================================================================

  void addLayer(String sceneId, {String? name}) {
    final layerId = _uuid.v4();
    final trackId = _uuid.v4();
    _commit(_withScene(sceneId, (scene) {
      return scene.copyWith(
        layers: [
          ...scene.layers,
          VecLayer(
            id: layerId,
            name: name ?? 'Layer ${scene.layers.length + 1}',
            order: scene.layers.length,
          ),
        ],
        timeline: scene.timeline.copyWith(
          tracks: [
            ...scene.timeline.tracks,
            VecTrack(id: trackId, layerId: layerId),
          ],
        ),
      );
    }));
  }

  void updateLayer(
    String sceneId,
    String layerId,
    VecLayer Function(VecLayer) updater,
  ) {
    _commit(_withLayer(sceneId, layerId, updater));
  }

  void removeLayer(String sceneId, String layerId) {
    _commit(_withScene(sceneId, (scene) {
      return scene.copyWith(
        layers: scene.layers.where((l) => l.id != layerId).toList(),
        timeline: scene.timeline.copyWith(
          tracks: scene.timeline.tracks
              .where((t) => t.layerId != layerId)
              .toList(),
        ),
      );
    }));
  }

  /// Reorders layers to match [orderedIds] (full ordered list of all layer IDs).
  /// Updates each layer's [order] field to reflect its new position.
  void reorderLayers(String sceneId, List<String> orderedIds) {
    _commit(_withScene(sceneId, (scene) {
      final layerMap = {for (final l in scene.layers) l.id: l};
      final reordered = [
        for (var i = 0; i < orderedIds.length; i++)
          if (layerMap.containsKey(orderedIds[i]))
            layerMap[orderedIds[i]]!.copyWith(order: i),
      ];
      return scene.copyWith(layers: reordered);
    }));
  }

  // ===========================================================================
  // Shapes
  // ===========================================================================

  void addShape(String sceneId, String layerId, VecShape shape) {
    _commit(_withLayer(
      sceneId,
      layerId,
      (l) => l.copyWith(shapes: [...l.shapes, shape]),
    ));
  }

  /// Adds multiple shapes in one undo-able step.
  void addShapes(String sceneId, String layerId, List<VecShape> shapes) {
    _commit(_withLayer(
      sceneId,
      layerId,
      (l) => l.copyWith(shapes: [...l.shapes, ...shapes]),
    ));
  }

  /// Removes multiple shapes in one undo-able step.
  void removeShapes(String sceneId, String layerId, List<String> shapeIds) {
    _commit(_withLayer(
      sceneId,
      layerId,
      (l) => l.copyWith(
        shapes: l.shapes.where((s) => !shapeIds.contains(s.id)).toList(),
      ),
    ));
  }

  /// Wraps [shapeIds] into a new [VecGroupShape] inserted at the topmost
  /// z-position of the selected shapes.  Returns the new group's ID.
  String groupShapes(String sceneId, String layerId, List<String> shapeIds) {
    final groupId = _uuid.v4();
    _commit(_withLayer(sceneId, layerId, (layer) {
      // Collect selected shapes in layer z-order, track lowest z-index
      final selected = <VecShape>[];
      var insertAt = layer.shapes.length;
      for (var i = 0; i < layer.shapes.length; i++) {
        if (shapeIds.contains(layer.shapes[i].id)) {
          selected.add(layer.shapes[i]);
          if (i < insertAt) insertAt = i;
        }
      }
      if (selected.isEmpty) return layer;

      // Bounding box of all selected shapes (ignoring rotation for simplicity)
      var minX = selected.first.transform.x;
      var minY = selected.first.transform.y;
      var maxX = minX + selected.first.transform.width;
      var maxY = minY + selected.first.transform.height;
      for (final s in selected) {
        final t = s.transform;
        if (t.x < minX) minX = t.x;
        if (t.y < minY) minY = t.y;
        if (t.x + t.width > maxX) maxX = t.x + t.width;
        if (t.y + t.height > maxY) maxY = t.y + t.height;
      }

      // Adjust children to group-local space
      final children = selected.map((s) => s.copyWith(
            data: s.data.copyWith(
              transform: s.transform.copyWith(
                x: s.transform.x - minX,
                y: s.transform.y - minY,
              ),
            ),
          )).toList();

      final group = VecShape.group(
        data: VecShapeData(
          id: groupId,
          transform: VecTransform(
            x: minX,
            y: minY,
            width: maxX - minX,
            height: maxY - minY,
          ),
          fills: const [],
          strokes: const [],
        ),
        children: children,
      );

      final remaining =
          layer.shapes.where((s) => !shapeIds.contains(s.id)).toList();
      remaining.insert(insertAt, group);
      return layer.copyWith(shapes: remaining);
    }));
    return groupId;
  }

  /// Dissolves the selected [VecGroupShape], inserting its children back into
  /// the layer at the group's z-position.  Returns the children's IDs.
  List<String> ungroupShape(
      String sceneId, String layerId, String groupId) {
    final childIds = <String>[];
    _commit(_withLayer(sceneId, layerId, (layer) {
      final groupIdx = layer.shapes.indexWhere((s) => s.id == groupId);
      if (groupIdx == -1) return layer;

      final groupShape = layer.shapes[groupIdx].maybeMap(
          group: (g) => g, orElse: () => null);
      if (groupShape == null) return layer;

      final gt = groupShape.data.transform;
      final children = groupShape.children.map((c) {
        childIds.add(c.id);
        return c.copyWith(
          data: c.data.copyWith(
            transform: c.transform.copyWith(
              x: c.transform.x + gt.x,
              y: c.transform.y + gt.y,
            ),
          ),
        );
      }).toList();

      final shapes = List<VecShape>.from(layer.shapes);
      shapes.removeAt(groupIdx);
      for (var i = 0; i < children.length; i++) {
        shapes.insert(groupIdx + i, children[i]);
      }
      return layer.copyWith(shapes: shapes);
    }));
    return childIds;
  }

  /// Updates a child of [groupId] without adding to undo history (use during
  /// drag).  Call [commitCurrentState] on drag-end.
  void updateGroupChildNoHistory(
    String sceneId,
    String layerId,
    String groupId,
    String childId,
    VecShape Function(VecShape) updater,
  ) {
    final newDoc = _withLayer(sceneId, layerId, (layer) {
      return layer.copyWith(
        shapes: [
          for (final s in layer.shapes)
            if (s.id == groupId)
              s.maybeMap(
                group: (g) => g.copyWith(
                  children: [
                    for (final c in g.children)
                      if (c.id == childId) updater(c) else c,
                  ],
                ),
                orElse: () => s,
              )
            else
              s,
        ],
      );
    });
    state = newDoc;
    _service.markDirty();
  }

  void updateShape(
    String sceneId,
    String layerId,
    String shapeId,
    VecShape Function(VecShape) updater,
  ) {
    _commit(_withLayer(sceneId, layerId, (layer) {
      return layer.copyWith(
        shapes: [
          for (final s in layer.shapes)
            if (s.id == shapeId) updater(s) else s,
        ],
      );
    }));
  }

  /// Updates shape state without adding to undo history.
  /// Use this during live drag operations; call [updateShape] on drag end
  /// to commit a single undo-able step.
  void updateShapeNoHistory(
    String sceneId,
    String layerId,
    String shapeId,
    VecShape Function(VecShape) updater,
  ) {
    final newDoc = _withLayer(sceneId, layerId, (layer) {
      return layer.copyWith(
        shapes: [
          for (final s in layer.shapes)
            if (s.id == shapeId) updater(s) else s,
        ],
      );
    });
    state = newDoc;
    _service.markDirty();
  }

  /// Commits the current in-memory state to undo history.
  /// Call after a series of [updateShapeNoHistory] calls to create one
  /// undo-able step for the entire drag operation.
  void commitCurrentState() {
    _commit(state);
  }

  // ===========================================================================
  // Pathfinder
  // ===========================================================================

  /// Applies [op] to the selected shapes (in bottom-to-top layer order),
  /// removes them from the layer, and inserts the result in their place.
  /// The entire replacement is one undo step.
  List<String> applyPathfinder(
    String sceneId,
    String layerId,
    List<String> shapeIds,
    PathfinderOp op,
  ) {
    if (shapeIds.length < 2) return [];

    final resultIds = <String>[];

    _commit(_withLayer(sceneId, layerId, (layer) {
      // Collect inputs in bottom-to-top order (layer.shapes order)
      final inputs = layer.shapes
          .where((s) => shapeIds.contains(s.id))
          .toList(); // already in layer order (bottom first)

      // Find insertion index = position of first (bottommost) selected shape
      final insertIdx =
          layer.shapes.indexWhere((s) => shapeIds.contains(s.id));

      // Remove originals
      final remaining =
          layer.shapes.where((s) => !shapeIds.contains(s.id)).toList();

      // Apply operation
      final results = PathfinderOps.apply(inputs, op);
      for (final r in results) {
        resultIds.add(r.id);
      }

      // Insert results at original position
      final newShapes = [
        ...remaining.take(insertIdx),
        ...results,
        ...remaining.skip(insertIdx),
      ];

      return layer.copyWith(shapes: newShapes);
    }));

    return resultIds;
  }

  /// Flattens a live [VecCompoundShape] to a [VecPathShape].
  String? expandCompound(String sceneId, String layerId, String shapeId) {
    String? newId;

    _commit(_withLayer(sceneId, layerId, (layer) {
      final idx = layer.shapes.indexWhere((s) => s.id == shapeId);
      if (idx == -1) return layer;

      final compound =
          layer.shapes[idx].maybeMap(compound: (c) => c, orElse: () => null);
      if (compound == null) return layer;

      final expanded = PathfinderOps.expand(compound);
      newId = expanded.id;

      final newShapes = [...layer.shapes];
      newShapes[idx] = expanded;
      return layer.copyWith(shapes: newShapes);
    }));

    return newId;
  }

  void removeShape(String sceneId, String layerId, String shapeId) {
    _commit(_withLayer(
      sceneId,
      layerId,
      (l) => l.copyWith(
        shapes: l.shapes.where((s) => s.id != shapeId).toList(),
      ),
    ));
  }

  // ===========================================================================
  // Symbols
  // ===========================================================================

  void addSymbol(VecSymbol symbol) {
    _commit(state.copyWith(symbols: [...state.symbols, symbol]));
  }

  void updateSymbol(String symbolId, VecSymbol Function(VecSymbol) updater) {
    _commit(state.copyWith(
      symbols: [
        for (final s in state.symbols)
          if (s.id == symbolId) updater(s) else s,
      ],
    ));
  }

  void removeSymbol(String symbolId) {
    _commit(state.copyWith(
      symbols: state.symbols.where((s) => s.id != symbolId).toList(),
    ));
  }

  // ===========================================================================
  // Keyframes
  // ===========================================================================

  void addKeyframe(String sceneId, String trackId, VecKeyframe keyframe) {
    _commit(_withScene(sceneId, (scene) {
      return scene.copyWith(
        timeline: scene.timeline.copyWith(
          tracks: [
            for (final t in scene.timeline.tracks)
              if (t.id == trackId)
                t.copyWith(keyframes: [...t.keyframes, keyframe])
              else
                t,
          ],
        ),
      );
    }));
  }

  void updateKeyframe(
    String sceneId,
    String trackId,
    int frame,
    VecKeyframe Function(VecKeyframe) updater,
  ) {
    _commit(_withScene(sceneId, (scene) {
      return scene.copyWith(
        timeline: scene.timeline.copyWith(
          tracks: [
            for (final t in scene.timeline.tracks)
              if (t.id == trackId)
                t.copyWith(
                  keyframes: [
                    for (final k in t.keyframes)
                      if (k.frame == frame) updater(k) else k,
                  ],
                )
              else
                t,
          ],
        ),
      );
    }));
  }

  void removeKeyframe(String sceneId, String trackId, int frame) {
    _commit(_withScene(sceneId, (scene) {
      return scene.copyWith(
        timeline: scene.timeline.copyWith(
          tracks: [
            for (final t in scene.timeline.tracks)
              if (t.id == trackId)
                t.copyWith(
                  keyframes:
                      t.keyframes.where((k) => k.frame != frame).toList(),
                )
              else
                t,
          ],
        ),
      );
    }));
  }
}

// ---------------------------------------------------------------------------
// Derived state providers
// ---------------------------------------------------------------------------

@riverpod
VecMeta currentMeta(CurrentMetaRef ref) {
  return ref.watch(vecDocumentStateProvider).meta;
}

@riverpod
List<VecScene> scenes(ScenesRef ref) {
  return ref.watch(vecDocumentStateProvider).scenes;
}

@riverpod
List<VecSymbol> symbolLibrary(SymbolLibraryRef ref) {
  return ref.watch(vecDocumentStateProvider).symbols;
}

// ---------------------------------------------------------------------------
// UI editing state (not persisted to .vct)
// ---------------------------------------------------------------------------

@riverpod
class ActiveSceneIndex extends _$ActiveSceneIndex {
  @override
  int build() => 0;

  void set(int index) => state = index;
}

@riverpod
class ActiveLayerId extends _$ActiveLayerId {
  @override
  String? build() {
    final scenes = ref.watch(scenesProvider);
    final sceneIndex = ref.watch(activeSceneIndexProvider);
    if (sceneIndex < scenes.length && scenes[sceneIndex].layers.isNotEmpty) {
      return scenes[sceneIndex].layers.first.id;
    }
    return null;
  }

  void set(String? id) => state = id;
}

@riverpod
class PlayheadFrame extends _$PlayheadFrame {
  @override
  int build() => 0;

  void set(int frame) => state = frame;
}
