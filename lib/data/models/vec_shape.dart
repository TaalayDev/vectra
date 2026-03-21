import 'package:freezed_annotation/freezed_annotation.dart';

import 'vec_color.dart';
import 'vec_fill.dart';
import 'vec_path_node.dart';
import 'vec_stroke.dart';
import 'vec_timeline.dart';
import 'vec_transform.dart';

part 'vec_shape.freezed.dart';
part 'vec_shape.g.dart';

enum VecCornerStyle { round, inverted, chamfer }

/// Which boolean / structural operation a [VecCompoundShape] performs.
enum PathfinderOp {
  unite,
  minusFront,
  intersect,
  exclude,
  divide,
  trim,
  outline,
}

enum VecTextAlign { left, center, right, justify }

/// Common properties shared by all shape variants.
@freezed
class VecShapeData with _$VecShapeData {
  const factory VecShapeData({
    required String id,
    required VecTransform transform,
    @Default([]) List<VecFill> fills,
    @Default([]) List<VecStroke> strokes,
    @Default(1.0) double opacity,
    @Default(VecBlendMode.normal) VecBlendMode blendMode,
    String? clipMaskId,
    String? name,
  }) = _VecShapeData;

  factory VecShapeData.fromJson(Map<String, dynamic> json) =>
      _$VecShapeDataFromJson(json);
}

/// The core shape model — a sealed union over all 7 shape types.
@Freezed(unionKey: 'type')
class VecShape with _$VecShape {
  const VecShape._();

  // Convenience getters so callers can write `shape.id` instead of `shape.data.id`.
  String get id => data.id;
  VecTransform get transform => data.transform;
  List<VecFill> get fills => data.fills;
  List<VecStroke> get strokes => data.strokes;
  double get opacity => data.opacity;
  VecBlendMode get blendMode => data.blendMode;
  String? get clipMaskId => data.clipMaskId;
  String? get name => data.name;

  const factory VecShape.path({
    required VecShapeData data,
    required List<VecPathNode> nodes,
    @Default(false) bool isClosed,
  }) = VecPathShape;

  const factory VecShape.rectangle({
    required VecShapeData data,
    @Default([0, 0, 0, 0]) List<double> cornerRadii,
    @Default(VecCornerStyle.round) VecCornerStyle cornerStyle,
  }) = VecRectangleShape;

  const factory VecShape.ellipse({
    required VecShapeData data,
    @Default(0) double startAngle,
    @Default(360) double endAngle,
    @Default(0) double innerRadius,
  }) = VecEllipseShape;

  const factory VecShape.polygon({
    required VecShapeData data,
    @Default(6) int sideCount,
    double? starDepth,
  }) = VecPolygonShape;

  const factory VecShape.text({
    required VecShapeData data,
    required String content,
    @Default('Inter') String fontFamily,
    @Default(16) double fontSize,
    @Default(400) int fontWeight,
    @Default(0) double tracking,
    @Default(1.2) double leading,
    @Default(VecTextAlign.left) VecTextAlign alignment,
    String? textOnPathRef,
  }) = VecTextShape;

  const factory VecShape.group({
    required VecShapeData data,
    required List<VecShape> children,
  }) = VecGroupShape;

  const factory VecShape.symbolInstance({
    required VecShapeData data,
    required String symbolId,
    VecColor? colorTint,
    @Default(0) double tintAmount,
    @Default(1.0) double alphaOverride,
    @Default(VecLoopType.loop) VecLoopType loopType,
    @Default(0) int firstFrame,
  }) = VecSymbolInstanceShape;

  /// A live pathfinder compound — remembers its inputs and the operation.
  /// Rendering recomputes the boolean result from [inputs] each frame.
  /// Call [expandCompound] in document_provider to flatten to a [VecPathShape].
  const factory VecShape.compound({
    required VecShapeData data,
    required PathfinderOp op,
    required List<VecShape> inputs,
  }) = VecCompoundShape;

  factory VecShape.fromJson(Map<String, dynamic> json) =>
      _$VecShapeFromJson(json);
}

