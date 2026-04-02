import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../core/utils/keyframe_interpolator.dart';
import '../core/pathfinder/pathfinder.dart';
import '../data/animation_presets.dart';
import '../data/models/vec_asset.dart';
import '../data/models/vec_color.dart';
import '../data/models/vec_document.dart';
import '../data/models/vec_keyframe.dart';
import '../data/models/vec_layer.dart';
import '../data/models/vec_motion_path.dart';
import '../data/models/vec_path_node.dart';
import '../data/models/vec_point.dart';
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

  /// Whether the document has already been saved to a file path.
  bool get hasFilePath => _service.currentFilePath != null;

  /// Whether the document has unsaved changes.
  bool get isDirty => _service.isDirty;

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
  // Assets
  // ===========================================================================

  void addAsset(VecAsset asset) {
    _commit(state.copyWith(assets: [...state.assets, asset]));
  }

  void removeAsset(String assetId) {
    _commit(state.copyWith(assets: state.assets.where((a) => a.id != assetId).toList()));
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
    final kf = VecKeyframe(
      frame: 0,
      tweenType: VecTweenType.classic,
      transform: shape.data.transform,
      opacity: shape.data.opacity,
      fills: List.unmodifiable(shape.data.fills),
      strokes: List.unmodifiable(shape.data.strokes),
    );
    _commit(_withScene(sceneId, (scene) {
      final newLayers = [
        for (final l in scene.layers)
          if (l.id == layerId) l.copyWith(shapes: [...l.shapes, shape]) else l,
      ];
      return scene.copyWith(
        layers: newLayers,
        timeline: scene.timeline.copyWith(
          tracks: [
            ...scene.timeline.tracks,
            VecTrack(
              id: _uuid.v4(),
              layerId: layerId,
              shapeId: shape.id,
              keyframes: [kf],
            ),
          ],
        ),
      );
    }));
  }

  /// Adds multiple shapes in one undo-able step.
  void addShapes(String sceneId, String layerId, List<VecShape> shapes) {
    _commit(_withScene(sceneId, (scene) {
      final newLayers = [
        for (final l in scene.layers)
          if (l.id == layerId)
            l.copyWith(shapes: [...l.shapes, ...shapes])
          else
            l,
      ];
      return scene.copyWith(
        layers: newLayers,
        timeline: scene.timeline.copyWith(
          tracks: [
            ...scene.timeline.tracks,
            for (final shape in shapes)
              VecTrack(
                id: _uuid.v4(),
                layerId: layerId,
                shapeId: shape.id,
                keyframes: [
                  VecKeyframe(
                    frame: 0,
                    tweenType: VecTweenType.classic,
                    transform: shape.data.transform,
                    opacity: shape.data.opacity,
                    fills: List.unmodifiable(shape.data.fills),
                    strokes: List.unmodifiable(shape.data.strokes),
                  ),
                ],
              ),
          ],
        ),
      );
    }));
  }

  /// Removes multiple shapes in one undo-able step.
  void removeShapes(String sceneId, String layerId, List<String> shapeIds) {
    _commit(_withScene(sceneId, (scene) {
      return scene.copyWith(
        layers: [
          for (final l in scene.layers)
            if (l.id == layerId)
              l.copyWith(
                shapes: l.shapes.where((s) => !shapeIds.contains(s.id)).toList(),
              )
            else
              l,
        ],
        timeline: scene.timeline.copyWith(
          tracks: scene.timeline.tracks
              .where((t) => t.shapeId == null || !shapeIds.contains(t.shapeId))
              .toList(),
        ),
      );
    }));
  }

  /// Removes [removeIds] and adds [newShapes] in a single undo-able step.
  void replaceShapes(
    String sceneId,
    String layerId,
    List<String> removeIds,
    List<VecShape> newShapes,
  ) {
    _commit(_withScene(sceneId, (scene) {
      final layer = scene.layers.where((l) => l.id == layerId).firstOrNull;
      if (layer == null) return scene;

      // Preserve insertion order: replace each removed shape with its pieces at
      // the same z-index so the visual stack order is maintained.
      final newShapeList = <VecShape>[];
      for (final s in layer.shapes) {
        if (removeIds.contains(s.id)) {
          // Insert the replacement pieces where the original shape was
          newShapeList.addAll(newShapes.where((ns) {
            // Match pieces back to their original by name prefix (set by KnifeTool)
            return ns.data.name?.startsWith(s.data.name ?? s.id) ?? false ||
                ns.id.startsWith(s.id.substring(0, 8));
          }));
        } else {
          newShapeList.add(s);
        }
      }
      // Any pieces not yet inserted (shouldn't happen, but be safe)
      final insertedIds = newShapeList.map((s) => s.id).toSet();
      for (final ns in newShapes) {
        if (!insertedIds.contains(ns.id)) newShapeList.add(ns);
      }

      // Prune tracks for removed shapes, add tracks for new shapes
      final newTracks = [
        ...scene.timeline.tracks.where(
          (t) => t.shapeId == null || !removeIds.contains(t.shapeId),
        ),
        for (final shape in newShapes)
          VecTrack(
            id: _uuid.v4(),
            layerId: layerId,
            shapeId: shape.id,
            keyframes: [
              VecKeyframe(
                frame: 0,
                tweenType: VecTweenType.classic,
                transform: shape.data.transform,
                opacity: shape.data.opacity,
                fills: List.unmodifiable(shape.data.fills),
                strokes: List.unmodifiable(shape.data.strokes),
              ),
            ],
          ),
      ];

      return scene.copyWith(
        layers: [
          for (final l in scene.layers)
            if (l.id == layerId) l.copyWith(shapes: newShapeList) else l,
        ],
        timeline: scene.timeline.copyWith(tracks: newTracks),
      );
    }));
  }

  /// Wraps [shapeIds] into a new [VecGroupShape] inserted at the topmost
  /// z-position of the selected shapes.  Returns the new group's ID.
  String groupShapes(String sceneId, String layerId, List<String> shapeIds) {
    final groupId = _uuid.v4();
    _commit(_withScene(sceneId, (scene) {
      final layer = scene.layers.where((l) => l.id == layerId).firstOrNull;
      if (layer == null) return scene;

      final selected = <VecShape>[];
      var insertAt = layer.shapes.length;
      for (var i = 0; i < layer.shapes.length; i++) {
        if (shapeIds.contains(layer.shapes[i].id)) {
          selected.add(layer.shapes[i]);
          if (i < insertAt) insertAt = i;
        }
      }
      if (selected.isEmpty) return scene;

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

      // Remove tracks for grouped children, add one for the new group.
      final cleanTracks = scene.timeline.tracks
          .where((t) => t.shapeId == null || !shapeIds.contains(t.shapeId))
          .toList();

      return scene.copyWith(
        layers: [
          for (final l in scene.layers)
            if (l.id == layerId) l.copyWith(shapes: remaining) else l,
        ],
        timeline: scene.timeline.copyWith(
          tracks: [...cleanTracks, _trackAt0(layerId, group)],
        ),
      );
    }));
    return groupId;
  }

  /// Dissolves the selected [VecGroupShape], inserting its children back into
  /// the layer at the group's z-position.  Returns the children's IDs.
  List<String> ungroupShape(String sceneId, String layerId, String groupId) {
    final childIds = <String>[];
    _commit(_withScene(sceneId, (scene) {
      final layer = scene.layers.where((l) => l.id == layerId).firstOrNull;
      if (layer == null) return scene;

      final groupIdx = layer.shapes.indexWhere((s) => s.id == groupId);
      if (groupIdx == -1) return scene;

      final groupShape =
          layer.shapes[groupIdx].maybeMap(group: (g) => g, orElse: () => null);
      if (groupShape == null) return scene;

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

      // Remove group's track, add tracks for each ungrouped child.
      final cleanTracks = scene.timeline.tracks
          .where((t) => t.shapeId != groupId)
          .toList();

      return scene.copyWith(
        layers: [
          for (final l in scene.layers)
            if (l.id == layerId) l.copyWith(shapes: shapes) else l,
        ],
        timeline: scene.timeline.copyWith(
          tracks: [
            ...cleanTracks,
            for (final child in children) _trackAt0(layerId, child),
          ],
        ),
      );
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
    final selectedFrame = ref.read(playheadFrameProvider);
    var newDoc = _withLayer(sceneId, layerId, (layer) {
      return layer.copyWith(
        shapes: [
          for (final s in layer.shapes)
            if (s.id == shapeId) updater(s) else s,
        ],
      );
    });
    newDoc = _recordShapeToKeyframe(newDoc, sceneId, layerId, shapeId, selectedFrame);
    _commit(newDoc);
  }

  /// Updates shape state without adding to undo history.
  /// Use this during live drag operations; call [updateShape] on drag end
  /// to commit a single undo-able step.
  ///
  /// Also mirrors the change to the keyframe at the selected frame (if one
  /// exists) so that [animatedSceneProvider] reflects the live position while
  /// dragging — without this, keyframe interpolation would freeze the visual
  /// at the last committed keyframe value.
  void updateShapeNoHistory(
    String sceneId,
    String layerId,
    String shapeId,
    VecShape Function(VecShape) updater,
  ) {
    final selectedFrame = ref.read(playheadFrameProvider);
    var newDoc = _withLayer(sceneId, layerId, (layer) {
      return layer.copyWith(
        shapes: [
          for (final s in layer.shapes)
            if (s.id == shapeId) updater(s) else s,
        ],
      );
    });
    newDoc = _recordShapeToKeyframe(newDoc, sceneId, layerId, shapeId, selectedFrame);
    state = newDoc;
    _service.markDirty();
  }

  /// Commits the current in-memory state to undo history.
  /// Call after a series of [updateShapeNoHistory] calls to create one
  /// undo-able step for the entire drag operation.
  /// Automatically records any changed shapes to their keyframe at the
  /// currently selected keyframe frame.
  void commitCurrentState() {
    final selectedFrame = ref.read(playheadFrameProvider);
    final prevDoc = _cursor >= 0 ? _history[_cursor] : null;

    var finalDoc = state;
    if (prevDoc != null) {
      for (final newScene in state.scenes) {
        final oldScene =
            prevDoc.scenes.where((s) => s.id == newScene.id).firstOrNull;
        if (oldScene == null) continue;
        for (final newLayer in newScene.layers) {
          final oldLayer =
              oldScene.layers.where((l) => l.id == newLayer.id).firstOrNull;
          if (oldLayer == null) continue;
          for (final newShape in newLayer.shapes) {
            final oldShape = oldLayer.shapes
                .where((s) => s.id == newShape.id)
                .firstOrNull;
            if (oldShape == null || oldShape == newShape) continue;
            finalDoc = _recordShapeToKeyframe(
                finalDoc, newScene.id, newLayer.id, newShape.id, selectedFrame);
          }
        }
      }
    }

    _commit(finalDoc);
  }

  /// Builds a [VecTrack] for [shape] in [layerId] with a single frame-0 keyframe.
  VecTrack _trackAt0(String layerId, VecShape shape) => VecTrack(
        id: _uuid.v4(),
        layerId: layerId,
        shapeId: shape.id,
        keyframes: [
          VecKeyframe(
            frame: 0,
            tweenType: VecTweenType.classic,
            transform: shape.data.transform,
            opacity: shape.data.opacity,
            fills: List.unmodifiable(shape.data.fills),
            strokes: List.unmodifiable(shape.data.strokes),
          ),
        ],
      );

  /// Pure helper – returns a new [VecDocument] with the keyframe at [frame]
  /// updated to snapshot the current state of [shapeId].
  ///
  /// - If the shape has no track (not animated): no-op.
  /// - If the shape has a track but no keyframe at [frame]: auto-inserts a
  ///   new keyframe at [frame] (the "auto-keyframe" feature — any edit while
  ///   the playhead sits between existing keyframes creates one automatically).
  /// - If a keyframe already exists at [frame]: updates it in-place.
  VecDocument _recordShapeToKeyframe(
    VecDocument doc,
    String sceneId,
    String layerId,
    String shapeId,
    int frame,
  ) {
    final scene = doc.scenes.where((s) => s.id == sceneId).firstOrNull;
    if (scene == null) return doc;

    final track = scene.timeline.tracks
        .where((t) => t.layerId == layerId && t.shapeId == shapeId)
        .firstOrNull;
    // Shape has no animation track — don't auto-create one.
    if (track == null) return doc;
    // Track exists but no keyframe here yet → will be auto-inserted below.

    VecShape? shape;
    for (final layer in scene.layers) {
      if (layer.id != layerId) continue;
      shape = layer.shapes.where((s) => s.id == shapeId).firstOrNull;
      break;
    }
    if (shape == null) return doc;

    // Inherit tweenType from the preceding keyframe so the animation curve is
    // preserved when auto-inserting between two existing keyframes.
    final sortedKfs = [...track.keyframes]..sort((a, b) => a.frame.compareTo(b.frame));
    VecKeyframe? preceding;
    for (final k in sortedKfs) {
      if (k.frame < frame) preceding = k;
    }
    final inheritedTween = preceding?.tweenType ?? VecTweenType.classic;

    final kf = VecKeyframe(
      frame: frame,
      tweenType: inheritedTween,
      transform: shape.data.transform,
      opacity: shape.data.opacity,
      fills: List.unmodifiable(shape.data.fills),
      strokes: List.unmodifiable(shape.data.strokes),
    );

    return doc.copyWith(
      scenes: [
        for (final s in doc.scenes)
          if (s.id == sceneId)
            s.copyWith(
              timeline: s.timeline.copyWith(
                tracks: [
                  for (final t in s.timeline.tracks)
                    if (t.id == track.id)
                      t.copyWith(
                        keyframes: [
                          for (final k in t.keyframes)
                            if (k.frame != frame) k,
                          kf,
                        ]..sort((a, b) => a.frame.compareTo(b.frame)),
                      )
                    else
                      t,
                ],
              ),
            )
          else
            s,
      ],
    );
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

    _commit(_withScene(sceneId, (scene) {
      final layer = scene.layers.where((l) => l.id == layerId).firstOrNull;
      if (layer == null) return scene;

      // Collect inputs in bottom-to-top order (layer.shapes order)
      final inputs = layer.shapes
          .where((s) => shapeIds.contains(s.id))
          .toList();

      final insertIdx =
          layer.shapes.indexWhere((s) => shapeIds.contains(s.id));
      final remaining =
          layer.shapes.where((s) => !shapeIds.contains(s.id)).toList();

      final results = PathfinderOps.apply(inputs, op);
      resultIds
        ..clear()
        ..addAll(results.map((r) => r.id));

      final newShapes = [
        ...remaining.take(insertIdx),
        ...results,
        ...remaining.skip(insertIdx),
      ];

      // Remove stale tracks for the consumed shapes, add tracks for results.
      final cleanTracks = scene.timeline.tracks
          .where((t) => t.shapeId == null || !shapeIds.contains(t.shapeId))
          .toList();

      return scene.copyWith(
        layers: [
          for (final l in scene.layers)
            if (l.id == layerId) l.copyWith(shapes: newShapes) else l,
        ],
        timeline: scene.timeline.copyWith(
          tracks: [
            ...cleanTracks,
            for (final shape in results) _trackAt0(layerId, shape),
          ],
        ),
      );
    }));

    return resultIds;
  }

  /// Flattens a live [VecCompoundShape] to a [VecPathShape].
  String? expandCompound(String sceneId, String layerId, String shapeId) {
    String? newId;

    _commit(_withScene(sceneId, (scene) {
      final layer = scene.layers.where((l) => l.id == layerId).firstOrNull;
      if (layer == null) return scene;

      final idx = layer.shapes.indexWhere((s) => s.id == shapeId);
      if (idx == -1) return scene;

      final compound =
          layer.shapes[idx].maybeMap(compound: (c) => c, orElse: () => null);
      if (compound == null) return scene;

      final expanded = PathfinderOps.expand(compound);
      newId = expanded.id;

      final newShapes = [...layer.shapes];
      newShapes[idx] = expanded;

      // Replace compound's track with one for the expanded path.
      final cleanTracks = scene.timeline.tracks
          .where((t) => t.shapeId != shapeId)
          .toList();

      return scene.copyWith(
        layers: [
          for (final l in scene.layers)
            if (l.id == layerId) l.copyWith(shapes: newShapes) else l,
        ],
        timeline: scene.timeline.copyWith(
          tracks: [...cleanTracks, _trackAt0(layerId, expanded)],
        ),
      );
    }));

    return newId;
  }

  // ===========================================================================
  // Z-order
  // ===========================================================================

  /// Moves [shapeId] one step toward the top (higher index = renders on top).
  void bringForward(String sceneId, String layerId, String shapeId) =>
      _commitZOrder(sceneId, layerId, shapeId, _moveUp);

  /// Moves [shapeId] one step toward the bottom.
  void sendBackward(String sceneId, String layerId, String shapeId) =>
      _commitZOrder(sceneId, layerId, shapeId, _moveDown);

  /// Moves [shapeId] to the very top (last in list).
  void bringToFront(String sceneId, String layerId, String shapeId) =>
      _commitZOrder(sceneId, layerId, shapeId, _moveToEnd);

  /// Moves [shapeId] to the very bottom (first in list).
  void sendToBack(String sceneId, String layerId, String shapeId) =>
      _commitZOrder(sceneId, layerId, shapeId, _moveToStart);

  /// Moves a shape from [fromIndex] to [toIndex] (used by drag-to-reorder).
  void reorderShape(String sceneId, String layerId, int fromIndex, int toIndex) {
    _commit(_withLayer(sceneId, layerId, (layer) {
      final shapes = [...layer.shapes];
      final shape = shapes.removeAt(fromIndex);
      final clampedTo = toIndex.clamp(0, shapes.length);
      shapes.insert(clampedTo, shape);
      return layer.copyWith(shapes: shapes);
    }));
  }

  void _commitZOrder(
    String sceneId,
    String layerId,
    String shapeId,
    List<VecShape> Function(List<VecShape>, int) fn,
  ) {
    _commit(_withLayer(sceneId, layerId, (layer) {
      final idx = layer.shapes.indexWhere((s) => s.id == shapeId);
      if (idx < 0) return layer;
      return layer.copyWith(shapes: fn(layer.shapes, idx));
    }));
  }

  static List<VecShape> _moveUp(List<VecShape> list, int i) {
    if (i >= list.length - 1) return list;
    final copy = [...list];
    final tmp = copy[i];
    copy[i] = copy[i + 1];
    copy[i + 1] = tmp;
    return copy;
  }

  static List<VecShape> _moveDown(List<VecShape> list, int i) {
    if (i <= 0) return list;
    final copy = [...list];
    final tmp = copy[i];
    copy[i] = copy[i - 1];
    copy[i - 1] = tmp;
    return copy;
  }

  static List<VecShape> _moveToEnd(List<VecShape> list, int i) {
    if (i >= list.length - 1) return list;
    final copy = [...list];
    final shape = copy.removeAt(i);
    copy.add(shape);
    return copy;
  }

  static List<VecShape> _moveToStart(List<VecShape> list, int i) {
    if (i <= 0) return list;
    final copy = [...list];
    final shape = copy.removeAt(i);
    copy.insert(0, shape);
    return copy;
  }

  void removeShape(String sceneId, String layerId, String shapeId) {
    _commit(_withScene(sceneId, (scene) {
      return scene.copyWith(
        layers: [
          for (final l in scene.layers)
            if (l.id == layerId)
              l.copyWith(
                shapes: l.shapes.where((s) => s.id != shapeId).toList(),
              )
            else
              l,
        ],
        timeline: scene.timeline.copyWith(
          tracks: scene.timeline.tracks
              .where((t) => t.shapeId != shapeId)
              .toList(),
        ),
      );
    }));
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

  /// Converts the given [shapeIds] (in [layerId] of [sceneId]) into a new
  /// [VecSymbol] named [name], replacing the original shapes with a single
  /// [VecSymbolInstanceShape] in one undo-able step.
  ///
  /// Returns the new symbol's ID, or null if no valid shapes were found.
  String? convertToSymbol(
    String sceneId,
    String layerId,
    List<String> shapeIds,
    String name,
  ) {
    final layer = state.scenes
        .where((s) => s.id == sceneId)
        .expand((s) => s.layers)
        .where((l) => l.id == layerId)
        .firstOrNull;
    if (layer == null) return null;

    final selected = layer.shapes.where((s) => shapeIds.contains(s.id)).toList();
    if (selected.isEmpty) return null;

    // Compute bounding box of all selected shapes in scene space
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

    // Translate shapes to symbol-local space (origin at bounding box top-left)
    final symbolShapes = selected.map((s) => s.copyWith(
          data: s.data.copyWith(
            transform: s.transform.copyWith(
              x: s.transform.x - minX,
              y: s.transform.y - minY,
            ),
          ),
        )).toList();

    final symbolId = _uuid.v4();
    final symbolLayerId = _uuid.v4();

    final symbol = VecSymbol(
      id: symbolId,
      name: name,
      registrationPoint: const VecPoint(x: 0, y: 0),
      layers: [
        VecLayer(
          id: symbolLayerId,
          name: 'Layer 1',
          shapes: symbolShapes,
        ),
      ],
      timeline: const VecTimeline(duration: 1),
    );

    final instanceId = _uuid.v4();
    final instance = VecShape.symbolInstance(
      data: VecShapeData(
        id: instanceId,
        name: name,
        transform: VecTransform(
          x: minX,
          y: minY,
          width: maxX - minX,
          height: maxY - minY,
        ),
      ),
      symbolId: symbolId,
    );

    final insertAt = layer.shapes.indexWhere((s) => shapeIds.contains(s.id));

    _commit(_withScene(sceneId, (scene) {
      final l = scene.layers.firstWhere((l) => l.id == layerId);
      final remaining = l.shapes.where((s) => !shapeIds.contains(s.id)).toList();
      remaining.insert(insertAt.clamp(0, remaining.length), instance);

      // Remove stale tracks, add track for the new instance
      final cleanTracks = scene.timeline.tracks
          .where((t) => t.shapeId == null || !shapeIds.contains(t.shapeId))
          .toList();

      return scene.copyWith(
        layers: [
          for (final lay in scene.layers)
            if (lay.id == layerId) lay.copyWith(shapes: remaining) else lay,
        ],
        timeline: scene.timeline.copyWith(
          tracks: [...cleanTracks, _trackAt0(layerId, instance)],
        ),
      );
    }).copyWith(symbols: [...state.symbols, symbol]));

    return symbolId;
  }

  // ---------------------------------------------------------------------------
  // Symbol layer / shape mutations (used in Symbol Edit Mode)
  // ---------------------------------------------------------------------------

  void addSymbolLayer(String symbolId, {String? name}) {
    final layerId = _uuid.v4();
    updateSymbol(symbolId, (sym) => sym.copyWith(
      layers: [
        ...sym.layers,
        VecLayer(id: layerId, name: name ?? 'Layer ${sym.layers.length + 1}'),
      ],
    ));
  }

  void removeSymbolLayer(String symbolId, String layerId) {
    updateSymbol(symbolId, (sym) => sym.copyWith(
      layers: sym.layers.where((l) => l.id != layerId).toList(),
    ));
  }

  void reorderSymbolLayers(String symbolId, List<String> orderedIds) {
    updateSymbol(symbolId, (sym) {
      final map = {for (final l in sym.layers) l.id: l};
      return sym.copyWith(layers: [
        for (var i = 0; i < orderedIds.length; i++)
          if (map.containsKey(orderedIds[i]))
            map[orderedIds[i]]!.copyWith(order: i),
      ]);
    });
  }

  void addSymbolShape(String symbolId, String layerId, VecShape shape) {
    updateSymbol(symbolId, (sym) => sym.copyWith(
      layers: [
        for (final l in sym.layers)
          if (l.id == layerId)
            l.copyWith(shapes: [...l.shapes, shape])
          else
            l,
      ],
    ));
  }

  void removeSymbolShapes(String symbolId, String layerId, List<String> shapeIds) {
    updateSymbol(symbolId, (sym) => sym.copyWith(
      layers: [
        for (final l in sym.layers)
          if (l.id == layerId)
            l.copyWith(shapes: l.shapes.where((s) => !shapeIds.contains(s.id)).toList())
          else
            l,
      ],
    ));
  }

  void updateSymbolShape(
    String symbolId,
    String layerId,
    String shapeId,
    VecShape Function(VecShape) updater,
  ) {
    updateSymbol(symbolId, (sym) => sym.copyWith(
      layers: [
        for (final l in sym.layers)
          if (l.id == layerId)
            l.copyWith(shapes: [
              for (final s in l.shapes) if (s.id == shapeId) updater(s) else s,
            ])
          else
            l,
      ],
    ));
  }

  void updateSymbolShapeNoHistory(
    String symbolId,
    String layerId,
    String shapeId,
    VecShape Function(VecShape) updater,
  ) {
    final newDoc = state.copyWith(symbols: [
      for (final sym in state.symbols)
        if (sym.id == symbolId)
          sym.copyWith(layers: [
            for (final l in sym.layers)
              if (l.id == layerId)
                l.copyWith(shapes: [
                  for (final s in l.shapes)
                    if (s.id == shapeId) updater(s) else s,
                ])
              else
                l,
          ])
        else
          sym,
    ]);
    state = newDoc;
    _service.markDirty();
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

  // ===========================================================================
  // Shape-level keyframes (Phase 4)
  // ===========================================================================

  /// Adds or replaces a keyframe for [shapeId] at [keyframe.frame].
  /// Automatically creates a shape-level [VecTrack] if one doesn't exist yet.
  void addKeyframeForShape(
    String sceneId,
    String layerId,
    String shapeId,
    VecKeyframe keyframe,
  ) {
    _commit(_withScene(sceneId, (scene) {
      final existing = scene.timeline.tracks.where(
        (t) => t.layerId == layerId && t.shapeId == shapeId,
      ).firstOrNull;

      late final List<VecTrack> newTracks;

      if (existing != null) {
        newTracks = [
          for (final t in scene.timeline.tracks)
            if (t.id == existing.id)
              t.copyWith(
                keyframes: [
                  for (final k in t.keyframes)
                    if (k.frame != keyframe.frame) k,
                  keyframe,
                ]..sort((a, b) => a.frame.compareTo(b.frame)),
              )
            else
              t,
        ];
      } else {
        newTracks = [
          ...scene.timeline.tracks,
          VecTrack(
            id: _uuid.v4(),
            layerId: layerId,
            shapeId: shapeId,
            keyframes: [keyframe],
          ),
        ];
      }

      return scene.copyWith(
        timeline: scene.timeline.copyWith(tracks: newTracks),
      );
    }));
  }

  /// Removes the keyframe at [frame] from [shapeId]'s track (if any).
  /// Applies [updater] to the keyframe at [frame] on [shapeId]'s track.
  /// No-op if the track or keyframe doesn't exist.
  void updateKeyframeForShape(
    String sceneId,
    String layerId,
    String shapeId,
    int frame,
    VecKeyframe Function(VecKeyframe) updater,
  ) {
    _commit(_withScene(sceneId, (scene) {
      return scene.copyWith(
        timeline: scene.timeline.copyWith(
          tracks: [
            for (final t in scene.timeline.tracks)
              if (t.layerId == layerId && t.shapeId == shapeId)
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

  void removeKeyframeForShape(
    String sceneId,
    String layerId,
    String shapeId,
    int frame,
  ) {
    _commit(_withScene(sceneId, (scene) {
      return scene.copyWith(
        timeline: scene.timeline.copyWith(
          tracks: [
            for (final t in scene.timeline.tracks)
              if (t.layerId == layerId && t.shapeId == shapeId)
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

  /// Moves the keyframe at [fromFrame] to [toFrame] for [shapeId]'s track.
  /// If a keyframe already exists at [toFrame], it is replaced.
  void moveKeyframeForShape(
    String sceneId,
    String layerId,
    String shapeId,
    int fromFrame,
    int toFrame,
  ) {
    if (fromFrame == toFrame) return;
    _commit(_withScene(sceneId, (scene) {
      final clampedTo = toFrame.clamp(0, scene.timeline.duration - 1);
      final newTracks = scene.timeline.tracks.map((t) {
        if (t.layerId != layerId || t.shapeId != shapeId) return t;
        final kfToMove =
            t.keyframes.where((k) => k.frame == fromFrame).firstOrNull;
        if (kfToMove == null) return t;
        final others = t.keyframes
            .where((k) => k.frame != fromFrame && k.frame != clampedTo)
            .toList();
        final moved = [...others, kfToMove.copyWith(frame: clampedTo)]
          ..sort((a, b) => a.frame.compareTo(b.frame));
        return t.copyWith(keyframes: moved);
      }).toList();
      return scene.copyWith(
          timeline: scene.timeline.copyWith(tracks: newTracks));
    }));
  }

  /// Applies an [AnimationPreset] to [shapeId] starting at [atFrame].
  /// Each preset keyframe's [frameOffset] is added to [atFrame] to produce the
  /// absolute frame number. Existing keyframes at those frames are replaced.
  void applyAnimationPreset(
    String sceneId,
    String layerId,
    String shapeId,
    AnimationPreset preset,
    int atFrame,
  ) {
    final scene = state.scenes.where((s) => s.id == sceneId).firstOrNull;
    if (scene == null) return;

    final layer = scene.layers.where((l) => l.id == layerId).firstOrNull;
    if (layer == null) return;

    final baseShape = layer.shapes.where((s) => s.id == shapeId).firstOrNull;
    if (baseShape == null) return;

    final existingTrack = scene.timeline.tracks
        .where((t) => t.layerId == layerId && t.shapeId == shapeId)
        .firstOrNull;

    // Anchor presets to the shape state at apply time, so presets are relative
    // and do not snap objects toward origin.
    final anchoredShape = existingTrack == null
        ? baseShape
        : KeyframeInterpolator.applyAtFrame(
            baseShape,
            existingTrack.keyframes,
            atFrame,
          );
    final anchor = anchoredShape.transform;

    for (final pk in preset.keyframes) {
      final absoluteFrame = atFrame + pk.frameOffset;
      final presetKf = pk.keyframe;
      final presetT = presetKf.transform;

      // Resolve the preset transform to be relative to the current shape position
      VecTransform? resolvedT;
      if (presetT != null) {
        resolvedT = presetT.copyWith(
          x: anchor.x + presetT.x,
          y: anchor.y + presetT.y,
          width: anchor.width,
          height: anchor.height,
          rotation: anchor.rotation + presetT.rotation,
          scaleX: anchor.scaleX * presetT.scaleX,
          scaleY: anchor.scaleY * presetT.scaleY,
          skewX: anchor.skewX + presetT.skewX,
          skewY: anchor.skewY + presetT.skewY,
          pivot: anchor.pivot,
        );
      }

      // Build the final keyframe, preserving all preset properties but ensuring
      // tweenType is set to motion (not none, which is the default).
      final kf = presetKf.copyWith(
        frame: absoluteFrame,
        transform: resolvedT,
        tweenType: VecTweenType.motion,
      );
      addKeyframeForShape(sceneId, layerId, shapeId, kf);
    }
  }

  /// Sets the total frame count (duration) of the scene's timeline.
  void setTimelineDuration(String sceneId, int duration) {
    if (duration < 1) return;
    _commit(_withScene(
        sceneId, (s) => s.copyWith(timeline: s.timeline.copyWith(duration: duration))));
  }

  void setLoopType(String sceneId, VecLoopType loopType) {
    _commit(_withScene(
        sceneId, (s) => s.copyWith(timeline: s.timeline.copyWith(loopType: loopType))));
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

  // ===========================================================================
  // Motion paths (Phase 4.3)
  // ===========================================================================

  /// Adds (or replaces) the motion path for [motionPath.shapeId] in [sceneId].
  void addMotionPath(String sceneId, VecMotionPath motionPath) {
    _commit(_withScene(sceneId, (scene) {
      // Replace existing path for same shape, otherwise append.
      final existing = scene.motionPaths.any((p) => p.shapeId == motionPath.shapeId);
      return scene.copyWith(
        motionPaths: existing
            ? [
                for (final p in scene.motionPaths)
                  if (p.shapeId == motionPath.shapeId) motionPath else p,
              ]
            : [...scene.motionPaths, motionPath],
      );
    }));
  }

  void removeMotionPath(String sceneId, String motionPathId) {
    _commit(_withScene(sceneId, (scene) {
      return scene.copyWith(
        motionPaths:
            scene.motionPaths.where((p) => p.id != motionPathId).toList(),
      );
    }));
  }

  void updateMotionPath(
    String sceneId,
    String motionPathId,
    VecMotionPath Function(VecMotionPath) updater,
  ) {
    _commit(_withScene(sceneId, (scene) {
      return scene.copyWith(
        motionPaths: [
          for (final p in scene.motionPaths)
            if (p.id == motionPathId) updater(p) else p,
        ],
      );
    }));
  }

  /// Updates the nodes of a motion path without adding to undo history.
  /// Use during live drag; call [commitCurrentState] on drag end.
  void updateMotionPathNodesNoHistory(
    String sceneId,
    String motionPathId,
    List<VecPathNode> nodes,
  ) {
    final newDoc = _withScene(sceneId, (scene) {
      return scene.copyWith(
        motionPaths: [
          for (final p in scene.motionPaths)
            if (p.id == motionPathId) p.copyWith(nodes: nodes) else p,
        ],
      );
    });
    state = newDoc;
    _service.markDirty();
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
