import 'package:freezed_annotation/freezed_annotation.dart';

import 'vec_color.dart';
import 'vec_fill.dart';
import 'vec_width_profile.dart';

part 'vec_stroke.freezed.dart';
part 'vec_stroke.g.dart';

enum VecStrokeCap { butt, round, square }

enum VecStrokeJoin { miter, round, bevel }

enum VecStrokeAlign { inside, center, outside }

@freezed
class VecStroke with _$VecStroke {
  const factory VecStroke({
    required VecColor color,
    @Default(1.0) double width,
    @Default(1.0) double opacity,
    @Default(VecBlendMode.normal) VecBlendMode blendMode,
    @Default(VecStrokeCap.butt) VecStrokeCap cap,
    @Default(VecStrokeJoin.miter) VecStrokeJoin join,
    @Default(VecStrokeAlign.center) VecStrokeAlign align,
    @Default([]) List<double> dashPattern,
    @Default(0) double dashOffset,
    VecWidthProfile? widthProfile,
  }) = _VecStroke;

  factory VecStroke.fromJson(Map<String, dynamic> json) =>
      _$VecStrokeFromJson(json);
}
