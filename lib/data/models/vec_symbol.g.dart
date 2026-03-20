// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vec_symbol.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VecSymbolImpl _$$VecSymbolImplFromJson(Map<String, dynamic> json) =>
    _$VecSymbolImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      type:
          $enumDecodeNullable(_$VecSymbolTypeEnumMap, json['type']) ??
          VecSymbolType.graphic,
      registrationPoint: json['registrationPoint'] == null
          ? null
          : VecPoint.fromJson(
              json['registrationPoint'] as Map<String, dynamic>,
            ),
      layers: (json['layers'] as List<dynamic>)
          .map((e) => VecLayer.fromJson(e as Map<String, dynamic>))
          .toList(),
      timeline: VecTimeline.fromJson(json['timeline'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$VecSymbolImplToJson(_$VecSymbolImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$VecSymbolTypeEnumMap[instance.type]!,
      'registrationPoint': instance.registrationPoint,
      'layers': instance.layers,
      'timeline': instance.timeline,
    };

const _$VecSymbolTypeEnumMap = {
  VecSymbolType.graphic: 'graphic',
  VecSymbolType.movieClip: 'movieClip',
  VecSymbolType.button: 'button',
};
