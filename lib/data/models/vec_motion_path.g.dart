// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vec_motion_path.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VecMotionPathImpl _$$VecMotionPathImplFromJson(Map<String, dynamic> json) =>
    _$VecMotionPathImpl(
      guideLayerId: json['guideLayerId'] as String,
      attachedLayerId: json['attachedLayerId'] as String,
      orientToPath: json['orientToPath'] as bool? ?? false,
      easeAlongPath: json['easeAlongPath'] as bool? ?? false,
    );

Map<String, dynamic> _$$VecMotionPathImplToJson(_$VecMotionPathImpl instance) =>
    <String, dynamic>{
      'guideLayerId': instance.guideLayerId,
      'attachedLayerId': instance.attachedLayerId,
      'orientToPath': instance.orientToPath,
      'easeAlongPath': instance.easeAlongPath,
    };
