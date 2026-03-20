// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vec_easing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VecPresetEasingImpl _$$VecPresetEasingImplFromJson(
  Map<String, dynamic> json,
) => _$VecPresetEasingImpl(
  preset: $enumDecode(_$VecEasingPresetEnumMap, json['preset']),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$VecPresetEasingImplToJson(
  _$VecPresetEasingImpl instance,
) => <String, dynamic>{
  'preset': _$VecEasingPresetEnumMap[instance.preset]!,
  'type': instance.$type,
};

const _$VecEasingPresetEnumMap = {
  VecEasingPreset.linear: 'linear',
  VecEasingPreset.easeIn: 'easeIn',
  VecEasingPreset.easeOut: 'easeOut',
  VecEasingPreset.easeInOut: 'easeInOut',
  VecEasingPreset.bounce: 'bounce',
  VecEasingPreset.elastic: 'elastic',
  VecEasingPreset.spring: 'spring',
};

_$VecCubicBezierEasingImpl _$$VecCubicBezierEasingImplFromJson(
  Map<String, dynamic> json,
) => _$VecCubicBezierEasingImpl(
  x1: (json['x1'] as num).toDouble(),
  y1: (json['y1'] as num).toDouble(),
  x2: (json['x2'] as num).toDouble(),
  y2: (json['y2'] as num).toDouble(),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$VecCubicBezierEasingImplToJson(
  _$VecCubicBezierEasingImpl instance,
) => <String, dynamic>{
  'x1': instance.x1,
  'y1': instance.y1,
  'x2': instance.x2,
  'y2': instance.y2,
  'type': instance.$type,
};
