import 'package:freezed_annotation/freezed_annotation.dart';

import 'vec_color.dart';

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

@freezed
class VecFill with _$VecFill {
  const factory VecFill({
    required VecColor color,
    @Default(1.0) double opacity,
    @Default(VecBlendMode.normal) VecBlendMode blendMode,
  }) = _VecFill;

  factory VecFill.fromJson(Map<String, dynamic> json) =>
      _$VecFillFromJson(json);
}
