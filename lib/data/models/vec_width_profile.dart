import 'package:freezed_annotation/freezed_annotation.dart';

part 'vec_width_profile.freezed.dart';
part 'vec_width_profile.g.dart';

@freezed
class VecWidthPoint with _$VecWidthPoint {
  const factory VecWidthPoint({
    required double position,
    required double leftWidth,
    required double rightWidth,
  }) = _VecWidthPoint;

  factory VecWidthPoint.fromJson(Map<String, dynamic> json) =>
      _$VecWidthPointFromJson(json);
}

@freezed
class VecWidthProfile with _$VecWidthProfile {
  const factory VecWidthProfile({
    String? name,
    required List<VecWidthPoint> points,
  }) = _VecWidthProfile;

  factory VecWidthProfile.fromJson(Map<String, dynamic> json) =>
      _$VecWidthProfileFromJson(json);
}
