import 'package:freezed_annotation/freezed_annotation.dart';

part 'vec_motion_path.freezed.dart';
part 'vec_motion_path.g.dart';

@freezed
class VecMotionPath with _$VecMotionPath {
  const factory VecMotionPath({
    required String guideLayerId,
    required String attachedLayerId,
    @Default(false) bool orientToPath,
    @Default(false) bool easeAlongPath,
  }) = _VecMotionPath;

  factory VecMotionPath.fromJson(Map<String, dynamic> json) =>
      _$VecMotionPathFromJson(json);
}
