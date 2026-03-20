import 'package:freezed_annotation/freezed_annotation.dart';

import 'vec_point.dart';

part 'vec_shape_hint.freezed.dart';
part 'vec_shape_hint.g.dart';

@freezed
class VecShapeHint with _$VecShapeHint {
  const factory VecShapeHint({
    required String label,
    required VecPoint startPoint,
    required VecPoint endPoint,
  }) = _VecShapeHint;

  factory VecShapeHint.fromJson(Map<String, dynamic> json) =>
      _$VecShapeHintFromJson(json);
}
