// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vec_keyframe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VecKeyframeImpl _$$VecKeyframeImplFromJson(Map<String, dynamic> json) =>
    _$VecKeyframeImpl(
      frame: (json['frame'] as num).toInt(),
      type:
          $enumDecodeNullable(_$VecKeyframeTypeEnumMap, json['type']) ??
          VecKeyframeType.keyframe,
      tweenType:
          $enumDecodeNullable(_$VecTweenTypeEnumMap, json['tweenType']) ??
          VecTweenType.none,
      transform: json['transform'] == null
          ? null
          : VecTransform.fromJson(json['transform'] as Map<String, dynamic>),
      fills: (json['fills'] as List<dynamic>?)
          ?.map((e) => VecFill.fromJson(e as Map<String, dynamic>))
          .toList(),
      strokes: (json['strokes'] as List<dynamic>?)
          ?.map((e) => VecStroke.fromJson(e as Map<String, dynamic>))
          .toList(),
      easing: json['easing'] == null
          ? null
          : VecEasing.fromJson(json['easing'] as Map<String, dynamic>),
      position: json['position'] == null
          ? null
          : VecPoint.fromJson(json['position'] as Map<String, dynamic>),
      scale: json['scale'] == null
          ? null
          : VecPoint.fromJson(json['scale'] as Map<String, dynamic>),
      rotation: (json['rotation'] as num?)?.toDouble(),
      opacity: (json['opacity'] as num?)?.toDouble(),
      fillColor: json['fillColor'] == null
          ? null
          : VecColor.fromJson(json['fillColor'] as Map<String, dynamic>),
      strokeColor: json['strokeColor'] == null
          ? null
          : VecColor.fromJson(json['strokeColor'] as Map<String, dynamic>),
      pathNodes: (json['pathNodes'] as List<dynamic>?)
          ?.map((e) => VecPathNode.fromJson(e as Map<String, dynamic>))
          .toList(),
      positionEasing: json['positionEasing'] == null
          ? null
          : VecEasing.fromJson(json['positionEasing'] as Map<String, dynamic>),
      scaleEasing: json['scaleEasing'] == null
          ? null
          : VecEasing.fromJson(json['scaleEasing'] as Map<String, dynamic>),
      rotationEasing: json['rotationEasing'] == null
          ? null
          : VecEasing.fromJson(json['rotationEasing'] as Map<String, dynamic>),
      opacityEasing: json['opacityEasing'] == null
          ? null
          : VecEasing.fromJson(json['opacityEasing'] as Map<String, dynamic>),
      fillColorEasing: json['fillColorEasing'] == null
          ? null
          : VecEasing.fromJson(json['fillColorEasing'] as Map<String, dynamic>),
      strokeColorEasing: json['strokeColorEasing'] == null
          ? null
          : VecEasing.fromJson(
              json['strokeColorEasing'] as Map<String, dynamic>,
            ),
      pathEasing: json['pathEasing'] == null
          ? null
          : VecEasing.fromJson(json['pathEasing'] as Map<String, dynamic>),
      shapeHints:
          (json['shapeHints'] as List<dynamic>?)
              ?.map((e) => VecShapeHint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$VecKeyframeImplToJson(_$VecKeyframeImpl instance) =>
    <String, dynamic>{
      'frame': instance.frame,
      'type': _$VecKeyframeTypeEnumMap[instance.type]!,
      'tweenType': _$VecTweenTypeEnumMap[instance.tweenType]!,
      'transform': instance.transform,
      'fills': instance.fills,
      'strokes': instance.strokes,
      'easing': instance.easing,
      'position': instance.position,
      'scale': instance.scale,
      'rotation': instance.rotation,
      'opacity': instance.opacity,
      'fillColor': instance.fillColor,
      'strokeColor': instance.strokeColor,
      'pathNodes': instance.pathNodes,
      'positionEasing': instance.positionEasing,
      'scaleEasing': instance.scaleEasing,
      'rotationEasing': instance.rotationEasing,
      'opacityEasing': instance.opacityEasing,
      'fillColorEasing': instance.fillColorEasing,
      'strokeColorEasing': instance.strokeColorEasing,
      'pathEasing': instance.pathEasing,
      'shapeHints': instance.shapeHints,
    };

const _$VecKeyframeTypeEnumMap = {
  VecKeyframeType.keyframe: 'keyframe',
  VecKeyframeType.blank: 'blank',
};

const _$VecTweenTypeEnumMap = {
  VecTweenType.none: 'none',
  VecTweenType.motion: 'motion',
  VecTweenType.shape: 'shape',
  VecTweenType.classic: 'classic',
};
