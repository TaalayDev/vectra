// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vec_timeline.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VecTimelineImpl _$$VecTimelineImplFromJson(Map<String, dynamic> json) =>
    _$VecTimelineImpl(
      duration: (json['duration'] as num).toInt(),
      inPoint: (json['inPoint'] as num?)?.toInt() ?? 0,
      outPoint: (json['outPoint'] as num?)?.toInt(),
      loopType:
          $enumDecodeNullable(_$VecLoopTypeEnumMap, json['loopType']) ??
          VecLoopType.loop,
      tracks:
          (json['tracks'] as List<dynamic>?)
              ?.map((e) => VecTrack.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      frameLabels:
          (json['frameLabels'] as List<dynamic>?)
              ?.map((e) => VecFrameLabel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      motionPaths:
          (json['motionPaths'] as List<dynamic>?)
              ?.map((e) => VecMotionPath.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$VecTimelineImplToJson(_$VecTimelineImpl instance) =>
    <String, dynamic>{
      'duration': instance.duration,
      'inPoint': instance.inPoint,
      'outPoint': instance.outPoint,
      'loopType': _$VecLoopTypeEnumMap[instance.loopType]!,
      'tracks': instance.tracks,
      'frameLabels': instance.frameLabels,
      'motionPaths': instance.motionPaths,
    };

const _$VecLoopTypeEnumMap = {
  VecLoopType.loop: 'loop',
  VecLoopType.playOnce: 'playOnce',
  VecLoopType.pingPong: 'pingPong',
};
