// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vec_track.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VecTrackImpl _$$VecTrackImplFromJson(Map<String, dynamic> json) =>
    _$VecTrackImpl(
      id: json['id'] as String,
      layerId: json['layerId'] as String,
      keyframes:
          (json['keyframes'] as List<dynamic>?)
              ?.map((e) => VecKeyframe.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$VecTrackImplToJson(_$VecTrackImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'layerId': instance.layerId,
      'keyframes': instance.keyframes,
    };
