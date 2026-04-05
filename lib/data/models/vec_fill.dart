import 'package:freezed_annotation/freezed_annotation.dart';

import 'vec_color.dart';
import 'vec_gradient.dart';
import 'vec_pattern.dart';

part 'vec_fill.freezed.dart';
part 'vec_fill.g.dart';

enum VecBlendMode {
  normal,
  multiply,
  screen,
  overlay,
  darken,
  lighten,
  colorDodge,
  colorBurn,
  hardLight,
  softLight,
  difference,
  exclusion,
  hue,
  saturation,
  color,
  luminosity,
}

enum VecFillImageFit { contain, cover, fill, none }

@freezed
class VecFill with _$VecFill {
  const factory VecFill({
    required VecColor color,
    @Default(1.0) double opacity,
    @Default(VecBlendMode.normal) VecBlendMode blendMode,
    VecGradient? gradient,
    VecPattern? pattern,
    String? imageAssetId,
    @Default(VecFillImageFit.cover) VecFillImageFit imageFit,
  }) = _VecFill;

  factory VecFill.fromJson(Map<String, dynamic> json) => _$VecFillFromJson(json);
}
