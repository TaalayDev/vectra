// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vec_shape_hint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VecShapeHintImpl _$$VecShapeHintImplFromJson(Map<String, dynamic> json) =>
    _$VecShapeHintImpl(
      label: json['label'] as String,
      startPoint: VecPoint.fromJson(json['startPoint'] as Map<String, dynamic>),
      endPoint: VecPoint.fromJson(json['endPoint'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$VecShapeHintImplToJson(_$VecShapeHintImpl instance) =>
    <String, dynamic>{
      'label': instance.label,
      'startPoint': instance.startPoint,
      'endPoint': instance.endPoint,
    };
