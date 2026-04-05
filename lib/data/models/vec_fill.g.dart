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
      pattern: json['pattern'] == null
          ? null
          : VecPattern.fromJson(json['pattern'] as Map<String, dynamic>),
      imageAssetId: json['imageAssetId'] as String?,
      imageFit:
          $enumDecodeNullable(_$VecFillImageFitEnumMap, json['imageFit']) ??
          VecFillImageFit.cover,
    );

Map<String, dynamic> _$$VecFillImplToJson(_$VecFillImpl instance) =>
    <String, dynamic>{
      'color': instance.color,
      'opacity': instance.opacity,
      'blendMode': _$VecBlendModeEnumMap[instance.blendMode]!,
      'gradient': instance.gradient,
      'pattern': instance.pattern,
      'imageAssetId': instance.imageAssetId,
      'imageFit': _$VecFillImageFitEnumMap[instance.imageFit]!,
    };

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

const _$VecFillImageFitEnumMap = {
  VecFillImageFit.contain: 'contain',
  VecFillImageFit.cover: 'cover',
  VecFillImageFit.fill: 'fill',
  VecFillImageFit.none: 'none',
};
