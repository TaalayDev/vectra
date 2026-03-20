import 'package:freezed_annotation/freezed_annotation.dart';

import 'vec_point.dart';

part 'vec_transform.freezed.dart';
part 'vec_transform.g.dart';

@freezed
class VecTransform with _$VecTransform {
  const factory VecTransform({
    @Default(0) double x,
    @Default(0) double y,
    @Default(0) double width,
    @Default(0) double height,
    @Default(0) double rotation,
    @Default(1) double scaleX,
    @Default(1) double scaleY,
    @Default(0) double skewX,
    @Default(0) double skewY,
    VecPoint? pivot,
  }) = _VecTransform;

  factory VecTransform.fromJson(Map<String, dynamic> json) =>
      _$VecTransformFromJson(json);
}
