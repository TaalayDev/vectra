import 'package:freezed_annotation/freezed_annotation.dart';

import 'vec_color.dart';

part 'vec_pattern.freezed.dart';
part 'vec_pattern.g.dart';

enum VecPatternType { dots, stripes, crosshatch, checkerboard, customTile }

@freezed
class VecPattern with _$VecPattern {
  const factory VecPattern({
    @Default(VecPatternType.dots) VecPatternType type,
    @Default(10.0) double scale,
    @Default(0.0) double rotation,
    VecColor? backgroundColor,
    @Default(2.0) double thickness,
    @Default(5.0) double spacing,
    String? tileAssetId,
  }) = _VecPattern;

  factory VecPattern.fromJson(Map<String, dynamic> json) => _$VecPatternFromJson(json);
}
