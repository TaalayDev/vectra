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
// Document state
// ---------------------------------------------------------------------------

@riverpod
class VecDocumentState extends _$VecDocumentState {
  @override
  VecDocument build() => VecDocument.blank();

  VecDocumentService get _service =>
      ref.read(vecDocumentServiceProvider);

  // -- File operations ------------------------------------------------------

  Future<void> openFile(String filePath) async {
    state = await _service.openFile(filePath);
  }

  Future<void> save() async {
    final now = DateTime.now();
    state = state.copyWith(
      meta: state.meta.copyWith(modifiedAt: now),
    );
    await _service.save(state);
  }

  Future<void> saveAs(String filePath) async {
    final now = DateTime.now();
    state = state.copyWith(
      meta: state.meta.copyWith(modifiedAt: now),
    );
    await _service.saveAs(state, filePath);
  }

  void newDocument({
    String name = 'Untitled',
    double stageWidth = 1920,
    double stageHeight = 1080,
    int fps = 24,
    VecColor backgroundColor = VecColor.white,
  }) {
    state = _service.createNew(
      name: name,
      stageWidth: stageWidth,
      stageHeight: stageHeight,
      fps: fps,
      backgroundColor: backgroundColor,
    );
  }

  // -- Meta -----------------------------------------------------------------

  void updateMeta(VecMeta meta) {
    state = state.copyWith(meta: meta);
    _service.markDirty();
  }

  // -- Scenes ---------------------------------------------------------------

  void addScene(VecScene scene) {
    state = state.copyWith(scenes: [...state.scenes, scene]);
    _service.markDirty();
  }

  void updateScene(String sceneId, VecScene Function(VecScene) updater) {
    state = state.copyWith(
      scenes: [
        for (final s in state.scenes)
          if (s.id == sceneId) updater(s) else s,
      ],
    );
    _service.markDirty();
  }

  void removeScene(String sceneId) {
    state = state.copyWith(
      scenes: state.scenes.where((s) => s.id != sceneId).toList(),
    );
    _service.markDirty();
  }

  // -- Layers (scoped to a scene) -------------------------------------------

  void addLayer(String sceneId, {String? name}) {
    final layerId = _uuid.v4();
    final trackId = _uuid.v4();
    updateScene(sceneId, (scene) {
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
    });
  }

  void updateLayer(
    String sceneId,
    String layerId,
    VecLayer Function(VecLayer) updater,
  ) {
    updateScene(sceneId, (scene) {
      return scene.copyWith(
        layers: [
          for (final l in scene.layers)
            if (l.id == layerId) updater(l) else l,
        ],
      );
    });
  }

  void removeLayer(String sceneId, String layerId) {
    updateScene(sceneId, (scene) {
      return scene.copyWith(
        layers: scene.layers.where((l) => l.id != layerId).toList(),
        timeline: scene.timeline.copyWith(
          tracks: scene.timeline.tracks
              .where((t) => t.layerId != layerId)
              .toList(),
        ),
      );
    });
  }

  // -- Shapes (scoped to a scene + layer) -----------------------------------

  void addShape(String sceneId, String layerId, VecShape shape) {
    updateLayer(sceneId, layerId, (layer) {
      return layer.copyWith(shapes: [...layer.shapes, shape]);
    });
  }

  void updateShape(
    String sceneId,
    String layerId,
    String shapeId,
    VecShape Function(VecShape) updater,
  ) {
    updateLayer(sceneId, layerId, (layer) {
      return layer.copyWith(
        shapes: [
          for (final s in layer.shapes)
            if (s.id == shapeId) updater(s) else s,
        ],
      );
    });
  }

  void removeShape(String sceneId, String layerId, String shapeId) {
    updateLayer(sceneId, layerId, (layer) {
      return layer.copyWith(
        shapes: layer.shapes.where((s) => s.id != shapeId).toList(),
      );
    });
  }

  // -- Symbols --------------------------------------------------------------

  void addSymbol(VecSymbol symbol) {
    state = state.copyWith(symbols: [...state.symbols, symbol]);
    _service.markDirty();
  }

  void updateSymbol(String symbolId, VecSymbol Function(VecSymbol) updater) {
    state = state.copyWith(
      symbols: [
        for (final s in state.symbols)
          if (s.id == symbolId) updater(s) else s,
      ],
    );
    _service.markDirty();
  }

  void removeSymbol(String symbolId) {
    state = state.copyWith(
      symbols: state.symbols.where((s) => s.id != symbolId).toList(),
    );
    _service.markDirty();
  }

  // -- Keyframes (scoped to a scene + track) --------------------------------

  void addKeyframe(String sceneId, String trackId, VecKeyframe keyframe) {
    updateScene(sceneId, (scene) {
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
    });
  }

  void updateKeyframe(
    String sceneId,
    String trackId,
    int frame,
    VecKeyframe Function(VecKeyframe) updater,
  ) {
    updateScene(sceneId, (scene) {
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
    });
  }

  void removeKeyframe(String sceneId, String trackId, int frame) {
    updateScene(sceneId, (scene) {
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
    });
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
