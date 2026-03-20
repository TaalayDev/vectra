// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vec_width_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VecWidthPointImpl _$$VecWidthPointImplFromJson(Map<String, dynamic> json) =>
    _$VecWidthPointImpl(
      position: (json['position'] as num).toDouble(),
      leftWidth: (json['leftWidth'] as num).toDouble(),
      rightWidth: (json['rightWidth'] as num).toDouble(),
    );

Map<String, dynamic> _$$VecWidthPointImplToJson(_$VecWidthPointImpl instance) =>
    <String, dynamic>{
      'position': instance.position,
      'leftWidth': instance.leftWidth,
      'rightWidth': instance.rightWidth,
    };

_$VecWidthProfileImpl _$$VecWidthProfileImplFromJson(
  Map<String, dynamic> json,
) => _$VecWidthProfileImpl(
  name: json['name'] as String?,
  points: (json['points'] as List<dynamic>)
      .map((e) => VecWidthPoint.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$VecWidthProfileImplToJson(
  _$VecWidthProfileImpl instance,
) => <String, dynamic>{'name': instance.name, 'points': instance.points};
