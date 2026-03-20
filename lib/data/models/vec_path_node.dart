import 'package:freezed_annotation/freezed_annotation.dart';

import 'vec_point.dart';

part 'vec_path_node.freezed.dart';
part 'vec_path_node.g.dart';

enum VecNodeType { smooth, corner, symmetric }

@freezed
class VecPathNode with _$VecPathNode {
  const factory VecPathNode({
    required VecPoint position,
    VecPoint? handleIn,
    VecPoint? handleOut,
    @Default(VecNodeType.corner) VecNodeType type,
  }) = _VecPathNode;

  factory VecPathNode.fromJson(Map<String, dynamic> json) =>
      _$VecPathNodeFromJson(json);
}
