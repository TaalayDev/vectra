// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vec_layer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VecLayerImpl _$$VecLayerImplFromJson(Map<String, dynamic> json) =>
    _$VecLayerImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      type:
          $enumDecodeNullable(_$VecLayerTypeEnumMap, json['type']) ??
          VecLayerType.normal,
      visible: json['visible'] as bool? ?? true,
      locked: json['locked'] as bool? ?? false,
      colorDot: json['colorDot'] == null
          ? null
          : VecColor.fromJson(json['colorDot'] as Map<String, dynamic>),
      order: (json['order'] as num?)?.toInt() ?? 0,
      parentId: json['parentId'] as String?,
      shapes:
          (json['shapes'] as List<dynamic>?)
              ?.map((e) => VecShape.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isReference: json['isReference'] as bool? ?? false,
      referenceOpacity: (json['referenceOpacity'] as num?)?.toDouble() ?? 0.5,
    );

Map<String, dynamic> _$$VecLayerImplToJson(_$VecLayerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$VecLayerTypeEnumMap[instance.type]!,
      'visible': instance.visible,
      'locked': instance.locked,
      'colorDot': instance.colorDot,
      'order': instance.order,
      'parentId': instance.parentId,
      'shapes': instance.shapes,
      'isReference': instance.isReference,
      'referenceOpacity': instance.referenceOpacity,
    };

const _$VecLayerTypeEnumMap = {
  VecLayerType.normal: 'normal',
  VecLayerType.guide: 'guide',
  VecLayerType.raster: 'raster',
};
