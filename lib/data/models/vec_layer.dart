import 'package:freezed_annotation/freezed_annotation.dart';

import 'vec_color.dart';
import 'vec_shape.dart';

part 'vec_layer.freezed.dart';
part 'vec_layer.g.dart';

enum VecLayerType { normal, guide }

@freezed
class VecLayer with _$VecLayer {
  const factory VecLayer({
    required String id,
    required String name,
    @Default(VecLayerType.normal) VecLayerType type,
    @Default(true) bool visible,
    @Default(false) bool locked,
    VecColor? colorDot,
    @Default(0) int order,
    String? parentId,
    @Default([]) List<VecShape> shapes,
  }) = _VecLayer;

  factory VecLayer.fromJson(Map<String, dynamic> json) =>
      _$VecLayerFromJson(json);
}
