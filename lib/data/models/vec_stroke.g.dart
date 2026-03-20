// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vec_stroke.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VecStrokeImpl _$$VecStrokeImplFromJson(Map<String, dynamic> json) =>
    _$VecStrokeImpl(
      color: VecColor.fromJson(json['color'] as Map<String, dynamic>),
      width: (json['width'] as num?)?.toDouble() ?? 1.0,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
      blendMode:
          $enumDecodeNullable(_$VecBlendModeEnumMap, json['blendMode']) ??
          VecBlendMode.normal,
      cap:
          $enumDecodeNullable(_$VecStrokeCapEnumMap, json['cap']) ??
          VecStrokeCap.butt,
      join:
          $enumDecodeNullable(_$VecStrokeJoinEnumMap, json['join']) ??
          VecStrokeJoin.miter,
      align:
          $enumDecodeNullable(_$VecStrokeAlignEnumMap, json['align']) ??
          VecStrokeAlign.center,
      dashPattern:
          (json['dashPattern'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [],
      dashOffset: (json['dashOffset'] as num?)?.toDouble() ?? 0,
      widthProfile: json['widthProfile'] == null
          ? null
          : VecWidthProfile.fromJson(
              json['widthProfile'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$$VecStrokeImplToJson(_$VecStrokeImpl instance) =>
    <String, dynamic>{
      'color': instance.color,
      'width': instance.width,
      'opacity': instance.opacity,
      'blendMode': _$VecBlendModeEnumMap[instance.blendMode]!,
      'cap': _$VecStrokeCapEnumMap[instance.cap]!,
      'join': _$VecStrokeJoinEnumMap[instance.join]!,
      'align': _$VecStrokeAlignEnumMap[instance.align]!,
      'dashPattern': instance.dashPattern,
      'dashOffset': instance.dashOffset,
      'widthProfile': instance.widthProfile,
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

const _$VecStrokeCapEnumMap = {
  VecStrokeCap.butt: 'butt',
  VecStrokeCap.round: 'round',
  VecStrokeCap.square: 'square',
};

const _$VecStrokeJoinEnumMap = {
  VecStrokeJoin.miter: 'miter',
  VecStrokeJoin.round: 'round',
  VecStrokeJoin.bevel: 'bevel',
};

const _$VecStrokeAlignEnumMap = {
  VecStrokeAlign.inside: 'inside',
  VecStrokeAlign.center: 'center',
  VecStrokeAlign.outside: 'outside',
};
