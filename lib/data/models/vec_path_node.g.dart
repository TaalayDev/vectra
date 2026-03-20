// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vec_path_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VecPathNodeImpl _$$VecPathNodeImplFromJson(Map<String, dynamic> json) =>
    _$VecPathNodeImpl(
      position: VecPoint.fromJson(json['position'] as Map<String, dynamic>),
      handleIn: json['handleIn'] == null
          ? null
          : VecPoint.fromJson(json['handleIn'] as Map<String, dynamic>),
      handleOut: json['handleOut'] == null
          ? null
          : VecPoint.fromJson(json['handleOut'] as Map<String, dynamic>),
      type:
          $enumDecodeNullable(_$VecNodeTypeEnumMap, json['type']) ??
          VecNodeType.corner,
    );

Map<String, dynamic> _$$VecPathNodeImplToJson(_$VecPathNodeImpl instance) =>
    <String, dynamic>{
      'position': instance.position,
      'handleIn': instance.handleIn,
      'handleOut': instance.handleOut,
      'type': _$VecNodeTypeEnumMap[instance.type]!,
    };

const _$VecNodeTypeEnumMap = {
  VecNodeType.smooth: 'smooth',
  VecNodeType.corner: 'corner',
  VecNodeType.symmetric: 'symmetric',
};
