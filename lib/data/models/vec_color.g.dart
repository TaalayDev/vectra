// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vec_color.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VecColorImpl _$$VecColorImplFromJson(Map<String, dynamic> json) =>
    _$VecColorImpl(
      a: (json['a'] as num?)?.toInt() ?? 255,
      r: (json['r'] as num).toInt(),
      g: (json['g'] as num).toInt(),
      b: (json['b'] as num).toInt(),
    );

Map<String, dynamic> _$$VecColorImplToJson(_$VecColorImpl instance) =>
    <String, dynamic>{
      'a': instance.a,
      'r': instance.r,
      'g': instance.g,
      'b': instance.b,
    };
