// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vec_scene.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VecSceneImpl _$$VecSceneImplFromJson(Map<String, dynamic> json) =>
    _$VecSceneImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      layers: (json['layers'] as List<dynamic>)
          .map((e) => VecLayer.fromJson(e as Map<String, dynamic>))
          .toList(),
      timeline: VecTimeline.fromJson(json['timeline'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$VecSceneImplToJson(_$VecSceneImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'layers': instance.layers,
      'timeline': instance.timeline,
    };
