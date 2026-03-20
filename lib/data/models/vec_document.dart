import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import 'vec_asset.dart';
import 'vec_color.dart';
import 'vec_layer.dart';
import 'vec_scene.dart';
import 'vec_symbol.dart';
import 'vec_timeline.dart';
import 'vec_track.dart';

part 'vec_document.freezed.dart';
part 'vec_document.g.dart';

@freezed
class VecMeta with _$VecMeta {
  const factory VecMeta({
    required String name,
    @Default(1) int version,
    @Default(24) int fps,
    @Default(1920) double stageWidth,
    @Default(1080) double stageHeight,
    @Default(VecColor.white) VecColor backgroundColor,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) = _VecMeta;

  factory VecMeta.fromJson(Map<String, dynamic> json) =>
      _$VecMetaFromJson(json);
}

@freezed
class VecDocument with _$VecDocument {
  const factory VecDocument({
    required VecMeta meta,
    @Default([]) List<VecSymbol> symbols,
    @Default([]) List<VecScene> scenes,
    @Default([]) List<VecAsset> assets,
  }) = _VecDocument;

  factory VecDocument.blank({
    String name = 'Untitled',
    double stageWidth = 1920,
    double stageHeight = 1080,
    int fps = 24,
    VecColor backgroundColor = VecColor.white,
  }) {
    const uuid = Uuid();
    final sceneId = uuid.v4();
    final layerId = uuid.v4();
    final trackId = uuid.v4();
    final now = DateTime.now();

    return VecDocument(
      meta: VecMeta(
        name: name,
        stageWidth: stageWidth,
        stageHeight: stageHeight,
        fps: fps,
        backgroundColor: backgroundColor,
        createdAt: now,
        modifiedAt: now,
      ),
      scenes: [
        VecScene(
          id: sceneId,
          name: 'Scene 1',
          layers: [
            VecLayer(id: layerId, name: 'Layer 1'),
          ],
          timeline: VecTimeline(
            duration: 72, // 3 seconds at 24fps
            tracks: [
              VecTrack(id: trackId, layerId: layerId),
            ],
          ),
        ),
      ],
    );
  }

  factory VecDocument.fromJson(Map<String, dynamic> json) =>
      _$VecDocumentFromJson(json);
}
