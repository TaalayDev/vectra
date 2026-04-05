// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vec_pattern.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VecPatternImpl _$$VecPatternImplFromJson(Map<String, dynamic> json) =>
    _$VecPatternImpl(
      type:
          $enumDecodeNullable(_$VecPatternTypeEnumMap, json['type']) ??
          VecPatternType.dots,
      scale: (json['scale'] as num?)?.toDouble() ?? 10.0,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      backgroundColor: json['backgroundColor'] == null
          ? null
          : VecColor.fromJson(json['backgroundColor'] as Map<String, dynamic>),
      thickness: (json['thickness'] as num?)?.toDouble() ?? 2.0,
      spacing: (json['spacing'] as num?)?.toDouble() ?? 5.0,
      tileAssetId: json['tileAssetId'] as String?,
    );

Map<String, dynamic> _$$VecPatternImplToJson(_$VecPatternImpl instance) =>
    <String, dynamic>{
      'type': _$VecPatternTypeEnumMap[instance.type]!,
      'scale': instance.scale,
      'rotation': instance.rotation,
      'backgroundColor': instance.backgroundColor,
      'thickness': instance.thickness,
      'spacing': instance.spacing,
      'tileAssetId': instance.tileAssetId,
    };

const _$VecPatternTypeEnumMap = {
  VecPatternType.dots: 'dots',
  VecPatternType.stripes: 'stripes',
  VecPatternType.crosshatch: 'crosshatch',
  VecPatternType.checkerboard: 'checkerboard',
  VecPatternType.customTile: 'customTile',
};
