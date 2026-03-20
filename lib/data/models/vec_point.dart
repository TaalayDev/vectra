import 'package:freezed_annotation/freezed_annotation.dart';

part 'vec_point.freezed.dart';
part 'vec_point.g.dart';

@freezed
class VecPoint with _$VecPoint {
  const factory VecPoint({
    required double x,
    required double y,
  }) = _VecPoint;

  factory VecPoint.zero() => const VecPoint(x: 0, y: 0);

  factory VecPoint.fromJson(Map<String, dynamic> json) =>
      _$VecPointFromJson(json);
}
