import 'package:freezed_annotation/freezed_annotation.dart';

part 'vec_easing.freezed.dart';
part 'vec_easing.g.dart';

enum VecEasingPreset {
  linear,
  easeIn,
  easeOut,
  easeInOut,
  bounce,
  elastic,
  spring,
}

@Freezed(unionKey: 'type')
class VecEasing with _$VecEasing {
  const factory VecEasing.preset({
    required VecEasingPreset preset,
  }) = VecPresetEasing;

  const factory VecEasing.cubicBezier({
    required double x1,
    required double y1,
    required double x2,
    required double y2,
  }) = VecCubicBezierEasing;

  factory VecEasing.fromJson(Map<String, dynamic> json) =>
      _$VecEasingFromJson(json);
}
