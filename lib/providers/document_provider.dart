import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../data/models/vec_color.dart';
import '../data/models/vec_document.dart';
import '../data/models/vec_keyframe.dart';
import '../data/models/vec_layer.dart';
import '../data/models/vec_scene.dart';
import '../data/models/vec_shape.dart';
import '../data/models/vec_symbol.dart';
import '../data/models/vec_track.dart';
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
