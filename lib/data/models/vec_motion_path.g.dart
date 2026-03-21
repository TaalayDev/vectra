// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vec_motion_path.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VecMotionPathImpl _$$VecMotionPathImplFromJson(Map<String, dynamic> json) =>
    _$VecMotionPathImpl(
      id: json['id'] as String,
      shapeId: json['shapeId'] as String,
      nodes:
          (json['nodes'] as List<dynamic>?)
              ?.map((e) => VecPathNode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isClosed: json['isClosed'] as bool? ?? false,
      orientToPath: json['orientToPath'] as bool? ?? false,
      easeAlongPath: json['easeAlongPath'] as bool? ?? false,
    );

Map<String, dynamic> _$$VecMotionPathImplToJson(_$VecMotionPathImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shapeId': instance.shapeId,
      'nodes': instance.nodes,
      'isClosed': instance.isClosed,
      'orientToPath': instance.orientToPath,
      'easeAlongPath': instance.easeAlongPath,
    };
