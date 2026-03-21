import 'package:freezed_annotation/freezed_annotation.dart';

import 'vec_layer.dart';
import 'vec_motion_path.dart';
import 'vec_timeline.dart';

part 'vec_scene.freezed.dart';
part 'vec_scene.g.dart';

@freezed
class VecScene with _$VecScene {
  const factory VecScene({
    required String id,
    required String name,
    required List<VecLayer> layers,
    required VecTimeline timeline,
    @Default([]) List<VecMotionPath> motionPaths,
  }) = _VecScene;

  factory VecScene.fromJson(Map<String, dynamic> json) =>
      _$VecSceneFromJson(json);
}
