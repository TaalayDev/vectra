import 'package:freezed_annotation/freezed_annotation.dart';

import 'vec_path_node.dart';

part 'vec_motion_path.freezed.dart';
part 'vec_motion_path.g.dart';

@freezed
class VecMotionPath with _$VecMotionPath {
  const factory VecMotionPath({
    required String id,
    required String shapeId,
    @Default([]) List<VecPathNode> nodes,
    @Default(false) bool isClosed,
    @Default(false) bool orientToPath,
    @Default(false) bool easeAlongPath,
  }) = _VecMotionPath;

  factory VecMotionPath.fromJson(Map<String, dynamic> json) =>
      _$VecMotionPathFromJson(json);
}
