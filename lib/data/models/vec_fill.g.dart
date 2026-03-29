// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vec_fill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VecFillImpl _$$VecFillImplFromJson(Map<String, dynamic> json) =>
    _$VecFillImpl(
      color: VecColor.fromJson(json['color'] as Map<String, dynamic>),
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
      blendMode:
          $enumDecodeNullable(_$VecBlendModeEnumMap, json['blendMode']) ??
          VecBlendMode.normal,
      gradient: json['gradient'] == null
          ? null
          : VecGradient.fromJson(json['gradient'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$VecFillImplToJson(_$VecFillImpl instance) {
  final val = <String, dynamic>{
    'color': instance.color,
    'opacity': instance.opacity,
    'blendMode': _$VecBlendModeEnumMap[instance.blendMode]!,
  };
  if (instance.gradient != null) {
    val['gradient'] = instance.gradient!.toJson();
  }
  return val;
}

const _$VecBlendModeEnumMap = {
  VecBlendMode.normal: 'normal',
  VecBlendMode.multiply: 'multiply',
  VecBlendMode.screen: 'screen',
  VecBlendMode.overlay: 'overlay',
  VecBlendMode.darken: 'darken',
  VecBlendMode.lighten: 'lighten',
  VecBlendMode.colorDodge: 'colorDodge',
  VecBlendMode.colorBurn: 'colorBurn',
  VecBlendMode.hardLight: 'hardLight',
  VecBlendMode.softLight: 'softLight',
  VecBlendMode.difference: 'difference',
  VecBlendMode.exclusion: 'exclusion',
  VecBlendMode.hue: 'hue',
  VecBlendMode.saturation: 'saturation',
  VecBlendMode.color: 'color',
  VecBlendMode.luminosity: 'luminosity',
};
