// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vec_transform.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VecTransformImpl _$$VecTransformImplFromJson(Map<String, dynamic> json) =>
    _$VecTransformImpl(
      x: (json['x'] as num?)?.toDouble() ?? 0,
      y: (json['y'] as num?)?.toDouble() ?? 0,
      width: (json['width'] as num?)?.toDouble() ?? 0,
      height: (json['height'] as num?)?.toDouble() ?? 0,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
      scaleX: (json['scaleX'] as num?)?.toDouble() ?? 1,
      scaleY: (json['scaleY'] as num?)?.toDouble() ?? 1,
      skewX: (json['skewX'] as num?)?.toDouble() ?? 0,
      skewY: (json['skewY'] as num?)?.toDouble() ?? 0,
      pivot: json['pivot'] == null
          ? null
          : VecPoint.fromJson(json['pivot'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$VecTransformImplToJson(_$VecTransformImpl instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'width': instance.width,
      'height': instance.height,
      'rotation': instance.rotation,
      'scaleX': instance.scaleX,
      'scaleY': instance.scaleY,
      'skewX': instance.skewX,
      'skewY': instance.skewY,
      'pivot': instance.pivot,
    };
